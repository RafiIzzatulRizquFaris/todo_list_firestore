import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('todo').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.blue,
              ),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(snapshot.data.documents[index]['task']),
                subtitle: Text(snapshot.data.documents[index]['description']),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InsertScreen(),
            )),
      ),
    );
  }
}

class InsertScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return InsertScreenState();
  }
}

class InsertScreenState extends State<InsertScreen> {
  final insertFormKey = GlobalKey<FormState>();
  TextEditingController titleTaskController = TextEditingController();
  TextEditingController descTaskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Task"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          autovalidateMode: AutovalidateMode.always,
          key: insertFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Task Name",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: 8,
              ),
              TextFormField(
                validator: (value) {
                  if (value.isEmpty || value.trim().length == 0) {
                    return "Task name cannot be empty";
                  }
                  return null;
                },
                controller: titleTaskController,
                style: TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Insert Task Name....",
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                "Task Description",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: 8,
              ),
              TextFormField(
                controller: descTaskController,
                validator: (value) {
                  if (value.isEmpty || value.trim().length == 0) {
                    return "Task description cannot be empty";
                  }
                  return null;
                },
                style: TextStyle(
                  color: Colors.black,
                ),
                maxLines: 4,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Insert Task Description....",
                ),
              ),
              SizedBox(
                height: 24,
              ),
              FlatButton(
                minWidth: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(10),
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Submit",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                onPressed: () async {
                  if (insertFormKey.currentState.validate()){
                    progressDialog(context).show();
                    DocumentReference result = await Firestore.instance.collection('todo').add(<String, dynamic>{
                      'task' : titleTaskController.text.toString(),
                      'description' : descTaskController.text.toString(),
                    });
                    if (result.documentID != null){
                      progressDialog(context).hide();
                      successAlert("Success", "Success Insert Task", context);
                    } else {
                      progressDialog(context).hide();
                      errorAlert("Failed", "Failed to Insert Task", context);
                    }
                  } else {
                    errorAlert("Failed", "Please fill all the fields", context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  ProgressDialog progressDialog(BuildContext ctx) {
    ProgressDialog loadingDialog = ProgressDialog(
      ctx,
      type: ProgressDialogType.Normal,
      isDismissible: false,
    );
    loadingDialog.style(
      message: "Loading",
      progressWidget: Container(
        padding: EdgeInsets.all(8.0),
        child: CircularProgressIndicator(
          backgroundColor: Colors.blue,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      messageTextStyle: TextStyle(
        color: Colors.blue,
      ),
    );
    return loadingDialog;
  }

  successAlert(String title, String subtitle, BuildContext ctx) {
    return Alert(
      context: ctx,
      title: title,
      desc: subtitle,
      type: AlertType.success,
      buttons: [
        DialogButton(
          onPressed: () {
            Navigator.pop(ctx);
          },
          child: Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ],
      style: AlertStyle(
        animationType: AnimationType.grow,
        isCloseButton: false,
        isOverlayTapDismiss: false,
        descStyle: TextStyle(fontWeight: FontWeight.bold),
        descTextAlign: TextAlign.center,
        animationDuration: Duration(milliseconds: 400),
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: Colors.grey,
          ),
        ),
        titleStyle: TextStyle(
          color: Colors.blue,
        ),
        alertAlignment: Alignment.center,
      ),
    ).show();
  }

  errorAlert(String title, String subtitle, BuildContext ctx) {
    return Alert(
      context: ctx,
      title: title,
      desc: subtitle,
      type: AlertType.warning,
      buttons: [
        DialogButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ],
      style: AlertStyle(
        animationType: AnimationType.grow,
        isCloseButton: false,
        isOverlayTapDismiss: false,
        descStyle: TextStyle(fontWeight: FontWeight.bold),
        descTextAlign: TextAlign.center,
        animationDuration: Duration(milliseconds: 400),
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: Colors.grey,
          ),
        ),
        titleStyle: TextStyle(
          color: Colors.red,
        ),
        alertAlignment: Alignment.center,
      ),
    ).show();
  }

}
