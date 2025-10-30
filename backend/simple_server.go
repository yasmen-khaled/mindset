package main

import (
	"bytes"
	"database/sql"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"math/rand"
	"net/http"
	"regexp"
	"strings"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	_ "github.com/go-sql-driver/mysql"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

type LoginRequest struct {
	PhoneNumber string `json:"phone_number" binding:"required"`
	Password    string `json:"password" binding:"required"`
}

type RegisterRequest struct {
	Username    string `json:"username" binding:"required"`
	PhoneNumber string `json:"phone_number" binding:"required"`
	Password    string `json:"password" binding:"required,min=6"`
	Gender      string `json:"gender,omitempty"`
}

type SendSMSRequest struct {
	PhoneNumber string `json:"phone_number" binding:"required"`
}

type VerifySMSRequest struct {
	PhoneNumber      string `json:"phone_number" binding:"required"`
	VerificationCode string `json:"verification_code" binding:"required"`
	NewPassword      string `json:"new_password" binding:"required,min=6"`
}

type ResetPasswordRequest struct {
	PhoneNumber string `json:"phone_number" binding:"required"`
	NewPassword string `json:"new_password" binding:"required,min=6"`
}

var jwtSecret = []byte("your-secret-key")
var db *sql.DB

// GitHub API configuration
const GITHUB_TOKEN = "" // Replace with your GitHub personal access token
const GITHUB_API_BASE = "https://api.github.com"

// In-memory storage for when database is not available
type User struct {
	ID           int       `json:"id"`
	Username     string    `json:"username"`
	PhoneNumber  string    `json:"phone_number"`
	PasswordHash string    `json:"-"`
	Gender       string    `json:"gender"`
	CreatedAt    time.Time `json:"created_at"`
}

type SMSCode struct {
	PhoneNumber string    `json:"phone_number"`
	Code        string    `json:"code"`
	ExpiresAt   time.Time `json:"expires_at"`
	Used        bool      `json:"used"`
}

var (
	inMemoryUsers    = make(map[string]*User)    // phone_number -> User
	inMemorySMSCodes = make(map[string]*SMSCode) // phone_number -> SMSCode
	userIDCounter    = 1
	userRepoURL      = make(map[string]string) // phone_number -> repo URL
)

// Database configuration - UPDATE THESE WITH YOUR MySQL CREDENTIALS
const (
	DB_USER     = "root"       // Your MySQL username
	DB_PASSWORD = ""           // Your MySQL password (often empty for localhost)
	DB_HOST     = "localhost"  // Usually localhost
	DB_PORT     = "3306"       // Usually 3306
	DB_NAME     = "mindset_db" // The database we created
)

func initDatabase() error {
	// MySQL connection string
	dsn := DB_USER + ":" + DB_PASSWORD + "@tcp(" + DB_HOST + ":" + DB_PORT + ")/" + DB_NAME + "?parseTime=true"

	var err error
	db, err = sql.Open("mysql", dsn)
	if err != nil {
		log.Printf("⚠️  Database connection failed, using in-memory storage: %v", err)
		db = nil // Set to nil for proper fallback
		return err
	}

	// Test the connection
	if err = db.Ping(); err != nil {
		log.Printf("⚠️  Database connection failed, using in-memory storage: %v", err)
		db = nil // Set to nil for proper fallback
		return err
	}

	log.Printf("✅ Connected to MySQL database successfully!")

	// Create SMS verification codes table if it doesn't exist
	createSMSTable := `
	CREATE TABLE IF NOT EXISTS sms_verification_codes (
		id INT AUTO_INCREMENT PRIMARY KEY,
		phone_number VARCHAR(20) NOT NULL,
		verification_code VARCHAR(10) NOT NULL,
		code_type ENUM('password_reset', 'phone_verification') DEFAULT 'password_reset',
		expires_at TIMESTAMP NOT NULL,
		used_at TIMESTAMP NULL,
		is_used BOOLEAN DEFAULT FALSE,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		
		INDEX idx_phone_code (phone_number, verification_code),
		INDEX idx_expires_at (expires_at),
		INDEX idx_code_type (code_type)
	)`

	if _, err := db.Exec(createSMSTable); err != nil {
		log.Printf("⚠️  Failed to create SMS table: %v", err)
	} else {
		log.Printf("✅ SMS verification codes table ready")
	}

	// Update test user passwords with proper bcrypt hash for 'password123'
	// Generate a fresh hash for password123
	correctHash, err := bcrypt.GenerateFromPassword([]byte("password123"), bcrypt.DefaultCost)
	if err != nil {
		log.Printf("⚠️  Failed to generate hash: %v", err)
		return nil
	}

	updateTestUsers := fmt.Sprintf(`
	UPDATE users SET password_hash = '%s' 
	WHERE username IN ('john_doe', 'sarah_chen', 'alex_kumar', 'maria_garcia', 'ahmed_libya', 'fatima_libya', 'demo_user')
	`, string(correctHash))

	if _, err := db.Exec(updateTestUsers); err != nil {
		log.Printf("⚠️  Failed to update test user passwords: %v", err)
	} else {
		log.Printf("✅ Test user passwords updated")
	}

	return nil
}

func initInMemoryStorage() {
	// Add test users to in-memory storage
	testUsers := []struct {
		username, phone, password, gender string
	}{
		{"john_doe", "+12345678901", "password123", "male"},
		{"sarah_chen", "+12345678902", "password123", "female"},
		{"demo_user", "+12345678903", "password123", "male"},
		{"test_user", "+12345678999", "password123", "male"},
	}

	for _, user := range testUsers {
		hashedPassword, _ := bcrypt.GenerateFromPassword([]byte(user.password), bcrypt.DefaultCost)
		inMemoryUsers[user.phone] = &User{
			ID:           userIDCounter,
			Username:     user.username,
			PhoneNumber:  user.phone,
			PasswordHash: string(hashedPassword),
			Gender:       user.gender,
			CreatedAt:    time.Now(),
		}
		userIDCounter++
	}
	log.Printf("✅ In-memory storage initialized with %d test users", len(inMemoryUsers))
}

func generateToken(phoneNumber string) (string, error) {
	claims := jwt.MapClaims{
		"phone_number": phoneNumber,
		"exp":          time.Now().Add(time.Hour * 24).Unix(),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(jwtSecret)
}

// Generate 6-digit SMS verification code
func generateSMSCode() string {
	return fmt.Sprintf("%06d", rand.Intn(1000000))
}

// Validate phone number format (enhanced international support)
func isValidPhoneNumber(phone string) bool {
	// Enhanced phone validation for international numbers
	// Supports various country codes including Libya (+218)
	// Format: +[1-9][0-9]{0,3}[0-9]{7,14} (country code 1-4 digits + 7-14 digit number)
	match, _ := regexp.MatchString(`^\+[1-9]\d{0,3}\d{7,14}$`, phone)
	return match && len(phone) >= 10 && len(phone) <= 18
}

// Format phone number for different countries
func formatPhoneNumber(phone string) string {
	// Remove any non-digit characters except +
	cleaned := regexp.MustCompile(`[^\d+]`).ReplaceAllString(phone, "")

	// Handle different input formats
	if strings.HasPrefix(cleaned, "00") {
		// Convert 00218 format to +218
		cleaned = "+" + cleaned[2:]
	} else if !strings.HasPrefix(cleaned, "+") && len(cleaned) >= 7 {
		// If no country code, assume it needs one
		// For demo, we'll require explicit country code
		return cleaned // Return as-is, let validation catch it
	}

	return cleaned
}

// Get country info from phone number
func getCountryFromPhone(phone string) string {
	countryMap := map[string]string{
		"+1":   "US/Canada",
		"+44":  "UK",
		"+218": "Libya",
		"+20":  "Egypt",
		"+966": "Saudi Arabia",
		"+971": "UAE",
		"+33":  "France",
		"+49":  "Germany",
		"+86":  "China",
		"+91":  "India",
		"+81":  "Japan",
		"+82":  "South Korea",
		"+212": "Morocco",
		"+213": "Algeria",
		"+216": "Tunisia",
	}

	for code, country := range countryMap {
		if strings.HasPrefix(phone, code) {
			return country
		}
	}
	return "Unknown"
}

// Send SMS function (placeholder - integrate with Twilio/AWS SNS)
func sendSMS(phoneNumber, message string) error {
	// TODO: Integrate with SMS service (Twilio, AWS SNS, etc.)
	log.Printf("📱 SMS to %s: %s", phoneNumber, message)

	// For demo purposes, we'll just log the SMS
	// In production, implement actual SMS sending:
	/*
		// Example Twilio integration:
		client := twilio.NewRestClient(accountSid, authToken)
		params := &api.CreateMessageParams{}
		params.SetTo(phoneNumber)
		params.SetFrom(twilioPhoneNumber)
		params.SetBody(message)
		_, err := client.Api.CreateMessage(params)
		return err
	*/

	return nil
}

func main() {
	// Try to connect to database
	if err := initDatabase(); err != nil {
		log.Printf("⚠️  Database connection failed, using in-memory storage")
		db = nil // Ensure db is nil for proper fallback
		initInMemoryStorage()
	}

	r := gin.Default()

	// Configure CORS for Flutter app
	config := cors.DefaultConfig()
	config.AllowOrigins = []string{"*"}
	config.AllowMethods = []string{"GET", "POST", "PUT", "DELETE"}
	config.AllowHeaders = []string{"Origin", "Content-Type", "Authorization"}
	r.Use(cors.New(config))

	// Routes for Flutter app
	webstudent := r.Group("/webstudent")
	{
		webstudent.POST("/login", handleLogin)
		webstudent.POST("/register", handleRegister)
		webstudent.POST("/send_sms_reset", handleSendSMSReset)     // Send SMS for password reset
		webstudent.POST("/verify_sms_reset", handleVerifySMSReset) // Verify SMS and reset password
		webstudent.POST("/reset_password", handleResetPassword)    // Direct password reset without SMS
		webstudent.POST("/get_profile", handleGetProfile)
		webstudent.POST("/upload_file", handleFileUpload)
		webstudent.POST("/set_repo_url", handleSetRepoURL)
		webstudent.POST("/submit_code", handleSubmitCode)
	}

	log.Printf("🚀 Server starting on port 8005...")
	if db != nil {
		log.Printf("📊 Database: MySQL connected (%s)", DB_NAME)
	} else {
		log.Printf("📊 Database: Using in-memory storage")
	}
	log.Printf("📱 SMS-enabled endpoints:")
	log.Printf("  POST http://localhost:8005/webstudent/login")
	log.Printf("  POST http://localhost:8005/webstudent/register")
	log.Printf("  POST http://localhost:8005/webstudent/send_sms_reset")
	log.Printf("  POST http://localhost:8005/webstudent/verify_sms_reset")
	log.Printf("  POST http://localhost:8005/webstudent/reset_password")
	log.Printf("  POST http://localhost:8005/webstudent/get_profile")
	log.Printf("  POST http://localhost:8005/webstudent/upload_file")
	log.Printf("  POST http://localhost:8005/webstudent/set_repo_url")
	log.Printf("  POST http://localhost:8005/webstudent/submit_code")

	if err := r.Run(":8005"); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}

func handleLogin(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Format and validate phone number
	formattedPhone := formatPhoneNumber(req.PhoneNumber)
	if !isValidPhoneNumber(formattedPhone) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid phone number format. Use international format like +218912345678"})
		return
	}

	country := getCountryFromPhone(formattedPhone)
	log.Printf("🌍 Login attempt from %s (%s)", formattedPhone, country)

	if db != nil {
		log.Printf("📊 Using MySQL database for login")
		// Database login
		var passwordHash string
		var username string

		query := "SELECT username, password_hash FROM users WHERE phone_number = ? AND is_active = TRUE"
		err := db.QueryRow(query, formattedPhone).Scan(&username, &passwordHash)

		if err == sql.ErrNoRows {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
			return
		} else if err != nil {
			log.Printf("Database error: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
			return
		}

		if err := bcrypt.CompareHashAndPassword([]byte(passwordHash), []byte(req.Password)); err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
			return
		}

		// Update last login
		_, err = db.Exec("UPDATE users SET last_login = NOW() WHERE phone_number = ?", formattedPhone)
		if err != nil {
			log.Printf("Failed to update last login: %v", err)
		}

		token, err := generateToken(formattedPhone)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
			return
		}

		log.Printf("✅ Login successful for: %s (%s)", formattedPhone, country)

		c.JSON(http.StatusOK, gin.H{
			"message":  "Login successful",
			"token":    token,
			"username": username,
			"country":  country,
		})
	} else {
		log.Printf("📊 Using in-memory storage for login")
		// In-memory storage login
		user, exists := inMemoryUsers[formattedPhone]
		if !exists {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
			return
		}

		if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)); err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
			return
		}

		token, err := generateToken(formattedPhone)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
			return
		}

		log.Printf("✅ Login successful (in-memory) for: %s (%s)", formattedPhone, country)

		c.JSON(http.StatusOK, gin.H{
			"message":  "Login successful",
			"token":    token,
			"username": user.Username,
			"country":  country,
		})
	}
}

func handleRegister(c *gin.Context) {
	var req RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Format and validate phone number
	formattedPhone := formatPhoneNumber(req.PhoneNumber)
	if !isValidPhoneNumber(formattedPhone) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid phone number format. Use international format like +218912345678"})
		return
	}

	country := getCountryFromPhone(formattedPhone)
	log.Printf("🌍 Registration attempt from %s (%s)", formattedPhone, country)

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to process password"})
		return
	}

	if db != nil {
		log.Printf("📊 Using MySQL database for registration")
		// Check if phone number already exists
		var count int
		err := db.QueryRow("SELECT COUNT(*) FROM users WHERE phone_number = ?", formattedPhone).Scan(&count)
		if err != nil {
			log.Printf("Database error: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
			return
		}

		if count > 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Phone number already registered"})
			return
		}

		// Insert new user into database
		query := "INSERT INTO users (username, phone_number, password_hash, gender) VALUES (?, ?, ?, ?)"
		result, err := db.Exec(query, req.Username, formattedPhone, string(hashedPassword), req.Gender)
		if err != nil {
			log.Printf("Failed to create user: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user"})
			return
		}

		userID, _ := result.LastInsertId()
		log.Printf("✅ New user registered: %s (%s) - ID: %d", formattedPhone, country, userID)

		// Generate JWT token for automatic login
		token, err := generateToken(formattedPhone)
		if err != nil {
			log.Printf("Failed to generate token: %v", err)
			// Return without token - user can still login manually
			c.JSON(http.StatusOK, gin.H{
				"message":  "Registration successful",
				"user_id":  userID,
				"username": req.Username,
				"country":  country,
			})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"message":  "Registration successful",
			"user_id":  userID,
			"username": req.Username,
			"token":    token,
			"country":  country,
		})
	} else {
		log.Printf("📊 Using in-memory storage for registration")
		// In-memory storage registration
		if _, exists := inMemoryUsers[formattedPhone]; exists {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Phone number already registered"})
			return
		}

		// Create new user in memory
		inMemoryUsers[formattedPhone] = &User{
			ID:           userIDCounter,
			Username:     req.Username,
			PhoneNumber:  formattedPhone,
			PasswordHash: string(hashedPassword),
			Gender:       req.Gender,
			CreatedAt:    time.Now(),
		}
		userID := userIDCounter
		userIDCounter++

		log.Printf("✅ New user registered (in-memory): %s (%s) - ID: %d", formattedPhone, country, userID)

		// Generate JWT token for automatic login
		token, err := generateToken(formattedPhone)
		if err != nil {
			log.Printf("Failed to generate token: %v", err)
			c.JSON(http.StatusOK, gin.H{
				"message":  "Registration successful",
				"user_id":  userID,
				"username": req.Username,
				"country":  country,
			})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"message":  "Registration successful",
			"user_id":  userID,
			"username": req.Username,
			"token":    token,
			"country":  country,
		})
	}
}

func handleSendSMSReset(c *gin.Context) {
	var req SendSMSRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Format and validate phone number
	formattedPhone := formatPhoneNumber(req.PhoneNumber)
	if !isValidPhoneNumber(formattedPhone) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid phone number format. Use international format like +218912345678"})
		return
	}

	country := getCountryFromPhone(formattedPhone)
	log.Printf("🌍 SMS reset request from %s (%s)", formattedPhone, country)

	if db != nil {
		// Check if phone number exists
		var count int
		err := db.QueryRow("SELECT COUNT(*) FROM users WHERE phone_number = ? AND is_active = TRUE", formattedPhone).Scan(&count)
		if err != nil {
			log.Printf("Database error: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
			return
		}

		if count == 0 {
			c.JSON(http.StatusNotFound, gin.H{"error": "Phone number not found"})
			return
		}

		// Generate verification code
		verificationCode := generateSMSCode()
		expiresAt := time.Now().Add(10 * time.Minute) // Code expires in 10 minutes

		// Store verification code in database
		query := `INSERT INTO sms_verification_codes 
				  (phone_number, verification_code, code_type, expires_at) 
				  VALUES (?, ?, 'password_reset', ?)`

		_, err = db.Exec(query, formattedPhone, verificationCode, expiresAt)
		if err != nil {
			log.Printf("Failed to store verification code: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate verification code"})
			return
		}

		// Send SMS with country-specific message
		var message string
		if country == "Libya" {
			message = fmt.Sprintf("كود إعادة تعيين كلمة المرور لتطبيق Mindset: %s. صالح لمدة 10 دقائق.", verificationCode)
		} else {
			message = fmt.Sprintf("Your Mindset password reset code is: %s. Valid for 10 minutes.", verificationCode)
		}

		err = sendSMS(formattedPhone, message)
		if err != nil {
			log.Printf("Failed to send SMS: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to send SMS"})
			return
		}

		log.Printf("📱 SMS reset code sent to: %s (%s)", formattedPhone, country)

		c.JSON(http.StatusOK, gin.H{
			"message":            "Verification code sent via SMS",
			"expires_in_minutes": 10,
			"country":            country,
		})
	} else {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database not connected"})
	}
}

func handleVerifySMSReset(c *gin.Context) {
	var req VerifySMSRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Format phone number
	formattedPhone := formatPhoneNumber(req.PhoneNumber)
	country := getCountryFromPhone(formattedPhone)
	log.Printf("🌍 SMS verification from %s (%s)", formattedPhone, country)

	if db != nil {
		// Verify SMS code
		var codeID int
		var attempts int
		query := `SELECT id, attempts FROM sms_verification_codes 
				  WHERE phone_number = ? AND verification_code = ? 
				  AND code_type = 'password_reset' AND is_used = FALSE 
				  AND expires_at > NOW()`

		err := db.QueryRow(query, formattedPhone, req.VerificationCode).Scan(&codeID, &attempts)
		if err == sql.ErrNoRows {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid or expired verification code"})
			return
		} else if err != nil {
			log.Printf("Database error: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
			return
		}

		// Mark code as used
		_, err = db.Exec("UPDATE sms_verification_codes SET is_used = TRUE WHERE id = ?", codeID)
		if err != nil {
			log.Printf("Failed to mark code as used: %v", err)
		}

		// Hash new password
		newPasswordHash, err := bcrypt.GenerateFromPassword([]byte(req.NewPassword), bcrypt.DefaultCost)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to process password"})
			return
		}

		// Update password in database
		_, err = db.Exec("UPDATE users SET password_hash = ?, updated_at = NOW() WHERE phone_number = ?",
			string(newPasswordHash), formattedPhone)
		if err != nil {
			log.Printf("Failed to update password: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update password"})
			return
		}

		log.Printf("✅ Password reset successful for: %s (%s)", formattedPhone, country)

		c.JSON(http.StatusOK, gin.H{
			"message": "Password reset successful",
			"country": country,
		})
	} else {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database not connected"})
	}
}

func handleResetPassword(c *gin.Context) {
	var req ResetPasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Format and validate phone number
	formattedPhone := formatPhoneNumber(req.PhoneNumber)
	if !isValidPhoneNumber(formattedPhone) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid phone number format. Use international format like +218912345678"})
		return
	}

	country := getCountryFromPhone(formattedPhone)
	log.Printf("🌍 Password reset request from %s (%s)", formattedPhone, country)

	if db != nil {
		// Check if phone number exists
		var count int
		err := db.QueryRow("SELECT COUNT(*) FROM users WHERE phone_number = ? AND is_active = TRUE", formattedPhone).Scan(&count)
		if err != nil {
			log.Printf("Database error: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
			return
		}

		if count == 0 {
			c.JSON(http.StatusNotFound, gin.H{"error": "Phone number not found"})
			return
		}

		// Hash new password
		newPasswordHash, err := bcrypt.GenerateFromPassword([]byte(req.NewPassword), bcrypt.DefaultCost)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to process password"})
			return
		}

		// Update password in database
		_, err = db.Exec("UPDATE users SET password_hash = ?, updated_at = NOW() WHERE phone_number = ?",
			string(newPasswordHash), formattedPhone)
		if err != nil {
			log.Printf("Failed to update password: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update password"})
			return
		}

		log.Printf("✅ Password reset successful for: %s (%s)", formattedPhone, country)

		c.JSON(http.StatusOK, gin.H{
			"message": "Password reset successful",
			"country": country,
		})
	} else {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database not connected"})
	}
}

func handleGetProfile(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"id":           1,
		"phone_number": "1234567890",
		"created_at":   time.Now(),
	})
}

func handleFileUpload(c *gin.Context) {
	file, err := c.FormFile("file")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No file uploaded"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":  "File upload endpoint ready",
		"filename": file.Filename,
	})
}

type SetRepoURLRequest struct {
	RepoURL string `json:"repo_url" binding:"required"`
}

func handleSetRepoURL(c *gin.Context) {
	var req SetRepoURLRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// In a real app, extract phone from JWT. For demo, accept optional header X-Phone
	phone := c.GetHeader("X-Phone")
	if phone == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing X-Phone header"})
		return
	}

	userRepoURL[phone] = req.RepoURL
	log.Printf("📦 Repo URL set for %s: %s", phone, req.RepoURL)
	c.JSON(http.StatusOK, gin.H{"message": "Repository URL saved"})
}

type SubmitCodeRequest struct {
	Code     string `json:"code" binding:"required"`
	Filename string `json:"filename"`
	Language string `json:"language"`
	TaskID   string `json:"task_id"`
}

// GitHub API structures
type GitHubFileRequest struct {
	Message string `json:"message"`
	Content string `json:"content"`
	Branch  string `json:"branch,omitempty"`
}

type GitHubFileResponse struct {
	Content struct {
		Sha string `json:"sha"`
	} `json:"content"`
}

// Create file in GitHub repository
func createGitHubFile(repoURL, filename, content string, token string) error {
	if token == "" {
		log.Printf("  GitHub token not provided, skipping file creation")
		return fmt.Errorf("GitHub token not provided")
	}

	// Parse repo URL to get owner/repo
	// Expected format: https://github.com/owner/repo or owner/repo
	parts := strings.Split(strings.TrimPrefix(repoURL, "https://github.com/"), "/")
	if len(parts) < 2 {
		return fmt.Errorf("invalid repo URL format")
	}
	owner, repo := parts[0], parts[1]

	// Encode content to base64
	encodedContent := base64.StdEncoding.EncodeToString([]byte(content))

	// Create file request
	fileReq := GitHubFileRequest{
		Message: fmt.Sprintf("Add %s from Mindset quiz", filename),
		Content: encodedContent,
		Branch:  "main", // Default branch
	}

	jsonData, err := json.Marshal(fileReq)
	if err != nil {
		return err
	}

	// Make API request
	url := fmt.Sprintf("%s/repos/%s/%s/contents/%s", GITHUB_API_BASE, owner, repo, filename)
	req, err := http.NewRequest("PUT", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return err
	}

	req.Header.Set("Authorization", "token "+token)
	req.Header.Set("Accept", "application/vnd.github.v3+json")
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: 30 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusCreated && resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("GitHub API error %d: %s", resp.StatusCode, string(body))
	}

	log.Printf(" Created file %s in %s/%s", filename, owner, repo)
	return nil
}

func handleSubmitCode(c *gin.Context) {
	var req SubmitCodeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	phone := c.GetHeader("X-Phone")
	if phone == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing X-Phone header"})
		return
	}

	// Simulated checks
	checks := map[string]bool{}
	score := 0

	// Basic cleanliness checks
	if len(req.Code) >= 10 {
		checks["length_ok"] = true
		score += 10
	} else {
		checks["length_ok"] = false
	}

	// Language hint checks
	if req.Language == "dart" {
		hasMain := strings.Contains(req.Code, "void main(") || strings.Contains(req.Code, "main(")
		checks["has_main"] = hasMain
		if hasMain {
			score += 20
		}
	}

	// Simple forbidden words check
	forbidden := []string{"eval(", "rm -rf", "DROP TABLE"}
	safe := true
	for _, w := range forbidden {
		if strings.Contains(strings.ToLower(req.Code), strings.ToLower(w)) {
			safe = false
			break
		}
	}
	checks["safe_content"] = safe
	if safe {
		score += 20
	}

	// Check repo configuration (allow override via header)
	headerRepo := c.GetHeader("X-Repo-Url")
	if headerRepo != "" {
		userRepoURL[phone] = headerRepo
	}
	repo := userRepoURL[phone]
	checks["repo_configured"] = repo != ""
	if repo != "" {
		score += 10
	}

	// Check filename requirement
	if req.Filename != "" {
		checks["filename_provided"] = true
		score += 10
	} else {
		checks["filename_provided"] = false
	}

	// Try to create file in GitHub repo
	var githubError error
	if repo != "" && req.Filename != "" && req.Code != "" {
		// Allow token override via header
		token := c.GetHeader("X-Github-Token")
		if token == "" {
			token = GITHUB_TOKEN
		}
		githubError = createGitHubFile(repo, req.Filename, req.Code, token)
		if githubError == nil {
			checks["github_file_created"] = true
			score += 30
		} else {
			checks["github_file_created"] = false
			log.Printf(" Failed to create GitHub file: %v", githubError)
		}
	} else {
		checks["github_file_created"] = false
	}

	// Normalize score to 0..100
	if score > 100 {
		score = 100
	}

	message := "Code evaluated"
	if githubError != nil {
		message = fmt.Sprintf("Code evaluated, but GitHub upload failed: %v", githubError)
	} else if checks["github_file_created"] {
		message = "Code evaluated and uploaded to GitHub successfully!"
	}

	c.JSON(http.StatusOK, gin.H{
		"message": message,
		"score":   score,
		"checks":  checks,
	})
}
