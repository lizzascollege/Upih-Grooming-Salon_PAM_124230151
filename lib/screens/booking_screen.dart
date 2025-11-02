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
    'IDR': {'symbol': 'Rp', 'rate': 1.0, 'name': 'Indonesian Rupiah'},
    'USD': {'symbol': '\$', 'rate': 0.000063, 'name': 'US Dollar'},
    'JPY': {'symbol': '¥', 'rate': 0.0095, 'name': 'Japanese Yen'},
    'KRW': {'symbol': '₩', 'rate': 0.085, 'name': 'Korean Won'},
    'GBP': {'symbol': '£', 'rate': 0.000051, 'name': 'British Pound'},
    'SAR': {'symbol': '﷼', 'rate': 0.00024, 'name': 'Saudi Riyal'},
  };

  final Map<String, Map<String, dynamic>> _timezones = {
    'WIB': {'offset': 0, 'name': 'Western Indonesia Time', 'utc': 7},
    'WITA': {'offset': 1, 'name': 'Central Indonesia Time', 'utc': 8},
    'WIT': {'offset': 2, 'name': 'Eastern Indonesia Time', 'utc': 9},
    'GMT': {'offset': -7, 'name': 'London Time', 'utc': 0},
    'AEDT': {'offset': 4, 'name': 'Australia (Sydney)', 'utc': 11},
    'CET': {'offset': -6, 'name': 'Central Europe Time', 'utc': 1},
  };

  @override
  void initState() {
    super.initState();
    _myPets = _petBox.values.toList();
    if (_myPets.isNotEmpty) {
      _selectedPet = _myPets[0];
    }
  }

  String _getConvertedPrice() {
    final basePrice = widget.service['price'] ?? 0;
    final rate = _currencies[_selectedCurrency]!['rate'] as double;
    final convertedPrice = basePrice * rate;
    final symbol = _currencies[_selectedCurrency]!['symbol'];

    if (_selectedCurrency == 'IDR') {
      return '$symbol${NumberFormat('#,##0', 'id_ID').format(convertedPrice)}';
    } else if (_selectedCurrency == 'JPY' || _selectedCurrency == 'KRW') {
      return '$symbol${NumberFormat('#,##0').format(convertedPrice)}';
    } else {
      return '$symbol${NumberFormat('#,##0.00').format(convertedPrice)}';
    }
  }

  String _getConvertedTime() {
    if (_selectedTime == null) return "Select Time";
    
    final offset = _timezones[_selectedTimezone]!['offset'] as int;
    int hour = (_selectedTime!.hour + offset);
    
    if (hour < 0) {
      hour = 24 + hour;
    } else if (hour >= 24) {
      hour = hour - 24;
    }
    
    final minute = _selectedTime!.minute;
    
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  TimeOfDay _convertTimeToWIB(TimeOfDay displayedTime) {
    final offset = _timezones[_selectedTimezone]!['offset'] as int;
    int wibHour = (displayedTime.hour - offset);
    
    if (wibHour < 0) {
      wibHour = 24 + wibHour;
    } else if (wibHour >= 24) {
      wibHour = wibHour - 24;
    }
    
    return TimeOfDay(hour: wibHour, minute: displayedTime.minute);
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
              onSurface: AppColors.textDark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _pickTime() async {
    final String openString = widget.salon['open'];
    final String closeString = widget.salon['close'];

    final int openHourWIB = int.parse(openString.split(':')[0]);
    final int openMinuteWIB = int.parse(openString.split(':')[1]);
    final int closeHourWIB = int.parse(closeString.split(':')[0]);
    final int closeMinuteWIB = int.parse(closeString.split(':')[1]);

    final offset = _timezones[_selectedTimezone]!['offset'] as int;
    int initialHour = openHourWIB + offset;
    
    if (initialHour < 0) {
      initialHour = 24 + initialHour;
    } else if (initialHour >= 24) {
      initialHour = initialHour - 24;
    }
    
    final TimeOfDay initialTime = TimeOfDay(
      hour: initialHour,
      minute: openMinuteWIB,
    );

    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textLight,
              onSurface: AppColors.textDark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      int wibHour = time.hour - offset;
      
      if (wibHour < 0) {
        wibHour = 24 + wibHour;
      } else if (wibHour >= 24) {
        wibHour = wibHour - 24;
      }
      
      final TimeOfDay wibTime = TimeOfDay(hour: wibHour, minute: time.minute);
      final double chosenTimeInMinutes = wibTime.hour * 60.0 + wibTime.minute;
      final double openTimeInMinutes = openHourWIB * 60.0 + openMinuteWIB;
      final double closeTimeInMinutes = closeHourWIB * 60.0 + closeMinuteWIB;

      if (chosenTimeInMinutes >= openTimeInMinutes &&
          chosenTimeInMinutes < closeTimeInMinutes) {
        setState(() {
          _selectedTime = wibTime; 
        });
      } else {
        setState(() {
          _selectedTime = null;
        });

        if (mounted) {
          int userOpenHour = openHourWIB + offset;
          int userCloseHour = closeHourWIB + offset;
          
          if (userOpenHour < 0) userOpenHour = 24 + userOpenHour;
          else if (userOpenHour >= 24) userOpenHour = userOpenHour - 24;
          
          if (userCloseHour < 0) userCloseHour = 24 + userCloseHour;
          else if (userCloseHour >= 24) userCloseHour = userCloseHour - 24;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Booking time is outside salon operational hours!\n'
                'Operational: ${userOpenHour.toString().padLeft(2, '0')}:${openMinuteWIB.toString().padLeft(2, '0')} - '
                '${userCloseHour.toString().padLeft(2, '0')}:${closeMinuteWIB.toString().padLeft(2, '0')} $_selectedTimezone\n'
                '(WIB: $openString - $closeString)',
                textAlign: TextAlign.center,
              ),
              backgroundColor: Colors.red[700],
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    }
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      "Time Zone Assistance",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  "Salon operational hours: ${widget.salon['open']} - ${widget.salon['close']} WIB",
                  style: TextStyle(color: AppColors.mediumGrey),
                ),
                SizedBox(height: 16),
                _buildTimezoneRow("WIB (Jakarta)", openHourWIB, closeHourWIB, 7),
                _buildTimezoneRow("WITA (Makassar)", openHourWIB + 1, closeHourWIB + 1, 8),
                _buildTimezoneRow("WIT (Jayapura)", openHourWIB + 2, closeHourWIB + 2, 9),
                _buildTimezoneRow("GMT (London)", openHourWIB - 7, closeHourWIB - 7, 0),
                _buildTimezoneRow("AEDT (Sydney)", openHourWIB + 4, closeHourWIB + 4, 11),
                _buildTimezoneRow("CET (Europe)", openHourWIB - 6, closeHourWIB - 6, 1),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimezoneRow(String zone, int open, int close, int offset) {
    final now = DateTime.now().toUtc().add(Duration(hours: offset));
    String openStr = open < 0 ? "${24 + open}:00" : open >= 24 ? "${open - 24}:00" : "$open:00";
    String closeStr = close < 0 ? "${24 + close}:00" : close >= 24 ? "${close - 24}:00" : "$close:00";
    
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
                  color: AppColors.textDark,
                ),
              ),
              Text(
                "Operational: $openStr - $closeStr",
                style: TextStyle(fontSize: 14, color: AppColors.mediumGrey),
              ),
            ],
          ),
          Text(
            DateFormat('HH:mm').format(now),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Card(
      color: Colors.white,
      elevation: 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mediumGrey,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
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

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    double width = 100,
  }) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          icon: Icon(Icons.keyboard_arrow_down, size: 20),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.spa, color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.service['name'],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.white70, size: 16),
                        SizedBox(width: 4),
                        Text(
                          widget.salon['name'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Text(
                "Price",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 12),
              _buildInfoCard(
                label: 'Service Price',
                value: _getConvertedPrice(),
                icon: Icons.payments,
                trailing: _buildDropdown(
                  value: _selectedCurrency,
                  items: _currencies.keys.toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCurrency = val!;
                    });
                  },
                ),
              ),
              SizedBox(height: 24),

              Text(
                "Select Pet",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 12),
              _myPets.isEmpty
                  ? Card(
                      color: Colors.orange[50],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.orange[200]!),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange[700]),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "You don't have any pet data yet. Add it in the Profile menu.",
                                style: TextStyle(color: Colors.orange[900]),
                              ),
                            ),
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
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        items: _myPets.map((pet) {
                          return DropdownMenuItem<PetModel>(
                            value: pet,
                            child: Text("${pet.name} (${pet.breed})"),
                          );
                        }).toList(),
                        onChanged: (pet) {
                          setState(() {
                            _selectedPet = pet;
                          });
                        },
                        dropdownColor: Colors.white,
                        icon: Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                      ),
                    ),
              SizedBox(height: 24),

              Text(
                "Select Date",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 12),
              _buildInfoCard(
                label: 'Booking Date',
                value: _selectedDate == null
                    ? "Tap to select date"
                    : DateFormat('EEEE, dd MMM yyyy').format(_selectedDate!),
                icon: Icons.calendar_today,
                onTap: _pickDate,
              ),
              SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select Time",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showTimezoneHelp(context),
                    icon: Icon(Icons.help_outline, size: 18),
                    label: Text("Help"),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              _buildInfoCard(
                label: 'Booking Time',
                value: _getConvertedTime(),
                icon: Icons.access_time,
                onTap: _pickTime,
                trailing: _buildDropdown(
                  value: _selectedTimezone,
                  items: _timezones.keys.toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedTimezone = val!;
                    });
                  },
                  width: 90,
                ),
              ),
              SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: (_selectedDate == null ||
                          _selectedTime == null ||
                          _selectedPet == null)
                      ? null
                      : () {
                          final bookingDateTime = DateTime(
                            _selectedDate!.year,
                            _selectedDate!.month,
                            _selectedDate!.day,
                            _selectedTime!.hour,
                            _selectedTime!.minute,
                          );

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PaymentScreen(
                                salon: widget.salon,
                                service: widget.service,
                                pet: _selectedPet!,
                                bookingTime: bookingDateTime,
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    "Proceed to Payment",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}