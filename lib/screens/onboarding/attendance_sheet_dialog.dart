import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:letsmeet/utils/ThemeProvider.dart';
import 'package:provider/provider.dart';

class AttendanceSheetDialog extends StatelessWidget {
  final String meetingID;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  AttendanceSheetDialog({required this.meetingID});

  Future<List<Map<String, dynamic>>> _fetchAttendanceData() async {
    try {
      final attendanceSnapshot = await _db.child('meetings/$meetingID/attendance').once();

      if (attendanceSnapshot.snapshot.exists) {
        final data = attendanceSnapshot.snapshot.value;
        print('Fetched data: $data');
        
        // Handling both List and Map structures
        if (data is List) {
          return (data as List<dynamic>).map((entry) {
            final value = entry as Map<dynamic, dynamic>;
            return {
              'username': value['username'] ?? 'Unknown',
              'isPresent': value['isPresent'] ?? false,
              'connectionTime': value['connectionTime'] ?? 0,  // Default to 0 if not found
            };
          }).toList();
        } else if (data is Map) {
          return (data.values).map((entry) {
            final value = entry as Map<dynamic, dynamic>;
            return {
              'username': value['username'] ?? 'Unknown',
              'isPresent': value['isPresent'] ?? false,
              'connectionTime': value['connectionTime'] ?? 0,
            };
          }).toList();
        } else {
          print('Unexpected data structure: ${data.runtimeType}');
        }
      }
    } catch (e) {
      print('Error fetching attendance data: $e');
    }
    return [];
  }

  String _formatConnectionTime(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final themeProvider = Provider.of<ThemeProvider>(context);
    // ignore: unused_local_variable
    final isDarkMode = themeProvider.isDarkMode;
    return Container(
      height: 500,
      decoration: BoxDecoration(
        color: isDarkMode? Color.fromARGB(255, 52, 52, 52):Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          width: 2,
          color: Color.fromARGB(255, 137, 137, 137),
        ),
      ),
      width: double.infinity, // Make the container full width
      padding: EdgeInsets.all(16.0),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchAttendanceData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error fetching data.');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Column(
              children: [
                Container(
                  height: screenHeight * 0.005,
                  width: screenWidth * 0.15,
                  margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                  decoration: BoxDecoration(
                    color: Colors.grey[600], // Lighter gray for the handle
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Text(
                  'No attendance data found for meeting: $meetingID',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                ),
                Center(
                      child: Container(
                        height: 250,
                        width: 250,
                        child: Image.asset("assets/attendance_n.png"),
                      ),
                    ),
              ],
            );
          } else {
            final attendanceList = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 5,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  Text(
                    'Attendance for Meeting  : $meetingID',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Divider(height: 2, color: Colors.white),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.only(top: 5),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const <DataColumn>[
                          DataColumn(label: Text('Username', style: TextStyle(fontSize: 15))),
                          DataColumn(label: Text('Status', style: TextStyle(fontSize: 15))),
                          DataColumn(label: Text('Time', style: TextStyle(fontSize: 15))),
                        ],
                        rows: attendanceList.map((attendee) {
                          final username = attendee['username'] ?? 'Unknown';
                          final isPresent = attendee['isPresent'] ? 'Present' : 'Absent';
                          final connectionTimeMinutes = attendee['connectionTime'] ?? 0;
                          final connectionTime = _formatConnectionTime(connectionTimeMinutes);

                          return DataRow(cells: <DataCell>[
                            DataCell(Text(username, style: TextStyle(fontSize: 13,))),
                            DataCell(Text(isPresent, style: TextStyle(fontSize: 13,color: attendee['isPresent'] ? Colors.green : Colors.red))),
                            DataCell(Text(connectionTime, style: TextStyle(fontSize: 13))),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
