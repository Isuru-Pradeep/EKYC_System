import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../models/chat_message.dart';
import 'success_screen.dart';
import '../api/api_service.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class KYCChatScreen extends StatefulWidget {
  const KYCChatScreen({super.key});

  @override
  State<KYCChatScreen> createState() => _KYCChatScreenState();
}

class _KYCChatScreenState extends State<KYCChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _currentStep = 0;
  String? _fullName;
  DateTime? _dateOfBirth;
  String? _idDocument;
  String? _billDocument;
  String? _selectedIdType;
  String? _nicFront;
  String? _nicBack;
  String? _address;
  String? _phoneNumber;
  String? _email;
  String? _nicNumber;

  // File paths for mobile
  String? _nicFrontPath;
  String? _nicBackPath;
  String? _idDocumentPath;
  String? _billDocumentPath;

  // File bytes for web
  Uint8List? _nicFrontBytes;
  Uint8List? _nicBackBytes;
  Uint8List? _idDocumentBytes;
  String? _idDocumentName;
  Uint8List? _billDocumentBytes;
  String? _billDocumentName;
  final List<String> _idTypes = ['NIC', 'Passport', 'Driving License'];
  final KYCApiService _apiService = KYCApiService();
  bool _isSubmitting = false;

  // Add applicationId to track if we have a valid ID for saving chat messages
  int? _applicationId;

  @override
  void initState() {
    super.initState();
    _addBotMessage("Welcome to KYC verification! Let's get started.");
    _askNextQuestion();
  }

  void _askNextQuestion() {
    switch (_currentStep) {
      case 0:
        _addBotMessage("Please enter your full name:");
        break;
      case 1:
        _addBotMessage("Please enter your email address:");
        break;
      case 2:
        _addBotMessage("Please select your date of birth:");
        Future.delayed(const Duration(milliseconds: 500), _showDatePicker);
        break;
      case 3:
        _addBotMessage("Please enter your current residential address:");
        break;
      case 4:
        _addBotMessage("Please enter your phone number:");
        break;
      case 5:
        _addBotMessage("Please enter your NIC number:");
        break;
      case 6:
        _addBotMessage("Please select your ID type:");
        Future.delayed(const Duration(milliseconds: 500), _showIdTypeSelector);
        break;
      case 7:
        if (_selectedIdType == 'NIC') {
          _addBotMessage("Please submit the front side of your NIC:");
        } else {
          _addBotMessage("Please submit your ${_selectedIdType} document:");
        }
        break;
      case 8:
        if (_selectedIdType == 'NIC') {
          _addBotMessage("Please submit the back side of your NIC :");
        } else {
          _addBotMessage("Please submit your bill documentation :");
        }
        break;
      case 9:
        if (_selectedIdType == 'NIC') {
          _addBotMessage("Please submit your bill documentation :");
        } else {
          _showSummary();
        }
        break;
      case 10:
        if (_selectedIdType == 'NIC') {
          _showSummary();
        }
        break;
    }
  }

  void _showIdTypeSelector() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select ID Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _idTypes.map((type) {
              return ListTile(
                title: Text(type),
                onTap: () {
                  setState(() {
                    _selectedIdType = type;
                    _messages.add(ChatMessage(
                      text: "Selected ID Type: $type",
                      isUser: true,
                    ));
                  });

                  // If we have an application ID, save this message
                  if (_applicationId != null) {
                    _saveChatMessage("Selected ID Type: $type",
                        isSystemMessage: false);
                  }

                  Navigator.pop(context);
                  _currentStep++;
                  Future.delayed(
                      const Duration(milliseconds: 500), _askNextQuestion);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showSummary() {
    _addBotMessage('''
Thank you! Here's your KYC information summary:
- Full Name: ${_fullName ?? 'Not provided'}
- Email: ${_email ?? 'Not provided'}
- Date of Birth: ${_dateOfBirth != null ? DateFormat('dd/MM/yyyy').format(_dateOfBirth!) : 'Not provided'}
- Address: ${_address ?? 'Not provided'}
- Phone Number: ${_phoneNumber ?? 'Not provided'}
- NIC Number: ${_nicNumber ?? 'Not provided'}
- ID Type: ${_selectedIdType ?? 'Not provided'}
${_selectedIdType == 'NIC' ? '''- NIC Front: ${_nicFront ?? 'Not provided'}
- NIC Back: ${_nicBack ?? 'Not provided'}''' : '''- ${_selectedIdType} Document: ${_idDocument ?? 'Not provided'}'''}
- Bill Document: ${_billDocument ?? 'Not provided'}

Is this information correct? Type 'yes' to confirm or 'no' to restart.''');
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: false));
    });
    _scrollToBottom();

    // If we have an application ID, save the bot message
    if (_applicationId != null) {
      _saveChatMessage(text, isSystemMessage: true);
    }
  }

  // Add a method to save chat messages
  Future<void> _saveChatMessage(String message,
      {bool isSystemMessage = false}) async {
    try {
      await _apiService.saveChatMessage(
        applicationId: _applicationId!,
        message: message,
        isSystemMessage: isSystemMessage,
      );
    } catch (e) {
      print("Failed to save chat message: $e");
      // Don't show error to user to avoid disrupting the flow
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSubmitted(String text) {
    if (text.isEmpty) return;

    // Sanitize input to prevent injection
    text = text.trim();
    if (text.length > 500) {
      text = text.substring(0, 500); // Limit message length
    }

    _textController.clear();
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
    });
    _scrollToBottom();

    // If we have an application ID, save the user message
    if (_applicationId != null) {
      _saveChatMessage(text, isSystemMessage: false);
    }

    // Check for "yes" to confirm submission
    if (_currentStep >= 10 && text.toLowerCase() == 'yes') {
      _submitKYCInformation();
      return;
    } else if (_currentStep >= 10 && text.toLowerCase() == 'no') {
      // Reset flow if user says "no" to confirmation
      setState(() {
        _currentStep = 0;
        _fullName = null;
        _dateOfBirth = null;
        _email = null;
        _address = null;
        _phoneNumber = null;
        _nicNumber = null;
        _selectedIdType = null;
        _nicFront = null;
        _nicBack = null;
        _idDocument = null;
        _billDocument = null;
        _nicFrontPath = null;
        _nicBackPath = null;
        _idDocumentPath = null;
        _billDocumentPath = null;
        _nicFrontBytes = null;
        _nicBackBytes = null;
        _idDocumentBytes = null;
        _billDocumentBytes = null;
      });
      _addBotMessage("Let's restart the process.");
      _askNextQuestion();
      return;
    }

    switch (_currentStep) {
      case 0:
        _fullName = text;
        _currentStep++;
        break;
      case 1:
        if (_isValidEmail(text)) {
          _email = text;
          _currentStep++;
        } else {
          _addBotMessage("Please enter a valid email address.");
          return;
        }
        break;
      case 3:
        _address = text;
        _currentStep++;
        break;
      case 4:
        if (_isValidPhoneNumber(text)) {
          _phoneNumber = text;
          _currentStep++;
        } else {
          _addBotMessage("Please enter a valid phone number (10-12 digits).");
          return;
        }
        break;
      case 5:
        if (_isValidNICNumber(text)) {
          _nicNumber = text;
          _currentStep++;
        } else {
          _addBotMessage("Please enter a valid NIC number.");
          return;
        }
        break;
    }

    Future.delayed(const Duration(milliseconds: 500), _askNextQuestion);
  }

  // Add phone number validation
  bool _isValidPhoneNumber(String phone) {
    // This regex matches numbers with optional '+' prefix and 10-12 digits
    return RegExp(r'^\+?[0-9]{10,12}$').hasMatch(phone);
  }

  bool _isValidNICNumber(String nic) {
    return RegExp(r'^([0-9]{9}[vVxX]|[0-9]{12})$').hasMatch(nic);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000), // Default to year 2000
      firstDate: DateTime(1900), // Allowing dates from 1900
      lastDate: DateTime.now(), // Up to current date
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Calendar text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
        _messages.add(ChatMessage(
          text: "Selected DOB: ${DateFormat('dd MMMM yyyy').format(picked)}",
          isUser: true,
        ));
      });

      // If we have an application ID, save the date selection message
      if (_applicationId != null) {
        _saveChatMessage(
            "Selected DOB: ${DateFormat('dd MMMM yyyy').format(picked)}",
            isSystemMessage: false);
      }

      _currentStep++;
      Future.delayed(const Duration(milliseconds: 500), _askNextQuestion);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessage(message);
              },
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: EdgeInsets.only(
        top: 8,
        bottom: 8,
        left: message.isUser ? 64 : 8,
        right: message.isUser ? 8 : 64,
      ),
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageComposer() {
    // Check if all required fields are filled
    bool canSubmit = _fullName != null &&
        _dateOfBirth != null &&
        _address != null &&
        _phoneNumber != null &&
        _selectedIdType != null &&
        _billDocument != null &&
        (_selectedIdType == 'NIC'
            ? (_nicFront != null && _nicBack != null)
            : _idDocument != null);

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_billDocument != null) // Only show button after bill is uploaded
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 45),
                  // Disable button if not all details are provided or currently submitting
                  disabledBackgroundColor: Colors.grey,
                ),
                onPressed: (canSubmit && !_isSubmitting)
                    ? _submitKYCInformation
                    : null,
                child: _isSubmitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text("Submitting...",
                              style: TextStyle(color: Colors.white)),
                        ],
                      )
                    : Text(
                        canSubmit
                            ? 'Submit KYC Information'
                            : 'Complete All Details First',
                        style: TextStyle(
                          fontSize: 16,
                          color: canSubmit ? Colors.white : Colors.white70,
                        ),
                      ),
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: _pickFile,
              ),
              Expanded(
                child: TextField(
                  controller: _textController,
                  onSubmitted: _handleSubmitted,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Send a message',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: kIsWeb, // Get bytes for web
        withReadStream: !kIsWeb, // Use stream for mobile
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        String fileName = file.name;

        setState(() {
          if (_currentStep == 7) {
            // Step for NIC front or ID Document
            if (_selectedIdType == 'NIC') {
              _nicFront = fileName;
              if (kIsWeb) {
                _nicFrontBytes = file.bytes;
              } else {
                _nicFrontPath = file.path;
              }
              _messages.add(ChatMessage(
                text: "NIC Front uploaded: $fileName",
                isUser: true,
              ));

              // Save file upload message if we have an application ID
              if (_applicationId != null) {
                _saveChatMessage("NIC Front uploaded: $fileName",
                    isSystemMessage: false);
              }
            } else {
              _idDocument = fileName;
              if (kIsWeb) {
                _idDocumentBytes = file.bytes;
                _idDocumentName = fileName;
              } else {
                _idDocumentPath = file.path;
              }
              _messages.add(ChatMessage(
                text: "${_selectedIdType} Document uploaded: $fileName",
                isUser: true,
              ));

              // Save file upload message if we have an application ID
              if (_applicationId != null) {
                _saveChatMessage(
                    "${_selectedIdType} Document uploaded: $fileName",
                    isSystemMessage: false);
              }
            }
          } else if (_currentStep == 8) {
            // Step for NIC back or Bill document
            if (_selectedIdType == 'NIC') {
              _nicBack = fileName;
              if (kIsWeb) {
                _nicBackBytes = file.bytes;
              } else {
                _nicBackPath = file.path;
              }
              _messages.add(ChatMessage(
                text: "NIC Back uploaded: $fileName",
                isUser: true,
              ));

              // Save file upload message if we have an application ID
              if (_applicationId != null) {
                _saveChatMessage("NIC Back uploaded: $fileName",
                    isSystemMessage: false);
              }
            } else {
              _billDocument = fileName;
              if (kIsWeb) {
                _billDocumentBytes = file.bytes;
                _billDocumentName = fileName;
              } else {
                _billDocumentPath = file.path;
              }
              _messages.add(ChatMessage(
                text: "Bill Document uploaded: $fileName",
                isUser: true,
              ));

              // Save file upload message if we have an application ID
              if (_applicationId != null) {
                _saveChatMessage("Bill Document uploaded: $fileName",
                    isSystemMessage: false);
              }
            }
          } else if (_currentStep == 9) {
            // Step for bill document (NIC only)
            _billDocument = fileName;
            if (kIsWeb) {
              _billDocumentBytes = file.bytes;
              _billDocumentName = fileName;
            } else {
              _billDocumentPath = file.path;
            }
            _messages.add(ChatMessage(
              text: "Bill Document uploaded: $fileName",
              isUser: true,
            ));

            // Save file upload message if we have an application ID
            if (_applicationId != null) {
              _saveChatMessage("Bill Document uploaded: $fileName",
                  isSystemMessage: false);
            }
          }

          _currentStep++;
          Future.delayed(const Duration(milliseconds: 500), _askNextQuestion);
        });
      }
    } catch (e) {
      _addBotMessage("Error uploading file: $e. Please try again.");
    }
  }

  // Add method to save all previous chat history
  Future<void> _saveAllChatHistory(int applicationId) async {
    try {
      // Save all messages except the last one (which was the success message we just added)
      for (int i = 0; i < _messages.length - 1; i++) {
        ChatMessage message = _messages[i];
        await _apiService.saveChatMessage(
          applicationId: applicationId,
          message: message.text,
          isSystemMessage: !message.isUser,
        );
        // Add small delay to avoid overwhelming the server
        await Future.delayed(const Duration(milliseconds: 50));
      }
    } catch (e) {
      print("Error saving chat history: $e");
      // Continue with the flow even if there's an error saving chat history
    }
  }

  Future<void> _submitKYCInformation() async {
    String documentInfo = _selectedIdType == 'NIC'
        ? '''- NIC Front: ${_nicFront}
- NIC Back: ${_nicBack}'''
        : '''- ${_selectedIdType} Document: ${_idDocument}''';

    _addBotMessage('''
Your KYC information is ready to be submitted:
- Full Name: $_fullName
- Date of Birth: ${DateFormat('dd/MM/yyyy').format(_dateOfBirth!)}
- Address: $_address
- Phone Number: $_phoneNumber
- NIC Number: ${_nicNumber ?? 'Not provided'}
- ID Type: $_selectedIdType
$documentInfo
- Bill Document: $_billDocument

Processing your submission...''');

    setState(() {
      _isSubmitting = true;
    });

    try {
      // First, submit the KYC application
      final kycResponse = await _apiService.submitKYCApplication(
        fullName: _fullName!,
        phoneNumber: _phoneNumber!,
        dob: _dateOfBirth!,
        address: _address!,
        idType: _selectedIdType!,
        idNumber: _nicNumber!,
        email: _email,
      );

      final int applicationId = kycResponse['id'];

      // Store the application ID for future chat messages
      _applicationId = applicationId;

      _addBotMessage(
          "KYC application submitted successfully! Application ID: $applicationId");

      // Save all previous chat messages to the database
      await _saveAllChatHistory(applicationId);

      _addBotMessage("Now uploading your documents...");

      // Upload the documents
      List<Future> documentUploads = [];

      // Upload NIC front or ID document
      if (_selectedIdType == 'NIC') {
        if (kIsWeb && _nicFrontBytes != null) {
          documentUploads.add(_apiService.uploadDocument(
            applicationId: applicationId,
            fileBytes: _nicFrontBytes,
            fileName: _nicFront ?? 'nic_front.pdf',
            documentType: 'NIC_FRONT',
            specialNote: 'NIC Front Side',
          ));
        } else if (!kIsWeb && _nicFrontPath != null) {
          documentUploads.add(_apiService.uploadDocument(
            applicationId: applicationId,
            filePath: _nicFrontPath,
            fileName: _nicFront ?? 'nic_front.pdf',
            documentType: 'NIC_FRONT',
            specialNote: 'NIC Front Side',
          ));
        }
      } else {
        if (kIsWeb && _idDocumentBytes != null) {
          documentUploads.add(_apiService.uploadDocument(
            applicationId: applicationId,
            fileBytes: _idDocumentBytes,
            fileName: _idDocument ?? 'id_document.pdf',
            documentType: _selectedIdType!,
            specialNote: '$_selectedIdType Document',
          ));
        } else if (!kIsWeb && _idDocumentPath != null) {
          documentUploads.add(_apiService.uploadDocument(
            applicationId: applicationId,
            filePath: _idDocumentPath,
            fileName: _idDocument ?? 'id_document.pdf',
            documentType: _selectedIdType!,
            specialNote: '$_selectedIdType Document',
          ));
        }
      }

      // Upload NIC back if applicable
      if (_selectedIdType == 'NIC') {
        if (kIsWeb && _nicBackBytes != null) {
          documentUploads.add(_apiService.uploadDocument(
            applicationId: applicationId,
            fileBytes: _nicBackBytes,
            fileName: _nicBack ?? 'nic_back.pdf',
            documentType: 'NIC_BACK',
            specialNote: 'NIC Back Side',
          ));
        } else if (!kIsWeb && _nicBackPath != null) {
          documentUploads.add(_apiService.uploadDocument(
            applicationId: applicationId,
            filePath: _nicBackPath,
            fileName: _nicBack ?? 'nic_back.pdf',
            documentType: 'NIC_BACK',
            specialNote: 'NIC Back Side',
          ));
        }
      }

      // Upload bill document if available
      if (kIsWeb && _billDocumentBytes != null) {
        documentUploads.add(_apiService.uploadDocument(
          applicationId: applicationId,
          fileBytes: _billDocumentBytes,
          fileName: _billDocument ?? 'bill_document.pdf',
          documentType: 'BILL_DOCUMENT',
          specialNote: 'Address Verification Bill',
        ));
      } else if (!kIsWeb && _billDocumentPath != null) {
        documentUploads.add(_apiService.uploadDocument(
          applicationId: applicationId,
          filePath: _billDocumentPath,
          fileName: _billDocument ?? 'bill_document.pdf',
          documentType: 'BILL_DOCUMENT',
          specialNote: 'Address Verification Bill',
        ));
      }

      // Wait for all document uploads to complete
      if (documentUploads.isNotEmpty) {
        await Future.wait(documentUploads);
        _addBotMessage("All documents uploaded successfully!");
      }

      // Navigate to success screen
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SuccessScreen(applicationId: applicationId.toString()),
          ),
        );
      });
    } catch (e) {
      _addBotMessage(
          "Error during submission: ${e.toString().replaceAll('Exception: ', '')}");
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}
