import 'package:flutter/material.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  _SupportScreenState createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: Text(
          "How can you support Senboo?",
          style: Theme.of(context).textTheme.headline2!.copyWith(fontSize: 18),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.40),
              blurRadius: 5,
              offset: Offset(0, 0),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: 8,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Flexible(flex: 1, child: Icon(Icons.arrow_right)),
                        Flexible(
                          flex: 9,
                          child: Text(
                            'When creating a repeat grid in ADOBE XD,  what you are required to say. XD,  what you are required to say.',
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            _donateButton(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _donateButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(Theme.of(context).primaryColor),
          shadowColor:
              MaterialStateProperty.all(Theme.of(context).primaryColor),
          padding: MaterialStateProperty.all(
              EdgeInsets.symmetric(vertical: 15, horizontal: 35)),
          shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)))),
      child: Text(
        "Donate".toUpperCase(),
        style: Theme.of(context).textTheme.subtitle2,
      ),
    );
  }
}
