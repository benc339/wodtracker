import 'networking.dart';
import 'constants.dart';

class WorkoutModel {
  Future<dynamic> getWorkoutData() async {
    //print(urlExtension);

    NetworkHelper networkHelper =
        NetworkHelper('https://www.crossfit.com/$urlExtension');

    var workoutData = await networkHelper.getData();
    //var workoutData = ['3 rounds for time of:', 'Run 800 meters'];
    return workoutData;
  }
}
