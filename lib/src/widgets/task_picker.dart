import 'package:flutter/material.dart';
import 'package:flutter_task_time_tracker/flutter_task_time_tracker.dart';

class TaskPicker extends StatefulWidget {
  final Function(TimerData task) onPicked;
  final double? borderRadius;
  final List<TimerData> tasks;
  final TimerData? initialTask;
  final Widget Function(TimerData)? titleBuilder;
  final Widget Function(TimerData)? subtitleBuilder;

  final String hintText;
  final String noDataText;
  final String headerText;

  const TaskPicker({
    super.key,
    required this.onPicked,
    this.borderRadius,
    required this.tasks,
    this.initialTask,
    this.titleBuilder,
    this.subtitleBuilder,
    this.hintText="Search task",
    this.noDataText="No tasks are available at the moment.",
    this.headerText="Choose Task",
  });

  @override
  State<TaskPicker> createState() => _TaskPickerState();
}

class _TaskPickerState extends State<TaskPicker> {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<bool> _haveText = ValueNotifier(false);
  TimerData? _selectedTechnicianTask;

  List<TimerData> _filteredTasks = [];

  @override
  void initState() {
    super.initState();
    _filteredTasks = widget.tasks;
    _selectedTechnicianTask = widget.initialTask;

    _searchController.addListener(() {
      _haveText.value = _searchController.text.isNotEmpty;
      _filterTasks(_searchController.text);
    });
  }

  void _filterTasks(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTasks = widget.tasks;
      } else {
        _filteredTasks =
            widget.tasks
                .where(
                  (task) =>
                      task.taskName.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      task.taskId.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      }
    });
  }

  Widget _searchWidget() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        suffixIcon: ValueListenableBuilder<bool>(
          valueListenable: _haveText,
          builder: (context, value, _) {
            return value
                ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    FocusManager.instance.primaryFocus?.unfocus();
                    _filterTasks("");
                  },
                  icon: const Icon(Icons.clear, color: Colors.grey),
                )
                : const SizedBox.shrink();
          },
        ),
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        hintText: widget.hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
    );
  }

  Widget _header() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.headerText,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w900,
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const Divider(color: Colors.black12),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Builder(
          builder: (_) {
            if (_filteredTasks.isEmpty) {
              return Column(
                children: [
                  _header(),
                  _searchWidget(),
                  const SizedBox(height: 15),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.noDataText,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  _header(),
                  _searchWidget(),
                  const SizedBox(height: 15),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _filteredTasks.length,
                      itemBuilder: (context, index) {
                        TimerData task = _filteredTasks[index];
                        return RadioListTile<TimerData>(
                          title:
                              widget.titleBuilder != null
                                  ? widget.titleBuilder!(task)
                                  : Text(
                                    task.taskId,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall!.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          subtitle:
                              widget.subtitleBuilder != null
                                  ? widget.subtitleBuilder!(task)
                                  : Text(
                                    task.taskName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium!.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          value: task,
                          groupValue: _selectedTechnicianTask,
                          onChanged: (TimerData? value) {
                            setState(() {
                              _selectedTechnicianTask = value;
                            });
                            if (value != null) {
                              widget.onPicked.call(value);
                            }
                          },
                        );
                      },
                      separatorBuilder:
                          (_, __) => const Divider(color: Colors.black12),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
