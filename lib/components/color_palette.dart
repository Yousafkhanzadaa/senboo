import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senboo/providers/color_provider.dart';

class ColorPalette extends StatefulWidget {
  const ColorPalette({Key? key}) : super(key: key);

  @override
  _ColorPaletteState createState() => _ColorPaletteState();
}

class _ColorPaletteState extends State<ColorPalette> {
  List<String> colorsList = [
    '0xFF939597',
    '0xFF72C89E',
    '0xFFFF6F61',
    '0xFF604C8D',
    '0xFF92B558',
    '0xFFB3CEE5',
    '0xFF955251',
    '0xFFB565A7',
    '0xFF009B77',
    '0xFFDD4124',
    '0xFFD65076',
    '0xFF45B8AC',
    '0xFFEFC050',
    '0xFF5B5EA6',
    '0xFF9B2335',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.50,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              itemCount: colorsList.length,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
              itemBuilder: (context, index) {
                return _colorContainer(colorsList[index]);
              },
            ),
          ),
          _paletteDoneButton(),
        ],
      ),
    );
  }

  // Card decoration goes here ---------------------------------------
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
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
    );
  }

  // Color container goes here ---------------------------------------------
  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Widget _colorContainer(String colorCode) {
    return Consumer<ColorProvider>(
      builder: (context, changer, child) {
        return GestureDetector(
          onTap: () {
            changer.setColor(colorCode);
            changer.loadColor();
          },
          child: Container(
            height: 30,
            width: 30,
            margin: EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color(int.parse(colorCode)),
            ),
          ),
        );
      },
    );
  }

  // Done button goes here -----------------------------------------------
  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  Widget _paletteDoneButton() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.80,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(Theme.of(context).primaryColor),
          shadowColor:
              MaterialStateProperty.all(Theme.of(context).primaryColor),
          padding: MaterialStateProperty.all(
              EdgeInsets.symmetric(vertical: 15, horizontal: 25)),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
          ),
        ),
        child: Text(
          "Done".toUpperCase(),
          style: Theme.of(context).textTheme.subtitle2,
        ),
      ),
    );
  }
}
