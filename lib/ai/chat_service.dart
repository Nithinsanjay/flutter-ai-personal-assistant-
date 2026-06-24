import 'gemma_service.dart';

class ChatService {
  static Future<String> sendMessage(String message) async {
    return await GemmaService.instance.sendMessage(message);
  }

  static Stream<String> sendMessageStream(String message) {
    return GemmaService.instance.sendMessageStream(message);
  }
}
