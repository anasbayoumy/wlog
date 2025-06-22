import 'package:fpdart/fpdart.dart';
import 'package:wlog/core/error/failures.dart';
import 'package:wlog/core/usecase/usecase.dart';
import 'package:wlog/features/chat/domain/entities/chat_message.dart';
import 'package:wlog/features/chat/domain/repositories/chat_repository.dart';

class GetMessages implements Usecase<List<ChatMessage>, String> {
  final ChatRepository repository;

  GetMessages(this.repository);

  @override
  Future<Either<Failure, List<ChatMessage>>> call(String groupId) async {
    return await repository.getMessages(groupId);
  }
}
