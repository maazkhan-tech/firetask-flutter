import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firetask/common/app_bottom_sheet.dart';
import 'package:firetask/common/app_dailog.dart';
import 'package:firetask/common/app_snackbars.dart';
import 'package:firetask/modules/home/providers/firestore_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TaskDetailScreen extends ConsumerWidget {
  final String id;
  const TaskDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(firebaseFirestoreProvider);
    ref.listen(firebaseFirestoreProvider, (previous, next) {
      if (next.action == FireStoreAction.deleteTask) {
        next.status.when(
          data: (data) {
            context.go('/');
            AppSnackbars.showSuccess(context, 'Task Deleted Successfuly');
          },
          error: (error, stackTrace) =>
              AppSnackbars.showError(context, error.toString()),
          loading: () => CircularProgressIndicator(),
        );
      }
      if (next.action == FireStoreAction.updateTask) {
        next.status.when(
          data: (data) {
            AppSnackbars.showSuccess(context, 'Task Updated Successfuly');
          },
          error: (error, stackTrace) =>
              AppSnackbars.showError(context, error.toString()),
          loading: () => CircularProgressIndicator(),
        );
      }
    });
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Task Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: state.status.when(
        data: (data) => StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('tasks')
              .doc(id)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.data() == null) {
              return const Center(child: Text("Task not found"));
            }
            var data = snapshot.data!.data() as Map<String, dynamic>;
            DateTime date = (data['createdAt'] as Timestamp).toDate();
            final formattedDate = DateFormat('MMMM d, yyyy').format(date);
            final formattedTime = DateFormat('hh:mm a').format(date);
            bool isCompleted = data['isCompleted'] ?? false;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isCompleted ? '● Completed' : '● In Progress',
                      style: TextStyle(
                        color: isCompleted
                            ? Colors.green[700]
                            : Colors.orange[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          data['title'] ?? 'No Title',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return AppBottomSheet(
                                existingDesc: data['description'],
                                existingTitle: data['title'],
                                isUpdated: true,
                                userId: id,
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AppDialog(
                                title: 'Delete',
                                content: 'Are you sure want to Delete?',
                                actions: [
                                  TextButton(
                                    onPressed: () => context.pop(),
                                    child: Text('No'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      ref
                                          .read(
                                            firebaseFirestoreProvider.notifier,
                                          )
                                          .deleteTask(id);
                                      context.pop();
                                    },

                                    child: Text('Yes'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: Icon(
                          Icons.delete_forever_outlined,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "$formattedDate at $formattedTime",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                  const Divider(height: 40, thickness: 1),

                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      data['description'] ?? 'No description provided.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        loading: () => Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
