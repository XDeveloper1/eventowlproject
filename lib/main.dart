import 'dart:convert';
import 'package:ct/DetailPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Event Page',
      theme: ThemeData(

        primarySwatch: Colors.blue,
        backgroundColor: Colors.blue, // Set the background color to blue
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<String> _dates = [];
  List<dynamic> _data = [];
  List<dynamic> _filteredData = [];
  bool _isLoading = true; // Set _isLoading to true initially

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await http.post(
        Uri.parse('http://eventowl.net:3680/demo_agneda_list'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'eid': '1989', 'pid': '117195'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final data = jsonData['data'] ?? [];
        final List<String> dates = [];
        final DateFormat dateFormatter = DateFormat('EEE, MMM d');
        final DateFormat timeFormatter = DateFormat('hh:mm a');
        for (var item in data) {
          final String startDate = item['start_date'] ?? '';
          final String endDate = item['end_date'] ?? '';
          final String startTime = startDate.substring(startDate.indexOf('T') + 1, startDate.indexOf('.'));
          final String endTime = endDate.substring(endDate.indexOf('T') + 1, endDate.indexOf('.'));
          final formattedStartTime = timeFormatter.format(DateTime.parse('2023-01-01T$startTime'));
          final formattedEndTime = timeFormatter.format(DateTime.parse('2023-01-01T$endTime'));
          final formattedDate = dateFormatter.format(DateTime.parse(startDate));
          if (!dates.contains(formattedDate)) {
            dates.add(formattedDate);
          }
          item['formattedStartTime'] = formattedStartTime;
          item['formattedEndTime'] = formattedEndTime;
        }
        setState(() {
          _dates = dates;
          _data = data;
          _filteredData = data;
          _tabController = TabController(length: dates.length, vsync: this);
          _isLoading = false; // Data is loaded, set _isLoading to false
        });
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Error occurred, set _isLoading to false
      });
      print('Error: $e');
    }
  }

  void _filterData(String date) {
    final filteredData = _data.where((item) {
      final String startDate = item['start_date'] ?? '';
      final formattedDate = DateFormat('EEE, MMM d').format(DateTime.parse(startDate));
      return formattedDate == date;
    }).toList();

    setState(() {
      _filteredData = filteredData;
    });
  }

  void _showSnackBar(String itemId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item ID: $itemId'),
      ),
    );
  }

  void _navigateToDetailPage(String itemId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(itemId: itemId),
      ),
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 150, // Adjust the height as needed
            color: Colors.white,
            child: Stack(
              children: [
                Positioned(
                  left: 12,
                  top: 80,
                  child: Text(
                    'Agenda',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                      color: Colors.black,
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 80,
                  child: CircleAvatar(
                    radius: 32,
                    backgroundImage: AssetImage('images/img1.png'),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: _dates.map((date) {
                return Tab(text: date);
              }).toList(),
              onTap: (index) {
                final selectedDate = _dates[index];
                _filterData(selectedDate);
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(
              child: CircularProgressIndicator(), // Show a loader while loading
            )
                : ListView.builder(
              itemCount: _filteredData.length,
              itemBuilder: (context, index) {
                final item = _filteredData[index];
                final String itemId = item['id'].toString();
                final String name = item['name'] ?? '';
                final String formattedStartTime = item['formattedStartTime'] ?? '';
                final String formattedEndTime = item['formattedEndTime'] ?? '';
                final List<dynamic> attendees = item['attendees'] ?? [];

                return GestureDetector(
                  onTap: () {
                    _navigateToDetailPage(itemId);
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Time: $formattedStartTime - $formattedEndTime',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: attendees.map<Widget>((attendee) {
                              final String attendeeImage = attendee['image'] ?? '';
                              return Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(attendeeImage),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
