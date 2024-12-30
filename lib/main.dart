import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NFL Players',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CsvExample(),
    );
  }
}

class CsvExample extends StatefulWidget {
  @override
  CsvExampleState createState() => CsvExampleState();
}

class CsvExampleState extends State<CsvExample> {
  List<String?> csvElements = List.filled(5, null); // To store 5 elements
  List<bool> showContainers = List.filled(5, false); // Visibility for 5 containers
  List<bool> isButtonActive = [true, false, false, false, false]; // Activation states
  int randomRow = 1; // Default random row

  // Define column mappings for each button
  final Map<int, int> buttonToColumnMap = {
    0: 1, // Button 1 shows data from column 2
    1: 2, // Button 2 shows data from column 3
    2: 3, // Button 3 shows data from column 4
    3: 0, // Button 4 shows data from column 1
    4: 4, // Button 5 shows data from column 5 (example)
  };

  @override
  void initState() {
    super.initState();
    pickRandomRow();
  }

  void pickRandomRow() {
    final random = Random();
    setState(() {
      randomRow = random.nextInt(1879) + 1; // Picks a row between 1 and 1879
    });
  }

  // Load specific data from the CSV file
  Future<void> loadCsvFile(int buttonIndex) async {
    try {
      String fileContents = await rootBundle.loadString('assets/NFL_Players.csv');
      List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(fileContents);

      int columnIndex = buttonToColumnMap[buttonIndex]!;

      // Ensure the row and column indices are within range
      if (rowsAsListOfValues.isEmpty || randomRow >= rowsAsListOfValues.length || columnIndex >= rowsAsListOfValues[randomRow].length) {
        throw RangeError('Row $randomRow or Column $columnIndex is out of bounds.');
      }

      var element = rowsAsListOfValues[randomRow][columnIndex]; // Random row, mapped column

      setState(() {
        csvElements[buttonIndex] = element.toString();
        showContainers[buttonIndex] = true;
        if (buttonIndex < isButtonActive.length - 1) {
          isButtonActive[buttonIndex + 1] = true; // Activate the next button
        }
      });
    } catch (e) {
      setState(() {
        csvElements[buttonIndex] = "Error loading CSV file: $e";
        showContainers[buttonIndex] = true;
      });
    }
  }

  void restartGame() {
    setState(() {
      csvElements = List.filled(5, null);
      showContainers = List.filled(5, false);
      isButtonActive = [true, false, false, false, false];
      pickRandomRow();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/NFL_Logo.png',
              height: 40,
            ),
            SizedBox(width: 10),
            Text(
              'NFL PLAYERS',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color.fromRGBO(1, 51, 105, 1),
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Buttons and Containers
                  for (int i = 0; i < 4; i++) ...[
                    ElevatedButton(
                      onPressed: isButtonActive[i]
                          ? () {
                              if (csvElements[i] == null) {
                                loadCsvFile(i); // Load specific data for the button
                              } else {
                                setState(() {
                                  showContainers[i] = !showContainers[i]; // Toggle
                                });
                              }
                            }
                          : null, // Disable button if not active
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 24.0,
                        ),
                        elevation: 5,
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Text(
                        showContainers[i]
                            ? 'Hide Data ${i + 1}'
                            : ['Initials', 'Clue', 'Hint', 'Name'][i],
                      ),
                    ),
                    SizedBox(height: 10),
                    if (showContainers[i])
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5.0,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          csvElements[i] != null
                              ? 'Data ${i + 1}: ${csvElements[i]}'
                              : 'Loading...',
                          style: TextStyle(fontSize: 18, color: Colors.black87),
                        ),
                      ),
                    SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),
          // Play Button at Bottom Center
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: restartGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 32.0,
                  ),
                  elevation: 5,
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text('Play'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}