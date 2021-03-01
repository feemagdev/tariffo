import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FullscreenImage extends StatelessWidget {
  final String url;
  final String imageID;
  final String userId;
  final currentUserID;
  FullscreenImage(this.url, this.imageID, this.userId, this.currentUserID);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 30,
        leadingWidth: MediaQuery.of(context).size.width * 0.28,
        leading: userId != currentUserID
            ? Container()
            : Padding(
                padding: const EdgeInsets.only(left: 20),
                child: FlatButton(
                  onPressed: () async {
                    final reference = Firestore.instance
                        .collection("Users")
                        .document("$userId")
                        .collection("Gallery")
                        .document(imageID);
                    print(reference.path);
                    print(reference.documentID);

                    StorageReference storageReference =
                        await FirebaseStorage.instance.getReferenceFromUrl(url);
                    await storageReference.delete();
                    await reference.delete();
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Delete",
                    style: TextStyle(color: Colors.white),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      side: BorderSide(color: Colors.white)),
                ),
              ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context))
        ],
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 50, bottom: 50),
        child: Center(child: Image.network(url)),
      ),
      backgroundColor: Colors.black,
    );
  }
}
