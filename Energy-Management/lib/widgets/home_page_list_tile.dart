import 'package:flutter/material.dart';

class HomePageListTile extends StatelessWidget {
  final Icon preceedingIcon;
  final String title;
  final String subTitle;
  final String individualPowerConsumption;
  const HomePageListTile(
      {super.key,
      required this.individualPowerConsumption,
      required this.preceedingIcon,
      required this.subTitle,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Theme.of(context).secondaryHeaderColor,
      leading: CircleAvatar(
        child: preceedingIcon,
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 20),
      ),
      subtitle: Text(
        subTitle,
        style: TextStyle(fontSize: 20),
      ),
      trailing: Text(
        individualPowerConsumption,
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}
