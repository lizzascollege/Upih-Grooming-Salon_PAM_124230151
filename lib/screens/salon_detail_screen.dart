import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:upih_pet_grooming/screens/service_detail_screen.dart';
import 'package:upih_pet_grooming/services/api_service.dart';
import 'package:upih_pet_grooming/utils/app_colors.dart';

class SalonDetailScreen extends StatefulWidget {
  final Map<String, dynamic> salon;
  const SalonDetailScreen({super.key, required this.salon});

  @override
  _SalonDetailScreenState createState() => _SalonDetailScreenState();
}

class _SalonDetailScreenState extends State<SalonDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    final int salonId = widget.salon['id'];
    _servicesFuture = _apiService.getServicesBySalon(salonId);
  }

  void _showTimezoneHelp(BuildContext context) {
    final int openHourWIB = int.parse(widget.salon['open'].split(':')[0]);
    final int closeHourWIB = int.parse(widget.salon['close'].split(':')[0]);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white, 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Timezone Help 🌍",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Operational Hour ${widget.salon['name']} in different time zones:",
                // Otomatis pakai font Unbounded
              ),
              SizedBox(height: 16),
              _buildTimezoneRow("WIB (Jakarta)", openHourWIB, closeHourWIB, 7),
              _buildTimezoneRow("WITA (Makassar)", openHourWIB + 1, closeHourWIB + 1, 8),
              _buildTimezoneRow("WIT (Jayapura)", openHourWIB + 2, closeHourWIB + 2, 9),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimezoneRow(String zone, int open, int close, int offset) {
    final now = DateTime.now().toUtc().add(Duration(hours: offset));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                zone, 
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark
                )
              ),
              Text(
                "Operational: $open:00 - $close:00", 
                style: TextStyle(fontSize: 14, color: AppColors.mediumGrey)
              ),
            ],
          ),
          Text(
            DateFormat('HH:mm').format(now),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.salon['name']),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.salon['image_url'] ?? 'https://via.placeholder.com/350'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.salon['name'],
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, color: Colors.white.withOpacity(0.8), size: 18),
                            SizedBox(width: 4),
                            Expanded( 
                              child: Text(
                                widget.salon['address'], 
                                style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8)),
                                overflow: TextOverflow.ellipsis, 
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star_rounded, color: AppColors.accent, size: 18),
                            SizedBox(width: 4),
                            Text(
                              widget.salon['rating'].toString(),
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: Colors.white,
                    elevation: 1.0, 
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Operational Hour (WIB)",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold, 
                              color: AppColors.textDark 
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded( 
                                  child: Text(
                                    "Monday - Sunday: ${widget.salon['open']} - ${widget.salon['close']}",
                                  ),
                              ),
                              TextButton.icon(
                                icon: Icon(Icons.help_outline, size: 16, color: AppColors.primary),
                                label: Text("Time Zone", style: TextStyle(color: AppColors.primary)),
                                onPressed: () => _showTimezoneHelp(context),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  alignment: Alignment.centerRight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 37),
                  Text(
                    "Choose a Service",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold, 
                      color: AppColors.textDark 
                    ),
                  ),
                  SizedBox(height: 12),

                  FutureBuilder<List<dynamic>>(
                    future: _servicesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(color: AppColors.primary));
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text(
                          "Failed to load service. ${snapshot.error}", 
                          style: TextStyle(color: Colors.red.shade700))
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            "No services available at this salon. 😿",
                            style: TextStyle(fontSize: 16, color: AppColors.mediumGrey),
                          ),
                        );
                      }

                      final services = snapshot.data!;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          final service = services[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            color: Colors.white, 
                            elevation: 1.0, 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              title: Text(
                                service['name'],
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold, 
                                  color: AppColors.textDark 
                                ),
                              ),
                              subtitle: Text(
                                "${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(service['price'])} • ${service['duration']}",
                                style: TextStyle(color: AppColors.mediumGrey),
                              ),
                              trailing: Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 16),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ServiceDetailScreen(salon: widget.salon, service: service),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}