import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:upih_pet_grooming/screens/salon_detail_screen.dart';
import 'package:upih_pet_grooming/utils/app_colors.dart';

class FindSalonsScreen extends StatefulWidget {
  const FindSalonsScreen({super.key});

  @override
  State<FindSalonsScreen> createState() => _FindSalonsScreenState();
}

class _FindSalonsScreenState extends State<FindSalonsScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _allSalons = [];
  List<dynamic> _filteredSalons = [];

  bool _isLoading = true;
  String _loadingMessage = "Find the nearest salon...";
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _fetchLocationAndSalons();
    _searchController.addListener(_filterSalons);
  }

  Future<void> _fetchLocationAndSalons() async {
    try {
      if (mounted) {
        setState(() => _loadingMessage = "Getting your location...");
      }

      _currentPosition = await _determinePosition();

      if (mounted) {
        setState(() => _loadingMessage = "Getting salon data...");
      }

      final response = await supabase
          .from('salons')
          .select()
          .order('name', ascending: true);

      if (!mounted) return;

      List<dynamic> salonsWithDistance = [];

      for (var salon in response) {
        final salonLat = double.tryParse(salon['latitude'].toString()) ?? 0.0;
        final salonLng = double.tryParse(salon['longitude'].toString()) ?? 0.0;

        double distanceInMeters = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          salonLat,
          salonLng,
        );

        salon['distance_meters'] = distanceInMeters;
        salonsWithDistance.add(salon);
      }

      salonsWithDistance.sort((a, b) =>
          (a['distance_meters'] as double)
              .compareTo(b['distance_meters'] as double));

      setState(() {
        _allSalons = salonsWithDistance;
        _filteredSalons = salonsWithDistance;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMessage = "There is an error: ${e.toString()}";
        });
      }
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Layanan lokasi tidak aktif.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location Permission Denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location Permission Denied Forever.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  void _filterSalons() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSalons = _allSalons.where((salon) {
        final name = (salon['name'] ?? '').toString().toLowerCase();
        final address = (salon['address'] ?? '').toString().toLowerCase();
        return name.contains(query) || address.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cari Salon Terdekat 📍"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search for salon name or address...",
                prefixIcon: Icon(Icons.search, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: _isLoading
                  ? _buildLoadingWidget()
                  : _filteredSalons.isEmpty
                      ? _buildEmptyWidget()
                      : ListView.builder(
                          itemCount: _filteredSalons.length,
                          itemBuilder: (context, index) {
                            final salon = _filteredSalons[index];
                            return _buildSalonCard(salon);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            _loadingMessage,
            style: TextStyle(color: AppColors.mediumGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Text(
        "Salon cannot be found.",
        style: TextStyle(color: AppColors.mediumGrey),
      ),
    );
  }

  Widget _buildSalonCard(Map<String, dynamic> salon) {
    final distanceInMeters = salon['distance_meters'] as double?;
    String distanceText = '';

    if (distanceInMeters != null) {
      distanceText = distanceInMeters < 1000
          ? "${distanceInMeters.toStringAsFixed(0)} m"
          : "${(distanceInMeters / 1000).toStringAsFixed(1)} km";
    }

    return Card(
      color: Colors.white,
      elevation: 1.0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            salon['image_url'] ?? 'https://via.placeholder.com/150',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          salon['name'] ?? 'Without a name',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              salon['address'] ?? 'Address not available',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              distanceText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: AppColors.accent, size: 16),
            const SizedBox(width: 4),
            Text(
              (salon['rating'] ?? '0').toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SalonDetailScreen(salon: salon),
          ));
        },
      ),
    );
  }
}
