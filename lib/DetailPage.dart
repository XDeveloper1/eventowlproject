import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

// #if kIsWeb
// import 'dart:html' as html;
// #endif

// import 'dart:html' as html;
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatefulWidget {
  final String itemId;

  const DetailPage({Key? key, required this.itemId}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _isLoading = true;
  List<String> _jsonDataLines = [];
  String? imageUrl;
  String? name;
  List<String> _attendeesImages = [];
  String? startDate;
  String? endDate;
  String? startTime;
  String? endTime;
  String? locationname;
  List<dynamic> _agendaSpeakers = [];
  var registerlink;
  var documnetfile;
  var description;
  var imgPaths;
  var simgurls;
  var sponsorname;

  Future<void> _fetchData() async {
    final url = Uri.parse(
        'http://eventowl.net:3680/demo_agenda_detail?sid=1&eid=1989&pid=117195&aid=${widget.itemId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final rawData = response.body;
      final jsonData = json.decode(rawData);

      setState(() {
        if (jsonData.containsKey('data')) {
          final data = jsonData['data'];
          if (data.containsKey('header_img')) {
            final headerImg = data['header_img'];
            if (jsonData.containsKey('imgPath')) {
              final imgPath = jsonData['imgPath'];
              imgPaths = imgPath;
              imageUrl = '$imgPath$headerImg';
              print('Image URL: $imageUrl');
            } else {
              print('imgPath key not found');
            }
          } else {
            print('header_img key not found');
          }
          if (data.containsKey('name')) {
            name = data['name'];
            print('Name: $name');
          } else {
            print('name key not found');
          }
          if (data.containsKey('start_date')) {
            final rawStartDate = data['start_date'];
            final startDateDateTime = DateTime.parse(rawStartDate);
            final startDateFormat = DateFormat('MMM d, y');
            final startTimeFormat = DateFormat('hh:mm a');
            startDate = startDateFormat.format(startDateDateTime);
            startTime = startTimeFormat.format(startDateDateTime);
            print('Start Date: $startDate');
          } else {
            print('start_date key not found');
          }
          if (data.containsKey('end_date')) {
            final rawEndDate = data['end_date'];
            final endDateDateTime = DateTime.parse(rawEndDate);
            final endDateFormat = DateFormat('MMM d, y');
            final endTimeFormat = DateFormat('hh:mm a');
            endDate = endDateFormat.format(endDateDateTime);
            endTime = endTimeFormat.format(endDateDateTime);
            print('End Date: $endDate');
          } else {
            print('end_date key not found');
          }
          if (data.containsKey('location_name')) {
            locationname = data['location_name'];
            print('location_name: $locationname');
          } else {
            print('description key not found');
          }
          if (data.containsKey('attendees')) {
            final attendees = data['attendees'];
            if (attendees is List) {
              for (final attendee in attendees) {
                if (attendee.containsKey('image')) {
                  final image = attendee['image'];
                  _attendeesImages.add(image);
                }
              }
              print('Attendees Images: $_attendeesImages');
            }
          }
          if (data.containsKey('agenda_speakers')) {
            final agendaSpeakers = data['agenda_speakers'];
            if (agendaSpeakers is List) {
              _agendaSpeakers = agendaSpeakers;
              print('Agenda Speakers: $_agendaSpeakers');
            }
          }
          if (data.containsKey('register_links')) {
            final registerLinks = data['register_links'];
            if (registerLinks is List) {
              for (final link in registerLinks) {
                if (link.containsKey('register_link')) {
                  final registerLink = link['register_link'];
                  registerlink = registerLink;
                  print('Register Link: $registerLink');
                }
              }
            }
          }
          if (data.containsKey('agenda_documents')) {
            final registerLinks = data['agenda_documents'];
            if (registerLinks is List) {
              for (final link in registerLinks) {
                if (link.containsKey('document_file')) {
                  final documentfile = link['document_file'];
                  documnetfile = documentfile;
                  print('document_file: $documentfile');
                }
              }
            }
          }
          if (data.containsKey('description')) {
            final descriptionHtml = data['description'];
            final descriptionText = parse(descriptionHtml)
                .body!
                .text; // Parse HTML and get text content
            description = descriptionText;
            print('Description Text: $descriptionText');
          }
          if (data.containsKey('sponsor_name')) {
            final sponsorName = data['sponsor_name'];
            sponsorname = sponsorName;
            print('Sponsor Name: $sponsorName');
          }

          if (data.containsKey('sponsor_img')) {
            final sponsorImage = data['sponsor_img'];
            final simgurl = imgPaths + sponsorImage;
            simgurls = simgurl;
            print(simgurl);
            print('Sponsor Image URL: $sponsorImage');
          }
        }
      });
    } else {
      print('Failed to fetch data');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = screenHeight * 0.5;

    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Stack(
                  children: [
                    if (imageUrl != null)
                      Container(
                        height: appBarHeight,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(imageUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (name != null)
                        Text(
                          name!,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (_attendeesImages.isNotEmpty)
                        Container(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _attendeesImages.length,
                            itemBuilder: (context, index) {
                              if (index < 4) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: CircleAvatar(
                                    radius: 32,
                                    backgroundImage:
                                        NetworkImage(_attendeesImages[index]),
                                  ),
                                );
                              } else if (index == 4) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: CircleAvatar(
                                    radius: 32,
                                    backgroundColor: Colors.grey,
                                    child: Text(
                                      '+${_attendeesImages.length - 4}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                        ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 8),
                          if (startDate != null)
                            Text(
                              startDate!,
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 8),
                      if (startTime != null && endTime != null)
                        Row(
                          children: [
                            SizedBox(width: 40),
                            Text(
                              startTime!,
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              '-',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              endTime!,
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 16),
                      if (locationname != null)
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 8),
                            Text(
                              locationname!,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              child: Text('Enter Code'),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              child: Text('Take Survey'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      if (_agendaSpeakers.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Agenda Speakers:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _agendaSpeakers.length,
                              itemBuilder: (context, index) {
                                final speaker = _agendaSpeakers[index];
                                if (speaker.containsKey('name') &&
                                    speaker.containsKey('title') &&
                                    speaker.containsKey('image')) {
                                  final speakerName = speaker['name'];
                                  final speakerTitle = speaker['title'];
                                  final speakerImage = speaker['image'];

                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 16.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 32,
                                          backgroundImage: NetworkImage(
                                            speakerImage,
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              speakerName,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              speakerTitle,
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            ),
                          ],
                        ),
                      SizedBox(height: 16),
                      Text(
                        'Registration Links:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        // This makes the button cover the full width of the screen.
                        child: ElevatedButton(
                          onPressed: () {
                            _launchURL(registerlink);
                          },
                          child: Text('Craxinno Technologies'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Documents:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        // This makes the button cover the full width of the screen.
                        child: ElevatedButton(
                          onPressed: () {
                            _launchURL(documnetfile);
                          },
                          child: Text('Feature List (DOC)'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Description:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(description),
                      SizedBox(height: 5),
                      Text(
                        sponsorname,
                        style: TextStyle(fontSize: 24),
                      ),
                      SizedBox(height: 10),
                      if (simgurls != null)
                        Container(
                          height: appBarHeight,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(simgurls!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

void _launchURL(String url) async {
  // Use 'url_launcher' package for mobile platforms.
  if (!kIsWeb) {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  // For web platforms, use 'dart:html' functionality.
}
