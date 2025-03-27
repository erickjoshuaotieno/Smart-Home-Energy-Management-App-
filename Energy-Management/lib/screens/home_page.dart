import 'package:energy_management/models/form_model.dart';
import 'package:energy_management/providers/energy.dart';
import 'package:energy_management/widgets/EnergyFormField.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'meter_reading_dialog.dart';


class EnergyHomePage extends StatefulWidget {
  const EnergyHomePage({super.key});

  @override
  State<EnergyHomePage> createState() => _EnergyHomePageState();
}

class _EnergyHomePageState extends State<EnergyHomePage> {
  String? selectedHostelValue;
  String? selectedGadgetValue;
  final TextEditingController kwhController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  DateTime? selectedDate;
  final _formKey = GlobalKey<FormState>();
  FormModel formModel = FormModel(
      id: '',
      applianceName: '',
      dateFilled: DateTime.now(),
      hostelName: '',
      kwh: 0.0);

  Future<void> _showDatePicker() async {
    await showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: CalendarDatePicker(
                initialDate: DateTime.now(),
                firstDate: DateTime(2025),
                lastDate: DateTime(2030),
                onDateChanged: (DateTime? selectedDate) {
                  if (selectedDate != null) {
                    setState(() {
                      selectedDate = selectedDate;
                      dateController.text =
                          "${selectedDate?.year}-${selectedDate?.day}-${selectedDate?.month}";
                    });

                    Navigator.pop(context);
                  }
                }),
          );
        });
  }

  _submitHandler() async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
      try {
        if (mounted) {
          Navigator.pop(context);
        }
        _formKey.currentState!.reset();
        await Provider.of<EnergyManagementProvider>(context, listen: false)
            .saveEnergyData(formModel);

        await Provider.of<EnergyManagementProvider>(context, listen: false)
            .getEnergyData();
        setState(() {});
      } catch (error) {
        if (mounted) {
          Navigator.pop(context);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save energy data.Are you online?.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } else {
      Navigator.pop(context);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Add Device Energy Usage'),
                  content: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                            hint: Text('Select Hostel To Insert Data'),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select hostel';
                              }
                              return null;
                            },
                            onSaved: (String? hostelName) {
                              if (hostelName != null) {
                                formModel = FormModel(
                                    id: DateTime.now().toString(),
                                    applianceName: formModel.applianceName,
                                    dateFilled: formModel.dateFilled,
                                    hostelName: hostelName,
                                    kwh: formModel.kwh);
                              }
                            },
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                )),
                            items: [
                              DropdownMenuItem(
                                value: 'HOSTEL A',
                                child: Row(
                                  spacing: 4,
                                  children: [
                                    Icon(
                                      Icons.home_work_outlined,
                                      color: theme.primaryColor,
                                    ),
                                    Text('HOSTEL A')
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                  value: 'HOSTEL B',
                                  child: Row(
                                    spacing: 4,
                                    children: [
                                      Icon(
                                        Icons.home_work_outlined,
                                        color: theme.primaryColor,
                                      ),
                                      Text('HOSTEL B')
                                    ],
                                  )),
                              DropdownMenuItem(
                                  value: 'HOSTEL C',
                                  child: Row(
                                    spacing: 4,
                                    children: [
                                      Icon(
                                        Icons.home_work_outlined,
                                        color: theme.primaryColor,
                                      ),
                                      Text('HOSTEL C')
                                    ],
                                  )),
                              DropdownMenuItem(
                                value: 'HOSTEL D',
                                child: Row(
                                  spacing: 4,
                                  children: [
                                    Icon(
                                      Icons.home_work_outlined,
                                      color: theme.primaryColor,
                                    ),
                                    Text('HOSTEL D')
                                  ],
                                ),
                              )
                            ],
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedHostelValue = newValue;
                                });
                              }
                            }),
                        SizedBox(
                          height: size.height * .02,
                        ),
                        DropdownButtonFormField<String>(
                            hint: Text('Select Appliance'),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select an appliance';
                              }
                              return null;
                            },
                            onSaved: (String? applianceName) {
                              if (applianceName != null) {
                                formModel = FormModel(
                                    id: DateTime.now().toString(),
                                    applianceName: applianceName,
                                    dateFilled: formModel.dateFilled,
                                    hostelName: formModel.hostelName,
                                    kwh: formModel.kwh);
                              }
                            },
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                )),
                            items: [
                              DropdownMenuItem(
                                value: 'Kettle',
                                child: Row(
                                  spacing: 4,
                                  children: [
                                    Icon(
                                      Icons.local_cafe,
                                      color: theme.primaryColor,
                                    ),
                                    Text('Kettle or immersion Heater')
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Laptop',
                                child: Row(
                                  spacing: 4,
                                  children: [
                                    Icon(
                                      Icons.laptop,
                                      color: theme.primaryColor,
                                    ),
                                    Text('Laptop (Dell, Hp, Lenovo)')
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Lighting',
                                child: Row(
                                  spacing: 4,
                                  children: [
                                    Icon(
                                      Icons.light,
                                      color: theme.primaryColor,
                                    ),
                                    Text('Lighting (Fluorescent Tubes)')
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Phone',
                                child: Row(
                                  spacing: 4,
                                  children: [
                                    Icon(
                                      Icons.mobile_friendly,
                                      color: theme.primaryColor,
                                    ),
                                    Text('Phone, Radio or Woofer')
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedGadgetValue = newValue;
                                });
                              }
                            }),
                        SizedBox(
                          height: size.height * .02,
                        ),
                        EnergyFormField(
                          hintText: 'Enter kwH used',
                          keyboardType: TextInputType.number,
                          controller: kwhController,
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter kwH used';
                            }
                            return null;
                          },
                          onSaved: (String? kwh) {
                            if (kwh != null) {
                              formModel = FormModel(
                                  id: DateTime.now().toString(),
                                  applianceName: formModel.applianceName,
                                  dateFilled: formModel.dateFilled,
                                  hostelName: formModel.hostelName,
                                  kwh: double.parse(kwh));
                            }
                          },
                        ),
                        SizedBox(
                          height: size.height * .02,
                        ),
                        EnergyFormField(
                          hintText: 'Enter date',
                          isReadOnly: true,
                          onTap: _showDatePicker,
                          controller: dateController,
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter date';
                            }
                            return null;
                          },
                          onSaved: (String? date) {
                            if (date != null) {
                              formModel = FormModel(
                                  id: DateTime.now().toString(),
                                  applianceName: formModel.applianceName,
                                  dateFilled: selectedDate ?? DateTime.now(),
                                  hostelName: formModel.hostelName,
                                  kwh: formModel.kwh);
                            }
                          },
                        ),
                        SizedBox(
                          height: size.height * .02,
                        ),
                      ],
                    ),
                  ),
                    actions: [
                    Row(
                      children: [
                      Card(
                        color: Colors.blueGrey,
                        child: TextButton(
                        onPressed: () {
                          showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const MeterReadingDialog();
                          },
                          );
                        },
                        child: Text("Meter reading"),
                        ),
                      ),
                      Spacer(),
                      TextButton(
                        onPressed: () {
                        Navigator.pop(context);
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: _submitHandler,
                        child: Text('Add'),
                      ),
                      ],
                    ),
                    ],
                  
                );
              });
        },
        shape: CircleBorder(),
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            Text('Ecowise'), // Your existing title text
            SizedBox(
                width: 8), // Add some spacing between the text and the image
            Image.asset(
              'assets/ic_launcher.png', // Path to your image in the assets folder
              width: 34, // Non-nullable value
              height: 34, // Non-nullable value
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications_outlined),
              tooltip: 'Notifications',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer<EnergyManagementProvider>(
              builder: (context, provider, child) {
                return IconButton(
                  onPressed: () {
                    provider.toggleAppTheme();
                  },
                  icon: Icon(
                    provider.isDarkMode
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                  ),
                  tooltip: 'Toggle Theme',
                );
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<EnergyManagementProvider>(context, listen: false)
              .getEnergyData();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Centered Image and Text
                Center(
                  child: Column(
                    children: [
                      // Larger Image
                      // Image.asset(
                      //   'assets/ic_launcher.png', // Path to your image
                      //   width: 245, // Adjust the size as needed
                      //   height: 245, // Adjust the size as needed
                      // ),
                      SizedBox(height: 100), // Spacing between image and text
                      // Centered Text
                      Text(
                        'Device consumption overview',
                        style: theme.textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24), // Spacing below the centered content
                _buildEnergyOverviewCard(context, size),
                SizedBox(height: 24),
                _buildHostelsList(context),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnergyOverviewCard(BuildContext context, Size size) {
    final theme = Theme.of(context);
    final date = DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device Total Consumption',
                      style: theme.textTheme.titleMedium,
                    ),
                    FutureBuilder(
                      future: Provider.of<EnergyManagementProvider>(context,
                              listen: false)
                          .getEnergyData(),
                      builder: (context, snapShot) {
                        if (snapShot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapShot.connectionState ==
                            ConnectionState.done) {
                          if (snapShot.hasError) {
                            return Center(
                                child: Icon(
                              Icons.error,
                              color: Theme.of(context).colorScheme.error,
                              size: 22,
                            ));
                          } else if (snapShot.hasData) {
                            final energyData = snapShot.data as List<FormModel>;
                            final totalKiloWat = energyData.fold(
                                0.0, (sum, wattage) => sum + wattage.kwh);
                            if (energyData.isEmpty) {
                              return Center(
                                child: Text('No Energy Data Available',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary)),
                              );
                            }
                            return Text(
                              '${totalKiloWat.toStringAsFixed(2)} KWh',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          } else {
                            return Center(
                              child: Text('No Energy Data Available',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary)),
                            );
                          }
                        }
                        return Center(
                          child: Text('Something went wrong.'),
                        );
                      },
                    ),
                  ],
                ),
                Chip(
                  label: Text(formattedDate),
                  backgroundColor: theme.colorScheme.primaryContainer,
                  labelStyle:
                      TextStyle(color: theme.colorScheme.onPrimaryContainer),
                ),
              ],
            ),
            Divider(height: size.height * 0.02),
            Text(
              'Device overal consumption',
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: size.height * 0.02),
            FutureBuilder(
              future:
                  Provider.of<EnergyManagementProvider>(context, listen: false)
                      .getEnergyData(),
              builder: (context, snapShot) {
                if (snapShot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapShot.connectionState == ConnectionState.done) {
                  if (snapShot.hasError) {
                    return Center(
                      child: Text(
                          'An error occurred while fetching data. Check your connection',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                  color: Theme.of(context).colorScheme.error)),
                    );
                  } else if (snapShot.hasData) {
                    final energyData = snapShot.data as List<FormModel>;
                    final totalKiloWat = energyData.fold(
                        0.0, (sum, wattage) => sum + wattage.kwh);
                    final lightingData = energyData
                        .where((lData) => lData.applianceName == 'Lighting')
                        .toList();
                    final totalLightingKwh =
                        lightingData.fold(0.0, (sum, lData) => sum + lData.kwh);
                    final lightingPercentage =
                        ((totalLightingKwh / totalKiloWat) * 100);
                    final heatingData = energyData
                        .where((hData) => hData.applianceName == 'Kettle')
                        .toList();
                    final totalHeatingKwh =
                        heatingData.fold(0.0, (sum, lData) => sum + lData.kwh);
                    final heatingPercentage =
                        ((totalHeatingKwh / totalKiloWat)) * 100;
                    final chargingLaptopData = energyData
                        .where((cData) => cData.applianceName == 'Laptop')
                        .toList();
                    final phoneData = energyData
                        .where((pData) => pData.applianceName == 'Phone')
                        .toList();
                    final totalChargingKwh = chargingLaptopData.fold(
                        0.0, (sum, lData) => sum + lData.kwh);
                    final totalPhoneChargingKwh =
                        phoneData.fold(0.0, (sum, cData) => sum + cData.kwh);

                    final totalChargingPercentage =
                        (((totalChargingKwh + totalPhoneChargingKwh) /
                                totalKiloWat) *
                            100);
                    if (energyData.isEmpty) {
                      return Center(
                        child: Text('No Energy Data Available',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary)),
                      );
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildUsageItem(context, 'Lighting', lightingPercentage,
                            Icons.lightbulb_outline, size),
                        _buildVerticalDivider(context),
                        _buildUsageItem(context, 'Heating', heatingPercentage,
                            Icons.thermostat_outlined, size),
                        _buildVerticalDivider(context),
                        _buildUsageItem(
                            context,
                            'Charging',
                            totalChargingPercentage,
                            Icons.battery_charging_full,
                            size),
                      ],
                    );
                  } else {
                    return Center(
                      child: Text('No Energy Data Available',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary)),
                    );
                  }
                }
                return Center(
                  child: Text('Something went wrong.'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageItem(BuildContext context, String label, double percentage,
      IconData icon, Size size) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        SizedBox(height: size.height * 0.02),
        Text(
          label,
          style: theme.textTheme.bodyMedium,
        ),
        Text(
          '${percentage.toStringAsFixed(2)}%',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(BuildContext context) {
    return VerticalDivider(
      thickness: 1,
      color: Theme.of(context).dividerColor,
    );
  }

  Widget _buildHostelsList(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<EnergyManagementProvider>(context, listen: false)
          .getEnergyData(),
      builder: (context, snapShot) {
        if (snapShot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapShot.connectionState == ConnectionState.done) {
          if (snapShot.hasError) {
            return Center(
              child: Text(
                'An error occurred while fetching data. Check your connection',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            );
          } else if (snapShot.hasData) {
            final energyData = snapShot.data as List<FormModel>;
            final totalKiloWatPerHostel = energyData
                .where((element) => element.hostelName == 'HOSTEL A')
                .toList();
            final totalKiloWatPerHostelF = energyData
                .where((element) => element.hostelName == 'HOSTEL B')
                .toList();
            final totalKiloWatPerHostelG = energyData
                .where((element) => element.hostelName == 'HOSTEL C')
                .toList();
            final totalKiloWatPerHostelD = energyData
                .where(
                  (element) => element.hostelName == 'HOSTEL D',
                )
                .toList();
            final totalKwHostelE = totalKiloWatPerHostel.fold(
                0.0, (sum, number) => sum + number.kwh);
            final totalKwHostelF = totalKiloWatPerHostelF.fold(
                0.0, (sum, number) => sum + number.kwh);
            final totalKwHostelG = totalKiloWatPerHostelG.fold(
                0.0, (sum, number) => sum + number.kwh);
            final totalKwHostelD = totalKiloWatPerHostelD.fold(
                0.0, (sum, number) => sum + number.kwh);

            if (energyData.isEmpty) {
              return Center(
                child: Text('No Energy Data Available',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary)),
              );
            }
            return buildHostelCards(
              totalKwHostelE,
              totalKwHostelF,
              totalKwHostelG,
              totalKwHostelD,
            );
          } else {
            return Center(
              child: Text('No Energy Data Available',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary)),
            );
          }
        }
        return Center(
          child: Text('Something went wrong.'),
        );
      },
    );
  }

  Widget buildHostelCards(
    double totalKwHostelE,
    double totalKwHostelF,
    double totalKwHostelG,
    double totalKwHostelD,
  ) {
    return Column(
      
      children: [
        Text('Hostel Device Consumption',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildHostelCard(
                  title: 'HOSTEL A',
                  powerConsumption: '${totalKwHostelE.toStringAsFixed(2)} kwh',
                  subTitle: 'Occupied',
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildHostelCard(
                  title: 'HOSTEL B',
                  powerConsumption: '${totalKwHostelF.toStringAsFixed(2)} kwh',
                  subTitle: 'Occupied',
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildHostelCard(
                  title: 'HOSTEL C',
                  powerConsumption: '${totalKwHostelG.toStringAsFixed(2)} kwh',
                  subTitle: 'Empty',
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildHostelCard(
                  title: 'HOSTEL D',
                  powerConsumption: '${totalKwHostelD.toStringAsFixed(2)} kwh',
                  subTitle: 'Empty',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildHostelCard({
    required String title,
    required String powerConsumption,
    required String subTitle,
  }) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              powerConsumption,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              subTitle,
              style: TextStyle(fontSize: 20, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
