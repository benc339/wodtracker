import 'package:flutter/material.dart';
import 'package:path/path.dart' as Path;
import 'package:image_picker/image_picker.dart';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'dart:io';
import 'workout.dart';
import 'networking.dart';
import 'constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'wide_button.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'standard_text_field.dart';
import 'results_page.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:sortedmap/sortedmap.dart';
import 'dart:collection';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';

final _firestore = FirebaseFirestore.instance;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> boxList = ['Crossfit.com', 'Chemical City Crossfit'];
  bool _checkedValue = false;
  int runningCount = 0;
  String scaledText;
  bool customVisible = false;
  String customLabel = 'Add custom workout';
  List<dynamic> workoutData;
  String userId;
  String userName;
  List<bool> showTextField = [];
  int movementCount = -1;
  String scoreMetric;
  String score;
  List<Widget> screen = [];
  Map currentWorkoutResults = {};
  Map lastWorkoutResults = {};
  String dropdownValue = 'Crossfit.com';
  bool showSpinner = true;
  String metricValue;
  VideoPlayerController _controller;

  File _image;
  String _uploadedFileURL;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getVideo(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        print('file picked');
        _image = File(pickedFile.path);
        uploadFile(_image);
      } else {
        print('No image selected.');
      }
    });
  }

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState

    super.initState();

    createScreen();
  }

  Future uploadFile(File _image) async {
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('videos/${Path.basename(_image.path)}}');
    UploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.whenComplete(() => null);
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        _uploadedFileURL = fileURL;
        print(fileURL);
      });
    });
  }

  Future<List> getPreviousMovementResults(movement) async {
    userId = await getId();

    final collection = await _firestore.collection(userId).get();

    List previousResults = [];

    for (var doc in collection.docs) {
      var data = doc.data();

      data.forEach((key, value) {
        print(key);
        if (doc.id == 'workouts') {
        } else if (key.toLowerCase().contains(movement)) {
          print(key + value);
          print(doc.id);
          previousResults.add([doc.id, key, value]);
        }
      });
    }
    return previousResults;
  }

  void updateWorkoutNotes(key, value, mov) async {
    print('tryupdate');
    runningCount++;
    final isRunningCount = runningCount;
    await Future.delayed(Duration(seconds: 1));
    key = key.replaceAll('.', '').replaceAll('/', '\\');
    if (isRunningCount == runningCount) {
      print('updateWorkoutNotes');
      final lastResults =
          await _firestore.collection(userId).doc('workouts').get();
      if (lastResults.exists) {
        print('2');
        _firestore.collection(userId).doc('workouts').update({mov: value});
      } else {
        _firestore.collection(userId).add({"key": 'value'});
        _firestore.collection(userId).doc('workouts').set({mov: value});
      }

      final results =
          await _firestore.collection(userId).doc(urlExtension).get();
      print('3');
      if (results.exists) {
        print(key);
        print(urlExtension);
        _firestore
            .collection(userId)
            .doc(urlExtension)
            .update({key.replaceAll('.', '').replaceAll('/', '\\'): value});
      } else {
        _firestore.collection(userId).add({"key": 'value'});
        _firestore.collection(userId).doc(urlExtension).set({key: value});
      }
    }
  }

  saveId(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('id', value);
    userId = value;
  }

  saveName(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('name', value);
    userName = value;
  }

  Future<String> getId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String stringValue = prefs.getString('id');
    if (stringValue == null) {
      Random random = new Random();
      int randomNumber = random.nextInt(1000000);
      stringValue = randomNumber.toString();
      saveId(stringValue);
    }
    return stringValue;
  }

  Future<String> getName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String stringValue = prefs.getString('name');
    if (stringValue == null) {
      Random random = new Random();
      int randomNumber = random.nextInt(1000000);
      stringValue = randomNumber.toString();
      saveId(stringValue);
    }
    return stringValue;
  }

  //check if value exists
  //prefs.containsKey('value');
  void getData() async {}

  void createScreen() async {
    setState(() {
      showSpinner = true;
    });
    Firebase.initializeApp();

    userId = await getId();
    userName = await getName();

    print('username: $userId');

    // WorkoutModel workoutModel = WorkoutModel();
    // workoutData = await workoutModel.getWorkoutData();
    if (dropdownValue == 'Crossfit.com') {
      print('get crossfit data');
      NetworkHelper networkHelper =
          NetworkHelper('https://www.crossfit.com/$urlExtension');
      workoutData = await networkHelper.getData();
    } else {
      print('get chemical data');
      NetworkHelper networkHelper = NetworkHelper(
          'https://chemicalcitycrossfit.com/2021/$currentMonth/$currentDay/');
      workoutData = await networkHelper.getData();
    }

    //get previous workout
    try {
      final document =
          await _firestore.collection(userId).doc('workouts').get();
      lastWorkoutResults = document.data();
    } catch (e) {}
    print('after firestore');
    setState(() {
      showSpinner = false;
    });

    //print(workoutData[0]);
  }

  Widget getPicker() {
    try {
      if (Platform.isIOS) {
        return getCupertinoPicker();
      } else {
        return getDropdownButton();
      }
    } catch (e) {
      return getDropdownButton();
    }
  }

  CupertinoPicker getCupertinoPicker() {
    return CupertinoPicker(
      backgroundColor: Colors.lightBlue,
      itemExtent: 32,
      onSelectedItemChanged: (selectedIndex) {
        setState(() {
          dropdownValue = getCupertinoStrings()[selectedIndex];
        });
      },
      children: getCupertinoItems(),
    );
  }

  List<String> getCupertinoStrings() {
    List<String> cupertinoStrings = [];
    for (String box in boxList) {
      cupertinoStrings.add(box);
    }
    return cupertinoStrings;
  }

  List<Widget> getCupertinoItems() {
    List<Widget> dropdownList = [];
    for (String box in boxList) {
      dropdownList.add(Text(box));
    }
    return dropdownList;
  }

  DropdownButton<String> getDropdownButton() {
    return DropdownButton<String>(
      value: dropdownValue,
      //icon: Icon(Icons.arrow_downward),
      //iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String newValue) {
        setState(() {
          dropdownValue = newValue;
          createScreen();
        });
      },
      items: <String>['Crossfit.com', 'Chemical City Crossfit']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  Future _showResults(BuildContext context, result) async {
    print('here1');
    saveName(userName);
    String rxResult = result;
    if (_checkedValue) {
      rxResult = result + 'rx';
    }
    final results =
        await _firestore.collection('Scores').doc(urlExtension).get();
    print('here2');
    if (results.exists) {
      _firestore
          .collection('Scores')
          .doc(urlExtension)
          .update({userName: rxResult});
    } else {
      print('here');
      _firestore.collection('Scores').add({"key": 'value'});
      _firestore
          .collection('Scores')
          .doc(urlExtension)
          .set({userName: rxResult});
    }

    var resultMap = results.data();
    var resultList = [];
    var rxResultList = [];
    print('here3');
    bool userResultAdded = false;
    if (resultMap != null) {
      resultMap.forEach((key, value) {
        if (value.contains('rx')) {
          rxResultList.add([key, value.replaceAll('rx', '')]);
        } else {
          resultList.add([key, value]);
        }
        if (userName == key) {
          userResultAdded = true;
        }
      });
    }
    if (!userResultAdded) {
      if (_checkedValue) {
        rxResultList.add([userName, result.replaceAll('rx', '')]);
      } else {
        resultList.add([userName, result]);
      }
    }
    var cnt = -1;
    for (var element in resultList) {
      cnt++;
      if (scoreMetric.contains('rounds')) {
        try {
          var x = double.parse(element[1].split('+')[0]) +
              double.parse(element[1].split('+')[1]) / 100;
        } catch (e) {
          resultList[cnt][1] = '0+0';
        }
      } else if (scoreMetric.contains('time')) {
        try {
          var y = double.parse(element[1].split(':')[0]) +
              double.parse(element[1].split(':')[1]) / 100;
        } catch (e) {
          print(e);
          resultList[cnt][1] = '0:0';
        }
      }
    }
    cnt = -1;
    for (var element in rxResultList) {
      cnt++;
      if (scoreMetric.contains('rounds')) {
        try {
          var x = double.parse(element[1].split('+')[0]) +
              double.parse(element[1].split('+')[1]) / 100;
        } catch (e) {
          rxResultList[cnt][1] = '0+0';
        }
      } else if (scoreMetric.contains('time')) {
        try {
          var y = double.parse(element[1].split(':')[0]) +
              double.parse(element[1].split(':')[1]) / 100;
        } catch (e) {
          print(e);
          rxResultList[cnt][1] = '0:0';
        }
      }
    }

    print('here4');
    if (scoreMetric.contains('rounds')) {
      resultList.sort((a, b) => (double.parse(a[1].split('+')[0]) +
              double.parse(a[1].split('+')[1]) / 100)
          .compareTo(double.parse(b[1].split('+')[0]) +
              double.parse(b[1].split('+')[1]) / 100));
      rxResultList.sort((a, b) => (double.parse(a[1].split('+')[0]) +
              double.parse(a[1].split('+')[1]) / 100)
          .compareTo(double.parse(b[1].split('+')[0]) +
              double.parse(b[1].split('+')[1]) / 100));
    } else if (scoreMetric.contains('time')) {
      resultList.sort((a, b) => (double.parse(a[1].split(':')[0]) +
              double.parse(a[1].split(':')[1]) / 100)
          .compareTo(double.parse(b[1].split(':')[0]) +
              double.parse(b[1].split(':')[1]) / 100));
      rxResultList.sort((a, b) => (double.parse(a[1].split(':')[0]) +
              double.parse(a[1].split(':')[1]) / 100)
          .compareTo(double.parse(b[1].split(':')[0]) +
              double.parse(b[1].split(':')[1]) / 100));
    }

    print(resultList);
    print('here5');
    List<Widget> elementList = [];
    print('beforeprev');
    int ctr = 0;

    var listToIterate1;
    var listToIterate2;
    if (scoreMetric.contains('time')) {
      listToIterate1 = rxResultList;
      listToIterate2 = resultList;
    } else {
      listToIterate1 = rxResultList.reversed;
      listToIterate2 = resultList.reversed;
    }
    print('listiterate');
    for (var result in listToIterate1) {
      if (result[0] == null) {
        break;
      }
      ctr++;
      print(result[0]);
      print('listiterate1');
      print(userName);
      //print('result' + result[0] + ' ' + result[0]);
      elementList.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
              child: StandaloneText(
                  ctr.toString() + '. ' + result[0] + ' : ', null, 20)),
          Expanded(child: StandaloneText(result[1] + ' rx', null, 20)),
        ],
      ));
      elementList.add(SizedBox(height: 5));
    }
    for (var result in listToIterate2) {
      if (result[0] == null) {
        break;
      }
      ctr++;
      print('result' + result[0] + ' ' + result[0]);
      elementList.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
              child: StandaloneText(
                  ctr.toString() + '. ' + result[0] + ' : ', null, 20)),
          Expanded(child: StandaloneText(result[1], null, 20)),
        ],
      ));
      elementList.add(SizedBox(height: 5));
    }
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: StandaloneText(capitalize('Results')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: elementList,
          ),
        );
      },
    );
  }

  void playVideo() {
    _controller = VideoPlayerController.network(
        'http://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  Future _ackAlert(BuildContext context, movement) async {
    movement = movement.replaceAll('heavy ', '');
    var previousResults = await getPreviousMovementResults(movement);

    List<Widget> elementList = [];
    print('beforeprev');
    for (var result in previousResults.reversed) {
      print('result' + result[0]);
      elementList.add(Row(
        //mainAxisSize: MainAxisSize.min,
        children: [
          StandaloneText(
              result[0].substring(2, 4) + '/' + result[0].substring(4, 6),
              null,
              15),
          SizedBox(width: 3),
          StandaloneText('|', null, 30, FontWeight.w100),
          SizedBox(width: 3),
          Flexible(
              fit: FlexFit.tight,
              flex: 10,
              child: StandaloneText(result[1].replaceAll('\\', '/'), null, 15)),
          SizedBox(width: 3),
          StandaloneText('|', null, 30, FontWeight.w100),
          SizedBox(width: 3),
          Flexible(
              flex: 10,
              fit: FlexFit.tight,
              child: StandaloneText(result[2], Colors.blueAccent, 15)),
          Container(
              padding: const EdgeInsets.all(0.0),
              width: 20,
              child: IconButton(
                  onPressed: () {
                    playVideo();
                  },
                  icon: Icon(Icons.ondemand_video))),
        ],
      ));
      elementList.add(SizedBox(height: 5));
    }
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: StandaloneText(capitalize(movement)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: elementList,
          ),
        );
      },
    );
  }

  List<Widget> getElements() {
    if (workoutData == null) {
      return [];
    }
    bool scaledSection = false;
    bool intermediateSection = false;
    bool beginnerSection = false;
    bool isMovement = false;

    String sectionType;
    String beginnerText;
    String intermediateText;
    String currentMovement;
    List<Widget> workoutElements = [SizedBox(height: 25)];
    List<String> currentDataLines = [];
    String userScore = '';
    print('before username');
    bool grossStrength = false;

    //select wod
    //workoutElements.add(getPicker());
    String searchValue;
    workoutElements.add(Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StandardTextField('Search movement', 200.0, (value) {
          searchValue = value;

          //print('$mov,$value');
        }),
        SizedBox(width: 10),

        //IconButton(icon: Icon(Icons.video_label), onPressed: null),
        WideButton(
          'Search',
          () {
            _ackAlert(context, searchValue);
          },
        ),
      ],
    ));
    //add date

    workoutElements.add(SizedBox(height: 20));
    workoutElements.add(
        StandaloneText('Crossfit.com workout:', null, 20, FontWeight.bold));
    print('first');

    //loop through data sections
    for (var section in workoutData) {
      print('section');
      //print(section);
      //print('_______');
      currentDataLines = [];
      //create list of lines from the section
      for (var line in section.split('\n')) {
        print(line);
        //if the line is scaled, beginner, intermediate or whatever else
        if (line.contains('Compare to') || line.contains('See below for')) {
          continue;
        } else if (line.contains('Scaled') || line.contains('Scaling')) {
          sectionType = 'scaled';
        }
        // print(line);
        // print('_____');
        currentDataLines.add(line);
      }
      if (sectionType == 'scaled') {
        // workoutElements.add(ScaledElement(
        //     context: context, formKey: _formKey, section: section));
        scaledText = section;
        break;
      }
      //loop through section lines
      movementCount = -1;
      for (String line in currentDataLines) {
        // print(line);
        if (line.contains('Gross Strength')) {
          grossStrength = true;
        }
        if (line.contains('WOD')) {
          grossStrength = false;
        }
        //check if line is a movement
        if (grossStrength) {
          for (String movement in kHeavyMovements) {
            if (line.contains(movement)) {
              isMovement = true;
              currentMovement = 'heavy $movement';
            }
          }
        }

        for (String movement in kMovements) {
          if (line.toLowerCase().contains(movement)) {
            isMovement = true;
            if (line.split('-').length > 2) {
              currentMovement = 'heavy $movement';
              //print(currentMovement);
              break;
            } else if (grossStrength) {
              currentMovement = 'heavy $movement';
            } else {
              currentMovement = movement;
              //print(currentMovement);
              break;
            }
          }
        }
        if (line.contains('♀')) {
          isMovement = false;
        }
        //print(lastWorkoutResults[currentMovement]);
        //print(currentMovement);
        //add movement element if line is a movement
        print(line + isMovement.toString());
        print((!line.toLowerCase().contains('to comments.')).toString());

        if (isMovement) {
          var hintText = 'Enter notes';

          try {
            hintText = lastWorkoutResults[currentMovement];
            if (hintText == null) {
              hintText = 'Enter notes';
            }
          } catch (e) {}
          final mov = currentMovement;
          movementCount++;
          final currentMovementCnt = movementCount;
          showTextField.add(false);
          workoutElements.add(Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //IconButton(icon: Icon(Icons.video_label), onPressed: null),
              Flexible(
                flex: 10,
                child: TextButton(
                    onPressed: () {
                      _ackAlert(context, mov);
                    },
                    child: StandaloneText('  ' + line)),
              ),

              Visibility(
                visible: showTextField[currentMovementCnt],
                child: Flexible(
                  flex: 10,
                  child: StandardTextField(hintText, 200.0, (value) {
                    currentWorkoutResults[line] = value;
                    updateWorkoutNotes(line, value, mov);
                    //print('$mov,$value');
                  }),
                ),
              ),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(0.0),
                    width: 26,
                    child: IconButton(
                        icon: Icon(Icons.note_add_rounded),
                        onPressed: () {
                          setState(() {
                            print('currentMovementCnt' +
                                currentMovementCnt.toString());
                            print(showTextField[currentMovementCnt]);
                            showTextField[currentMovementCnt] =
                                !showTextField[currentMovementCnt];
                          });
                        }),
                  ),
                  Container(
                    padding: const EdgeInsets.all(0.0),
                    width: 30,
                    child: IconButton(
                        icon: Icon(Icons.ondemand_video),
                        onPressed: () {
                          getImage();
                        }),
                  ),
                ],
              ),
            ],
          ));
          isMovement = false;
        } else if (!line.toLowerCase().contains('comments') &&
            !line.contains('Subscribe')) {
          workoutElements.add(StandaloneText(line));
        } else if (line.toLowerCase().contains('to comments.')) {
          print('metric');
          scoreMetric = line.split('Post ')[1].split(' to comments')[0];
          scoreMetric = scoreMetric.replaceAll('number of ', '');
          if (scoreMetric.contains('rounds')) {
            scoreMetric = 'rounds';
          } else if (scoreMetric.contains('time')) {
            scoreMetric = 'time';
          }
          String printMetric;
          try {
            printMetric = 'Enter ' + scoreMetric + kMetricExample[scoreMetric];
          } catch (e) {
            printMetric = 'Enter ' + scoreMetric;
          }

          print('j');

          workoutElements.add(SizedBox(height: 5));
          if (userName == null) {
            workoutElements.add(StandardTextField('Enter name', 170.0, (value) {
              userName = value;
            }));
          }

          print('f');

          workoutElements.add(Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              StandardTextField(printMetric, 220.0, (value) {
                metricValue = value;

                //print('$mov,$value');
              }),

              Container(
                  child: TextButton(
                      // here toggle the bool value so that when you click
                      // on the whole item, it will reflect changes in Checkbox
                      onPressed: () => setState(() {
                            _checkedValue = !_checkedValue;
                            print(_checkedValue);
                          }),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                                height: 24.0,
                                width: 24.0,
                                child: Checkbox(
                                  value: _checkedValue,
                                  onChanged: (value) {
                                    setState(() {
                                      _checkedValue = value;
                                      print(value);
                                    });
                                  },
                                )),
                            // You can play with the width to adjust your
                            // desired spacing
                            SizedBox(width: 3.0),
                            Text("Rx", style: TextStyle(fontSize: 18)),
                          ]))),
              //IconButton(icon: Icon(Icons.video_label), onPressed: null),
              WideButton(
                'Post result',
                () {
                  _showResults(context, metricValue);
                },
              ),
            ],
          ));
        }
      }
    }
    workoutElements.add(SizedBox(height: 30));

    workoutElements.add(TextButton(
        onPressed: () {
          setState(() {
            customVisible = !customVisible;
            customLabel = 'Custom Workout:';
          });
        },
        child: WideButton(customLabel, null)));
    String movement1;
    workoutElements.add(Visibility(
        visible: customVisible,
        child: AddCustomMovement(movement1, currentMovement)));
    workoutElements.add(SizedBox(height: 3));
    String movement2;
    workoutElements.add(Visibility(
        visible: customVisible,
        child: AddCustomMovement(movement2, currentMovement)));
    workoutElements.add(SizedBox(height: 3));
    String movement3;
    workoutElements.add(Visibility(
        visible: customVisible,
        child: AddCustomMovement(movement3, currentMovement)));
    workoutElements.add(SizedBox(height: 3));
    String movement4;
    workoutElements.add(Visibility(
        visible: customVisible,
        child: AddCustomMovement(movement4, currentMovement)));

    screen = workoutElements;
    setState(() {
      showSpinner = false;
    });
    return screen;
  }

  Row AddCustomMovement(String movement1, String currentMovement) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //IconButton(icon: Icon(Icons.video_label), onPressed: null),
        StandardTextField('Enter movement', 200.0, (value) {
          movement1 = value;
          for (String movement in kMovements) {
            if (movement1.toLowerCase().contains(movement)) {
              currentMovement = movement;
            }
          }
          //print('$mov,$value');
        }),

        StandardTextField('Enter notes', 200.0, (value) {
          currentWorkoutResults[movement1] = value;
          final mov1 = movement1;
          final mov2 = currentMovement;
          updateWorkoutNotes(mov1, value, mov2);
          //print('$mov,$value');
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    playVideo();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.all(5),
            child: ModalProgressHUD(
              inAsyncCall: showSpinner,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: getElements(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
