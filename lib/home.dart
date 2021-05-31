import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}


class _HomeState extends State<Home> {
  List _toDoList = [];
  Map<String, dynamic> _lastRemoved;
  int _lastRemovePos;


  @override
  void initState() {
    super.initState();

    _readData().then((data){
     setState(() {
       _toDoList = json.decode(data);
     });
    });
  }

  final _toDoController = TextEditingController();

  void _addTOdO(){
      setState(() {
        if(_toDoController.text != ""){
          Map<String, dynamic> newToDo = Map();
          newToDo["title"] = _toDoController.text;
          _toDoController.text = "";
          newToDo["ok"] = false;
          _toDoList.add(newToDo);
          _saveData();
        }
      });
  }

  Future<Null> _refresh() async{
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _toDoList.sort((a,b){
        if (a["ok"] && !b["ok"]) return 1;
        else if (!a["ok"] && b["ok"]) return -1;
        else return 0;
      });

      _saveData();
    });

    return null;
  }

  @override


  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json"); //retorna um future
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();

      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Lista de Tarefas",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(17, 10, 7, 1),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    cursorColor: Colors.blue,
                    style: TextStyle(color: Colors.blue),
                    controller: _toDoController,
                    decoration: InputDecoration(
                        focusColor: Colors.blue,
                        fillColor: Colors.blue,
                        hoverColor: Colors.blue,
                        labelText: "Nova tarefa",
                        labelStyle: TextStyle(color: Colors.blue)),
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(primary: Colors.blue),
                  onPressed: _addTOdO,
                  label: Text("Add"),
                  icon: Icon(
                    Icons.add,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.separated(
                  padding: EdgeInsets.only(top:10),
                  itemCount: _toDoList.length,
                  separatorBuilder: (context, index){
                    return SizedBox(
                      height: 5,
                    );
                  },
                  itemBuilder: buildItem,
                ),
              )
          )
        ],
      ),
    );
  }

  Widget buildItem  (BuildContext context, int index){
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(child: Icon(Icons.delete, color: Colors.white,), alignment: Alignment(-0.9, 0) ,),
      ),
      direction: DismissDirection.startToEnd,
      child: Container(
        child: CheckboxListTile(
          onChanged: (check){
            setState(() {
              _toDoList[index]["ok"] = check;
              _saveData();

            });
          },
          checkColor: Colors.blue,
          selectedTileColor: Colors.blue,
          activeColor: const Color(0xff252525),
          tileColor: Colors.grey[700],
          title: Text(_toDoList[index]["title"], style: TextStyle(color: Colors.white),),
          value: _toDoList[index]["ok"],
          secondary: CircleAvatar(
            backgroundColor: const Color(0xff252525),
            child: Icon(_toDoList[index]["ok"] ? Icons.check : Icons.add_alert, color: Colors.blue,),
          ),
        ),
      ),
      onDismissed: (direction){
        setState(() {
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovePos = index;
          _toDoList.removeAt(index);
          _saveData();

          final snack = SnackBar(
            content: Text("Tarefa \"${_lastRemoved["title"]}\" removida"),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: (){
                setState(() {
                  _toDoList.insert(_lastRemovePos, _lastRemoved);
                  _saveData();
                });
              },
            ),
            duration: Duration(seconds: 4),
          );

          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(snack);
        });
      },
    );

  }
}


