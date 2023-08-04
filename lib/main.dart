import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(home: Home(),));}
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

final TextEditingController taskNameController=TextEditingController();
final TextEditingController taskDescController=TextEditingController();
class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    final fireStore=FirebaseFirestore.instance;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("To do list"),
        actions: [
          IconButton(onPressed: (){}, icon: const Icon(CupertinoIcons.calendar),)
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context){

               var width = MediaQuery.of(context).size.width;
                var height = MediaQuery.of(context).size.height;

                Future addTasks({required String taskName, required String taskDesc}) async {
                  DocumentReference docRef=await
                  FirebaseFirestore.instance.collection('/tasks').add({
                    'taskName':taskName,
                    'taskDesc':taskDesc,
                  });
                }
                taskNameController.text="";
                taskDescController.text="";
                return AlertDialog(
                  scrollable: true,
                  title: const Text("Add Task",textAlign: TextAlign.center,style: TextStyle(fontSize: 16,color: Colors.teal),),
                  content: SizedBox(
                    height: height*0.35,
                    width: width,
                    child: Form(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: taskNameController,
                            style: const TextStyle(fontSize: 14),decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                              hintText: "Task",
                              hintStyle: const TextStyle(fontSize: 14),
                              icon: const Icon(CupertinoIcons.square_list,color: Colors.teal,),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              )
                          ),
                          ),
                          const SizedBox(height: 15),
                          TextFormField(keyboardType: TextInputType.multiline,
                            controller: taskDescController,
                            maxLines: null,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                                hintText: "Description",
                                hintStyle: const TextStyle(fontSize: 14),
                                icon: const Icon(CupertinoIcons.bubble_left_bubble_right,color: Colors.teal,),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                )
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    ElevatedButton(onPressed: (){
                      Navigator.of(context,rootNavigator: true).pop();
                    }, child: const Text("Cancel"),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.cyan,
                      ),),
                    ElevatedButton(onPressed: (){
                      final taskName=(taskNameController.text).toString();
                      final taskDesc=(taskDescController.text).toString();
                      addTasks(taskName:taskName,taskDesc:taskDesc);
                      Navigator.of(context,rootNavigator: true).pop();
                    }, child: const Text("Save"))
                  ],
                );
              }
          );
        },
        child: const Icon(Icons.add),
      ), //Add TASK

      body: Container(
        margin: const EdgeInsets.all(10.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: fireStore.collection('tasks').snapshots(),
          builder: (context, snapshot){

            return ListView(
              scrollDirection: Axis.vertical,
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.cyan,
                        blurRadius: 5.0,
                        offset: Offset(0, 5), // shadow direction: bottom right
                      ),
                    ],
                  ),
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 15.0),
                  child: ListTile (
                    title: Text(data['taskName'].toString()),
                    subtitle: Text(data['taskDesc'].toString()),
                    trailing: PopupMenuButton(
                itemBuilder: (context){
                  return[
                    PopupMenuItem(child: Text('Edit'),value: 'edit',),
                PopupMenuItem(child: Text('Delete'),value: 'delete',)
                  ];
                },
                      onSelected: (value) {
                        if (value == 'edit') {
                          String taskId = (data['id']);
                          String taskName = (data['taskName']);
                          String taskDesc = (data['taskDesc']);
                          Future.delayed(
                            const Duration(seconds: 0),
                                () =>
                                showDialog( //opens an alert dialog box with the strings already populated
                                  context: context,
                                  builder: (context) =>
                                      UpdateTaskAlertDialog(taskId: taskId,
                                          taskName: taskName,
                                          taskDesc: taskDesc),
                                ),
                          );
                        }
                        if(value=='delete'){
                          String taskId = (data['id']);
                          String taskName = (data['taskName']);
                          String taskDesc = (data['taskDesc']);
                          Future.delayed(
                            const Duration(seconds: 0),
                                () => showDialog(
                              context: context,
                              builder: (context) => DeleteTaskDialog(taskId: taskId, taskName:taskName,taskDesc: taskDesc),
                            ),
                          );
                        }
                      },
                )
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 5.0,
        clipBehavior: Clip.antiAlias,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.list_alt_outlined), onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.bookmark_add_outlined), onPressed: () {},
            )
          ],
        ),
      ),
    );
  }
}

class UpdateTaskAlertDialog extends StatefulWidget {
  final String taskId, taskName, taskDesc;

  UpdateTaskAlertDialog(
      {Key? Key, required this.taskId, required this.taskName, required this.taskDesc})
      : super(key: Key);

  @override
  State<UpdateTaskAlertDialog> createState() => _UpdateTaskAlertDialogState();
}

class _UpdateTaskAlertDialogState extends State<UpdateTaskAlertDialog> {

  Future _updateTasks(String taskName, String taskDesc) async {
    DocumentReference docRef=await
    FirebaseFirestore.instance.collection('/tasks').add({
      'taskName':taskName,
      'taskDesc':taskDesc,
    });
    String taskId=docRef.id;
    await
    FirebaseFirestore.instance.collection('/tasks').doc(taskId).update(
      {'id':taskId},
    );
    var collection = FirebaseFirestore.instance.collection('tasks'); // fetch the collection name i.e. tasks
    collection
        .doc(widget.taskId) // ensure the right task is updated by referencing the task id in the method
        .update({'taskName': taskName, 'taskDesc': taskDesc}) // the update method will replace the values in the db, with these new values from the update alert dialog box
        .then( // implement error handling
          (_) => null
    );
  }
  @override
  Widget build(BuildContext context) {
    taskNameController.text=(widget.taskName).toString();
    taskDescController.text=(widget.taskDesc).toString();
    return AlertDialog(
      scrollable: true,
      title: const Text("Update Task",textAlign: TextAlign.center,style: TextStyle(fontSize: 16,color: Colors.teal),),
      content: SizedBox(
        child: Form(
          child: Column(
            children: [
              TextFormField(
                controller: taskNameController,
                style: const TextStyle(fontSize: 14),decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                  icon: const Icon(CupertinoIcons.square_list,color: Colors.teal,),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  )
              ),
              ),
              const SizedBox(height: 15),
              TextFormField(keyboardType: TextInputType.multiline,
                controller: taskDescController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                    icon: const Icon(CupertinoIcons.bubble_left_bubble_right,color: Colors.teal,),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    )
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(onPressed: (){
          Navigator.pop(context);
        }, child: const Text("Cancel"),
          style: ElevatedButton.styleFrom(
            primary: Colors.cyan,
          ),),
        ElevatedButton(onPressed: (){
          final taskName=(taskNameController.text).toString();
          final taskDesc=(taskDescController.text).toString();
          _updateTasks(taskName, taskDesc);
          Navigator.of(context,rootNavigator: true).pop();
        }, child: const Text("Update"))
      ],
    );
  }
}



class DeleteTaskDialog extends StatefulWidget {
  final taskId,taskName,taskDesc;
  const DeleteTaskDialog({Key? key,required this.taskId, required this.taskName,required this.taskDesc}) : super(key: key);

  @override
  State<DeleteTaskDialog> createState() => _DeleteTaskDialogState();
}

class _DeleteTaskDialogState extends State<DeleteTaskDialog> {
  Future _DeleteTasks() async{
    var collection = FirebaseFirestore.instance.collection('tasks'); // fetch the collection name i.e. tasks
    collection
        .doc(widget.taskId) // ensure the right task is deleted by passing the task id to the method
        .delete() // delete method removes the task entry in the collection
        .then( // implement error handling
            (_) => null);
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Alert'),
      content: Text("Are you sure you want to delete?"),
      actions: <Widget>[
        TextButton(onPressed: (){
          _DeleteTasks();
          Navigator.of(context,rootNavigator: true).pop();
        }, child: Text("Yes")),
        TextButton(onPressed: (){
          Navigator.of(context,rootNavigator: true).pop();
        }, child: Text("No"))
      ],
    );
  }
}




