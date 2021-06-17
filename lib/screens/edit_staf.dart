import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:trkar_vendor/model/roles_model.dart';
import 'package:trkar_vendor/model/user_model.dart';
import 'package:trkar_vendor/utils/Provider/provider.dart';
import 'package:trkar_vendor/utils/local/LanguageTranslated.dart';
import 'package:trkar_vendor/utils/screen_size.dart';
import 'package:trkar_vendor/utils/service/API.dart';
import 'package:trkar_vendor/widget/ResultOverlay.dart';
import 'package:trkar_vendor/widget/commons/custom_textfield.dart';
import 'package:trkar_vendor/widget/commons/drop_down_menu/find_dropdown.dart';

class EditStaff extends StatefulWidget {
  EditStaff(this.user);
  User user ;
  @override
  _EditStaffState createState() => _EditStaffState();

}

class _EditStaffState extends State<EditStaff> {
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  List<Role> roles;
  bool passwordVisible = false;
  @override
  void initState() {
    getRoles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Provider.of<Provider_control>(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/staff.svg',
              color: Colors.white,
            ),
            SizedBox(
              width: 10,
            ),
            Text(getTransrlate(context, 'staff')),
          ],
        ),
        backgroundColor: themeColor.getColor(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(25),
            child: Form(
              key: _formKey,
              child: Container(
                height: ScreenUtil.getHeight(context) / 1.5,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyTextFormField(
                        intialLabel: widget.user.name ?? ' ',
                        Keyboard_Type: TextInputType.name,
                        labelText: getTransrlate(context, 'name'),
                        hintText: getTransrlate(context, 'name'),
                        isPhone: true,
                        enabled: true,
                        validator: (String value) {
                          if (value.isEmpty) {
                            return getTransrlate(context, 'name');
                          }
                          _formKey.currentState.save();
                          return null;
                        },
                        onSaved: (String value) {
                          widget.user.name = value;
                        },
                      ),
                      MyTextFormField(
                        intialLabel: widget.user.email ?? ' ',
                        Keyboard_Type: TextInputType.emailAddress,
                        labelText: getTransrlate(context, 'Email'),
                        hintText: getTransrlate(context, 'Email'),
                        isPhone: true,
                        enabled: true,
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
                          widget.user.email = value;
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text("الدور الوظيفي",style: TextStyle(color: Colors.black,fontSize: 16),),

                      SizedBox(
                        height: 10,
                      ),
                      roles == null
                          ? Container()
                          : DropdownSearch<Role>(
                              showSearchBox: false,
                              showClearButton: false,
                              selectedItem:widget.user.roles ,
                              label: "   ",
                              validator: (Role item) {
                                if (item == null) {
                                  return "Required field";
                                } else
                                  return null;
                              },
                              items: roles,
                              //  onFind: (String filter) => getData(filter),
                              itemAsString: (Role u) => u.title,
                              onChanged: (Role data) =>
                              widget.user.rolesid = data.id),
                      SizedBox(
                        height: 10,
                      ),
                      MyTextFormField(
                        intialLabel: '',
                        Keyboard_Type: TextInputType.visiblePassword,
                        labelText: getTransrlate(context, 'password'),
                        hintText: getTransrlate(context, 'password'),
                        suffixIcon: IconButton(
                          icon: Icon(
                            // Based on passwordVisible state choose the icon
                            passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.black26,
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
                          if (value.isEmpty) {
                            return getTransrlate(context, 'password');
                          } else if (!value.contains(new RegExp(
                              r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$'))) {
                            return "one Uppercase, One Lowercase, One Number and one Special Character";
                          }
                          _formKey.currentState.save();
                          return null;
                        },
                        onSaved: (String value) {
                          widget.user.password = value;
                        },
                      ),
                      MyTextFormField(
                        intialLabel: '',
                        Keyboard_Type: TextInputType.emailAddress,
                        labelText:
                            getTransrlate(context, 'ConfirmPassword'),
                        hintText: getTransrlate(context, 'ConfirmPassword'),
                        suffixIcon: IconButton(
                          icon: Icon(
                            // Based on passwordVisible state choose the icon
                            passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.black26,
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
                          if (value != widget.user.password) {
                            return getTransrlate(context, 'Passwordmatch');
                          }
                          _formKey.currentState.save();
                          return null;
                        },
                        onSaved: (String value) {
                          widget.user.passwordConfirmation = value;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12.withOpacity(0.5),
                      offset: Offset(0, 0),
                      blurRadius: 1)
                ],
              ),
              child: Container(
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FlatButton(
                        minWidth: ScreenUtil.getWidth(context) / 2.5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(1),
                            side: BorderSide(
                                color: Colors.orange, width: 1)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            getTransrlate(context, 'save'),
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            setState(() => loading = true);
                            API(context).Put("users/${widget.user.id}", {
                              "name": widget.user.name,
                              "email": widget.user.email,
                              "password": widget.user.password,
                              "roles": widget.user.rolesid
                            }).then((value) {
                              if (value != null) {
                                setState(() {
                                  loading = false;
                                });
                                print(value.containsKey('errors'));
                                if (value.containsKey('errors')) {
                                  showDialog(
                                    context: context,
                                    builder: (_) => ResultOverlay(
                                      value['errors'].toString(),
                                    ),
                                  );
                                } else {
                                  Navigator.pop(context);
                                  showDialog(
                                    context: context,
                                    builder: (_) => ResultOverlay(
                                      'Done',
                                    ),
                                  );
                                }
                              }
                            });
                          }
                        }),
                    FlatButton(
                        minWidth: ScreenUtil.getWidth(context) / 2.5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(1),
                            side:
                            BorderSide(color: Colors.grey, width: 1)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            getTransrlate(context, 'close'),
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                        }),
                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  Future<void> getRoles() async {
    API(context).get('roleslist').then((value) {
      if (value != null) {
        setState(() {
          roles = Roles_model.fromJson(value).data;
        });
      }
    });
  }
}