import '../models/course.dart';

class CourseService {
  // Sample courses - in production, this would come from a database or API
  List<Course> getSampleCourses() {
    return [
      Course(
        id: '1',
        name: 'Pebble Beach Golf Links',
        location: 'Pebble Beach, CA',
        numberOfHoles: 18,
        latitude: 36.5674,
        longitude: -121.9500,
        holes: List.generate(
          18,
          (i) => Hole(
            number: i + 1,
            par: _getParForHole(i + 1),
            distance: _getDistanceForHole(i + 1),
          ),
        ),
      ),
      Course(
        id: '2',
        name: 'Augusta National Golf Club',
        location: 'Augusta, GA',
        numberOfHoles: 18,
        latitude: 33.5030,
        longitude: -82.0200,
        holes: List.generate(
          18,
          (i) => Hole(
            number: i + 1,
            par: _getParForHole(i + 1),
            distance: _getDistanceForHole(i + 1),
          ),
        ),
      ),
      Course(
        id: '3',
        name: 'St Andrews Links',
        location: 'St Andrews, Scotland',
        numberOfHoles: 18,
        latitude: 56.3398,
        longitude: -2.8050,
        holes: List.generate(
          18,
          (i) => Hole(
            number: i + 1,
            par: _getParForHole(i + 1),
            distance: _getDistanceForHole(i + 1),
          ),
        ),
      ),
      Course(
        id: '4',
        name: 'Pinehurst No. 2',
        location: 'Pinehurst, NC',
        numberOfHoles: 18,
        latitude: 35.1900,
        longitude: -79.4700,
        holes: List.generate(
          18,
          (i) => Hole(
            number: i + 1,
            par: _getParForHole(i + 1),
            distance: _getDistanceForHole(i + 1),
          ),
        ),
      ),
    ];
  }

  int _getParForHole(int holeNumber) {
    // Typical par distribution for 18 holes (par 72)
    const pars = [4, 4, 3, 4, 5, 4, 3, 4, 4, 4, 5, 4, 3, 4, 4, 3, 5, 4];
    return pars[holeNumber - 1];
  }

  int _getDistanceForHole(int holeNumber) {
    // Sample distances in yards
    const distances = [
      445, 502, 198, 421, 567, 411, 189, 456, 445,
      490, 543, 408, 175, 439, 456, 212, 589, 421
    ];
    return distances[holeNumber - 1];
  }

  Course? getCourseById(String courseId) {
    try {
      return getSampleCourses().firstWhere((c) => c.id == courseId);
    } catch (e) {
      return null;
    }
  }
}
