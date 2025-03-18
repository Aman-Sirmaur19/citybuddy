import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import '../../../providers/filter_provider.dart';
import '../../../providers/location_provider.dart';
import '../../../utils/utils.dart';
import '../../dashboard/dashboard_screen.dart';
import '../post/create_post_screen.dart';
import 'across_india_screen.dart';
import 'address_form_screen.dart';
import 'my_city_screen.dart';

class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({super.key});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  List<geo.Placemark>? _placeMark;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    _placeMark = await geo.placemarkFromCoordinates(
        locationData.latitude!, locationData.longitude!);
    if (_placeMark != null) {
      Provider.of<LocationProvider>(context, listen: false).setLocation(
        country: _placeMark![0].country!,
        state: _placeMark![0].administrativeArea!,
        city: _placeMark![0].locality!,
        latitude: locationData.latitude!,
        longitude: locationData.longitude!,
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          leadingWidth: 50,
          leading: IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                showDragHandle: true,
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Filter Options',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            _getCurrentLocation();
                            Utils.showSnackBar(
                                context, 'Current location fetched!');
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.deepPurpleAccent,
                          ),
                          icon: const Icon(Icons.my_location_rounded),
                          label: const Text('Current location'),
                        ),
                        const SizedBox(
                          width: double.infinity,
                          child: Text(
                            'Or',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) =>
                                      const AddressFormScreen())),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Colors.deepPurpleAccent),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            foregroundColor: Colors.deepPurpleAccent,
                          ),
                          icon: const Icon(Icons.map_rounded),
                          label: const Text('Custom location'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            tooltip: 'Fetch location',
            icon: const Icon(Icons.my_location_rounded),
          ),
          title: Row(
            children: [
              Image.asset(
                Theme.of(context).brightness == Brightness.dark
                    ? 'assets/images/logo_dark.png'
                    : 'assets/images/logo_light.png',
                width: 50,
              ),
              if (locationProvider.latitude != null &&
                  locationProvider.longitude != null) ...[
                const SizedBox(width: 4),
                Text(
                  '${locationProvider.city}\n${locationProvider.state}, ${locationProvider.country}',
                  style: const TextStyle(
                    fontSize: 13,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            IconButton(
              onPressed: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => const DashboardScreen())),
              tooltip: 'Dashboard',
              icon: const Icon(CupertinoIcons.square_grid_2x2),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50), // Adjust height
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    labelColor: Colors.deepPurpleAccent,
                    indicatorColor: Colors.deepPurpleAccent,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: [
                      Tab(text: 'My City'),
                      Tab(text: 'Across India'),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      showDragHandle: true,
                      builder: (context) {
                        final filterProvider =
                            Provider.of<FilterProvider>(context);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Filter Options',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              CheckboxListTile(
                                activeColor: Colors.green,
                                value: filterProvider.filterType == 'latest',
                                title: const Row(
                                  children: [
                                    Icon(CupertinoIcons.calendar_today),
                                    SizedBox(width: 8),
                                    Text('Latest'),
                                  ],
                                ),
                                onChanged: (value) {
                                  filterProvider.setFilter('latest');
                                  Navigator.pop(context);
                                },
                              ),
                              CheckboxListTile(
                                activeColor: Colors.green,
                                value:
                                    filterProvider.filterType == 'most_upvoted',
                                title: const Row(
                                  children: [
                                    Icon(Icons.arrow_circle_up_rounded),
                                    SizedBox(width: 8),
                                    Text('Most upvoted'),
                                  ],
                                ),
                                onChanged: (value) {
                                  filterProvider.setFilter('most_upvoted');
                                  Navigator.pop(context);
                                },
                              ),
                              CheckboxListTile(
                                activeColor: Colors.green,
                                value:
                                    filterProvider.filterType == 'most_viewed',
                                title: const Row(
                                  children: [
                                    Icon(Icons.bar_chart_rounded),
                                    SizedBox(width: 8),
                                    Text('Most viewed'),
                                  ],
                                ),
                                onChanged: (value) {
                                  filterProvider.setFilter('most_viewed');
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  tooltip: 'Filter',
                  icon: const Icon(CupertinoIcons.slider_horizontal_3),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => const CreatePostScreen(
                        userId: '',
                        tweetId: '',
                      ))),
          tooltip: 'Post something',
          foregroundColor: Colors.white,
          backgroundColor: Colors.deepPurpleAccent,
          child: const Icon(CupertinoIcons.add),
        ),
        body: const TabBarView(
          children: [
            MyCityScreen(),
            AcrossIndiaScreen(),
          ],
        ),
      ),
    );
  }
}
