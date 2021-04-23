import 'dart:io';
import 'package:chatapp/helper/constants.dart';
import 'package:chatapp/services/database.dart';
import 'package:chatapp/widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:utopic_tor_onion_proxy/utopic_tor_onion_proxy.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:url_launcher/url_launcher.dart';

class Chat extends StatefulWidget {

  final String chatRoomId;
  File _image;
  FileType _picktype = FileType.any;
  String _uploadedimageurl;
  String _path;
  String filelocation;
  String _extension;
  GlobalKey <ScaffoldState> _scaffoldkey = GlobalKey();
  List <StorageUploadTask> _tasks = <StorageUploadTask>[];

  Chat({this.chatRoomId});

  @override
  _ChatState createState() => _ChatState();

}

class _ChatState extends State<Chat> {

  File _image;
  FileType _picktype = FileType.any;
  String _uploadedimageurl;
  String _path;
  String filelocation;
  String _extension;
  GlobalKey <ScaffoldState> _scaffoldkey = GlobalKey();

  var key = "null";
  String encryptedS,decryptedS;
  var password = "null";
  PlatformStringCryptor cryptor;

  Stream<QuerySnapshot> chats;
  TextEditingController messageEditingController = new TextEditingController();

  Widget chatMessages(){
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot){
        return snapshot.hasData ?  ListView.builder(
          itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index){
              return MessageTile(
                message: snapshot.data.documents[index].data["message"],
                sendByMe: Constants.myName == snapshot.data.documents[index].data["sendBy"],
              );
            }) : Container();
      },
    );
  }

  Future getimage() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      setState(() {
        _image = image;
      });
    });
    if(_image != null)
      {
        uploadimage();
      }
  }

  Future uploadimage() async {
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('chats/${widget.chatRoomId}/${Path.basename(_image.path)}');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        _uploadedimageurl = fileURL;
      });
    });
    Map<String, dynamic> chatMessageMap = {
      "sendBy": Constants.myName,
      "message": _uploadedimageurl,
      'time': DateTime
          .now()
          .millisecondsSinceEpoch,
    };

    DatabaseMethods().addMessage(widget.chatRoomId, chatMessageMap);


  }

  openfileexplorer () async {
    try{
      _path = await FilePicker.getFilePath(type: _picktype);
      uploadToFirebase();
    } on PlatformException catch (e) {
      print('Unsupported Operation '+e.toString());
    }
    if(!mounted) {
      return;
    }
  }

  uploadToFirebase() {
    String fileName = _path.split('/').last;
    String filePath = _path;
    upload(fileName, filePath);
  }

  upload(fileName, filePath) {
    _extension = fileName.toString().split('.').last;
    StorageReference storageReference = FirebaseStorage.instance.ref().child('files/${widget.chatRoomId}/$fileName');
    final StorageUploadTask uploadTask =
        storageReference.putFile(File(filePath),
        StorageMetadata(
          contentType: '$_picktype/$_extension',
        ));
    storageReference.getDownloadURL().then((fileURI){
      setState(() {
        filelocation = fileURI;
      });
    });
    print(filelocation);
    Map<String, dynamic> chatMessageMap = {
      "sendBy": Constants.myName,
      "message": filelocation,
      'time': DateTime
          .now()
          .millisecondsSinceEpoch,
    };

    DatabaseMethods().addMessage(widget.chatRoomId, chatMessageMap);
  }

  void Decrypt() async{
    try{
      //here pass encrypted string and the key to decrypt it
      decryptedS = await cryptor.decrypt(encryptedS, key);
    }on MacMismatchException{
    }
  }

  addMessage() async {
    cryptor = PlatformStringCryptor();
    final salt = await cryptor.generateSalt();
    password = messageEditingController.text;
    key = await cryptor.generateKeyFromPassword(password, salt);
    // here pass the password entered by user and the key
    encryptedS = await cryptor.encrypt(password, key);

    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "sendBy": Constants.myName,
        "message": messageEditingController.text,
        'time': DateTime
            .now()
            .millisecondsSinceEpoch,
      };

      DatabaseMethods().addMessage(widget.chatRoomId, chatMessageMap);

      setState((){
        messageEditingController.text = "";
      });
    }
    Decrypt();
  }

  @override
  void initState() {
    DatabaseMethods().getChats(widget.chatRoomId).then((val) {
      setState(() {
        chats = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
        title: Text(widget.chatRoomId),
        leading: Image.asset(
          "assets/images/logo.png",
          height: 40,
        ),
        elevation: 0.0,
        centerTitle: false,
      ),
      body: Container(
        child: Stack(
          children: [
            Container(
            child: chatMessages(),
            ),
            Container(alignment: Alignment.bottomCenter,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                color: Color(0x54FFFFFF),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        openfileexplorer();
                      },
                      child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    const Color(0x36FFFFFF),
                                    const Color(0x0FFFFFFF)
                                  ],
                                  begin: FractionalOffset.topLeft,
                                  end: FractionalOffset.bottomRight
                              ),
                              borderRadius: BorderRadius.circular(40)
                          ),
                          padding: EdgeInsets.all(6),
                          child: Image.asset("assets/images/addfile.png",
                            height: 50, width: 50,)),
                    ),
                    new GestureDetector(
                      onTap: () {
                        getimage();
                      },
                      child: new Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    const Color(0x36FFFFFF),
                                    const Color(0x0FFFFFFF)
                                  ],
                                  begin: FractionalOffset.topLeft,
                                  end: FractionalOffset.bottomRight
                              ),
                              borderRadius: BorderRadius.circular(40)
                          ),
                          padding: EdgeInsets.all(6),
                          child: new Image.asset("assets/images/addimage.png",
                            height: 50, width: 50,)),
                    ),
                    Expanded(
                        child: TextField(
                          controller: messageEditingController,
                          style: simpleTextStyle(),
                          decoration: InputDecoration(
                              hintText: "Message ...",
                              hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                              border: InputBorder.none
                          ),
                        )),
                    SizedBox(width: 16,),
                    new GestureDetector(
                      onTap: () {
                        addMessage();
                      },
                      child: new Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    const Color(0x36FFFFFF),
                                    const Color(0x0FFFFFFF)
                                  ],
                                  begin: FractionalOffset.topLeft,
                                  end: FractionalOffset.bottomRight
                              ),
                              borderRadius: BorderRadius.circular(40)
                          ),
                          padding: EdgeInsets.all(6),
                          child: new Image.asset("assets/images/send.png",
                            height: 50, width: 50,)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;
  MessageTile({@required this.message, @required this.sendByMe});

  @override
  Widget build(BuildContext context) {
    if (message == null)
    {
      return Container();
    }
    else if(message.startsWith('https://firebasestorage.googleapis.com/v0/b/flutterchatapp-77c15.appspot.com/o/files'))
    {
      return Container(
        padding: EdgeInsets.only(
            top: 8,
            bottom: 8,
            left: sendByMe ? 0 : 24,
            right: sendByMe ? 24 : 0),
        alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: sendByMe
              ? EdgeInsets.only(left: 30)
              : EdgeInsets.only(right: 30),
          padding: EdgeInsets.only(
              top: 17, bottom: 17, left: 20, right: 20),
          decoration: BoxDecoration(
              borderRadius: sendByMe ? BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomLeft: Radius.circular(23)
              ) :
              BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomRight: Radius.circular(23)),
              gradient: LinearGradient(
                colors: sendByMe ? [
                  const Color(0xff007EF4),
                  const Color(0xff2A75BC)
                ]
                    : [
                  const Color(0xff007EF4),
                  const Color(0xff2A75BC)
                ],
              )
          ),
          child: InkWell(
            child: Text(message,
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'OverpassRegular',
                    fontWeight: FontWeight.w300)),
            onTap: () => launch(message),
        ),
        ),
      );
    }
    else if(message.startsWith('https://firebasestorage.googleapis.com/v0/b/flutterchatapp-77c15.appspot.com/o/chats'))
    {
      return Container(
        padding: EdgeInsets.only(
            top: 8,
            bottom: 8,
            left: sendByMe ? 0 : 0,
            right: sendByMe ? 0 : 0),
        alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          child: Image.network(message,
          width: 200,
          height: 200),
        ),
      );
    }
    else
    {
      return Container(
        padding: EdgeInsets.only(
            top: 8,
            bottom: 8,
            left: sendByMe ? 0 : 24,
            right: sendByMe ? 24 : 0),
        alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: sendByMe
              ? EdgeInsets.only(left: 30)
              : EdgeInsets.only(right: 30),
          padding: EdgeInsets.only(
              top: 17, bottom: 17, left: 20, right: 20),
          decoration: BoxDecoration(
              borderRadius: sendByMe ? BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomLeft: Radius.circular(23)
              ) :
              BorderRadius.only(
          topLeft: Radius.circular(23),
            topRight: Radius.circular(23),
            bottomRight: Radius.circular(23)),
              gradient: LinearGradient(
                colors: sendByMe ? [
                  const Color(0xff007EF4),
                  const Color(0xff2A75BC)
                ]
                    : [
                  const Color(0xff007EF4),
                  const Color(0xff2A75BC)
                ],
              )
          ),
          child: Text(message,
              textAlign: TextAlign.start,
              style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'OverpassRegular',
              fontWeight: FontWeight.w300)),
        ),
      );
    }
  }
}