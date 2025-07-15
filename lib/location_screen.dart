import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/theme.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _currentLocationText = 'Auto-detect current location';
  List<Map<String, String>> _savedAddresses = [
    {'title': 'HOME', 'detail': 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has'},
    {'title': 'Office', 'detail': 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has'},
  ];
  List<Map<String, String>> _nearbyLocations = [
    {'title': 'Anjali Building', 'detail': 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has'},
    {'title': 'Kumar Office', 'detail': 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has'},
  ];
  List<Map<String, String>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _determineCurrentLocation();
  }

  Future<void> _determineCurrentLocation() async {
    setState(() {
      _currentLocationText = 'Fetching current location...';
    });

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _currentLocationText = 'Location services are disabled.';
      });
      // Optionally, prompt user to enable location services
      // await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _currentLocationText = 'Location permissions are denied.';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _currentLocationText = 'Location permissions are permanently denied.';
      });
      // Optionally, prompt user to open app settings
      // await openAppSettings();
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _currentLocationText = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}';
        });
      } else {
        setState(() {
          _currentLocationText = 'Could not determine address for current location.';
        });
      }
    } catch (e) {
      setState(() {
        _currentLocationText = 'Error fetching location: $e';
      });
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults.clear();
      _searchResults.add({'title': 'Searching...', 'detail': ''}); // Show a loading indicator
    });

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          locations.first.latitude,
          locations.first.longitude,
        );
        setState(() {
          _searchResults.clear(); // Clear loading indicator
          if (placemarks.isNotEmpty) {
            Placemark place = placemarks.first;
            _searchResults.add({
              'title': place.name ?? 'Found Location',
              'detail': '${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}'
            });
          } else {
            _searchResults.add({'title': 'No details found', 'detail': 'for "$query"'});
          }
        });
      } else {
        setState(() {
          _searchResults.clear(); // Clear loading indicator
          _searchResults.add({'title': 'No results found', 'detail': 'for "$query"'});
        });
      }
    } catch (e) {
      setState(() {
        _searchResults.clear(); // Clear loading indicator
        _searchResults.add({'title': 'Error', 'detail': 'searching location: $e'});
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.neutralWhite),
          onPressed: () {
            Navigator.pop(context); // Go back to AccountScreen
          },
        ),
        title: Text(
          'Select a Location',
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: AppColors.neutralWhite,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: AppColors.neutralWhite,
                borderRadius: BorderRadius.circular(8), // Very less curved edge
                border: Border.all(color: AppColors.neutralMediumGray, width: 1.0),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for area, Street name..',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.neutralMediumGray,
                    fontWeight: FontWeight.normal,
                  ),
                  prefixIcon: Icon(Icons.search, color: AppColors.neutralMediumGray, size: 20),
                  border: InputBorder.none, // Remove default TextField border
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                ),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.neutralBlack,
                  fontWeight: FontWeight.normal,
                ),
                onSubmitted: _searchLocation, // Trigger search on submit
                onChanged: (value) {
                  // Optional: Live search as user types, or keep onSubmitted for efficiency
                  if (value.isEmpty && _isSearching) {
                    setState(() {
                      _isSearching = false;
                      _searchResults.clear();
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 20),

            // Auto-detect current location
            GestureDetector(
              onTap: _determineCurrentLocation,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.neutralWhite,
                  borderRadius: BorderRadius.circular(8), // Very less curved
                  border: Border.all(color: AppColors.neutralMediumGray, width: 1.0),
                ),
                child: Row(
                  children: [
                    Icon(Icons.my_location, color: AppColors.primaryPurple, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _currentLocationText,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    Icon(Icons.refresh, color: AppColors.neutralMediumGray, size: 20), // Refresh icon
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Display Search Results or Saved/Nearby Addresses
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isSearching) ...[
                      Text(
                        'Search Results',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppColors.neutralBlack,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 15),
                      ..._searchResults.map((addressMap) => _buildLocationListItem(
                        addressMap['title']!,
                        addressMap['detail']!,
                        Icons.location_on,
                        isHeadingBold: false, // Search results title not bold
                      )),
                    ] else ...[
                      Text(
                        'SAVED ADDRESS',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppColors.neutralBlack,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 15),
                      ..._savedAddresses.map((addressMap) => _buildLocationListItem(
                        addressMap['title']!,
                        addressMap['detail']!,
                        Icons.location_on,
                        isHeadingBold: true, // Saved address title is bold
                      )),
                      const SizedBox(height: 20),
                      Text(
                        'Nearby Locations',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppColors.neutralBlack,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 15),
                      ..._nearbyLocations.map((addressMap) => _buildLocationListItem(
                        addressMap['title']!,
                        addressMap['detail']!,
                        Icons.location_on,
                        isHeadingBold: true, // Nearby location title is bold
                      )),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationListItem(String title, String addressDetail, IconData icon, {bool isHeadingBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0), // Maintain gap between list elements
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryPurple, size: 20),
          const SizedBox(width: 15), // Gap between icon and text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: isHeadingBold ? 16 : 14, // Larger font for headings
                    color: AppColors.neutralBlack,
                    fontWeight: isHeadingBold ? FontWeight.bold : FontWeight.normal, // Bold for headings
                  ),
                ),
                Text(
                  addressDetail,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.neutralBlack,
                    fontWeight: FontWeight.normal,
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
