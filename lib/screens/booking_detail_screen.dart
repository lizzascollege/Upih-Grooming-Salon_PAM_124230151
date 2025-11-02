import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:upih_pet_grooming/utils/app_colors.dart';

class BookingDetailScreen extends StatefulWidget {
  final int bookingId;
  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final supabase = Supabase.instance.client;
  Future<Map<String, dynamic>>? _bookingFuture;

  @override
  void initState() {
    super.initState();
    _bookingFuture = _fetchBookingDetails();
  }

  Future<Map<String, dynamic>> _fetchBookingDetails() async {
    try {
      final response = await supabase
          .from('bookings')
          .select(
            '''
            *,
            salons (name, address),
            services (name, duration)
            '''
          )
          .eq('id', widget.bookingId)
          .single();
      return response;
    } catch (e) {
      throw Exception("Failed to fetch booking details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Booking Details"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _bookingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return Center(child: Text("Booking cannot be found."));
          }

          final booking = snapshot.data!;
          final priceFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
          
          final String paymentMethod = booking['payment_method'] ?? 'N/A';
          final String status = booking['status'] ?? 'Waiting';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                status == 'Cancelled' 
                                  ? Icons.cancel_outlined 
                                  : (status == 'Completed' ? Icons.check_circle : Icons.check_circle_outline), 
                                color: status == 'Cancelled' 
                                  ? Colors.red[700] 
                                  : Colors.green[700], 
                                size: 60
                              ),
                              SizedBox(height: 12),
                              Text(
                                status == 'Cancelled' 
                                  ? "Booking Cancelled"
                                  : (status == 'Completed' ? "Booking Completed" : "Booking Confirmed!"),
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Show this detail at the salon cashier.",
                                style: TextStyle(color: AppColors.mediumGrey),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 32),
                        Text("Order Details", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        SizedBox(height: 12),
                        Card(
                          color: Colors.white,
                          elevation: 1.0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _buildDetailRow(Icons.store, "Salon", booking['salons']?['name'] ?? 'Data Salon Hilang'),
                                Divider(color: AppColors.lightGrey),
                                _buildDetailRow(Icons.cut, "Service", booking['services']?['name'] ?? 'Service Data Missing'),
                                Divider(color: AppColors.lightGrey),
                                _buildDetailRow(Icons.pets, "Pet", "${booking['pet_name'] ?? 'Pet'} (${booking['pet_breed'] ?? 'N/A'})"),
                                Divider(color: AppColors.lightGrey),
                                _buildDetailRow(
                                  Icons.calendar_today, 
                                  "Schedule", 
                                  DateFormat('EEE, dd MMM yyyy • HH:mm').format(DateTime.parse(booking['booking_time'] ?? DateTime.now().toIso8601String()))
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        Text("Payment Details", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        SizedBox(height: 12),
                        Card(
                          color: Colors.white,
                          elevation: 1.0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _buildDetailRow(Icons.credit_card, "Payment Method", paymentMethod),
                                Divider(color: AppColors.lightGrey),
                                _buildDetailRow(Icons.sell, "Total Price", priceFormat.format(booking['total_price'] ?? 0)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Close"),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: AppColors.mediumGrey, fontSize: 14)),
                SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }
}