import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreatePostScreen extends StatefulWidget {
  final String postType;

  const CreatePostScreen({
    super.key,
    required this.postType,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();

  final locationController = TextEditingController();
  final priceController = TextEditingController();
  final floorController = TextEditingController();
  final bhkController = TextEditingController();
  final squareFeetController = TextEditingController();
  final descriptionController = TextEditingController();

  bool parkingAvailable = false;

  @override
  void dispose() {
    locationController.dispose();
    priceController.dispose();
    floorController.dispose();
    bhkController.dispose();
    squareFeetController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  String get title {
    return "Post ${widget.postType}";
  }

  Color get themeColor {
    switch (widget.postType) {
      case "Home":
        return Colors.blue;
      case "Shop":
        return Colors.orange;
      case "Land":
        return Colors.green;
      case "Plot":
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  Future<void> submitPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Firebase saving will be connected in the next step.

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${widget.postType} post details are ready.",
        ),
      ),
    );
  }

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
          title,
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                // HEADER
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Row(
                    children: [

                      Icon(
                        getIcon(),
                        color: themeColor,
                        size: 38,
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: Text(
                          "Enter details for your ${widget.postType.toLowerCase()}",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // LOCATION
                buildTextField(
                  controller: locationController,
                  label: "Location",
                  hint: "Enter property location",
                  icon: Icons.location_on_outlined,
                ),

                const SizedBox(height: 18),

                // PRICE
                buildTextField(
                  controller: priceController,
                  label: "Price",
                  hint: "Enter price",
                  icon: Icons.currency_rupee,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 18),

                // HOME FIELDS
                if (widget.postType == "Home") ...[
                  buildTextField(
                    controller: floorController,
                    label: "Which Floor?",
                    hint: "Example: Ground Floor / 1st Floor",
                    icon: Icons.layers_outlined,
                  ),

                  const SizedBox(height: 18),

                  buildTextField(
                    controller: bhkController,
                    label: "How many BHK?",
                    hint: "Example: 1 BHK, 2 BHK, 3 BHK",
                    icon: Icons.bed_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ],

                // SHOP FIELDS
                if (widget.postType == "Shop") ...[
                  buildTextField(
                    controller: floorController,
                    label: "Which Floor?",
                    hint: "Example: Ground Floor / 1st Floor",
                    icon: Icons.layers_outlined,
                  ),

                  const SizedBox(height: 18),

                  buildTextField(
                    controller: squareFeetController,
                    label: "Square Feet",
                    hint: "Enter shop area",
                    icon: Icons.square_foot,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 18),

                  // PARKING
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 5,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,

                      title: Text(
                        "Parking Available",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      subtitle: Text(
                        parkingAvailable ? "Yes" : "No",
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                        ),
                      ),

                      activeThumbColor: themeColor,

                      value: parkingAvailable,

                      onChanged: (value) {
                        setState(() {
                          parkingAvailable = value;
                        });
                      },
                    ),
                  ),
                ],

                // LAND FIELDS
                if (widget.postType == "Land") ...[
                  buildTextField(
                    controller: squareFeetController,
                    label: "Square Feet",
                    hint: "Enter land area",
                    icon: Icons.square_foot,
                    keyboardType: TextInputType.number,
                  ),
                ],

                // PLOT FIELDS
                if (widget.postType == "Plot") ...[
                  buildTextField(
                    controller: squareFeetController,
                    label: "Square Feet",
                    hint: "Enter plot area",
                    icon: Icons.square_foot,
                    keyboardType: TextInputType.number,
                  ),
                ],

                const SizedBox(height: 18),

                // DESCRIPTION
                TextFormField(
                  controller: descriptionController,
                  maxLines: 4,

                  decoration: InputDecoration(
                    labelText: "Description",
                    hintText: "Describe your property",

                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 65),
                      child: Icon(Icons.description_outlined),
                    ),

                    filled: true,
                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter a description";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // POST BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton.icon(
                    onPressed: submitPost,

                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                    ),

                    label: Text(
                      "Create Post",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData getIcon() {
    switch (widget.postType) {
      case "Home":
        return Icons.home_rounded;
      case "Shop":
        return Icons.store_rounded;
      case "Land":
        return Icons.landscape_rounded;
      case "Plot":
        return Icons.grid_on_rounded;
      default:
        return Icons.home;
    }
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,

      keyboardType: keyboardType,

      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),

        filled: true,
        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),

      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Please enter $label";
        }

        return null;
      },
    );
  }
}