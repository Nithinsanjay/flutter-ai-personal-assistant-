import 'gemma_service.dart';

class ChatService {
  static Future<String> sendMessage(String message) async {
    return await GemmaService.instance.sendMessage(message);
  }
}
