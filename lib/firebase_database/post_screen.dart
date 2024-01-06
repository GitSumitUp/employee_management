import 'package:employee_management/ui/auth/login_screen.dart';
import 'package:employee_management/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:employee_management/firebase_database/add_posts.dart';


class PostScreen extends StatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
 State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {

  final auth = FirebaseAuth.instance ;
  final ref = FirebaseDatabase.instance.ref('Post');
  final searchFilter = TextEditingController();
  final editController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post'),
        actions: [
          IconButton(onPressed: (){
            auth.signOut().then((value){
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginScreen()));
            }).onError((error, stackTrace){
              Utils().toastMessage(error.toString());
            });
          }, icon: Icon(Icons.logout_outlined),),
          SizedBox(width: 10,)
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 10,),
          Padding(
             padding: const EdgeInsets.symmetric(horizontal: 10),
             child: TextFormField(
             decoration: InputDecoration(
              hintText: 'Search',
              border: OutlineInputBorder()
             ),
               onChanged: (String value) {
                 setState(() {

                 });
               }
           ),
          ),
          Expanded(
            child: FirebaseAnimatedList(
                query: ref,
                defaultChild: Text('Loading'),
                itemBuilder: (context, snapshot, animation, index){

                  final title = snapshot.child('title').value.toString();
                  final  id = snapshot.child('id').value.toString();

                  if(searchFilter.text.isEmpty){
                    return ListTile(
                    title: Text(snapshot.child('title').value.toString()),
                    subtitle: Text(snapshot.child('id').value.toString()),
                      trailing:  PopupMenuButton(
                          color: Colors.white,
                          elevation: 4,
                          padding: EdgeInsets.zero,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(2))),
                          icon: Icon(Icons.more_vert,),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 1,
                                child:  ListTile(
                                  onTap: (){
                                    Navigator.pop(context);
                                  showMyDialog(context, snapshot.child('title').value.toString(), id);
                                  },
                                  leading: Icon(Icons.edit),
                                  title: Text('Edit'),
                                ),
                              ),
                            PopupMenuItem(
                              value: 2,
                              child: ListTile(
                                onTap: () async {
                                  Navigator.pop(context);
                                  try {
                                    await ref.child(id).remove();
                                    // Additional logic after successful deletion if needed
                                    Utils().toastMessage('Record deleted successfully');
                                  } catch (error) {
                                    Utils().toastMessage('Error deleting record: $error');
                                  }
                                },
                                leading: Icon(Icons.delete_outline),
                                title: Text('Delete'),
                              ),
                            ),
                          ]
                       ),
                    );
                  }else if (title.split(' ').any((word) => word.isNotEmpty && word[0].toUpperCase() == searchFilter.text[0].toUpperCase())) {
                    return ListTile(
                      title: Text(title),
                      subtitle: Text(id),
                    );
                  }
                  else  {
                         return Container();
                        }
                       }
                     ),
                  ),
                ],
             ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddPostScreen()));
        } ,
        child: Icon(Icons.add),
      ),
    );
  }
  Future<void> showMyDialog(BuildContext context, String title, String id)async{
    editController.text = title;

    return showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text('Update'),
            content: Container(
              child: TextField(
                controller: editController,
                decoration: InputDecoration(
                  hintText: 'Edit'
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: (){
                Navigator.pop(context);
              }, child: Text('Cancel')),
              TextButton(onPressed: (){
                Navigator.pop(context);

                ref.child(id).update({
                    'id' : id,
                    'title': editController.text.split(' ').map((word) {
                if (word.isNotEmpty) {
                     return word[0].toUpperCase() + word.substring(1).toLowerCase();
                } else {
                        return '';
                       }
                    }).join(' ')
                }).then((value) {
                 Utils().toastMessage('Post Update');
                 }).onError((error, stackTrace){
                  Utils().toastMessage(error.toString());
                });
              }, child: Text('Update')),
            ],
          );
        }
    );
  }
}




