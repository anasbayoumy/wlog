import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wlog/core/common/widgets/app_navigation_bar.dart';
import 'package:wlog/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:wlog/features/chat/presentation/pages/chat_room_page.dart';

class ChatGroupsPage extends StatefulWidget {
  const ChatGroupsPage({super.key});

  @override
  State<ChatGroupsPage> createState() => _ChatGroupsPageState();
}

class _ChatGroupsPageState extends State<ChatGroupsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadChatGroups());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Groups'),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChatGroupsLoaded) {
            if (state.groups.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline,
                        size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No chat groups available',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Chat groups are created based on blog categories',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ChatBloc>().add(RefreshChatGroups());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.groups.length,
                itemBuilder: (context, index) {
                  final group = state.groups[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          group.category.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        group.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        '${group.memberCount} members • ${group.category} category',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatRoomPage(
                              group: group,
                            ),
                          ),
                        );
                      },
                    ),
                  );
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
                      context.read<ChatBloc>().add(RefreshChatGroups());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(
            child: Text('Welcome to Chat!\nPull down to refresh.'),
          );
        },
      ),
      bottomNavigationBar: const AppNavigationBar(currentIndex: 3),
    );
  }
}
