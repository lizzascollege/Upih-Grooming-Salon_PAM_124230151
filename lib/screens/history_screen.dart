import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:upih_pet_grooming/screens/booking_detail_screen.dart'; 
import 'package:upih_pet_grooming/utils/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key}); 

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<dynamic>> _historyFuture;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _historyFuture = _getMyBookings(); 
  }

  Future<List<dynamic>> _getMyBookings() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }
    try {
      final response = await supabase
          .from('bookings')
          .select(
            '''
            *,
            salons (name, image_url),
            services (name)
            '''
          )
          .eq('user_id', user.id)
          .neq('status', 'Canceled') 
          .order('booking_time', ascending: false); 
      return response;
    } catch (e) {
      throw Exception("Failed to load history: $e");
    }
  }

  Map<String, dynamic> _getBookingStatus(String status) {
    switch (status) {
      case 'Canceled':
        return {'text': 'Dibatalkan', 'color': Colors.red[700]};
      case 'Completed':
        return {'text': 'Completed', 'color': Colors.green[700]};
      case 'Pending':
      default:
        return {'text': 'Pending', 'color': Colors.orange[800]};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Booking History"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "You don't have any booking history.",
                style: TextStyle(color: AppColors.mediumGrey, fontSize: 16),
              ),
            );
          }
          final bookings = snapshot.data!;
          final priceFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final statusInfo = _getBookingStatus(booking['status'] ?? 'Pending');
              
              String displayPrice;
              if (booking['display_price'] != null) {
                displayPrice = booking['display_price'];
              } else {
                final dynamic rawPrice = booking['total_price'];
                num priceAsNum = 0;
                if (rawPrice is num) {
                  priceAsNum = rawPrice;
                } else if (rawPrice is String) {
                  priceAsNum = num.tryParse(rawPrice) ?? 0;
                }
                displayPrice = priceFormat.format(priceAsNum);
              }

              return Card(
                color: Colors.white,
                elevation: 1.0,
                margin: EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BookingDetailScreen(bookingId: booking['id']),
                      ),
                    );
                  },
                  
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                booking['salons']?['image_url'] ?? 'https://via.placeholder.com/150',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking['salons']?['name'] ?? 'Data Salon Lost',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    booking['services']?['name'] ?? 'Data Layanan Lost',
                                    style: TextStyle(color: AppColors.mediumGrey),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (statusInfo['color'] as Color).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                statusInfo['text'],
                                style: TextStyle(
                                  color: statusInfo['color'],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 20, color: AppColors.lightGrey),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('EEE, dd MMM yyyy • HH:mm').format(DateTime.parse(booking['booking_time'])),
                              style: TextStyle(color: AppColors.textDark, fontSize: 13),
                            ),
                            Text(
                              displayPrice,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary
                              )
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}