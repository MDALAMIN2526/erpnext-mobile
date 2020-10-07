import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../screens/custom_persistent_bottom_nav_bar.dart';

import '../config/palette.dart';

import '../widgets/frappe_button.dart';

import '../utils/frappe_alert.dart';
import '../utils/cache_helper.dart';
import '../utils/config_helper.dart';
import '../utils/backend_service.dart';
import '../utils/enums.dart';
import '../utils/helpers.dart';
import '../utils/http.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  bool _hidePassword = true;
  var serverURL;
  var savedUsr;
  var savedPwd;

  @override
  void initState() {
    super.initState();
    serverURL = ConfigHelper().baseUrl;
    savedUsr = CacheHelper.getCache('usr')["data"];
    savedPwd = CacheHelper.getCache('pwd')["data"];
  }

  _authenticate(data) async {
    await setBaseUrl(data["serverURL"]);

    var response2 =
        await BackendService.login(data["usr"].trimRight(), data["pwd"]);

    if (response2.statusCode == 200) {
      ConfigHelper.set('isLoggedIn', true);

      FrappeAlert.successAlert(title: 'Success', context: context);

      var userId =
          response2.headers.map["set-cookie"][3].split(';')[0].split('=')[1];
      ConfigHelper.set('userId', userId);
      ConfigHelper.set('user', response2.data["full_name"]);
      CacheHelper.putCache(
        'usr',
        data["usr"].trimRight(),
      );
      CacheHelper.putCache(
        'pwd',
        data["pwd"],
      );

      await cacheAllUsers();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) {
            return CustomPersistentBottomNavBar();
          },
        ),
      );
    } else {
      ConfigHelper.set('isLoggedIn', false);

      FrappeAlert.errorAlert(title: 'Login Failed', context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  FormBuilder(
                    key: _fbKey,
                    child: Column(
                      children: <Widget>[
                        Image(
                          image: AssetImage('assets/frappe_icon.jpg'),
                          width: 60,
                          height: 60,
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Text(
                          'Login to Frappe',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        buildDecoratedWidget(
                          FormBuilderTextField(
                            attribute: 'serverURL',
                            initialValue: serverURL,
                            validators: [
                              FormBuilderValidators.required(),
                              FormBuilderValidators.url()
                            ],
                            decoration: Palette.formFieldDecoration(
                              true,
                              "Server URL",
                            ),
                          ),
                          true,
                          "Server URL",
                        ),
                        buildDecoratedWidget(
                            FormBuilderTextField(
                              attribute: 'usr',
                              initialValue: savedUsr,
                              validators: [
                                FormBuilderValidators.required(),
                              ],
                              decoration: Palette.formFieldDecoration(
                                true,
                                "Email Address",
                              ),
                            ),
                            true,
                            "Email Address"),
                        buildDecoratedWidget(
                            FormBuilderTextField(
                              maxLines: 1,
                              attribute: 'pwd',
                              initialValue: savedPwd,
                              validators: [
                                FormBuilderValidators.required(),
                              ],
                              obscureText: _hidePassword,
                              decoration: Palette.formFieldDecoration(
                                true,
                                "Password",
                                FlatButton(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    child:
                                        Text(_hidePassword ? "Show" : "Hide"),
                                    onPressed: () {
                                      setState(() {
                                        _hidePassword = !_hidePassword;
                                      });
                                    }),
                              ),
                            ),
                            true,
                            "Password"),
                        FrappeFlatButton(
                          title: 'Login',
                          fullWidth: true,
                          height: 46,
                          buttonType: ButtonType.primary,
                          onPressed: () {
                            if (_fbKey.currentState.saveAndValidate()) {
                              var formValue = _fbKey.currentState.value;
                              _authenticate(formValue);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
