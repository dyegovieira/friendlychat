import 'package:flutter/material.dart';
import 'package:friendlychat/component/gradient_background_component.dart';


class UserPage extends StatelessWidget {


  static final userPageBottomNavigationBarItem = new BottomNavigationBarItem(
    icon: new Icon(Icons.person),
    title: new Text('User'),
  );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      //appBar: new AppBar(
      //  title: new Text('Counter')
      //),
      body: _buildBody(context),
    );
  }


  Widget _buildBody(BuildContext context) {
    return new GradientBackgroundComponent (
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: new CircleAvatar(
              //backgroundImage: new NetworkImage(store.state.googleSignIn.currentUser.photoUrl),
            ),
          ),
          //new Text(store.state.googleSignIn.currentUser.displayName),
          new FlatButton(
            onPressed: () async {
              //await store.state.auth.signOut();
            },
            child: new Text('SIGN OUT'),
          ),
        ],
      ),
    );
  }

}