// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firetask/common/app_button.dart';
import 'package:firetask/common/app_input_decoration.dart';
import 'package:firetask/common/app_snackbars.dart';
import 'package:firetask/modules/home/providers/firestore_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppBottomSheet extends ConsumerStatefulWidget {
  final bool isUpdated;
  final String? userId;
  final String? existingTitle;
  final String? existingDesc;
  const AppBottomSheet({
    super.key,
    this.existingTitle,
    this.existingDesc,
    this.userId,
    this.isUpdated = false,
  });

  @override
  ConsumerState<AppBottomSheet> createState() => _AppBottomSheetState();
}

class _AppBottomSheetState extends ConsumerState<AppBottomSheet> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late final titleController = TextEditingController(
    text: widget.existingTitle,
  );
  late final descController = TextEditingController(text: widget.existingDesc);

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.isUpdated ? "Task" : 'Create New Task',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: titleController,
                  decoration: AppInputDecoration.input(
                    context: context,
                    label: widget.isUpdated ? 'Update Title' : 'Task Title',
                    icon: Icons.assignment_outlined,
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter a title'
                      : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: descController,
                  maxLines: 3,
                  decoration: AppInputDecoration.input(
                    context: context,
                    isDesc: true,
                    hintText: 'Describe your task...',
                  ),
                ),
                const SizedBox(height: 30),
                Consumer(
                  builder: (ctx, ref, _) {
                    final state = ref.watch(firebaseFirestoreProvider);
                    return AppButton(
                      isLoading: state.status.isLoading,
                      text: widget.isUpdated ? 'Update Task' : 'Create Task',
                      textColor: Colors.white,
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          widget.isUpdated
                              ? await ref
                                    .read(firebaseFirestoreProvider.notifier)
                                    .updateTask(widget.userId.toString(), {
                                      'description': descController.text.trim(),
                                      'title': titleController.text.trim(),
                                      'updatedAt': FieldValue.serverTimestamp(),
                                    })
                              : await ref
                                    .read(firebaseFirestoreProvider.notifier)
                                    .addTask(
                                      titleController.text.trim(),
                                      descController.text.trim(),
                                    );
                          if (context.mounted) {
                            Navigator.pop(context);
                            AppSnackbars.showSuccess(
                              context,
                              widget.isUpdated
                                  ? 'Task Updated'
                                  : 'Added to your list',
                            );
                          } else {
                            return;
                          }
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
