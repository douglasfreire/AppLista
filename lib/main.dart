import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
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

  void addToDo(){
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = toDoController.text;
      toDoController.text="";
      newToDo["ok"] = false;
      toDoList.add(newToDo);
    });
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
                        labelStyle: TextStyle(color: Colors.black54)
                    ),
                  ),
                ),
                RaisedButton(
                  color: Colors.black54,
                  child: Text("Add"),
                  textColor: Colors.white,
                  onPressed: addToDo,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
                padding: EdgeInsets.only(top: 10.0),
                itemCount: toDoList.length,
                itemBuilder: (context, index){
                  return CheckboxListTile(
                    title: Text(toDoList[index]["title"]),
                    value: toDoList[index]["ok"],
                    secondary: CircleAvatar(
                      child: Icon(toDoList[index]["ok"]?
                      Icons.check : Icons.error),
                    ),
                    onChanged: (c){
                      setState(() {
                        toDoList[index]["ok"] = c;
                      });
                    },
                  );
                  },
          ),
          ),
        ],
      ),
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
    }catch (e){
      return null;
    }
  }
}



