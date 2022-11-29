import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

enum Menu { hideDone, onlyFavorite, deleteDone, editThread }

class Task {
  bool isFavorite = false;
  bool isDone = false;
  late int id;
  late String text;
  void display() {
    print("String: $String id: $id");
  }

  Task(String txt) {
    text = txt;
  }
}

class Branch extends StatefulWidget {
  const Branch({super.key});

  @override
  State<Branch> createState() => _BranchState();
}

class _BranchState extends State<Branch> {
  List<Task> allTasks = [];
  List<Task> visibleTasks = [];
  bool onlyFavorite = false;
  bool hideDone = false;
  String title = 'Учёба';

  final _textField = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          foregroundColor: Colors.white,
          backgroundColor: Colors.deepPurple,
          title: Text(title),
          actions: <Widget>[EditButton()],
        ),
        body: _TaskList(_visibleTasks(allTasks, onlyFavorite, hideDone)),
        backgroundColor: Colors.deepPurpleAccent,
        floatingActionButton: _addTask(allTasks),
      ),
    );
  }

  List<Task> _visibleTasks(List<Task> tasks, bool onlyFavorite, bool hideDone) {
    List<Task> out = [];
    out.addAll(tasks);
    if (onlyFavorite) {
      out.removeWhere((element) => element.isFavorite == false);
    }
    if (hideDone) {
      out.removeWhere((element) => element.isDone == true);
    }
    return out;
  }

  Widget _addTask(List tasks) {
    return FloatingActionButton(
      onPressed: () => _dialogCreateTask(context),
      backgroundColor: Colors.deepPurple,
      child: const Icon(Icons.add),
    );
  }

  Future<void> _dialogCreateTask(BuildContext context) {
    late String text;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Создать задачу'),
          actions: <Widget>[
            Form(
              key: _textField,
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Название не может быть пустым';
                  }
                  if (value.length > 40) {
                    return "Название слишком длинное";
                  }
                  return null;
                },
                maxLengthEnforcement: MaxLengthEnforcement.none,
                maxLength: 40,
                decoration: InputDecoration(
                  labelText: 'Введите название задачи',
                ),
                onChanged: (String value) {
                  text = value;
                },
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Отмена'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Ок'),
                onPressed: () {
                  if (_textField.currentState!.validate()) {
                    Task newTask = Task(text);
                    setState(() {
                      allTasks.add(newTask);
                    });
                    Navigator.of(context).pop();
                  }
                },
              )
            ]),
          ],
        );
      },
    );
  }

  @override
  Widget _TaskList(List<Task> tasks) {
    if (tasks.length != 0) {
      return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return Padding(
                padding: EdgeInsets.all(6.0),
                child: Dismissible(
                    background: Container(
                      color: Colors.red,
                      child: Icon(Icons.delete_forever),
                    ),
                    key: ValueKey<Task>(tasks[index]),
                    onDismissed: (DismissDirection direction) {
                      setState(() {
                        allTasks.remove(tasks[index]);
                      });
                    },
                    direction: DismissDirection.endToStart,
                    child: CheckboxListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                        checkboxShape: CircleBorder(),
                        tileColor: Colors.white,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(tasks[index].text),
                        value: tasks[index].isDone,
                        onChanged: (bool? value) {
                          setState(() {
                            tasks[index].isDone = !tasks[index].isDone;
                          });
                        },
                        secondary: IconButton(
                          iconSize: 30,
                          color: Colors.amber,
                          isSelected: tasks[index].isFavorite,
                          icon: const Icon(
                            Icons.star_border,
                          ),
                          selectedIcon: const Icon(
                            Icons.star,
                          ),
                          onPressed: () {
                            setState(() {
                              tasks[index].isFavorite = !tasks[index].isFavorite;
                            });
                          },
                        ))));
          });
    } else {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              SvgPicture.asset('assets/todolist_background.svg'),
              SvgPicture.asset('assets/todolist.svg'),
            ],
          ),
          const Text(
            'На данный момент задачи отсутствуют',
            style: TextStyle(fontSize: 20),
          ),
        ],
      ));
    }
  }

  @override
  Future<void> _dialogDeleteAlert(BuildContext context) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(title: const Text('Подтвердите удаление'), actions: <Widget>[
            Text("Удалить выполненные задачи? Это действие необратимо."),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Отмена'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Ок'),
                onPressed: () {
                  allTasks.removeWhere((element) => element.isDone == true);
                  setState(() {});
                  Navigator.of(context).pop();
                },
              )
            ]),
          ]);
        });
  }

  @override
  Future<void> _dialogEditThread(BuildContext context) {
    late String text;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Редактировать ветку'),
          actions: <Widget>[
            Form(
              key: _textField,
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Название не может быть пустым';
                  }
                  if (value.length > 40) {
                    return "Название слишком длинное";
                  }
                  return null;
                },
                maxLengthEnforcement: MaxLengthEnforcement.none,
                maxLength: 40,
                decoration: InputDecoration(
                  labelText: 'Введите название ветки',
                ),
                onChanged: (String value) {
                  text = value;
                },
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Отмена'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Ок'),
                onPressed: () {
                  if (_textField.currentState!.validate()) {
                    setState(() {
                      title = text;
                    });
                    Navigator.of(context).pop();
                  }
                },
              )
            ]),
          ],
        );
      },
    );
  }

  @override
  Widget EditButton() {
    List<String> _hideDoneButtonText = ['Скрыть выполненные', 'Показать выполненные'];
    List<String> _onlyFavoriteButtonText = ['Только избранные', 'Показать все'];
    List<IconData> _hideDoneButtonIcon = [Icons.check_circle, Icons.check_circle_outline];
    List<IconData> _onlyFavoriteButtonIcon = [Icons.star, Icons.star_border];

    return PopupMenuButton<Menu>(
        onSelected: (Menu item) {
          if (item == Menu.hideDone) {
            setState(() {
              hideDone = !hideDone;
            });
          }
          if (item == Menu.onlyFavorite) {
            setState(() {
              onlyFavorite = !onlyFavorite;
            });
          }
          if (item == Menu.deleteDone) {
            _dialogDeleteAlert(context);
          }
          if (item == Menu.editThread) {
            _dialogEditThread(context);
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
              PopupMenuItem<Menu>(
                  value: Menu.hideDone,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 4),
                    leading: Icon(_hideDoneButtonIcon[hideDone ? 1 : 0]),
                    title: Text(_hideDoneButtonText[hideDone ? 1 : 0]),
                  )),
              PopupMenuItem<Menu>(
                value: Menu.onlyFavorite,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 4),
                  leading: Icon(_onlyFavoriteButtonIcon[onlyFavorite ? 1 : 0]),
                  title: Text(_onlyFavoriteButtonText[onlyFavorite ? 1 : 0]),
                ),
              ),
              const PopupMenuItem<Menu>(
                value: Menu.deleteDone,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 4),
                  leading: Icon(Icons.delete_forever),
                  title: Text('Удалить выполненные'),
                ),
              ),
              const PopupMenuItem<Menu>(
                value: Menu.editThread,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 4),
                  leading: Icon(Icons.edit),
                  title: Text('Редактировать ветку'),
                ),
              ),
            ]);
  }
}
