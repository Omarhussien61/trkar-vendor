import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trkar_vendor/screens/home.dart';
import 'package:trkar_vendor/screens/lost_password.dart';
import 'package:trkar_vendor/utils/Provider/provider.dart';
import 'package:trkar_vendor/utils/Provider/provider_data.dart';
import 'package:trkar_vendor/utils/local/LanguageTranslated.dart';
import 'package:trkar_vendor/utils/navigator.dart';
import 'package:trkar_vendor/utils/screen_size.dart';
import 'package:trkar_vendor/utils/service/API.dart';
import 'package:trkar_vendor/widget/ResultOverlay.dart';
import 'package:trkar_vendor/widget/commons/custom_textfield.dart';
import 'package:trkar_vendor/widget/login/login_form_model.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  Model_login model = Model_login();
  bool passwordVisible = false;
  String CountryNo = '';
  bool _isLoading=false;
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final themeColor = Provider.of<Provider_control>(context);
    return Container(
      padding: EdgeInsets.only(top: 24, right: 42, left: 42),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            MyTextFormField(
              textStyle: TextStyle(color: Colors.white, fontSize: 16),
              intialLabel: '',
              Keyboard_Type: TextInputType.emailAddress,
              labelText: getTransrlate(context, 'mail'),
              hintText: getTransrlate(context, 'mail'),
              isPhone: true,
              validator: (String value) {
                if (value.isEmpty) {
                  return getTransrlate(context, 'mail');
                } else if (!RegExp(
                        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                    .hasMatch(value)) {
                  return getTransrlate(context, 'invalidemail');
                }
                _formKey.currentState.save();
                return null;
              },
              onSaved: (String value) {
                model.email = value;
              },
            ),
            MyTextFormField(
              textStyle: TextStyle(color: Colors.white, fontSize: 16),
              intialLabel: '',
              labelText: getTransrlate(context, 'password'),
              hintText: getTransrlate(context, 'password'),
              suffixIcon: IconButton(
                icon: Icon(
                  // Based on passwordVisible state choose the icon
                  passwordVisible ? Icons.visibility : Icons.visibility_off,
                  color: themeColor.getColor(),
                ),
                onPressed: () {
                  // Update the state i.e. toogle the state of passwordVisible variable
                  setState(() {
                    passwordVisible = !passwordVisible;
                  });
                },
              ),
              isPassword: passwordVisible,
              validator: (String value) {
                if (value.length < 7) {
                  return getTransrlate(context, 'password' + '< 7');
                }
                _formKey.currentState.save();
                return null;
              },
              onSaved: (String value) {
                model.password = value;
              },
            ),
            Container(
              height: 50,
              width: ScreenUtil.getWidth(context),
              margin: EdgeInsets.only(top: 48, bottom: 12),
              child: _isLoading?FlatButton(
                minWidth: ScreenUtil.getWidth(context) / 2.5,
                color: Colors.orange,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:Container(
                    height: 30,
                    child: Center(
                        child: CircularProgressIndicator(
                          valueColor:
                          AlwaysStoppedAnimation<Color>( Colors.white),
                        )),
                  ),
                ),
                onPressed: () async {
                },
              ):FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(1.0),
                ),
                color: Colors.orange,
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    setState(() => _isLoading = true);
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    API(context).post('login', {
                      'email': model.email,
                      'password': model.password,
                    }).then((value) {
                      setState(() => _isLoading = false);

                      if (value != null) {
                        if (value['status_code'] == 200) {
                          var user = value['data'];
                          prefs.setString("user_email", user['email']);
                          prefs.setString("user_name", user['name']);
                          prefs.setString("roles", user['roles'][0]['title']);
                          prefs.setString("token", user['token']);
                          prefs.setInt("user_id", user['id']);
                          themeColor.setLogin(true);
                          // Provider.of<Provider_Data>(context,listen: false).getAllstaff(context);
                          // Provider.of<Provider_Data>(context,listen: false).getAllStore(context);
                          // Provider.of<Provider_Data>(context,listen: false).getProducts(context);
                          Nav.routeReplacement(context, Home());

                      } else {
                        showDialog(
                            context: context,
                            builder: (_) => ResultOverlay(
                                "${value['message'] ?? value['errors']}"));
                      }}
                    });
                  }
                },
                child: Text(
                  getTransrlate(context, 'login'),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            Container(
              height: 50,
              width: ScreenUtil.getWidth(context),
              margin: EdgeInsets.only(top: 12, bottom: 12),
              child: FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(1.0),
                    side: BorderSide(color: Colors.orange)),
                color: Colors.white,
                onPressed: () async {
                  Nav.route(context, LostPassword());
                },
                child: Text(
                  getTransrlate(context, 'LostPassword'),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
