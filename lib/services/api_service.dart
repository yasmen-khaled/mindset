import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Try different URLs for different environments
  // For phone testing, use your computer's IP on the local network
  static const String baseUrl = 'http://192.168.0.112:8005/webstudent';
  static const String localhostUrl = 'http://localhost:8005/webstudent'; // For testing
  static const String emulatorUrl = 'http://10.0.2.2:8005/webstudent'; // Android emulator default
  
  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
  };
  
  // Login API call - NOW USES PHONE NUMBER
  static Future<Map<String, dynamic>> login(String phoneNumber, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'phone_number': phoneNumber,
          'password': password,
        }),
      ).timeout(Duration(seconds: 30));

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'],
          'token': responseData['token'],
          'username': responseData['username'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['error'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Register API call - NOW USES PHONE NUMBER
  static Future<Map<String, dynamic>> register(String username, String phoneNumber, String password, String gender) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'username': username,
          'phone_number': phoneNumber,  // Changed from email to phone_number
          'password': password,
          'gender': gender,
        }),
      ).timeout(Duration(seconds: 30));

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'],
          'username': responseData['username'],
          'token': responseData['token'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['error'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Send SMS for Password Reset
  static Future<Map<String, dynamic>> sendSMSReset(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send_sms_reset'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'phone_number': phoneNumber,
        }),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'],
          'expires_in_minutes': responseData['expires_in_minutes'] ?? 10,
        };
      } else {
        return {
          'success': false,
          'message': responseData['error'] ?? 'Failed to send SMS',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Verify SMS Code and Reset Password
  static Future<Map<String, dynamic>> verifySMSReset(
      String phoneNumber, String verificationCode, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify_sms_reset'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'phone_number': phoneNumber,
          'verification_code': verificationCode,
          'new_password': newPassword,
        }),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['error'] ?? 'Password reset failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Legacy method for compatibility (now uses phone)
  static Future<Map<String, dynamic>> resetPassword(String phoneNumber, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset_password'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'phone_number': phoneNumber,
          'new_password': newPassword,
        }),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['error'] ?? 'Password reset failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Update password API call (for authenticated users)
  static Future<Map<String, dynamic>> updatePassword(String oldPassword, String newPassword, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update_password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['error'] ?? 'Password update failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get profile API call
  static Future<Map<String, dynamic>> getProfile(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/get_profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['error'] ?? 'Failed to get profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Set GitHub repo URL for the authenticated user
  static Future<Map<String, dynamic>> setRepoUrl({
    required String token,
    required String repoUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/set_repo_url'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'repo_url': repoUrl,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      }
      return {'success': false, 'message': data['error'] ?? 'Failed to set repo URL'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Submit code for a task; backend will validate and optionally check repo file
  static Future<Map<String, dynamic>> submitCode({
    required String token,
    required String code,
    String? filename,
    String language = 'dart',
    String? taskId,
    String? xPhone,
    String? repoUrl,
    String? githubToken,
  }) async {
    try {
      print('🚀 Submitting code to: $baseUrl/submit_code');
      print('📱 Phone: $xPhone');
      print('🔗 Repo URL: $repoUrl');
      print('🔑 GitHub Token: ${githubToken != null ? 'Present' : 'Missing'}');
      print('📄 Filename: $filename');
      print('🏷️ Task ID: $taskId');
      
      final uri = Uri.parse('$baseUrl/submit_code');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        if (xPhone != null && xPhone.isNotEmpty) 'X-Phone': xPhone,
        if (repoUrl != null && repoUrl.isNotEmpty) 'X-Repo-Url': repoUrl,
        if (githubToken != null && githubToken.isNotEmpty) 'X-Github-Token': githubToken,
      };
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode({
          'code': code,
          'filename': filename,
          'language': language,
          'task_id': taskId,
        }),
      ).timeout(Duration(seconds: 30));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'score': data['score'],
          'checks': data['checks'],
        };
      }
      return {'success': false, 'message': data['error'] ?? 'Code submission failed'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Push code to GitHub repository
  static Future<Map<String, dynamic>> pushCodeToGithub({
    required String code,
    required String filename,
    required String repoUrl,
    required String githubToken,
    required String taskId,
    String? phoneNumber,
  }) async {
    try {
      // Extract owner and repo from URL
      // Expected format: https://github.com/username/repo or git@github.com:username/repo.git
      final repoRegex = RegExp(r'github\.com[:/](.+?)/(.+?)(?:\.git)?$');
      final match = repoRegex.firstMatch(repoUrl);
      
      if (match == null) {
        return {
          'success': false,
          'message': 'Invalid GitHub repository URL',
        };
      }

      final owner = match.group(1);
      final repo = match.group(2);

      // Create branch name with task ID and phone (for uniqueness)
      final branchName = 'solution-${phoneNumber ?? "user"}-$taskId-${DateTime.now().millisecondsSinceEpoch}';
      
      // GitHub API endpoint for creating/updating file
      final url = Uri.parse(
        'https://api.github.com/repos/$owner/$repo/contents/$filename',
      );

      // Get file SHA if it exists (for updates)
      final getResponse = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $githubToken',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      String? fileSha;
      if (getResponse.statusCode == 200) {
        final data = jsonDecode(getResponse.body);
        fileSha = data['sha'];
      }

      // Encode code to base64
      final encodedCode = base64Encode(utf8.encode(code));

      // Push code to GitHub
      final pushResponse = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $githubToken',
          'Accept': 'application/vnd.github.v3+json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': 'Solution for task: $taskId',
          'content': encodedCode,
          'branch': branchName,
          if (fileSha != null) 'sha': fileSha,
        }),
      );

      if (pushResponse.statusCode == 201 || pushResponse.statusCode == 200) {
        final responseData = jsonDecode(pushResponse.body);
        return {
          'success': true,
          'message': 'Code successfully pushed to GitHub',
          'filename': filename,
          'branch': branchName,
          'commit': responseData['commit']['sha'],
          'html_url': responseData['html_url'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to push code to GitHub (${pushResponse.statusCode}): ${pushResponse.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'GitHub push error: $e',
      };
    }
  }

  // Utility function to validate phone number format - ENHANCED for international
  static bool isValidPhoneNumber(String phone) {
    // Enhanced phone validation for international numbers including Libya (+218)
    // Format: +[1-9][0-9]{0,3}[0-9]{7,14} (country code 1-4 digits + 7-14 digit number)
    final phoneRegex = RegExp(r'^\+[1-9]\d{0,3}\d{7,14}$');
    return phoneRegex.hasMatch(phone) && phone.length >= 10 && phone.length <= 18;
  }

  // Utility function to format phone number - ENHANCED for Libya
  static String formatPhoneNumber(String phone) {
    // Remove any spaces, dashes, parentheses, or other non-digit characters except +
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Handle Libya's 00218 format and convert to +218
    if (cleaned.startsWith('00218')) {
      cleaned = '+218${cleaned.substring(5)}';
    }
    // Handle other 00XX formats and convert to +XX
    else if (cleaned.startsWith('00') && cleaned.length > 2) {
      cleaned = '+${cleaned.substring(2)}';
    }
    // Add + if not present and doesn't start with +
    else if (!cleaned.startsWith('+') && cleaned.length >= 7) {
      // For demo, we require explicit country code
      // In production, you could default to a country based on user location
      return cleaned; // Return as-is, let validation handle it
    }
    
    return cleaned;
  }

  // Get country info from phone number
  static String getCountryFromPhone(String phone) {
    final countryMap = {
      '+1': 'US/Canada',
      '+44': 'UK',
      '+218': 'Libya 🇱🇾',
      '+20': 'Egypt',
      '+966': 'Saudi Arabia',
      '+971': 'UAE',
      '+33': 'France',
      '+49': 'Germany',
      '+86': 'China',
      '+91': 'India',
      '+81': 'Japan',
      '+82': 'South Korea',
      '+212': 'Morocco',
      '+213': 'Algeria',
      '+216': 'Tunisia',
    };
    
    for (final entry in countryMap.entries) {
      if (phone.startsWith(entry.key)) {
        return entry.value;
      }
    }
    return 'Unknown';
  }

  // Format phone number for display
  static String formatPhoneForDisplay(String phone) {
    if (phone.startsWith('+218')) {
      // Libya format: +218 XX XXX XXXX
      if (phone.length >= 12) {
        return '${phone.substring(0, 4)} ${phone.substring(4, 6)} ${phone.substring(6, 9)} ${phone.substring(9)}';
      }
    } else if (phone.startsWith('+1')) {
      // US/Canada format: +1 (XXX) XXX-XXXX
      if (phone.length >= 12) {
        return '${phone.substring(0, 2)} (${phone.substring(2, 5)}) ${phone.substring(5, 8)}-${phone.substring(8)}';
      }
    }
    // Default format: +XX XXX XXX XXXX
    return phone;
  }

  // Judge0 API for code execution
  static const String judge0Url = 'https://judge0-ce.p.rapidapi.com/submissions';
  
  // Language ID mapping for Judge0
  static const Map<String, int> languageIds = {
    'dart': 90,
    'python': 71,
    'javascript': 63,
    'java': 62,
    'cpp': 54,
  };

  // Execute code using Judge0 API
  static Future<Map<String, dynamic>> executeCode({
    required String code,
    required String language,
    String? input,
  }) async {
    try {
      final languageId = languageIds[language.toLowerCase()];
      if (languageId == null) {
        return {
          'success': false,
          'message': 'Language not supported',
        };
      }

      // Submit code for execution
      final submitResponse = await http.post(
        Uri.parse('$judge0Url?base64_encoded=false&wait=false'),
        headers: {
          'Content-Type': 'application/json',
          'X-RapidAPI-Key': '05866d76afmsh1b71ef2bfce7463p13606bjsnec72c273dcb0',
          'X-RapidAPI-Host': 'judge0-ce.p.rapidapi.com',
        },
        body: jsonEncode({
          'language_id': languageId,
          'source_code': code,
          if (input != null) 'stdin': input,
        }),
      );

      if (submitResponse.statusCode != 201) {
        return {
          'success': false,
          'message': 'Failed to submit code for execution (${submitResponse.statusCode}): ${submitResponse.body}',
        };
      }

      final submitData = jsonDecode(submitResponse.body);
      final token = submitData['token'];

      // Poll for results
      await Future.delayed(Duration(seconds: 2));
      
      final resultResponse = await http.get(
        Uri.parse('$judge0Url/$token?base64_encoded=false'),
        headers: {
          'X-RapidAPI-Key': '05866d76afmsh1b71ef2bfce7463p13606bjsnec72c273dcb0',
          'X-RapidAPI-Host': 'judge0-ce.p.rapidapi.com',
        },
      );

      if (resultResponse.statusCode == 200) {
        final resultData = jsonDecode(resultResponse.body);
        final status = resultData['status']['id'];
        
        // Status codes: 1=queued, 2=processing, 3=accepted, 4=wrong answer, 5=time limit, 6=compilation error, 7=runtime error
        if (status == 3) {
          return {
            'success': true,
            'output': resultData['stdout'] ?? '',
            'message': 'Execution successful',
          };
        } else if (status == 6) {
          // Compilation error - get full error details
          final compileOutput = resultData['compile_output'] ?? 'No compilation error details';
          final stderr = resultData['stderr'] ?? '';
          final combinedError = stderr.isNotEmpty 
              ? '$compileOutput\n\nStandard Error:\n$stderr' 
              : compileOutput;
          
          return {
            'success': false,
            'output': combinedError,
            'message': 'Compilation Error',
            'error_type': 'compilation',
            'line_number': _extractLineNumber(combinedError),
          };
        } else if (status == 7) {
          // Runtime error - get full error details
          final stderr = resultData['stderr'] ?? 'No runtime error details';
          final stdout = resultData['stdout'] ?? '';
          final combinedError = stdout.isNotEmpty 
              ? 'Program Output:\n$stdout\n\nError:\n$stderr' 
              : stderr;
          
          return {
            'success': false,
            'output': combinedError,
            'message': 'Runtime Error',
            'error_type': 'runtime',
            'line_number': _extractLineNumber(stderr),
          };
        } else if (status == 5) {
          return {
            'success': false,
            'output': 'Time limit exceeded - Your code took too long to execute',
            'message': 'Execution Timeout',
            'error_type': 'timeout',
          };
        } else {
          return {
            'success': false,
            'output': 'Status: ${resultData['status']['description'] ?? 'Unknown'}',
            'message': 'Processing...',
          };
        }
      }

      return {
        'success': false,
        'message': 'Failed to get execution results',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Helper method to extract line number from error messages
  static String? _extractLineNumber(String error) {
    // Try to find line number patterns like "line X", "at line X", ":X:", etc.
    final patterns = [
      RegExp(r'line\s+(\d+)', caseSensitive: false),
      RegExp(r':(\d+):\d+'),  // Pattern like ":5:10"
      RegExp(r'\*(\d+)\*'),  // Pattern like "*5*"
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(error);
      if (match != null && match.group(1) != null) {
        return match.group(1);
      }
    }
    return null;
  }
} 