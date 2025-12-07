import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/groq_chat_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/logger.dart' as logger;
import '../../domain/entities/insurance.dart';
import '../../../garage/domain/entities/garage.dart';

/// Chatbot page for asking questions about insurance or garage/vehicles
///
/// Provides an AI-powered chat interface using Groq API
/// to answer questions about the user's insurance policy or vehicle.
/// Follows conversation-based pattern with message history.
class ChatbotPage extends StatefulWidget {
  final Insurance? insurance;
  final Garage? garage;

  const ChatbotPage({
    super.key,
    this.insurance,
    this.garage,
  });

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  late final GroqChatService _chatService;
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  late final String _conversationId;

  @override
  void initState() {
    super.initState();
    _chatService = sl<GroqChatService>();
    // Generate unique conversation ID
    _conversationId = _generateConversationId();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Generates a unique conversation ID
  String _generateConversationId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final assetId = widget.insurance?.id ?? widget.garage?.id ?? 'general';
    return 'conv_${assetId}_$timestamp';
  }

  void _addWelcomeMessage() {
    String welcomeText;
    if (widget.insurance != null) {
      welcomeText = 'Hello! I\'m your insurance assistant. I can help you with questions about your ${widget.insurance!.title} policy from ${widget.insurance!.provider}. What would you like to know?';
    } else if (widget.garage != null) {
      final vehicleName = widget.garage!.make != null || widget.garage!.model != null
          ? '${widget.garage!.make ?? ''} ${widget.garage!.model ?? ''}'.trim()
          : widget.garage!.vehicleType;
      welcomeText = 'Hello! I\'m your vehicle assistant. I can help you with questions about your $vehicleName (${widget.garage!.registrationNumber}). What would you like to know?';
    } else {
      welcomeText = 'Hello! I\'m your assistant. How can I help you today?';
    }

    setState(() {
      _messages.add(ChatMessage(
        text: welcomeText,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    // Add user message to UI
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Prepare context (only for new conversations)
      Map<String, dynamic>? assetContext;
      if (widget.insurance != null) {
        assetContext = {
          'title': widget.insurance!.title,
          'provider': widget.insurance!.provider,
          'policyNumber': widget.insurance!.policyNumber,
          'type': widget.insurance!.type,
          'endDate': widget.insurance!.endDate.toIso8601String(),
          'shortDescription': widget.insurance!.shortDescription,
        };
      } else if (widget.garage != null) {
        assetContext = {
          'vehicleType': widget.garage!.vehicleType,
          'registrationNumber': widget.garage!.registrationNumber,
          'make': widget.garage!.make,
          'model': widget.garage!.model,
          'year': widget.garage!.year,
          'color': widget.garage!.color,
          'insuranceProvider': widget.garage!.insuranceProvider,
          'policyNumber': widget.garage!.policyNumber,
          'insuranceEndDate': widget.garage!.insuranceEndDate?.toIso8601String(),
        };
      }

      // Get AI response with conversation history
      final response = await _chatService.sendMessage(
        message,
        _conversationId,
        insuranceContext: assetContext,
      );

      // Add AI response to UI
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      logger.Logger.error('Failed to send message', e);
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: e.toString().contains('session has ended')
                ? 'This chat session has ended. Please start a new conversation.'
                : 'Sorry, I encountered an error. Please try again later.',
            isUser: false,
            timestamp: DateTime.now(),
            isError: true,
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  /// Starts a new conversation
  void _startNewConversation() {
    _chatService.clearConversation(_conversationId);
    setState(() {
      _messages.clear();
      _addWelcomeMessage();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: AppTheme.textPrimary,
        ),
        title: Row(
          children: [
            const Icon(
              Icons.auto_awesome,
              color: AppTheme.primaryGreen,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              widget.garage != null ? 'Vehicle Assistant' : 'Insurance Assistant',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _startNewConversation,
            color: AppTheme.textPrimary,
            tooltip: 'Start new conversation',
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppConstants.spacingM),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildLoadingIndicator();
                }
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
              child: const Icon(
                Icons.auto_awesome,
                size: 18,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingM,
                vertical: AppConstants.spacingS,
              ),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppTheme.primaryGreen
                    : AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Text(
                message.text,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: message.isUser
                      ? Colors.white
                      : message.isError
                          ? AppTheme.errorColor
                          : AppTheme.textPrimary,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
              child: const Icon(
                Icons.person,
                size: 18,
                color: AppTheme.primaryGreen,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
            child: const Icon(
              Icons.auto_awesome,
              size: 18,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type your question...',
                  hintStyle: GoogleFonts.montserrat(
                    color: AppTheme.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppTheme.backgroundLight,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingM,
                    vertical: AppConstants.spacingS,
                  ),
                ),
                style: GoogleFonts.montserrat(),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: AppConstants.spacingS),
            Container(
              decoration: const BoxDecoration(
                color: AppTheme.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _isLoading ? null : _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chat message model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}

