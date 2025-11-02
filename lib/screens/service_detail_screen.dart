import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:upih_pet_grooming/screens/schedule_screen.dart';
import 'package:upih_pet_grooming/utils/app_colors.dart';

class ServiceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> salon;
  final Map<String, dynamic> service;

  const ServiceDetailScreen({
    super.key,
    required this.salon,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(service['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: AppColors.cardLightYellow,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service['name'],
                      style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.secondary),
                    ),
                    SizedBox(height: 12),
                    Text(
                      service['description'] ?? "Approximately ${service['duration']}.",
                      style: GoogleFonts.nunito(fontSize: 16, height: 1.5, color: AppColors.textDark),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Duration Estimation: ${service['duration']}",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            Text(
              "Service Price",
              style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.secondary),
            ),
            SizedBox(height: 12),
            Card(
              color: AppColors.cardLightYellow,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total:",
                      style: GoogleFonts.nunito(fontSize: 18, color: AppColors.textDark),
                    ),
                    Text(
                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(service['price']),
                      style: GoogleFonts.nunito(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.calendar_month, size: 24),
                label: Text("Choose Schedule", style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ScheduleScreen(
                        salon: salon, 
                        service: service,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}