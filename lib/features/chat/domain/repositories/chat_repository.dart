import 'package:fpdart/fpdart.dart';
import 'package:wlog/core/error/failures.dart';
import 'package:wlog/features/chat/domain/entities/chat_group.dart';
import 'package:wlog/features/chat/domain/entities/chat_message.dart';

abstract interface class ChatRepository {
  Future<Either<Failure, List<ChatGroup>>> getChatGroups();
  Future<Either<Failure, List<ChatMessage>>> getMessages(String groupId);
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String groupId,
    required String content,
    required String senderId,
    required String senderName,
  });
  Stream<ChatMessage> subscribeToMessages(String groupId);
}
