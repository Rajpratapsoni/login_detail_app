import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class DetailPage extends StatelessWidget {
  var userRef = Firestore.instance.collection("users").snapshots();
  var value;

  DetailPage(this.value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Details'),
      ),
      body: StreamBuilder(
        stream: userRef,
        builder: (context,snapshot){
          if(!snapshot.hasData)
            return CircularProgressIndicator();
          return ListView.builder(itemCount: 1,
            itemBuilder: (context,int index){
              return Column(
                children: [
                  SizedBox(height: 50,),
                  Text("Name: ${snapshot.data.documents[value]["username"]}"),
                  Text("Email: ${snapshot.data.documents[value]["email"]}"),
                  Text("Uid: ${snapshot.data.documents[value]["uid"]}"),
                  SizedBox(height: 50,)
                ],
              );
            },);
        },
      ),
    );

  }
}

