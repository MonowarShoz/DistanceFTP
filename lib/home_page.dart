import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:flcamftp/camera_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double? latitude;
  double? longitude;
  late LocationPermission permission;
  double? distanceinMeter;
  // double baseLongitude = 90.3601697;
  // double baseLatitude = 23.8166272;
  double baseLongitude = 90.35729740134856;
  double baseLatitude = 23.80939468081478;
  late StreamSubscription<Position> positionStream;

  double? distanceBetween;
  Future<Position> _determinePosition() async {
    bool serviceEnabled;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location Permission are denied');
      }
    }
    // await Geolocator.openAppSettings();
    // await Geolocator.openLocationSettings();
    return await Geolocator.getCurrentPosition();
  }

  _liveLocation() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
    );
    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position? position) {
      if (position == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unknown Location')));
      } else {
        setState(() {
          latitude = position.latitude;
          longitude = position.longitude;
          distanceBetween = Geolocator.distanceBetween(baseLatitude, baseLongitude, latitude!, longitude!);
          // double distanceInMeters = Geolocator.distanceBetween(52.2165157, 6.9437819, 52.3546274, 4.8285838);
          debugPrint('Longitude$longitude...Latitude$latitude');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('get location'),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Longitude ${longitude ?? ''}'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Latitude ${latitude ?? ''}'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Distance ${distanceBetween ?? ''}'),
            ),
            ElevatedButton(
              onPressed: () {
                // _determinePosition().then((value) {
                //   setState(() {
                //     latitude = value.latitude.toString();
                //     longitude = value.longitude.toString();
                //     distanceBetween = Geolocator.distanceBetween(baseLatitude, baseLongitude, value.latitude, value.longitude);
                //     debugPrint('Longitude$longitude...Latitude$latitude');
                //   });
                // });
                // if (distanceBetween! > 150) {
                //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You are outside of your position')));
                // }
                _liveLocation();
              },
              child: Text('Get Location'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  positionStream.cancel();
                });
              },
              child: Text('Cancel Taking Location'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CameraPage(),
          ),
        ),
      ),
    );
  }
}
