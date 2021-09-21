import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_app/detailpage.dart';
import 'package:login_app/user_model.dart';
import 'package:provider/provider.dart';

import 'authentication_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isSearching = false;
  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot> futureSearchResult;
  FirebaseAuth auth = FirebaseAuth.instance;
  var auth1=FirebaseFirestore.instance.collection('users');
  var userRef = Firestore.instance.collection("users").snapshots();
  UserModel _currentUser;
  List<UserModel> totalUsers = [],_searchResult = [];

  String _uid;
  String _username;
  String _email;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Firestore.instance.collection("users").getDocuments().then((data) async{
      var list = data.documents;
      print("init state document:"+list.length.toString());  // value is getting
      for(int i=0;i<list.length;i++){
        print(list[i]['username']);
        totalUsers.add(UserModel(
          email: list[i]['email'],
          uid: list[i]['uid'],
          username: list[i]['username']
        ));
      }
    });
    getCurrentUser();
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    totalUsers.forEach((userDetail) {
      if (userDetail.username.contains(text) || userDetail.email.contains(text) || userDetail.email.contains(text))
        _searchResult.add(userDetail);
    });

    setState(() {});
  }

  getCurrentUser() async {
    UserModel currentUser = await context
        .read<AuthenticationService>()
        .getUserFromDB(uid: auth.currentUser.uid);

   setState(() {
     _currentUser = currentUser;
   });
   print('all users is$userRef');

    print("${_currentUser.username}");

    setState(() {
      _uid = _currentUser.uid;
      _username = _currentUser.username;
      _email = _currentUser.email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !isSearching ? Text("HomePage"): TextField(
          controller: searchTextEditingController,
          onChanged: (value){
            onSearchTextChanged(value);
          },
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            icon: Icon(Icons.search,color: Colors.white,),
                hintText: "Search name",
            hintStyle: TextStyle(color: Colors.white),

          ),
        ),
        actions: <Widget>[
          isSearching? IconButton(icon: Icon(Icons.cancel), onPressed: (){
            setState(() {
              searchTextEditingController.clear();
              this.isSearching = false;
              Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()),);
            });

          },):
          IconButton(icon: Icon(Icons.search), onPressed: (){
            setState(() {
              this.isSearching = true;
            });
          },)
        ],
        centerTitle: true,
      ),
      drawer:Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountEmail: Text("$_email\n$_uid"),
              accountName: Text("$_username"),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            ),
            ListTile(
              leading: new IconButton(
                icon: new Icon(Icons.home, color: Colors.black),
                onPressed: () => null,
              ),
              title: Text('Home'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomePage()),
                );
              },
            ),
            ListTile(
              leading: new IconButton(
                icon: new Icon(Icons.exit_to_app, color: Colors.black),
                onPressed: () => null,
              ),
              title: Text('Exit'),
              onTap: () {
                context.read<AuthenticationService>().signOut();
              },
            ),
          ],
        ),
      ),
      body: _searchResult.length != 0 || searchTextEditingController.text.isNotEmpty
          ? ListView.builder(itemCount: _searchResult.length,
        itemBuilder: (context,int index){
          return
            SingleChildScrollView(
              child: GestureDetector(
               /* onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DetailPage(index)),
                  );
                },*/
                child: Card(
                  elevation: 10,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                      child: Text(_searchResult[index].username,style: TextStyle(fontSize: 20,),)),
                ),
              ),
            );
        },) : ListView.builder(itemCount: totalUsers.length,
        itemBuilder: (context,int index){
          return
            SingleChildScrollView(
              child: GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DetailPage(index)),
                  );
                },
                child: Card(
                  elevation: 10,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                      child: Text(totalUsers[index].username,style: TextStyle(fontSize: 20,),)),
                ),
              ),
            );
        },)
    );
  }
}
//
