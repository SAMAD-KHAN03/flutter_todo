// home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo/providers/task_providers.dart';
import 'package:todo/widgets/task_cards.dart';
import 'package:todo/model/task.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  var _selectedCategory = Situation.AllTasks;
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _subjectEditingController =
      TextEditingController();

  @override
  void dispose() {
    _textEditingController.dispose();
    _subjectEditingController.dispose();
    super.dispose();
  }

  // Show popup for adding a new task
  void showPopup(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext) => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 32, 25, 0),
            child: TextField(
              decoration: const InputDecoration(hintText: 'Task'),
              controller: _textEditingController,
              maxLength: 25,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 32, 25, 0),
            child: TextField(
              decoration: const InputDecoration(hintText: 'Details...'),
              maxLines: 2,
              controller: _subjectEditingController,
              maxLength: 50,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    ref.read(taskprovider.notifier).addItem(
                          Uuid().v4(),
                          _textEditingController.text,
                          _subjectEditingController.text,
                          Situation.Incomplete,
                        );
                    _textEditingController.clear();
                    _subjectEditingController.clear();
                    Navigator.pop(context);
                  });
                },
                child: const Text('Save'),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTaskList = ref.watch(filterprovider);
    final filteredTaskNotifier = ref.read(filterprovider.notifier);
    bool isFetchingData = ref.watch(taskprovider.notifier).isFetchingData;
    bool isUploadingData = ref.watch(taskprovider.notifier).isUploadingData;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        onPressed: () {
          showPopup(context, ref);
        },
        child: isUploadingData
            ? const CircularProgressIndicator()
            : const Icon(
                Icons.add,
                color: Colors.blueGrey,
              ),
      ),
      appBar: AppBar(
        title: const Text("Your Tasks"),
        centerTitle: false,
        actions: [
          DropdownButton(
            value: _selectedCategory,
            elevation: 8,
            isExpanded: false,
            padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
            items: Situation.values
                .map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(status.name),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() {
                _selectedCategory = value;
              });
              if (_selectedCategory == Situation.Completed) {
                filteredTaskNotifier.completedFilter();
              } else if (_selectedCategory == Situation.Incomplete) {
                filteredTaskNotifier.incompleteFilter();
              } else {
                filteredTaskNotifier.resetFilter();
              }
            },
            icon: const Icon(
              Icons.filter_list_sharp,
            ),
          )
        ],
      ),
      body: isFetchingData
          ? Center(
              child: CircularProgressIndicator(),
            )
          : filteredTaskList.isNotEmpty
              ? TaskCards(task: filteredTaskList)
              : const Center(
                  child: Text('No Tasks'),
                ),
    );
  }
}
