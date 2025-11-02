import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:upih_pet_grooming/models/pet_model.dart';
import 'package:upih_pet_grooming/screens/article_detail.dart';
import 'package:upih_pet_grooming/screens/my_pets_screen.dart';
import 'package:upih_pet_grooming/services/api_service.dart';
import 'package:upih_pet_grooming/services/auth_service.dart';
import 'package:upih_pet_grooming/utils/app_colors.dart';


final List<Map<String, String>> dummyArticles = [
  {
    "title": "5 Cara Bulu Anjing Tetap Sehat",
    "snippet": "Jaga kelembapan kulit dan pilih shampoo...",
    "imageUrl": "https://dozzwqcxrwzvgnlooyow.supabase.co/storage/v1/object/public/salon_images/Cute%20dog%20with%20a%20towel%20_%20Premium%20Photo.jpeg",
    "content": "Merawat bulu anjing bukan hanya soal penampilan, tapi juga kesehatan. Berikut 5 cara mudah: \n\n1. Sikat Bulu Secara Rutin: Ini membantu menghilangkan bulu mati dan kotoran.\n2. Mandikan Sesuai Kebutuhan: Terlalu sering mandi bisa membuat kulit kering.\n3. Pilih Shampoo yang Tepat: Gunakan shampoo khusus anjing.\n4. Beri Makanan Bergizi: Nutrisi yang baik tercermin pada bulu.\n5. Periksa dari Kutu: Lakukan pengecekan rutin."
  },
  {
    "title": "Kapan Kucing Perlu Grooming?",
    "snippet": "Meskipun bisa membersihkan diri...",
    "imageUrl": "https://dozzwqcxrwzvgnlooyow.supabase.co/storage/v1/object/public/salon_images/Midjourney_%20%20Surprised%20orange%20tabby%20cat%20with%20wide%20eyes%20and%20open%20mouth_.jpeg",
    "content": "Kucing memang dikenal sebagai hewan yang bersih. Namun, ada kalanya mereka butuh bantuan profesional. Kucing perlu grooming jika: \n\n1. Bulunya gimbal parah.\n2. Terkena kotoran yang sulit dibersihkan.\n3. Kucing sudah tua atau obesitas sehingga sulit menjangkau tubuhnya.\n4. Perawatan kuku rutin."
  },
  {
    "title": "Manfaat Olahraga Teratur untuk Hewan Peliharaan",
    "snippet": "Aktivitas fisik tidak hanya menyehatkan tubuh, tapi juga mental...",
    "imageUrl": "https://dozzwqcxrwzvgnlooyow.supabase.co/storage/v1/object/public/salon_images/How%20to%20Build%20a%20Raised%20Garden%20Bed.jpeg",
    "content": "Seperti manusia, hewan peliharaan juga membutuhkan aktivitas fisik rutin untuk menjaga kesehatan fisik dan mental. Sayangnya, banyak hewan peliharaan yang kurang mendapatkan latihan yang cukup, yang dapat menyebabkan berbagai masalah kesehatan.\n\nManfaat olahraga teratur untuk hewan peliharaan:\n\n1. Mengontrol Berat Badan: Obesitas adalah masalah serius yang dapat memicu diabetes, masalah sendi, dan penyakit jantung. Olahraga teratur membantu membakar kalori berlebih dan menjaga berat badan ideal.\n\n2. Meningkatkan Kesehatan Jantung: Aktivitas fisik memperkuat otot jantung dan meningkatkan sirkulasi darah, mengurangi risiko penyakit kardiovaskular.\n\n3. Menjaga Kesehatan Sendi: Gerakan teratur membantu melumasi sendi dan memperkuat otot pendukung, mengurangi risiko arthritis terutama pada hewan yang lebih tua.\n\n4. Mengurangi Masalah Perilaku: Hewan yang kurang aktivitas cenderung mengalami kebosanan yang dapat memicu perilaku destruktif seperti menggigit barang, menggores furniture, atau gonggongan berlebihan. Olahraga membantu menyalurkan energi dengan cara yang positif.\n\n5. Meningkatkan Kesehatan Mental: Aktivitas outdoor memberikan stimulasi mental melalui berbagai pemandangan, suara, dan bau yang berbeda. Ini penting untuk kebahagiaan dan kesejahteraan psikologis mereka.\n\n6. Memperkuat Ikatan dengan Pemilik: Waktu bermain dan berolahraga bersama adalah kesempatan quality time yang memperkuat hubungan antara hewan dan pemiliknya.\n\nTips olahraga yang aman:\n\n1. Sesuaikan Intensitas: Mulai dengan durasi pendek dan tingkatkan secara bertahap. Perhatikan usia, kondisi kesehatan, dan kemampuan hewan Anda.\n\n2. Variasi Aktivitas: Kombinasikan berbagai jenis aktivitas seperti jalan kaki, bermain lempar tangkap, berenang, atau bermain di taman.\n\n3. Perhatikan Cuaca: Hindari olahraga saat cuaca terlalu panas atau dingin ekstrem. Pilih waktu pagi atau sore hari saat cuaca lebih sejuk.\n\n4. Hidrasi yang Cukup: Selalu sediakan air bersih, terutama setelah aktivitas fisik.\n\n5. Konsultasi Dokter Hewan: Untuk hewan dengan kondisi kesehatan khusus, konsultasikan program olahraga yang aman dengan dokter hewan.\n\nIngat, konsistensi adalah kunci. Jadwalkan waktu olahraga rutin setiap hari untuk hasil optimal."
  },
];

class HomeScreen extends StatefulWidget {
  final void Function(int) onNavigateToTab;
  const HomeScreen({super.key, required this.onNavigateToTab});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = "User";
  final ApiService _apiService = ApiService();
  Key _upcomingBookingKey = UniqueKey(); 

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = await authService.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _userName = user.userMetadata?['full_name'] ?? 'User';
      });
    }
  }

  void _refreshData() {
    setState(() {
      _upcomingBookingKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Image.asset(
            'assets/logo.png',
            fit: BoxFit.contain,
          ),
        ),
        leadingWidth: 50,
        automaticallyImplyLeading: false, 
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Halo, $_userName! 🐾", 
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold, 
                color: AppColors.textDark
              )
            ),
            Text(
              "Welcome to Upih Grooming Salon", 
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mediumGrey
              )
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Fitur Notifikasi"),
                  content: Text("Halaman notifikasi akan dibuat di sini."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("OK"),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(width: 8), 
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainCta(context),
            SizedBox(height: 24),

            _buildUpcomingBookingCard(context),
            SizedBox(height: 24),

            _buildSectionTitle("Quick Access 🚀"),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildMyPetsCard(context)),
                SizedBox(width: 16),
                Expanded(child: _buildFindSalonCard(context)),
              ],
            ),
            SizedBox(height: 24),
            
            _buildSectionTitle("Tips & Articles 💡"),
            SizedBox(height: 14),
            ListView.builder(
              itemCount: dummyArticles.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(), 
              itemBuilder: (context, index) {
                final article = dummyArticles[index];
                return _buildArticleCard(
                  context,
                  article['title']!,
                  article['snippet']!,
                  article['imageUrl']!,
                  article['content']!,
                  Icons.article_outlined,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCta(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onNavigateToTab(1);
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage("https://dozzwqcxrwzvgnlooyow.supabase.co/storage/v1/object/public/salon_images/60%20Amazing%20Skills%20You%20Can%20Learn%20on%20YouTube.jpeg"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Need some grooming?",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white, 
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Book an appointment at the nearest salon for your beloved pet.",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.9)
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Book Now",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary, 
                  fontWeight: FontWeight.w600
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


  Widget _buildUpcomingBookingCard(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      key: _upcomingBookingKey,
      future: _apiService.getUpcomingBooking(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        
        if (!snapshot.hasData || snapshot.data == null) {
          return Card(
            elevation: 1.0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(Icons.calendar_today, color: AppColors.mediumGrey),
              title: Text("No Schedule", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              subtitle: Text("You don't have a grooming schedule yet."),
            ),
          );
        }

        final booking = snapshot.data!;
        final salonName = booking['salons']?['name'] ?? 'Salon';
        final petName = booking['pet_name'] ?? 'Anabul';
        final bookingTime = DateTime.parse(booking['booking_time']);
        
        return Card(
          elevation: 2,
          color: AppColors.accent.withOpacity(0.2), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(Icons.calendar_month, color: AppColors.accent, size: 30),
            title: Text(
              "Next Schedule: $petName",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold, 
                color: AppColors.textDark
              ),
            ),
            subtitle: Text(
              "$salonName\n${DateFormat('EEE, dd MMM yyyy • HH:mm').format(bookingTime)}",
              style: TextStyle(color: AppColors.textDark.withOpacity(0.8)),
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            isThreeLine: true,
            onTap: () {
              widget.onNavigateToTab(2);
              _refreshData(); 
            },
          ),
        );
      },
    );
  }


  Widget _buildMyPetsCard(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<PetModel>('myPetsBox').listenable(),
      builder: (context, Box<PetModel> box, _) {
        return InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyPetsScreen()));
          },
          child: Container(
            padding: EdgeInsets.all(16),
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.pets, size: 32, color: AppColors.primary),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${box.length}", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    Text("My Pets", style: TextStyle(color: AppColors.mediumGrey)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildFindSalonCard(BuildContext context) {
    return InkWell(
      onTap: () {
          widget.onNavigateToTab(1);
      },
      child: Container(
        padding: EdgeInsets.all(16),
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.search, size: 32, color: AppColors.accent),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Cari Salon", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text("Pesan Jadwal", style: TextStyle(color: AppColors.mediumGrey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.textDark, 
      ),
    );
  }
  
  Widget _buildArticleCard(BuildContext context, String title, String snippet, String imageUrl, String content, IconData icon) {
    return Card(
      elevation: 1.0,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary, size: 30),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(snippet),
        trailing: Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ArticleDetailScreen(
                title: title,
                content: content,
                imageUrl: imageUrl,
              ),
            ),
          );
        },
      ),
    );
  }
}
