import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

class HiveDatabaseFlutter extends StatefulWidget {
  const HiveDatabaseFlutter({super.key});

  @override
  State<HiveDatabaseFlutter> createState() => _HiveDatabaseFlutterState();
}

class _HiveDatabaseFlutterState extends State<HiveDatabaseFlutter> {
  var peopleBox = Hive.box("Box");
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final List<String> _workingAreas = ["frontdesk", "backdesk", "boss"];
  String? _selectedWorkingArea;
  TimeOfDay? _timeOfArrival;
  TimeOfDay? _timeOfDeparture;

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void showCustomSnackbar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50.0, // Adjust this value to change vertical position
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  void showSuccessSnackbar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50.0, // Adjust this value to change vertical position
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green, // Change to green
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  // function for add or update
  void addOrUpdatePerson({String? key}) {
    if (key != null) {
      final person = peopleBox.get(key);
      if (person != null) {
        _nameController.text = person['name'] ?? "";
        _lastnameController.text = person['lastname'] ?? "";
        _ageController.text = person['age']?.toString() ?? '';
        _selectedWorkingArea = person['workingArea'] ??
            _workingAreas[0]; // Set the selected workingArea
        _timeOfArrival = TimeOfDay.fromDateTime(
            DateTime.parse(person['timeOfArrival'])); // Retrieve and parse time
        _timeOfDeparture = TimeOfDay.fromDateTime(DateTime.parse(
            person['timeOfDeparture'])); // Retrieve and parse time
      }
    } else {
      _nameController.clear();
      _lastnameController.clear();
      _ageController.clear();
      _selectedWorkingArea = _workingAreas[0];
      _timeOfArrival = null;
      _timeOfDeparture = null;
    }
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 15,
              right: 15,
              top: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Enter name",
                ),
              ),
              TextField(
                controller: _lastnameController,
                decoration: InputDecoration(
                  labelText: "Enter lastname",
                ),
              ),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Enter age",
                ),
              ),
              DropdownButton<String>(
                value:
                    _selectedWorkingArea, // This value should be properly set in addOrUpdatePerson()
                items: _workingAreas.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedWorkingArea =
                        newValue; // Update the selected value and rebuild the widget
                  });
                },
              ),
              // Arrival Time Button
              ElevatedButton(
                onPressed: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _timeOfArrival ?? TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _timeOfArrival = pickedTime; // Update arrival time
                    });
                  }
                },
                child: Text(
                    "Select Arrival Time: ${_timeOfArrival != null ? _timeOfArrival!.format(context) : 'Not set'}"),
              ),

// Departure Time Button
              ElevatedButton(
                onPressed: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _timeOfDeparture ?? TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _timeOfDeparture = pickedTime; // Update departure time
                    });
                  }
                },
                child: Text(
                    "Select Departure Time: ${_timeOfDeparture != null ? _timeOfDeparture!.format(context) : 'Not set'}"),
              ),
              SizedBox(
                height: 15,
              ),
              ElevatedButton(
                onPressed: () {
                  final name = _nameController.text;
                  final lastname = _lastnameController.text;
                  final age = int.tryParse(_ageController.text);
                  // validate the textfield
                  if (name.isEmpty ||
                      lastname.isEmpty ||
                      age == null ||
                      _selectedWorkingArea == null ||
                      _timeOfArrival == null ||
                      _timeOfDeparture == null) {
                    showCustomSnackbar(context, "Please enter valid inputs");
                    return;
                  }
                  if (key == null) {
                    final newKey =
                        DateTime.now().microsecondsSinceEpoch.toString();
                    peopleBox.put(newKey, {
                      "name": name,
                      "lastname": lastname,
                      "age": age,
                      "workingArea": _selectedWorkingArea,
                      "timeOfArrival": DateTime(
                              2024,
                              1,
                              1,
                              _timeOfArrival?.hour ?? 0,
                              _timeOfArrival?.minute ?? 0)
                          .toIso8601String(), // Save time
                      "timeOfDeparture": DateTime(
                              2024,
                              1,
                              1,
                              _timeOfDeparture?.hour ?? 0,
                              _timeOfDeparture?.minute ?? 0)
                          .toIso8601String(), // Save time
                    });
                    // Show success notification
                    showSuccessSnackbar(context, "Successfully added");
                  } else {
                    peopleBox.put(key, {
                      "name": name,
                      "lastname": lastname,
                      "age": age,
                      "workingArea": _selectedWorkingArea,
                      "timeOfArrival": DateTime(
                              2024,
                              1,
                              1,
                              _timeOfArrival?.hour ?? 0,
                              _timeOfArrival?.minute ?? 0)
                          .toIso8601String(), // Save time
                      "timeOfDeparture": DateTime(
                              2024,
                              1,
                              1,
                              _timeOfDeparture?.hour ?? 0,
                              _timeOfDeparture?.minute ?? 0)
                          .toIso8601String(), // Save time
                    });
                    // Show success notification
                    showSuccessSnackbar(context, "Successfully updated");
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  key == null ? "Add" : "Update",
                ),
              ),
              SizedBox(
                height: 30,
              ),
            ],
          ),
        );
      },
    );
  }

  //for delete operation
  void deleteOperation(String key) {
    peopleBox.delete(key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[30],
      appBar: AppBar(
        title: const Text("Flutter app"),
        backgroundColor: Colors.blue[120],
      ),
      body: ValueListenableBuilder(
        valueListenable: peopleBox.listenable(),
        builder: (context, box, widget) {
          if (box.isEmpty) {
            return Center(
              child: Text("No items added yet."),
            );
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final key = box.keyAt(index).toString();
              final items = box.get(key);
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  color: Colors.white,
                  elevation: 2,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(items?["name"] ?? "Unknown"),
                      subtitle: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // Aligns text to the left
                        children: [
                          Text(items?["lastname"] ?? "Unknown"),
                          Text("Age: ${items?["age"] ?? "Unknown"}"),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => addOrUpdatePerson(key: key),
                            icon: const Icon(
                              Icons.edit,
                            ),
                          ),
                          IconButton(
                            onPressed: () => deleteOperation(key),
                            icon: const Icon(
                              Icons.delete,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(33, 49, 47, 47),
        foregroundColor: Colors.white,
        onPressed: () => addOrUpdatePerson(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
