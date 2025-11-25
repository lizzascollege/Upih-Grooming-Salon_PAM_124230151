// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  
  final SupabaseClient _supabase = Supabase.instance.client;
  
  final String _exchangeRateApiKey = "https://dozzwqcxrwzvgnlooyow.supabase.co";


  Future<List<dynamic>> getNearbySalons() async {
    try {
      final response = await _supabase.from('salons').select();
      return response;
    } catch (e) {
      print("Error getNearbySalons: $e");
      return [
        {"id": 1, "name": "Salon MeowGukGuk (Dummy)", "address": "Jl. Gagal API No. 1", "rating": 4.8, "open": "09:00", "close": "17:00"},
      ];
    }
  }

  Future<List<dynamic>> getServicesBySalon(int salonId) async {
     try {
      final response = await _supabase
          .from('services')
          .select()
          .eq('salon_id', salonId);
      
      return response;
    } catch (e) {
      print("Error getServicesBySalon: $e");
      return []; 
    }
  }

  Future<List<dynamic>> getMyBookings() async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('*, salons (name, address, image_url)')
          .order('booking_time', ascending: false);
          
      return response;
    } catch (e) {
      print("Error getMyBookings: $e");
      return [];
    }
  }

  Future<bool> createBooking({
    required DateTime bookingTime,
    required String petName,
    required int salonId,
    required int serviceId,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception("User tidak login");
      }

      final bookingData = {
        'booking_time': bookingTime.toIso8601String(),
        'pet_name': petName,
        'salon_id': salonId,
        'service_id': serviceId,
        'user_id': userId,
        'status': 'Menunggu'
      };

      await _supabase.from('bookings').insert(bookingData);
      
      return true; 
    } catch (e) {
      print("Error createBooking: $e");
      return false; 
    }
  }
  
  Future<Map<String, dynamic>?> getUpcomingBooking() async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('*, salons (name)') 
          .eq('status', 'Menunggu') 
          .order('booking_time', ascending: true) 
          .limit(1); 

      if (response.isNotEmpty) {
        return response[0]; 
      }
      return null; 
    } catch (e) {
      print("Error getUpcomingBooking: $e");
      return null;
    }
  }


  Future<Map<String, dynamic>> getExchangeRates() async {
    try {
      final response = await http.get(Uri.parse(
          'https://v6.exchangerate-api.com/v6/$_exchangeRateApiKey/latest/IDR'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body)['conversion_rates'];
      } else {
        throw Exception('Gagal memuat kurs');
      }
    } catch (e) {
      print("Gagal ambil kurs: $e. Menggunakan data dummy.");
      return {
        "USD": 0.000060,
        "JPY": 0.0092,
        "SGD": 0.000081,
      };
    }
  }

  Future<String?> uploadProfileImage(XFile imageFile) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception("User belum login");
      }

      // Ambil bytes data gambar (Universal: Web & Mobile bisa baca bytes)
      final bytes = await imageFile.readAsBytes();

      // Ambil ekstensi file
      final fileExt = imageFile.name.split('.').last;
      final fileName = '$userId/profile.$fileExt';
      
      // Upload menggunakan uploadBinary (Bukan upload biasa)
      await _supabase.storage
          .from('profile_images') 
          .uploadBinary(
            fileName, 
            bytes,
            fileOptions: FileOptions(
                cacheControl: '3600', 
                upsert: true,
                contentType: 'image/$fileExt' // Penting untuk Web agar gambar bisa dibuka di browser
            )
          );
      
      // Ambil URL Publik
      final publicUrl = _supabase.storage
          .from('profile_images')
          .getPublicUrl(fileName);
          
      return publicUrl;
    } catch (e) {
      print("Detailed Upload Error: $e"); 
      throw Exception("Upload Error: $e");
    }
  }
}