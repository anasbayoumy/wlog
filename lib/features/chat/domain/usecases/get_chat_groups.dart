import 'package:fpdart/fpdart.dart';
import 'package:wlog/core/error/failures.dart';
import 'package:wlog/core/usecase/usecase.dart';
import 'package:wlog/features/chat/domain/entities/chat_group.dart';
import 'package:wlog/features/chat/domain/repositories/chat_repository.dart';

class GetChatGroups implements Usecase<List<ChatGroup>, NoParams> {
  final ChatRepository repository;

  GetChatGroups(this.repository);

  @override
  Future<Either<Failure, List<ChatGroup>>> call(NoParams params) async {
    return await repository.getChatGroups();
  }
}
