import 'package:flutter/material.dart';
import 'package:upih_pet_grooming/utils/app_colors.dart';

class ArticleDetailScreen extends StatelessWidget {
  final String title;
  final String content;
  final String imageUrl;

  const ArticleDetailScreen({
    super.key,
    required this.title,
    required this.content,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 18),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: Icon(Icons.pets, size: 60, color: Colors.grey[400]),
                        ),
                      );
                    },
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.white.withOpacity(0.9),
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.pets, size: 14, color: AppColors.primary),
                            SizedBox(width: 6),
                            Text(
                              'Care Tips',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),

                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                          height: 1.3,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 16),

                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primary.withOpacity(0.15),
                            child: Icon(Icons.edit, size: 18, color: AppColors.primary),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Upih Pet Grooming',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '${DateTime.now().day} ${_getMonthName(DateTime.now().month)} ${DateTime.now().year}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.access_time_rounded, size: 14, color: Colors.orange[700]),
                                SizedBox(width: 4),
                                Text(
                                  '5 min',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Divider(color: Colors.grey[200], thickness: 1),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._buildFormattedContent(content),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Divider(color: Colors.grey[200], thickness: 1),
                      SizedBox(height: 20),

                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Share this article:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            Row(
                              children: [
                                _buildShareButton(Icons.bookmark_outline, AppColors.primary),
                                SizedBox(width: 10),
                                _buildShareButton(Icons.share_outlined, Colors.blue[600]!),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFormattedContent(String content) {
    List<Widget> widgets = [];
    List<String> paragraphs = content.split('\n\n');
    
    for (String paragraph in paragraphs) {
      if (paragraph.trim().isEmpty) continue;
      
      if (paragraph.contains(RegExp(r'^\d+\.'))) {
        List<String> lines = paragraph.split('\n');
        for (String line in lines) {
          if (line.trim().isEmpty) continue;
          
          if (RegExp(r'^\d+\.').hasMatch(line.trim())) {
            widgets.add(_buildListItem(line.trim()));
          } else {
            widgets.add(_buildParagraph(line.trim()));
          }
        }
      } else {
        widgets.add(_buildParagraph(paragraph.trim()));
      }
    }
    
    return widgets;
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          height: 1.8,
          color: AppColors.textDark,
          letterSpacing: 0.3,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildListItem(String text) {
    final match = RegExp(r'^(\d+)\.\s*(.+)$').firstMatch(text);
    if (match == null) return SizedBox.shrink();
    
    final number = match.group(1)!;
    final fullContent = match.group(2)!;
    
    String title = '';
    String description = fullContent;
    
    if (fullContent.contains(':')) {
      final parts = fullContent.split(':');
      title = parts[0].trim();
      description = parts.sublist(1).join(':').trim();
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 14),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty) ...[
                  Text(
                    '$title:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 6),
                ],
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.7,
                    color: AppColors.textDark,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: () {},
        padding: EdgeInsets.zero,
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
  }
}