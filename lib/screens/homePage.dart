import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'addPage.dart';
import 'viewPage.dart';
import 'package:wasteagram/models/picModel.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  String _formatDate(_date) {
    return DateFormat.yMMMMEEEEd().format(_date);
  }

  int? total;

  countItems() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('posts').get();
    int count = 0;
    snapshot.docs.forEach((post) {
      count += post['quantity'] as int;
    });
    setState(() {
      total = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    countItems();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Wasteagram - $total'),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .orderBy('date', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData && snapshot.data!.docs.length > 0) {
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var post = snapshot.data!.docs[index];
                    return Semantics(
                      label: 'View Details',
                      onTapHint: 'View Details',
                      child: ListTile(
                          title: Text(_formatDate(DateTime.parse(
                              post['date'].toDate().toString()))),
                          trailing: Text(post['quantity'].toString(),
                              style: TextStyle(fontSize: 16)),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ViewPage()));
                          }),
                    );
                  });
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => AddPage()));
          },
          child: Semantics(
              label: 'Add a new post',
              onTapHint: 'Add a new post',
              child: Icon(
                Icons.add_photo_alternate_outlined,
              ))),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
