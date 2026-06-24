import 'package:flutter_gemma/flutter_gemma.dart';

class GemmaService {
  GemmaService._();

  static final GemmaService instance = GemmaService._();

  InferenceModel? _model;
  InferenceChat? _chat;

  bool get isInitialized => _model != null;

  Future<void> initialize() async {
    if (_model != null) return;

    _model = await FlutterGemma.getActiveModel(maxTokens: 1024);
    _chat = await _model!.createChat(
      systemInstruction:
          "you are an ai personal assistant and help to solve user queries ",
    );
  }

  Future<String> sendMessage(String prompt) async {
    if (_chat == null) {
      throw Exception('Model not initialized');
    }

    await _chat!.addQuery(Message.text(text: prompt, isUser: true));
    final response = await _chat!.generateChatResponse();
    if (response is TextResponse) {
      return response.token;
    } else {
      return "Unable to parse response from model";
    }
  }

  Stream<String> sendMessageStream(String prompt) async* {
    if (_chat == null) {
      throw Exception('Model not initialized');
    }

    await _chat!.addQuery(Message.text(text: prompt, isUser: true));

    await for (final response in _chat!.generateChatResponseAsync()) {
      if (response is TextResponse) {
        yield response.token;
      }
    }
  }

  Future<void> dispose() async {
    if (_chat != null) {
      await _chat!.close();
      _chat = null;
    }
    _model = null;
  }
}
