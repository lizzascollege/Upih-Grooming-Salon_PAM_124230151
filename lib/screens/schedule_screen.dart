import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:upih_pet_grooming/models/pet_model.dart';
import 'package:upih_pet_grooming/screens/payment_screen.dart';
import 'package:upih_pet_grooming/utils/app_colors.dart';

class ScheduleScreen extends StatefulWidget {
  final Map<String, dynamic> salon;
  final Map<String, dynamic> service;

  const ScheduleScreen({
    super.key,
    required this.salon,
    required this.service,
  });

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  PetModel? _selectedPet;
  final Box<PetModel> _petBox = Hive.box<PetModel>('myPetsBox');
  List<PetModel> _myPets = [];

  String _selectedCurrency = 'IDR';
  String _selectedTimezone = 'WIB';

  final Map<String, Map<String, dynamic>> _currencies = {
    'IDR': {'symbol': 'Rp', 'rate': 1.0},
    'USD': {'symbol': '\$', 'rate': 0.000063},
    'JPY': {'symbol': '¥', 'rate': 0.0095},
    'KRW': {'symbol': '₩', 'rate': 0.085},
    'GBP': {'symbol': '£', 'rate': 0.000051},
    'SAR': {'symbol': '﷼', 'rate': 0.00024},
  };

  final Map<String, Map<String, dynamic>> _timezones = {
    'WIB': {'offset': 0, 'utc': 7},
    'WITA': {'offset': 1, 'utc': 8},
    'WIT': {'offset': 2, 'utc': 9},
    'GMT': {'offset': -7, 'utc': 0},
    'AEDT': {'offset': 4, 'utc': 11},
    'CET': {'offset': -6, 'utc': 1},
  };

  @override
  void initState() {
    super.initState();
    _myPets = _petBox.values.toList();
    if (_myPets.isNotEmpty) {
      _selectedPet = _myPets[0];
    }
  }

  double _getConvertedPriceValue() {
    final basePrice = widget.service['price'] ?? 0;
    final rate = _currencies[_selectedCurrency]!['rate'] as double;
    return basePrice * rate;
  }

  String _getConvertedPrice() {
    final convertedPrice = _getConvertedPriceValue();
    final symbol = _currencies[_selectedCurrency]!['symbol'];

    if (_selectedCurrency == 'IDR') {
      return '$symbol${NumberFormat('#,##0', 'id_ID').format(convertedPrice)}';
    } else if (_selectedCurrency == 'JPY' || _selectedCurrency == 'KRW') {
      return '$symbol${NumberFormat('#,##0').format(convertedPrice)}';
    } else {
      return '$symbol${NumberFormat('#,##0.00').format(convertedPrice)}';
    }
  }

  DateTime _getConvertedBookingTime() {
    if (_selectedDate == null || _selectedTime == null) {
      return DateTime.now();
    }
    
    final wibDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    
    final wibOffsetHours = _timezones['WIB']!['utc'] as int;
    final targetOffsetHours = _timezones[_selectedTimezone]!['utc'] as int;
    
    final utcDateTime = wibDateTime.subtract(Duration(hours: wibOffsetHours));
    
    final targetDateTime = utcDateTime.add(Duration(hours: targetOffsetHours));
    
    return targetDateTime;
  }

  String _getConvertedTime() {
    if (_selectedTime == null) return "Select Time";
    
    final offset = _timezones[_selectedTimezone]!['offset'] as int;
    int hour = _selectedTime!.hour + offset;
    
    if (hour < 0) hour = 24 + hour;
    else if (hour >= 24) hour = hour - 24;
    
    return '${hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textLight,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final openHourWIB = int.parse(widget.salon['open'].split(':')[0]);
    final openMinuteWIB = int.parse(widget.salon['open'].split(':')[1]);
    final closeHourWIB = int.parse(widget.salon['close'].split(':')[0]);
    final closeMinuteWIB = int.parse(widget.salon['close'].split(':')[1]);

    final offset = _timezones[_selectedTimezone]!['offset'] as int;
    int initialHour = openHourWIB + offset;
    if (initialHour < 0) initialHour = 24 + initialHour;
    else if (initialHour >= 24) initialHour = initialHour - 24;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: openMinuteWIB),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      int wibHour = time.hour - offset;
      if (wibHour < 0) wibHour = 24 + wibHour;
      else if (wibHour >= 24) wibHour = wibHour - 24;

      final chosenTimeInMinutes = wibHour * 60.0 + time.minute;
      final openTimeInMinutes = openHourWIB * 60.0 + openMinuteWIB;
      final closeTimeInMinutes = closeHourWIB * 60.0 + closeMinuteWIB;

      if (chosenTimeInMinutes >= openTimeInMinutes && chosenTimeInMinutes < closeTimeInMinutes) {
        setState(() => _selectedTime = TimeOfDay(hour: wibHour, minute: time.minute));
      } else {
        setState(() => _selectedTime = null);
        
        int userOpenHour = openHourWIB + offset;
        int userCloseHour = closeHourWIB + offset;
        if (userOpenHour < 0) userOpenHour = 24 + userOpenHour;
        else if (userOpenHour >= 24) userOpenHour = userOpenHour - 24;
        if (userCloseHour < 0) userCloseHour = 24 + userCloseHour;
        else if (userCloseHour >= 24) userCloseHour = userCloseHour - 24;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Outside operational hours!\nOpen: ${userOpenHour.toString().padLeft(2, '0')}:${openMinuteWIB.toString().padLeft(2, '0')} - ${userCloseHour.toString().padLeft(2, '0')}:${closeMinuteWIB.toString().padLeft(2, '0')} $_selectedTimezone',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red[700],
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showTimezoneHelp() {
    final openHour = int.parse(widget.salon['open'].split(':')[0]);
    final closeHour = int.parse(widget.salon['close'].split(':')[0]);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: AppColors.primary),
                SizedBox(width: 8),
                Text("Time Zone Help", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 16),
            Text("Operational: ${widget.salon['open']} - ${widget.salon['close']} WIB"),
            SizedBox(height: 16),
            ...['WIB', 'WITA', 'WIT', 'GMT', 'AEDT', 'CET'].map((tz) {
              final offset = _timezones[tz]!['offset'] as int;
              int open = openHour + offset;
              int close = closeHour + offset;
              if (open < 0) open = 24 + open;
              else if (open >= 24) open = open - 24;
              if (close < 0) close = 24 + close;
              else if (close >= 24) close = close - 24;
              
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text('$tz: $open:00 - $close:00', style: TextStyle(fontSize: 14)),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String label, required String value, required IconData icon, VoidCallback? onTap, Widget? trailing}) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    SizedBox(height: 4),
                    Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({required String value, required List<String> items, required Function(String?) onChanged, double width = 100}) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, size: 18),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)))).toList(),
          onChanged: onChanged,
          dropdownColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Schedule Booking"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.spa, color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Expanded(child: Text(widget.service['name'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.white70, size: 16),
                        SizedBox(width: 4),
                        Text(widget.salon['name'], style: TextStyle(fontSize: 14, color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              Text("Price", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _buildInfoCard(
                label: 'Service Price',
                value: _getConvertedPrice(),
                icon: Icons.payments,
                trailing: _buildDropdown(
                  value: _selectedCurrency,
                  items: _currencies.keys.toList(),
                  onChanged: (val) => setState(() => _selectedCurrency = val!),
                ),
              ),

              Text("Select Pet", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _myPets.isEmpty
                  ? Card(
                      color: Colors.orange[50],
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange[700]),
                            SizedBox(width: 12),
                            Expanded(child: Text("No pet data. Add in Profile menu.", style: TextStyle(color: Colors.orange[900]))),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonFormField<PetModel>(
                        value: _selectedPet,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.pets, color: AppColors.primary),
                        ),
                        items: _myPets.map((pet) => DropdownMenuItem(value: pet, child: Text("${pet.name} (${pet.breed})"))).toList(),
                        onChanged: (pet) => setState(() => _selectedPet = pet),
                        dropdownColor: Colors.white,
                      ),
                    ),
              SizedBox(height: 24),

              Text("Select Date", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _buildInfoCard(
                label: 'Booking Date',
                value: _selectedDate == null ? "Tap to select date" : DateFormat('EEEE, dd MMM yyyy').format(_selectedDate!),
                icon: Icons.calendar_today,
                onTap: _pickDate,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Select Time", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: _showTimezoneHelp,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.help_outline, size: 16),
                        SizedBox(width: 4),
                        Text("Help", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              _buildInfoCard(
                label: 'Booking Time',
                value: _getConvertedTime(),
                icon: Icons.access_time,
                onTap: _pickTime,
                trailing: _buildDropdown(
                  value: _selectedTimezone,
                  items: _timezones.keys.toList(),
                  onChanged: (val) => setState(() => _selectedTimezone = val!),
                  width: 90,
                ),
              ),
              SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: (_selectedDate == null || _selectedTime == null || _selectedPet == null)
                      ? null
                      : () {
                          
                          Map<String, dynamic> convertedService = Map.from(widget.service);
                          
                          convertedService['price'] = _getConvertedPriceValue();
                          
                          convertedService['formatted_price'] = _getConvertedPrice();
                          
                          convertedService['currency_symbol'] = _currencies[_selectedCurrency]!['symbol'];
                          convertedService['currency_code'] = _selectedCurrency;

                          DateTime convertedBookingTime = _getConvertedBookingTime();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentScreen(
                                salon: widget.salon,
                                service: convertedService, 
                                pet: _selectedPet!,
                                bookingTime: convertedBookingTime,
                                bookingTimezone: _selectedTimezone,
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text("Proceed to Payment", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}