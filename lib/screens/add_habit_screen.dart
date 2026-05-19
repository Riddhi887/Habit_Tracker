//appears when user tabs the + button

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/habit_provider.dart';

class AddHabitScreen extends ConsumerStatefulWidget {
  const AddHabitScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AddHabitScreenState();
  }
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  //controllers
  final _titleController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _selectedEmoji = '🎯'; //default

  bool _isLoading = false;

  //create list of emoji using its unicode
  final List<String> _emojis = [
    '\u{1F3AF}',
    '\u{1F4AA}',
    '\u{1F4DA}',
    '\u{1F4A7}',
    '\u{1F9D8}',
    '\u{1F3C3}',
    '\u{1F957}',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  //validate form
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });

    //get current user id
    final userId = FirebaseAuth.instance.currentUser!.uid;

    //use notifier to call addHabit
    await ref
        .read(habitNotifierProvider.notifier)
        .addHabit(
          title: _titleController.text.trim(),
          emoji: _selectedEmoji,
          userId: userId,
        );

    setState(() {
      _isLoading = false;
    });

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Habit")),
      body: Padding(
        padding: const EdgeInsetsGeometry.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text input for the habit name
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Habit Name',
                  hintText: 'Drink 8 glasses of water',
                  border: OutlineInputBorder(),
                ),

                //validation
                validator: (value) => (value == null || value.isEmpty
                    ? 'Please enter the habit name'
                    : null),
              ),

              const SizedBox(height: 25),

              const Text(
                'Pick an emoji:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),

              const SizedBox(height: 12),

              //emoji picker in same row
              Wrap(
                spacing: 9, //horizontal space
                runSpacing: 9, //vertical gap
                children: _emojis.map((emoji) {
                  final isSelected = emoji == _selectedEmoji;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedEmoji = emoji;
                      });
                    },

                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.deepPurple.shade100
                            : Colors.grey.shade100,

                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(color: Colors.deepPurple, width: 2)
                            : null,
                      ),

                      child: Text(emoji, style: const TextStyle(fontSize: 28)),
                    ),
                  );
                }).toList(),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 92, 72, 149),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Save Habit',
                          style: TextStyle(fontSize: 17),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
