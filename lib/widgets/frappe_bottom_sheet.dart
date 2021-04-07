import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_palette.dart';

class FrappeBottomSheet extends StatelessWidget {
  final Widget body;

  final String title;
  final Widget trailing;
  final String leadingText;
  final Function leadingOnPressed;
  final Function onActionButtonPress;
  final Widget bottomBar;
  final bool showLeading;

  const FrappeBottomSheet({
    Key key,
    this.body,
    @required this.title,
    this.trailing,
    this.leadingOnPressed,
    this.leadingText,
    this.bottomBar,
    this.onActionButtonPress,
    this.showLeading = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomBar,
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFF737373),
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            showLeading
                ? FlatButton(
                    child: Text(
                      leadingText ?? 'Cancel',
                      style: TextStyle(
                        fontSize: 13,
                        color: FrappePalette.blue[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    padding: EdgeInsets.zero,
                    minWidth: 70,
                    onPressed: leadingOnPressed ??
                        () {
                          Navigator.of(context).pop();
                        },
                  )
                : FlatButton(
                    padding: EdgeInsets.zero,
                    child: Container(),
                    onPressed: null,
                  ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: FrappePalette.grey[900],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FlatButton(
              padding: EdgeInsets.zero,
              minWidth: 65,
              child: trailing,
              onPressed: onActionButtonPress,
            )
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: 18,
        ),
        child: body,
      ),
    );
  }
}