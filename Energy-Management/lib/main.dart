import 'package:energy_management/screens/homepage.dart';
import 'package:energy_management/providers/energy.dart';
import 'package:energy_management/theme/app_theme.dart';
import 'package:energy_management/utils/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  Provider.debugCheckInvalidValueType = null;
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => EnergyManagementProvider()),
  ], child: EnergyManagement()));
}

class EnergyManagement extends StatelessWidget {
  const EnergyManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EnergyManagementProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode:
              themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          title: 'Energy Management',
          home: HomePage(),
        );
      },
    );
  }
}
