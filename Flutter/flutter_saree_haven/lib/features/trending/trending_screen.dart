import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import "../../core/widgets/saree_image.dart";
import '../../core/app_colors.dart';
import '../../core/data/api_repository.dart';
import '../../core/models/saree_model.dart';
import '../cart/cart_screen.dart';
import '../collections/collections_screen.dart';
import '../product_details/product_details_screen.dart';

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({super.key});

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  late Future<List<Saree>> _sareesFuture;

  @override
  void initState() {
    super.initState();
    _sareesFuture = ApiRepository.getSarees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA), // Light greyish white background
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Custom Header Area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Search Icon (Purple Circle)
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: AppColors.primary, // Indigo/Purple
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.search, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                      // Cart Icon (Plain)
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.shopping_cart_outlined, size: 28),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CartScreen()),
                              );
                            },
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Text('0', style: TextStyle(color: Colors.white, fontSize: 10)),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 10),
                
                // Orange Ribbon Banner
                SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: const Size(double.infinity, 100),
                        painter: _RibbonBannerPainter(),
                      ),
                      Center(
                        child: CustomPaint(
                          size: const Size(double.infinity, 100),
                          painter: _CurvedTextPainter(
                            'Welcome To The Future Of Fashion',
                            GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Trending',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Trending List (Card)
                Expanded(
                  child: FutureBuilder<List<Saree>>(
                    future: ApiRepository.getSarees(),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final sarees = snap.data ?? [];
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                        itemCount: sarees.length,
                        itemBuilder: (context, index) {
                          final saree = sarees[index];
                          return _TrendingCard(saree: saree);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Purple Circle Button
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ]
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CollectionsScreen()),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final Saree saree;

  const _TrendingCard({required this.saree});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
         Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(saree: saree),
          ),
        );
      },
      child: Container(
        height: 480, // Increased height
        margin: const EdgeInsets.only(bottom: 30),
        child: Stack(
          alignment: Alignment.center,
          children: [
             // Abstract Background Shapes
             Positioned(
               top: 20, left: 10,
               child: Container(
                 width: 150, height: 200,
                 decoration: BoxDecoration(
                   color: Color(0xFFFFCC00), // Yellow
                   borderRadius: BorderRadius.only(
                     topLeft: Radius.circular(60),
                     bottomRight: Radius.circular(60),
                     topRight: Radius.circular(20),
                     bottomLeft: Radius.circular(20)
                   )
                 ),
               ),
             ),
             Positioned(
               bottom: 40, right: 10,
               child: Container(
                 width: 120, height: 180,
                 decoration: BoxDecoration(
                   color: AppColors.orangeAccent,
                   borderRadius: BorderRadius.only(
                     bottomRight: Radius.circular(60),
                     topLeft: Radius.circular(60),
                     topRight: Radius.circular(20),
                     bottomLeft: Radius.circular(20)
                   )
                 ),
               ),
             ),
             
             // Main Image Card
             Container(
               width: double.infinity,
               height: 420, 
               margin: EdgeInsets.symmetric(horizontal: 10),
               decoration: BoxDecoration(
                 borderRadius: BorderRadius.circular(40),
                 boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                    )
                 ],
               ),
               clipBehavior: Clip.antiAlias,
               child: Stack(
                 fit: StackFit.expand,
                 children: [
                   SareeImage(
                     imageUrl: saree.imageUrls.isNotEmpty ? saree.imageUrls.first : '', 
                     fit: BoxFit.cover,
                   ),
                   // Gradient Overlay
                   Container(
                     decoration: BoxDecoration(
                       gradient: LinearGradient(
                         begin: Alignment.topCenter,
                         end: Alignment.bottomCenter,
                         colors: [
                           Colors.transparent,
                           Colors.black.withValues(alpha: 0.2),
                           Colors.black.withValues(alpha: 0.5),
                         ],
                       ),
                     ),
                   ),
                   
                   // "Winter" Text Overlay Group
                   Positioned(
                     top: 60,
                     left: 20,
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         // Main White Text
                         Text(
                           'Winter',
                           style: GoogleFonts.poppins(
                             fontSize: 56,
                             fontWeight: FontWeight.w900,
                             color: Colors.white,
                             height: 0.9,
                           ),
                         ),
                         // Faded/Offset Text behind/below
                         Transform.translate(
                           offset: Offset(10, -10), // slight overlap
                           child: Text(
                             'Winter',
                             style: GoogleFonts.poppins(
                               fontSize: 56,
                               fontWeight: FontWeight.w900,
                               color: Colors.white.withValues(alpha: 0.3),
                               height: 0.9,
                             ),
                           ),
                         ),
                       ],
                     ),
                   ),
                   
                   // Pink Curve Banner (Bottom)
                   Positioned(
                     bottom: 40,
                     left: 0,
                     right: 0,
                     child: SizedBox(
                       height: 60,
                       child: CustomPaint(
                         painter: _CardRibbonPainter(),
                         child: Center(
                           child: Padding(
                             padding: const EdgeInsets.only(top: 10),
                             child: Text(
                               'ALL NEW WINTER COLLECTION',
                               style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                             ),
                           ),
                         ),
                       ),
                     )
                   ),
                   
                   // Action Buttons Row (Floating at very bottom inside card)
                   Positioned(
                     bottom: 20,
                     left: 0,
                     right: 0,
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         _CircleBtn(icon: Icons.favorite_border),
                         SizedBox(width: 40), 
                         _CircleBtn(icon: Icons.bookmark_border),
                       ],
                     ),
                   )
                 ],
               ),
             ),
          ],
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  const _CircleBtn({required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: AppColors.primary),
    );
  }
}

class _RibbonBannerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = AppColors.orangeAccent
      ..style = PaintingStyle.fill;

    var path = Path();
    // "S" Curve Ribbon
    path.moveTo(0, 40);
    path.quadraticBezierTo(size.width * 0.25, 0, size.width * 0.5, 30);
    path.quadraticBezierTo(size.width * 0.75, 60, size.width, 30);
    path.lineTo(size.width, 80);
    path.quadraticBezierTo(size.width * 0.75, 110, size.width * 0.5, 80);
    path.quadraticBezierTo(size.width * 0.25, 50, 0, 90);
    path.close();

    canvas.drawShadow(path, Colors.orange.withValues(alpha: 0.4), 4, true);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _CurvedTextPainter extends CustomPainter {
  final String text;
  final TextStyle textStyle;

  _CurvedTextPainter(this.text, this.textStyle);

  @override
  void paint(Canvas canvas, Size size) {
    // Recreate the same path as the banner
    var path = Path();
    path.moveTo(0, 40);
    path.quadraticBezierTo(size.width * 0.25, 0, size.width * 0.5, 30);
    path.quadraticBezierTo(size.width * 0.75, 60, size.width, 30);
    // Note: We only need the top edge for the text path, or a slightly inset one.
    // Let's create a path that is slightly lower than the top edge to center the text visually in the ribbon.
    
    var textPath = Path();
    textPath.moveTo(0, 65); // Centered vertically (Ribbon is 40-90, center 65)
    textPath.quadraticBezierTo(size.width * 0.25, 25, size.width * 0.5, 55); // (Mid is 30-80, center 55)
    textPath.quadraticBezierTo(size.width * 0.75, 85, size.width, 55); // (End is 30-80, center 55)

    // Draw text along the path
    _drawTextOnPath(canvas, text, textPath, textStyle);
  }

  void _drawTextOnPath(Canvas canvas, String text, Path path, TextStyle style) {
    // 1. Get path length
    final pathMetrics = path.computeMetrics().first;
    final pathLength = pathMetrics.length;

    // 2. Measure text
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final textLength = textPainter.width;

    // 3. Calculate start position to center text
    double startDistance = (pathLength - textLength) / 2;
    if (startDistance < 0) startDistance = 0;

    // 4. Draw each character
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final charPainter = TextPainter(
        text: TextSpan(text: char, style: style),
        textDirection: TextDirection.ltr,
      );
      charPainter.layout();
      final charWidth = charPainter.width;

      // Calculate position for center of character
      final metric = pathMetrics.getTangentForOffset(startDistance + charWidth / 2);
      
      if (metric != null) {
        final pos = metric.position;
        final angle = -metric.angle; // Tangent angle

        canvas.save();
        canvas.translate(pos.dx, pos.dy);
        canvas.rotate(angle);
        // Draw character centered at (0,0) after translate
        charPainter.paint(canvas, Offset(-charWidth / 2, -charPainter.height / 2));
        canvas.restore();
      }

      startDistance += charWidth;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class _BottomNavPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Purple bump only - no white background
    var purplePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
      
    var bumpPath = Path();
    // Start from bottom left of bump
    bumpPath.moveTo(size.width * 0.35, 0);
    
    // Curve up to create inverted U
    bumpPath.cubicTo(
      size.width * 0.38, 0,
      size.width * 0.42, -35,
      size.width * 0.50, -35
    );
    bumpPath.cubicTo(
      size.width * 0.58, -35,
      size.width * 0.62, 0,
      size.width * 0.65, 0
    );
    
    // Close the bump shape
    bumpPath.lineTo(size.width * 0.35, 0);
    bumpPath.close();

    canvas.drawShadow(bumpPath, AppColors.primary.withValues(alpha: 0.3), 8, true);
    canvas.drawPath(bumpPath, purplePaint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _CardRibbonPainter extends CustomPainter {
   @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = const Color(0xFFFF9AA2) // Salmon Pink
      ..style = PaintingStyle.fill;

    var path = Path();
    // Upward curve
    path.moveTo(20, 10);
    path.quadraticBezierTo(size.width * 0.5, -10, size.width - 20, 10);
    path.lineTo(size.width - 20, 50);
    path.quadraticBezierTo(size.width * 0.5, 30, 20, 50);
    path.close();
    
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
