import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final toDoController = TextEditingController();

  List toDoList = [];
  Map<String, dynamic> lastRemoved;
  int lastRemovePos;

  @override
  void initState() {
    super.initState();

    readData().then((data) {
      setState(() {
        toDoList = json.decode(data);
      });
    });
  }

  void addToDo() {
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = toDoController.text;
      toDoController.text = "";
      newToDo["ok"] = false;
      toDoList.add(newToDo);
      saveData();
    });
  }

  Future<Null> refresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      toDoList.sort((a, b) {
        if (a["ok"] && !b["ok"])
          return 1;
        else if (a["ok"] && b["ok"])
          return -1;
        else
          return 0;
      });
      saveData();
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.black54,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: toDoController,
                    decoration: InputDecoration(
                        labelText: "Nova Tarefa",
                        labelStyle: TextStyle(color: Colors.black54)),
                  ),
                ),
                RaisedButton(
                  color: Colors.black54,
                  child: Text("Add"),
                  textColor: Colors.white,
                  onPressed: () {
                    if (toDoController.text.isEmpty) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: new Text("Erro"),
                              content: new Text("Campo não pode estar vazio"),
                              actions: <Widget>[
                                new FlatButton(
                                  child: new Text("Entendi"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          });
                    }else {
                      return addToDo;
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
              child: RefreshIndicator(
                  onRefresh: refresh,
                  child: ListView.builder(
                      padding: EdgeInsets.only(top: 10.0),
                      itemCount: toDoList.length,
                      itemBuilder: buildItem))),
        ],
      ),
    );
  }

  Widget buildItem(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(toDoList[index]["title"]),
        value: toDoList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(toDoList[index]["ok"] ? Icons.check : Icons.error),
        ),
        onChanged: (c) {
          setState(() {
            toDoList[index]["ok"] = c;
            saveData();
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          lastRemoved = Map.from(toDoList[index]);
          lastRemovePos = index;
          toDoList.removeAt(index);

          saveData();

          final snack = SnackBar(
            content: Text("Tarefa \"${lastRemoved["title"]}\" removida!"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    toDoList.insert(lastRemovePos, lastRemoved);
                    saveData();
                  });
                }),
            duration: Duration(seconds: 3),
          );
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Future<File> getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> saveData() async {
    String data = json.encode(toDoList);
    final file = await getFile();
    return file.writeAsString(data);
  }

  Future<String> readData() async {
    try {
      final file = await getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
