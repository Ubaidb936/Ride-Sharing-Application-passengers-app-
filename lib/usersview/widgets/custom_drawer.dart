import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:brand_colors/brand_colors.dart';
import 'package:sumostand/constants.dart';
import 'package:sumostand/divider.dart';

class CustomDrawer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 160,
            child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Image.asset(
                      "assets/images/user_icon.png",
                      height: 50,
                      width: 50,
                    ),
                    SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ubaid ul Majied',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'View profile',
                          style: TextStyle(
                              color: BrandColors.appleLightGray),
                        )
                      ],
                    )
                  ],
                )),
          ),
          DividerWidget(),
          ListTile(
            leading: Icon(OMIcons.cardGiftcard),
            title: Text('Free Rides', style: KDrawerItemStyle),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            leading: Icon(OMIcons.payment),
            title: Text('Payments', style: KDrawerItemStyle),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            leading: Icon(OMIcons.cardGiftcard),
            title: Text('Free Rides', style: KDrawerItemStyle),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            leading: Icon(OMIcons.history),
            title: Text('Ride History', style: KDrawerItemStyle),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            leading: Icon(OMIcons.contactSupport),
            title: Text('Support', style: KDrawerItemStyle),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
        ],
      ),
    );
  }
}
