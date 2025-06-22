import 'package:fpdart/fpdart.dart';
import 'package:wlog/core/error/exceptions.dart';
import 'package:wlog/core/error/failures.dart';
import 'package:wlog/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:wlog/features/chat/domain/entities/chat_group.dart';
import 'package:wlog/features/chat/domain/entities/chat_message.dart';
import 'package:wlog/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ChatGroup>>> getChatGroups() async {
    try {
      final groups = await remoteDataSource.getChatGroups();
      return right(groups);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(String groupId) async {
    try {
      final messages = await remoteDataSource.getMessages(groupId);
      return right(messages);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String groupId,
    required String content,
    required String senderId,
    required String senderName,
  }) async {
    try {
      final message = await remoteDataSource.sendMessage(
        groupId: groupId,
        content: content,
        senderId: senderId,
        senderName: senderName,
      );
      return right(message);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Stream<ChatMessage> subscribeToMessages(String groupId) {
    // Return WebSocket stream for real-time messages
    return remoteDataSource.subscribeToMessages(groupId);
  }

  // Clean up WebSocket connections when done
  void dispose() {
    if (remoteDataSource is ChatRemoteDataSourceImpl) {
      (remoteDataSource as ChatRemoteDataSourceImpl).dispose();
    }
  }
}
