import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:upih_pet_grooming/models/pet_model.dart';
import 'package:upih_pet_grooming/screens/article_detail.dart';
import 'package:upih_pet_grooming/screens/my_pets_screen.dart';
import 'package:upih_pet_grooming/services/api_service.dart';
import 'package:upih_pet_grooming/services/auth_service.dart';
import 'package:upih_pet_grooming/services/notification_service.dart';
import 'package:upih_pet_grooming/utils/app_colors.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final List<Map<String, String>> dummyArticles = [
  {
    "title": "5 Cara Merawat Bulu Hewan Peliharaan Tetap Sehat",
    "snippet": "Bulu yang sehat adalah tanda hewan peliharaan yang bahagia...",
    "imageUrl": "https://dozzwqcxrwzvgnlooyow.supabase.co/storage/v1/object/public/salon_images/Cute%20dog%20with%20a%20towel%20_%20Premium%20Photo.jpeg",
    "content": "Merawat bulu hewan peliharaan bukan hanya soal penampilan yang menggemaskan, tetapi juga tentang menjaga kesehatan kulit dan mencegah berbagai masalah kesehatan. Bulu yang terawat dengan baik mencerminkan kondisi kesehatan hewan secara keseluruhan.\n\nBerikut 5 cara mudah untuk menjaga bulu hewan peliharaan Anda tetap sehat dan berkilau:\n\n1. Sikat Bulu Secara Rutin: Menyisir bulu setiap hari membantu menghilangkan bulu mati, kotoran, dan mencegah gimbal. Untuk hewan berbulu panjang, sisir minimal 2 kali sehari. Gunakan sisir khusus sesuai jenis bulu hewan Anda.\n\n2. Mandikan Sesuai Kebutuhan: Frekuensi mandi tergantung jenis hewan dan aktivitasnya. Terlalu sering mandi dapat menghilangkan minyak alami kulit yang justru melindungi bulu. Umumnya 2-4 minggu sekali sudah cukup.\n\n3. Pilih Shampoo yang Tepat: Gunakan produk perawatan khusus hewan peliharaan dengan pH seimbang. Hindari shampoo manusia karena dapat menyebabkan iritasi kulit. Pilih yang mengandung bahan alami seperti oatmeal atau aloe vera.\n\n4. Berikan Makanan Bergizi: Nutrisi yang baik tercermin pada kondisi bulu. Pastikan makanan mengandung protein berkualitas, omega-3, dan omega-6 yang penting untuk kesehatan kulit dan bulu. Konsultasikan dengan dokter hewan untuk diet terbaik.\n\n5. Periksa Kesehatan Kulit Secara Rutin: Lakukan pengecekan rutin untuk mendeteksi kutu, tungau, atau masalah kulit lainnya. Perhatikan tanda-tanda kemerahan, ketombe berlebihan, atau bau tidak sedap. Konsultasikan segera ke dokter hewan jika menemukan kelainan.\n\nJangan lupa, setiap hewan memiliki kebutuhan perawatan yang berbeda. Yang terpenting adalah konsistensi dan perhatian rutin terhadap kesehatan bulu dan kulit mereka."
  },
  {
    "title": "Kapan Hewan Peliharaan Perlu Grooming Profesional?",
    "snippet": "Tidak semua hewan bisa merawat diri sendiri dengan sempurna...",
    "imageUrl": "https://dozzwqcxrwzvgnlooyow.supabase.co/storage/v1/object/public/salon_images/Midjourney_%20%20Surprised%20orange%20tabby%20cat%20with%20wide%20eyes%20and%20open%20mouth_.jpeg",
    "content": "Meskipun banyak hewan peliharaan memiliki kemampuan alami untuk membersihkan diri, ada kalanya mereka membutuhkan bantuan profesional untuk menjaga kesehatan dan kenyamanan optimal.\n\nBerikut adalah tanda-tanda hewan peliharaan Anda perlu grooming profesional:\n\n1. Bulu Gimbal atau Kusut Parah: Gimbal tidak hanya membuat penampilan tidak rapi, tetapi juga dapat menyebabkan iritasi kulit, infeksi, dan ketidaknyamanan saat bergerak. Groomer profesional memiliki alat dan teknik khusus untuk mengatasi gimbal tanpa menyakiti hewan.\n\n2. Kuku Terlalu Panjang: Kuku yang tidak terpotong secara rutin dapat menyebabkan masalah berjalan, nyeri sendi, bahkan cedera. Groomer terlatih dapat memotong kuku dengan aman tanpa melukai pembuluh darah di dalamnya.\n\n3. Masalah Kebersihan yang Sulit Diatasi: Ketika hewan terkena kotoran, lumpur, atau zat lengket yang sulit dibersihkan di rumah, grooming profesional adalah solusi terbaik. Mereka memiliki produk dan peralatan yang tepat untuk membersihkan dengan aman.\n\n4. Hewan Tua atau Obesitas: Hewan yang sudah berusia lanjut atau memiliki berat badan berlebih sering kesulitan menjangkau bagian tubuh tertentu untuk membersihkan diri. Grooming rutin membantu menjaga kebersihan dan mencegah masalah kulit.\n\nGrooming profesional sebaiknya dilakukan setiap 4-8 minggu tergantung jenis, ras, dan gaya hidup hewan peliharaan Anda."
  },
  {
    "title": "Manfaat Olahraga Teratur untuk Hewan Peliharaan",
    "snippet": "Aktivitas fisik tidak hanya menyehatkan tubuh, tapi juga mental...",
    "imageUrl": "https://dozzwqcxrwzvgnlooyow.supabase.co/storage/v1/object/public/salon_images/How%20to%20Build%20a%20Raised%20Garden%20Bed.jpeg",
    "content": "Seperti manusia, hewan peliharaan juga membutuhkan aktivitas fisik rutin untuk menjaga kesehatan fisik dan mental. Sayangnya, banyak hewan peliharaan yang kurang mendapatkan latihan yang cukup, yang dapat menyebabkan berbagai masalah kesehatan.\n\nManfaat olahraga teratur untuk hewan peliharaan:\n\n1. Mengontrol Berat Badan: Obesitas adalah masalah serius yang dapat memicu diabetes, masalah sendi, dan penyakit jantung. Olahraga teratur membantu membakar kalori berlebih dan menjaga berat badan ideal.\n\n2. Meningkatkan Kesehatan Jantung: Aktivitas fisik memperkuat otot jantung dan meningkatkan sirkulasi darah, mengurangi risiko penyakit kardiovaskular.\n\n3. Menjaga Kesehatan Sendi: Gerakan teratur membantu melumasi sendi dan memperkuat otot pendukung, mengurangi risiko arthritis terutama pada hewan yang lebih tua.\n\n4. Mengurangi Masalah Perilaku: Hewan yang kurang aktivitas cenderung mengalami kebosanan yang dapat memicu perilaku destruktif seperti menggigit barang, menggores furniture, atau gonggongan berlebihan. Olahraga membantu menyalurkan energi dengan cara yang positif.\n\n5. Meningkatkan Kesehatan Mental: Aktivitas outdoor memberikan stimulasi mental melalui berbagai pemandangan, suara, dan bau yang berbeda. Ini penting untuk kebahagiaan dan kesejahteraan psikologis mereka.\n\n6. Memperkuat Ikatan dengan Pemilik: Waktu bermain dan berolahraga bersama adalah kesempatan quality time yang memperkuat hubungan antara hewan dan pemiliknya.\n\nIngat, konsistensi adalah kunci. Jadwalkan waktu olahraga rutin setiap hari untuk hasil optimal."
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
  List<PendingNotificationRequest> _pendingNotifications = [];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadPendingNotifications();
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

  Future<void> _loadPendingNotifications() async {
    final notifications = await NotificationService().getPendingNotifications();
    if (mounted) {
      setState(() {
        _pendingNotifications = notifications;
      });
    }
  }

  void _refreshData() {
    setState(() {
      _upcomingBookingKey = UniqueKey();
    });
    _loadPendingNotifications();
  }

  void _showNotificationCenter() async {
    await _loadPendingNotifications();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Notification Center",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "${_pendingNotifications.length} scheduled notifications",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.mediumGrey,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: AppColors.mediumGrey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Divider(),
                Expanded(
                  child: _pendingNotifications.isEmpty
                      ? _buildEmptyNotifications()
                      : ListView.separated(
                          controller: scrollController,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          itemCount: _pendingNotifications.length,
                          separatorBuilder: (context, index) => Divider(height: 1),
                          itemBuilder: (context, index) {
                            final notif = _pendingNotifications[index];
                            return _buildNotificationItem(notif);
                          },
                        ),
                ),
                if (_pendingNotifications.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border(top: BorderSide(color: Colors.grey[200]!)),
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                await NotificationService().cancelAllNotifications();
                                _loadPendingNotifications();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('All notifications cleared'),
                                      backgroundColor: Colors.green[700],
                                    ),
                                  );
                                }
                              },
                              icon: Icon(Icons.clear_all, size: 20),
                              label: Text('Clear All'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red[700],
                                side: BorderSide(color: Colors.red[700]!),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _loadPendingNotifications();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Notifications refreshed'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              icon: Icon(Icons.refresh, size: 20),
                              label: Text('Refresh'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyNotifications() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 16),
          Text(
            "No Scheduled Notifications",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "You'll see upcoming reminders here",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(PendingNotificationRequest notif) {
    IconData icon = Icons.notifications_active;
    Color iconColor = AppColors.primary;

    if (notif.title?.contains('Tomorrow') ?? false) {
      icon = Icons.calendar_today;
      iconColor = Colors.blue;
    } else if (notif.title?.contains('2 Hours') ?? false) {
      icon = Icons.schedule;
      iconColor = Colors.orange;
    } else if (notif.title?.contains('Time to Go') ?? false) {
      icon = Icons.directions_run;
      iconColor = Colors.red;
    } else if (notif.title?.contains('Re-engagement') ?? false) {
      icon = Icons.repeat;
      iconColor = Colors.purple;
    }

    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      leading: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        notif.title ?? 'Notification',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: AppColors.textDark,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (notif.body != null) ...[
            SizedBox(height: 4),
            Text(
              notif.body!,
              style: TextStyle(fontSize: 12, color: AppColors.mediumGrey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          SizedBox(height: 4),
          Text(
            'ID: ${notif.id}',
            style: TextStyle(fontSize: 11, color: Colors.grey[400]),
          ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(Icons.close, size: 20, color: Colors.grey),
        onPressed: () async {
          await NotificationService().cancelNotification(notif.id);
          _loadPendingNotifications();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Notification cancelled'),
                duration: Duration(seconds: 1),
              ),
            );
          }
        },
      ),
    );
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
                color: AppColors.textDark,
              ),
            ),
            Text(
              "Welcome to Upih Grooming Salon",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mediumGrey,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined),
                onPressed: _showNotificationCenter,
              ),
              if (_pendingNotifications.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '${_pendingNotifications.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
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
            _buildSectionTitle("Tips & Article 💡"),
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
              subtitle: Text("You don't have a booking schedule yet."),
            ),
          );
        }

        final booking = snapshot.data!;
        final salonName = booking['salons']?['name'] ?? 'Salon';
        final petName = booking['pet_name'] ?? 'Pet';
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
                Text("Find Salons", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text("Book Schedule", style: TextStyle(color: AppColors.mediumGrey)),
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