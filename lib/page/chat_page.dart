import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:friendlychat/component/chat_message_component.dart';
import 'package:friendlychat/component/default_app_bar.dart';
import 'package:flutter/cupertino.dart';


import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math';
import 'dart:io';
import 'package:friendlychat/entity/user_entity.dart';
import 'package:friendlychat/component/gradient_background_component.dart';


final analytics = new FirebaseAnalytics();
final auth = FirebaseAuth.instance;


final reference = FirebaseDatabase.instance.reference().child('messages');


typedef ChatPageDidLoginAction();


class ChatPage extends StatefulWidget {

  final UserEntity user;

  final ChatPageDidLoginAction loginAction;

  ChatPage({
    Key key,
    this.user,

    @required this.loginAction,
  }) :
        super(key: key);


  @override
  State createState() => new ChatPageState();

  static final bottomNavigationBarItem = new BottomNavigationBarItem(
    icon: new Icon(Icons.chat_bubble),
    title: new Text('Chat'),
  );

}

class ChatPageState extends State<ChatPage> {


  final TextEditingController _textController = new TextEditingController();

  int newMessagesCount = 0;
  bool _isComposing = false;
  UserEntity user;



  @override
  Widget build(BuildContext context) {

    reference.onChildAdded.listen((event) {
      setState((){
        newMessagesCount += 1;
      });
    });

    if (widget.user == null) {
      return new Scaffold(
          body: _buildNeedLoginBody(context),
      );
    }

    return new Scaffold(
        appBar: new DefaultAppBarComponent(
          title: new Text("Friendlychat"),
        ),
        body: _buildBody(context),
    );
  }


  Widget _buildNeedLoginBody(BuildContext context) {
    return new GradientBackgroundComponent (
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new FlatButton(
            onPressed: () => widget.loginAction(),
            child: new Text('SIGN/LOG IN'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    user = widget.user;

    return new Container(
        child: new Column(
          children: <Widget>[
            new Flexible(
              child: new FirebaseAnimatedList(
                query: reference,
                sort: (a, b) => b.key.compareTo(a.key),
                padding: new EdgeInsets.all(8.0),
                reverse: true,
                itemBuilder: (_, DataSnapshot snapshot, Animation<double> animation, int index) {
                  return new ChatMessageComponent(
                      snapshot: snapshot,
                      animation: animation
                  );
                },
              ),
            ),
            new Divider(
                height: 1.0
            ),
            new Container(
              decoration: new BoxDecoration(
                  color: Theme.of(context).cardColor
              ),
              child: _buildTextComposer(),
            ),
          ],
        ),
        decoration: Theme.of(context).platform == TargetPlatform.iOS
            ? new BoxDecoration(
          border: new Border(
            top: new BorderSide(
                color: Colors.grey[200]
            ),
          ),
        )
            : null
    );
  }

  Widget _buildTextComposer() {
    return new Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: new Row(
        children: <Widget>[
          new Container(
            margin: new EdgeInsets.symmetric(horizontal: 4.0),
            child: new IconButton(
              icon: new Icon(Icons.photo_camera),
              color: Theme.of(context).accentColor,
              onPressed: () async {
                File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
                int random = new Random().nextInt(100000);
                StorageReference ref = FirebaseStorage.instance.ref().child("image_$random.jpg");
                StorageUploadTask uploadTask = ref.put(imageFile);
                Uri downloadUrl = (await uploadTask.future).downloadUrl;
                _sendMessage(imageUrl: downloadUrl.toString());
              },
            ),
          ),
          new Flexible(
            child: new TextField(
              controller: _textController,
              onChanged: (String text) {
                setState(() {
                  _isComposing = text.length > 0;
                });
              },
              onSubmitted: _handleSubmitted,
              decoration: new InputDecoration.collapsed(
                  hintText: "Send a message"
              ),
            ),
          ),
          new Container(
              margin: new EdgeInsets.symmetric(horizontal: 4.0),
              child: Theme.of(context).platform == TargetPlatform.iOS
                  ? (
                  new CupertinoButton(
                    child: new Text("Send"),
                    onPressed: _isComposing
                        ? () =>  _handleSubmitted(_textController.text)
                        : null,
                  )
              )
                  : (
                  new IconButton(
                    icon: new Icon(
                      Icons.send,
                    ),
                    onPressed: _isComposing
                        ? () =>  _handleSubmitted(_textController.text)
                        : null,
                  )
              )
          ),
        ],
      ),
    );
  }


  Future<Null> _handleSubmitted(String text) async {
    if (text.length == 0) {
      return null;
    }

    debugPrint(text);
    _textController.clear();

    setState(() {
      _isComposing = false;
    });

    _sendMessage(text: text);
  }

  void _sendMessage({ String text, String imageUrl}) {
    reference.push().set({
      'text': text,
      'imageUrl': imageUrl,
      'senderName': user.displayName,
      'senderPhotoUrl': user.photoUrl,
    });

    analytics.logEvent(name: 'send_message');
  }

}
