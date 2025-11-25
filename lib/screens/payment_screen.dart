import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upih_pet_grooming/models/pet_model.dart';
import 'package:upih_pet_grooming/screens/booking_detail_screen.dart';
import 'package:upih_pet_grooming/services/notification_service.dart';
import 'package:upih_pet_grooming/utils/app_colors.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> salon;
  final Map<String, dynamic> service;
  final PetModel pet;
  final DateTime bookingTime;
  final String bookingTimezone;

  const PaymentScreen({
    super.key,
    required this.salon,
    required this.service,
    required this.pet,
    required this.bookingTime,
    required this.bookingTimezone,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;

  final List<Map<String, dynamic>> _paymentOptions = [
    {
      'name': 'E-Wallet',
      'subtitle': 'Shopeepay, OVO, Dana, Gopay',
      'icon': Icons.account_balance,
      'color': Color(0xFF0066AE),
    },
    {
      'name': 'QRIS',
      'subtitle': 'Scan to pay',
      'icon': Icons.qr_code_scanner,
      'color': Color(0xFFFF6B6B),
    },
    {
      'name': 'Transfer Bank',
      'subtitle': 'BCA / Mandiri / BNI/ BRI',
      'icon': Icons.local_atm,
      'color': Color(0xFF4ECDC4),
    },
    {
      'name': 'Kartu Kredit',
      'subtitle': 'Visa / Mastercard',
      'icon': Icons.credit_card,
      'color': Color(0xFF95E1D3),
    },
    {
      'name': 'Cash (Bayar di Kasir)',
      'subtitle': 'Bayar langsung di salon',
      'icon': Icons.money,
      'color': Color(0xFF38B000),
    },
  ];

  late String _paymentMethod;
  late String _formattedPrice;

  @override
  void initState() {
    super.initState();
    _paymentMethod = _paymentOptions[0]['name'];
    
    _formattedPrice = widget.service['formatted_price'] ?? 
      NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(widget.service['price']);
  }

  Future<void> _processBooking() async {
    if (widget.bookingTime.isBefore(DateTime.now())) {
      _showErrorDialog('Booking time cannot be in the past');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await supabase.from('bookings').insert({
        'user_id': userId,
        'salon_id': widget.salon['id'],
        'service_id': widget.service['id'],
        'pet_name': widget.pet.name,
        'pet_breed': widget.pet.breed,
        'booking_time': widget.bookingTime.toIso8601String(),
        'total_price': (widget.service['price'] as double).round(),
        'status': _paymentMethod == 'Cash (Bayar di Kasir)' ? 'Pending Payment' : 'Confirmed',
        'payment_method': _paymentMethod,
        'display_price': _formattedPrice,
        'display_timezone': widget.bookingTimezone,
      }).select();

      if (response.isEmpty) {
        throw Exception('Failed to create booking');
      }

      final bookingId = response[0]['id'] as int;

      await NotificationService().showBookingConfirmation(
        petName: widget.pet.name,
        salonName: widget.salon['name'],
        bookingTime: widget.bookingTime,
      );

      await NotificationService().scheduleBookingReminders(
        bookingId: bookingId,
        petName: widget.pet.name,
        salonName: widget.salon['name'],
        bookingTime: widget.bookingTime,
      );

      if (_paymentMethod != 'Cash (Bayar di Kasir)') {
        await NotificationService().showPaymentSuccess(
          petName: widget.pet.name,
          amount: _formattedPrice,
        );
      }

      final reengagementTime = widget.bookingTime.add(const Duration(days: 45));
      await NotificationService().scheduleNotification(
        id: bookingId + 100000,
        title: "Time for Another Grooming! 🐾",
        body: "It's been 45 days since ${widget.pet.name}'s last visit at ${widget.salon['name']}. Book another appointment?",
        scheduledTime: reengagementTime,
        payload: 'reengagement_$bookingId',
      );

      if (mounted) {
        await _showSuccessDialog(bookingId);

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => BookingDetailScreen(bookingId: bookingId),
          ),
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      debugPrint('❌ Booking error: $e');
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showSuccessDialog(int bookingId) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 64,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Booking Successful!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your booking ID: #$bookingId',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.mediumGrey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _paymentMethod == 'Cash (Bayar di Kasir)'
                  ? 'Please pay at the salon counter'
                  : 'Payment has been processed',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.mediumGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[700]),
            const SizedBox(width: 8),
            const Text('Booking Failed'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment & Confirmation"),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order Summary",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            Icons.store,
                            "Salon",
                            widget.salon['name'],
                          ),
                          Divider(color: AppColors.lightGrey),
                          _buildDetailRow(
                            Icons.spa,
                            "Service",
                            widget.service['name'],
                          ),
                          Divider(color: AppColors.lightGrey),
                          _buildDetailRow(
                            Icons.pets,
                            "Pet",
                            "${widget.pet.name} (${widget.pet.breed})",
                          ),
                          Divider(color: AppColors.lightGrey),
                          _buildDetailRow(
                            Icons.calendar_today,
                            "Schedule",
                            "${DateFormat('EEEE, dd MMM yyyy • HH:mm').format(widget.bookingTime)} ${widget.bookingTimezone}",
                          ),
                          Divider(color: AppColors.lightGrey),
                          _buildDetailRow(
                            Icons.access_time,
                            "Duration",
                            widget.service['duration'] ?? '-',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Payment Method",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _paymentOptions.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final option = _paymentOptions[index];
                      final isSelected = _paymentMethod == option['name'];

                      return Card(
                        color: Colors.white,
                        elevation: isSelected ? 3 : 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (option['color'] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              option['icon'],
                              color: option['color'],
                            ),
                          ),
                          title: Text(
                            option['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          subtitle: Text(
                            option['subtitle'],
                            style: TextStyle(
                              color: AppColors.mediumGrey,
                              fontSize: 12,
                            ),
                          ),
                          trailing: Radio<String>(
                            value: option['name'],
                            groupValue: _paymentMethod,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _paymentMethod = value);
                              }
                            },
                            activeColor: AppColors.primary,
                          ),
                          onTap: () {
                            setState(() => _paymentMethod = option['name']);
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total Price",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.mediumGrey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formattedPrice,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.payments,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _processBooking,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _paymentMethod == "Cash (Bayar di Kasir)"
                                      ? Icons.check_circle_outline
                                      : Icons.payment,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _paymentMethod == "Cash (Bayar di Kasir)"
                                      ? "Confirm Booking"
                                      : "Pay & Confirm",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.mediumGrey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
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