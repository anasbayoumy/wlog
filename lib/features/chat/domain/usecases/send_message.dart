import 'package:fpdart/fpdart.dart';
import 'package:wlog/core/error/failures.dart';
import 'package:wlog/core/usecase/usecase.dart';
import 'package:wlog/features/chat/domain/entities/chat_message.dart';
import 'package:wlog/features/chat/domain/repositories/chat_repository.dart';

class SendMessage implements Usecase<ChatMessage, SendMessageParams> {
  final ChatRepository repository;

  SendMessage(this.repository);

  @override
  Future<Either<Failure, ChatMessage>> call(SendMessageParams params) async {
    return await repository.sendMessage(
      groupId: params.groupId,
      content: params.content,
      senderId: params.senderId,
      senderName: params.senderName,
    );
  }
}

class SendMessageParams {
  final String groupId;
  final String content;
  final String senderId;
  final String senderName;

  SendMessageParams({
    required this.groupId,
    required this.content,
    required this.senderId,
    required this.senderName,
  });
}
