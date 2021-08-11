//save data in the textfields in two categories for the future
////set up firebase
////save the entire workout and show it in a popup on a button press or something
////allow user to enter their name

import 'package:flutter/material.dart';

const kActiveCardColor = Color(0xff1d1e33);
const kInActiveCardColor = Color(0xff111328);
const kBottomContainerHeight = 80.0;
const kBottomContainerColor = Color(0xFFEB1555);
const kLabelTextStyle = TextStyle(
  fontSize: 18,
  color: Color(0xff8d8e98),
);
const kNumberStyle = TextStyle(fontSize: 50, fontWeight: FontWeight.w900);
const kLargeButtonTextStyle = TextStyle(
  fontSize: 25,
  fontWeight: FontWeight.bold,
);

const Map kWorkoutAlternatives = {
  'box jump': ['Step-ups' 'Squats', 'Lunges'],
  'push press': ['jump squat'],
  'toes-to-bar': ['hanging-knee tucks'],
  'squat': ['Lunges'],
  'row': ['sumo-deadlift high pulls'],
  'rowing': ['alt'],
  'clean': ['alt'],
  'jerk': ['alt'],
  'run': ['alt'],
  'muscle-ups': ['alt'],
  'muscle-up': ['alt'],
  'wall-ball': ['alt'],
  'double-unders': ['alt'],
  'double-under': ['alt'],
};

const List<String> kHeavyMovements = [
  'PP',
];

const List<String> kMovements = [
  'bodyweight back squat',
  'devils press',
  'overhead walking lunge',
  'strict pull-up',
  'chest-to-bar pull-up',
  'air squat',
  'ring push-up',
  'burpee over bar',
  'pull-up',
  'bsq/bp',
  'med-ball clean',
  'one-legged squat',
  'shuttle sprint',
  'weighted dip',
  'push-up',
  'ring-row',
  'thruster',
  'sit-to-stand',
  'overhead squat',
  'burpee',
  'power clean',
  'sandbag to shoulder',
  'flip squat',
  'ring dips',
  'pistol',
  'broad jump',
  'slips',
  'ghd sit-up',
  'front and back scale',
  'front scale',
  'back scale',
  'shoulder press',
  'sumo deadlift high pull',
  'deadlift',
  'farmer carry',
  'kettlebell swings',
  'hang power snatch',
  'power snatch',
  'l-sit',
  'lunge',
  'handstand hold',
  'handstand push-up',
  'sit up',
  'toes-to-bar',
  'rope climb',
  'box jump',
  'push press',
  'toes-to-bar',
  'front squat',
  'back squat',
  'row',
  'rowing',
  'clean and jerk',
  'clean',
  'push jerk',
  'push press',
  'run',
  'wall-ball',
  'wall ball'
      'muscle-up',
  'wall-ball',
  'double-under',
  'ohs',
  'kb snatch',
  'snatch',
  'abmat',
  'hspu',
  'bsq/pp',
  'walking rack lunge',
  'dl/p',
];

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  border: InputBorder.none,
);

const kSendButtonTextStyle = TextStyle(
  color: Colors.lightBlueAccent,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
  ),
);

Map kMetricExample = {
  'time': ' (eg: 21:30)',
  'rounds': ' (eg: 10+5)',
  'reps': '',
};

var now = new DateTime.now();
final String currentMonth = now.toString().split('-')[1];
final String currentDay = now.toString().split('-')[2].split(' ')[0];
final String currentYear = now.toString().split('-')[0].split('20')[1];
final urlExtension = currentYear + currentMonth + currentDay;
//final urlExtension = '210123';
