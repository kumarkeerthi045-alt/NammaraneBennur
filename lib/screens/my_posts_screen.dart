import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'create_post_screen.dart';

class MyPostsScreen extends StatelessWidget {
  const MyPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Text(
          "My Posts",
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(
              "Create a Post",
              style: GoogleFonts.poppins(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "What would you like to post?",
              style: GoogleFonts.poppins(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 25),

            postTypeCard(
              context,
              title: "Home",
              subtitle: "Post a house or residential property",
              icon: Icons.home_rounded,
              color: Colors.blue,
              type: "Home",
            ),

            const SizedBox(height: 15),

            postTypeCard(
              context,
              title: "Shop",
              subtitle: "Post a shop or commercial property",
              icon: Icons.store_rounded,
              color: Colors.orange,
              type: "Shop",
            ),

            const SizedBox(height: 15),

            postTypeCard(
              context,
              title: "Land",
              subtitle: "Post agricultural or other land",
              icon: Icons.landscape_rounded,
              color: Colors.green,
              type: "Land",
            ),

            const SizedBox(height: 15),

            postTypeCard(
              context,
              title: "Plot",
              subtitle: "Post a residential or commercial plot",
              icon: Icons.grid_on_rounded,
              color: Colors.purple,
              type: "Plot",
            ),
          ],
        ),
      ),
    );
  }

  static Widget postTypeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String type,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),

      child: InkWell(
        borderRadius: BorderRadius.circular(22),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreatePostScreen(
                postType: type,
              ),
            ),
          );
        },

        child: Padding(
          padding: const EdgeInsets.all(18),

          child: Row(
            children: [

              Container(
                width: 60,
                height: 60,

                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
                size: 17,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}