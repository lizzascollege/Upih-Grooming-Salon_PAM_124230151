// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// test/widget_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mocktail/mocktail.dart'; // Pastikan sudah install dev:mocktail

// Ganti dengan path main.dart kamu
import 'package:upih_pet_grooming/main.dart'; 
import 'package:upih_pet_grooming/models/pet_model.dart';
import 'package:upih_pet_grooming/services/auth_service.dart';

// 1. Buat Mock untuk AuthService KITA SENDIRI
// Ini jauh lebih gampang daripada mock Supabase
class MockAuthService extends Mock implements AuthService {}

void main() {
  // --- SETUP WAJIB SEBELUM TES ---
  late MockAuthService mockAuthService;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Inisialisasi Hive untuk tes
    await Hive.initFlutter('test_path'); // Cukup ini
    // Daftarkan adapter jika belum
    if (!Hive.isAdapterRegistered(PetAdapter().typeId)) {
       Hive.registerAdapter(PetAdapter());
    }
  });

  // Setup sebelum TIAP tes
  setUp(() {
    mockAuthService = MockAuthService();
  });
  // --- BATAS SETUP ---


  testWidgets('App Smoke Test (Menampilkan Halaman Login)', (WidgetTester tester) async {
    // 2. Siapkan SharedPreferences palsu
    SharedPreferences.setMockInitialValues({});
    
    // 3. Atur agar mock service kita mengembalikan "isLoggedIn = false"
    // Ini adalah inti dari mock-nya
    when(() => mockAuthService.isLoggedIn).thenReturn(false);

    // 4. REVISI BAGIAN INI:
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthService>(
        create: (context) => mockAuthService, // 1. Gunakan MockAuthService
        child: MyApp(isLoggedIn: false),      // 2. Beri nilai isLoggedIn: false
      ),
    );

    // 5. Tes seperti biasa
    // Cek apakah 2 tombol di login_screen.dart muncul
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Daftar Akun Baru'), findsOneWidget);
  });
}