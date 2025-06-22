import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wlog/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:wlog/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:wlog/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:wlog/features/chat/domain/entities/chat_group.dart';
import 'package:wlog/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:wlog/features/chat/presentation/widgets/chat_message_bubble.dart';

class ChatRoomPage extends StatefulWidget {
  final ChatGroup group;

  const ChatRoomPage({
    super.key,
    required this.group,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Store reference to avoid accessing context in dispose()
  ChatBloc? _chatBloc;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Store bloc reference for safe cleanup (as recommended by Flutter)
    if (_chatBloc == null) {
      _chatBloc = context.read<ChatBloc>();

      // Load existing messages first
      _chatBloc!.add(LoadMessages(groupId: widget.group.id));

      // Then establish WebSocket connection for real-time updates
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && _chatBloc != null) {
          _chatBloc!.add(SubscribeToMessages(groupId: widget.group.id));
        }
      });
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final userState = context.read<AppUserCubit>().state;
    if (userState is IsLoggedIn && _chatBloc != null) {
      _chatBloc!.add(SendMessageEvent(
        groupId: widget.group.id,
        content: content,
        senderId: userState.user.id,
        senderName: userState.user.name,
      ));

      _messageController.clear();
    }
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.group.name),
            Row(
              children: [
                Text(
                  '${widget.group.memberCount} members',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Live',
                  style: TextStyle(fontSize: 10, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_chatBloc != null) {
                _chatBloc!.add(RefreshMessages(groupId: widget.group.id));
              }
            },
            tooltip: 'Refresh messages',
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatMessagesLoaded ||
                    state is ChatMessagesUpdated) {
                  _scrollToBottom();
                }
              },
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ChatMessagesLoaded ||
                    state is ChatMessagesUpdated) {
                  final messages = state is ChatMessagesLoaded
                      ? state.messages
                      : (state as ChatMessagesUpdated).messages;

                  if (messages.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        if (_chatBloc != null) {
                          _chatBloc!
                              .add(RefreshMessages(groupId: widget.group.id));
                        }
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 200),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline,
                                    size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'No messages yet',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Be the first to start the conversation!',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Pull down to refresh',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      if (_chatBloc != null) {
                        _chatBloc!
                            .add(RefreshMessages(groupId: widget.group.id));
                      }
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return ChatMessageBubble(message: message);
                      },
                    ),
                  );
                } else if (state is ChatError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${state.message}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (_chatBloc != null) {
                              _chatBloc!
                                  .add(LoadMessages(groupId: widget.group.id));
                            }
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return const Center(
                  child: Text('Loading messages...'),
                );
              },
            ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Clean up WebSocket connection for this group using stored reference
    if (_chatBloc != null) {
      final chatRepository = _chatBloc!.chatRepository;
      if (chatRepository is ChatRepositoryImpl) {
        final dataSource = chatRepository.remoteDataSource;
        if (dataSource is ChatRemoteDataSourceImpl) {
          dataSource.cleanupGroup(widget.group.id);
        }
      }
    }

    _messageController.dispose();
    _scrollController.dispose();
    _chatBloc = null; // Clear the reference
    super.dispose();
  }
}
