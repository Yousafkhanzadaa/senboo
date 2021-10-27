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
    '0xFF9B2335',
    '0xFFFF6F61',
    '0xFF4885ed',
    '0xFF35423c',
    '0xFFEC9787',
    '0xFF9932CC',
    '0xFFD65076',
    '0xFF45B8AC',
    '0xFF2d2f4e',
    '0xFF2C2C2C', // pink
    '0xFF000100',
    '0xFF3e282d',
    '0xFF4b5862',
    '0xFF2E5090',
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
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      ),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).primaryColor.withOpacity(0.40),
          blurRadius: 3,
          offset: Offset(0, 0),
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
