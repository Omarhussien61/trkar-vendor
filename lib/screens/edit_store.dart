import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_pin_picker/map_pin_picker.dart';
import 'package:provider/provider.dart';
import 'package:trkar_vendor/model/store_model.dart';
import 'package:trkar_vendor/utils/Provider/provider.dart';
import 'package:trkar_vendor/utils/local/LanguageTranslated.dart';
import 'package:trkar_vendor/utils/screen_size.dart';
import 'package:trkar_vendor/utils/service/API.dart';
import 'package:trkar_vendor/widget/ResultOverlay.dart';
import 'package:trkar_vendor/widget/commons/custom_textfield.dart';

class Edit_Store extends StatefulWidget {
  Store store;

  Edit_Store(this.store);

  @override
  _Edit_StoreState createState() => _Edit_StoreState();
}

class _Edit_StoreState extends State<Edit_Store> {
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  Completer<GoogleMapController> _controller = Completer();
  MapPickerController mapPickerController = MapPickerController();

  CameraPosition cameraPosition = CameraPosition(
    target: LatLng(31.2060916, 29.9187),
    zoom: 14.4746,
  );
  @override
  void initState() {

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
              'assets/icons/store.svg',
              color: Colors.white,
              height: 25,
              width: 25,
            ),
            SizedBox(
              width: 10,
            ),
            Text(getTransrlate(context, 'store')),
          ],
        ),
        backgroundColor: themeColor.getColor(),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyTextFormField(
                          intialLabel: widget.store.name ?? ' ',
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
                            widget.store.name = value;
                          },
                        ),
                        MyTextFormField(
                          intialLabel: widget.store.moderatorName ?? ' ',
                          Keyboard_Type: TextInputType.name,
                          labelText: getTransrlate(context, 'Moderator'),
                          hintText: getTransrlate(context, 'Moderator'),
                          isPhone: true,
                          enabled: true,
                          validator: (String value) {
                            if (value.isEmpty) {
                              return getTransrlate(context, 'Moderator');
                            }
                            _formKey.currentState.save();
                            return null;
                          },
                          onSaved: (String value) {
                            widget.store.moderatorName = value;
                          },
                        ),
                        MyTextFormField(
                          intialLabel: widget.store.moderatorPhone ?? ' ',
                          Keyboard_Type: TextInputType.phone,
                          labelText: getTransrlate(context, 'ModeratorPhone'),
                          hintText: getTransrlate(context, 'ModeratorPhone'),
                          isPhone: true,
                          enabled: true,
                          validator: (String value) {
                            if (value.length<=8) {
                              return getTransrlate(context, 'ModeratorPhone');
                            }
                            _formKey.currentState.save();
                            return null;
                          },
                          onSaved: (String value) {
                            widget.store.moderatorPhone = value;
                          },
                        ),
                        MyTextFormField(
                          intialLabel: widget.store.moderatorAltPhone ?? ' ',
                          Keyboard_Type: TextInputType.phone,
                          labelText: getTransrlate(context, 'ModeratorPhone'),
                          hintText: getTransrlate(context, 'ModeratorPhone'),
                          isPhone: true,
                          enabled: true,
                          validator: (String value) {
                            if (value.isEmpty) {
                              return getTransrlate(context, 'ModeratorPhone');
                            }
                            _formKey.currentState.save();
                            return null;
                          },
                          onSaved: (String value) {
                            widget.store.moderatorAltPhone = value;
                          },
                        ),
                        MyTextFormField(
                          intialLabel: widget.store.address ?? ' ',
                          Keyboard_Type: TextInputType.text,
                          labelText: getTransrlate(context, 'address'),
                          hintText: getTransrlate(context, 'address'),
                          enabled: true,
                          validator: (String value) {
                            if (value.isEmpty) {
                              return getTransrlate(context, 'address');
                            }
                            _formKey.currentState.save();
                            return null;
                          },
                          onSaved: (String value) {
                            widget.store.address = value;
                          },
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          height: ScreenUtil.getHeight(context) / 5,
                          child: MapPicker(
                            // pass icon widget
                            iconWidget: Icon(
                              Icons.location_pin,
                              size: 50,
                            ),
                            //add map picker controller
                            mapPickerController: mapPickerController,
                            child: GoogleMap(
                              zoomControlsEnabled: true,
                              // hide location button
                              myLocationButtonEnabled: true,
                              mapType: MapType.normal,
                              //  camera position
                              initialCameraPosition: cameraPosition,
                              onMapCreated: (GoogleMapController controller) {
                                _controller.complete(controller);
                              },
                              onCameraMoveStarted: () {
                                // notify map is moving
                                mapPickerController.mapMoving();
                              },
                              onCameraMove: (cameraPosition) {
                                this.cameraPosition = cameraPosition;
                              },
                              onCameraIdle: () async {
                                // notify map stopped moving
                                mapPickerController.mapFinishedMoving();
                                //get address name from camera position
                                widget.store.lat = cameraPosition.target.latitude.toString();
                                widget.store.long = cameraPosition.target.longitude.toString();
                                List<Address> addresses = await Geocoder.local
                                    .findAddressesFromCoordinates(Coordinates(
                                    cameraPosition.target.latitude,
                                    cameraPosition.target.longitude));
                                // update the ui with the address
                                widget.store.address =
                                '${addresses.first?.addressLine ?? ''}';
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 100,
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

                          API(context)
                              .post(
                              "update/stores/${widget.store.id}",
                              widget.store.toJson())
                              .then((value) {
                            setState(() {
                              loading = false;
                            });
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
                                  'تم تعديل المتجر بنجاح',
                                ),
                              );
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

        ],
      ),
    );
  }
}
