import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upih_pet_grooming/models/pet_model.dart';
import 'package:upih_pet_grooming/screens/main_wrapper.dart';
import 'package:upih_pet_grooming/screens/login_screen.dart';
import 'package:upih_pet_grooming/services/auth_service.dart';
import 'package:upih_pet_grooming/services/notification_service.dart';
import 'package:upih_pet_grooming/utils/app_colors.dart';
import 'package:upih_pet_grooming/utils/route_observer.dart';
import 'package:permission_handler/permission_handler.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    var status = await Permission.notification.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      debugPrint('🚨 Meminta izin notifikasi...');
      await Permission.notification.request();
    }
    // Cek status setelah request (Opsional, untuk debug)
    status = await Permission.notification.status;
    if (status.isGranted) {
      debugPrint('✅ Izin Notifikasi Diberikan!');
    } else {
      debugPrint('❌ Izin Notifikasi Ditolak atau Dibatalkan. Status: $status');
    }
  } catch (e) {
    debugPrint('⚠️ Error saat meminta izin notifikasi: $e');
  }

  await Supabase.initialize(
    url: 'https://dozzwqcxrwzvgnlooyow.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRvenp3cWN4cnd6dmdubG9veW93Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE4MTYzOTYsImV4cCI6MjA3NzM5MjM5Nn0.3kL1Wh5ADdT066Y6NJUbIXEfCJDWZyxvV8Fxq9kwOhk',
  );

  await Hive.initFlutter();
  Hive.registerAdapter(PetModelAdapter()); 
  await Hive.openBox<PetModel>('myPetsBox'); 

  final prefs = await SharedPreferences.getInstance();
  await NotificationService().initNotifications();
  runApp(MyApp(prefs: prefs));
}


class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MyApp({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthService(prefs),
      child: Consumer<AuthService>(
        builder: (context, authService, child) {
          return MaterialApp(
            title: 'Upih Pet Grooming',
            debugShowCheckedModeBanner: false,
            
            theme: ThemeData(
              fontFamily: GoogleFonts.unbounded().fontFamily,
              primaryColor: AppColors.primary,
              scaffoldBackgroundColor: AppColors.background,
              colorScheme: ColorScheme.fromSwatch().copyWith(
                primary: AppColors.primary,
                secondary: AppColors.accent,
                background: AppColors.background,
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: AppColors.background,
                elevation: 0,
                centerTitle: true,
                iconTheme: IconThemeData(color: AppColors.textDark),
                titleTextStyle: GoogleFonts.unbounded(
                  color: AppColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textLight,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: GoogleFonts.unbounded(
                    fontSize: 16, 
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: AppColors.textFieldBg,
                contentPadding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0), 
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                hintStyle: TextStyle(
                  color: AppColors.mediumGrey,
                  fontSize: 14,
                ),
              ),
            ),

            navigatorObservers: [routeObserver],

            home: authService.isLoggedIn ? MainWrapper(initialIndex: 0,) : LoginScreen(),
          );
        },
      ),
    );
  }
}