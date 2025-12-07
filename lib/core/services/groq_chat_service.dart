import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../error/exceptions.dart';
import '../utils/logger.dart' as logger;

/// Conversation class to manage message history
class _Conversation {
  final String id;
  final List<Map<String, String>> messages;
  bool active;

  _Conversation({
    required this.id,
    List<Map<String, String>>? initialMessages,
  })  : messages = initialMessages ?? [],
        active = true;

  /// Adds a message to the conversation
  void addMessage(String role, String content) {
    messages.add({
      'role': role,
      'content': content,
    });
  }

  /// Gets all messages including system prompt
  List<Map<String, String>> getAllMessages() {
    return List.from(messages);
  }
}

/// Service for interacting with Groq API for chatbot functionality
///
/// This service provides a wrapper around the Groq API to enable
/// AI-powered chat assistance for insurance-related queries.
/// Follows conversation-based pattern with message history management.
class GroqChatService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.1-8b-instant';

  /// Gets the Groq API key from environment variables
  ///
  /// Throws [ValidationException] if the API key is not found.
  String get _apiKey {
    final apiKey = dotenv.env['GROQ_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw const ValidationException(
        'GROQ_API_KEY is not set in .env file. Please add GROQ_API_KEY=your_api_key to .env',
      );
    }
    return apiKey;
  }

  // Store conversations by conversation_id
  final Map<String, _Conversation> _conversations = {};

  /// Gets or creates a conversation
  _Conversation _getOrCreateConversation(
    String conversationId, {
    Map<String, dynamic>? insuranceContext,
  }) {
    if (!_conversations.containsKey(conversationId)) {
      // Create new conversation with system prompt
      final systemPrompt = _buildSystemPrompt(insuranceContext);
      _conversations[conversationId] = _Conversation(
        id: conversationId,
        initialMessages: [
          {
            'role': 'system',
            'content': systemPrompt,
          },
        ],
      );
      logger.Logger.info('GroqChatService: Created new conversation $conversationId');
    }
    return _conversations[conversationId]!;
  }

  /// Sends a chat message to Groq API with conversation history
  ///
  /// [message] - The user's message/question
  /// [conversationId] - Unique identifier for the conversation session
  /// [insuranceContext] - Optional context about the insurance policy (used for new conversations)
  ///
  /// Returns the AI assistant's response as a string.
  /// Throws an exception if the API call fails.
  Future<String> sendMessage(
    String message,
    String conversationId, {
    Map<String, dynamic>? insuranceContext,
  }) async {
    try {
      // Get or create conversation
      final conversation = _getOrCreateConversation(
        conversationId,
        insuranceContext: insuranceContext,
      );

      if (!conversation.active) {
        throw const ValidationException('The chat session has ended. Please start a new session.');
      }

      // Add user message to conversation history
      conversation.addMessage('user', message);

      // Get all messages including system prompt and history
      final messages = conversation.getAllMessages();

      // Make API request
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': _model,
          'messages': messages,
          'temperature': 1.0,
          'max_tokens': 1024,
          'top_p': 1.0,
        }),
      );

      // Handle response
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>;
        if (choices.isNotEmpty) {
          final messageContent = choices[0]['message'] as Map<String, dynamic>;
          final content = messageContent['content'] as String? ?? '';
          
          // Add assistant response to conversation history
          conversation.addMessage('assistant', content.trim());
          
          logger.Logger.info('Groq API: Successfully received response');
          return content.trim();
        } else {
          throw const ServerException('No response from AI assistant');
        }
      } else {
        final errorData = json.decode(response.body) as Map<String, dynamic>;
        final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
        logger.Logger.error(
          'Groq API error: ${response.statusCode}',
          Exception(errorMessage),
        );
        throw ServerException(
          'Failed to get response: $errorMessage',
          originalError: Exception(errorMessage),
        );
      }
    } catch (e, stackTrace) {
      logger.Logger.error(
        'Groq API: Failed to send message',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Ends a conversation session
  void endConversation(String conversationId) {
    if (_conversations.containsKey(conversationId)) {
      _conversations[conversationId]!.active = false;
      logger.Logger.info('GroqChatService: Ended conversation $conversationId');
    }
  }

  /// Clears a conversation (removes from memory)
  void clearConversation(String conversationId) {
    _conversations.remove(conversationId);
    logger.Logger.info('GroqChatService: Cleared conversation $conversationId');
  }

  /// Builds the system prompt with insurance context
  String _buildSystemPrompt(Map<String, dynamic>? insuranceContext) {
    String prompt = '''You are a helpful insurance assistant for ASSETWIZE, an asset management application. 
Your role is to help users understand their insurance policies, answer questions about coverage, 
claims, renewals, and provide general insurance guidance.

Be concise, friendly, and professional in your responses.
If you don't know something, admit it and suggest contacting the insurance provider directly.''';

    if (insuranceContext != null) {
      prompt += '\n\nCurrent Insurance Policy Context:';
      if (insuranceContext['title'] != null) {
        prompt += '\n- Policy Type: ${insuranceContext['title']}';
      }
      if (insuranceContext['provider'] != null) {
        prompt += '\n- Insurance Provider: ${insuranceContext['provider']}';
      }
      if (insuranceContext['policyNumber'] != null) {
        prompt += '\n- Policy Number: ${insuranceContext['policyNumber']}';
      }
      if (insuranceContext['type'] != null) {
        prompt += '\n- Insurance Type: ${insuranceContext['type']}';
      }
      if (insuranceContext['endDate'] != null) {
        prompt += '\n- Policy End Date: ${insuranceContext['endDate']}';
      }
      if (insuranceContext['shortDescription'] != null) {
        prompt += '\n- Description: ${insuranceContext['shortDescription']}';
      }
      prompt += '\n\nUse this context to provide relevant and personalized answers.';
    }

    return prompt;
  }
}

