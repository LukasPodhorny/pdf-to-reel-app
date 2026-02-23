import 'package:flutter/material.dart';
import '../../constants.dart';
import '../safe_network_image.dart';

class BottomInputArea extends StatelessWidget {
  const BottomInputArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 70,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildUploadButton(),
                _buildFilePreview("pdf"),
                _buildFilePreview("pptx"),
                _buildFilePreview("doc"),
                _buildFilePreview("pdf"),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Input prompt...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: AppColors.element,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.12),
                        width: 1.0,
                      ),
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.12),
                        width: 1.0,
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  shape: const StadiumBorder(),
                ),
                onPressed: () {},
                child: const Row(
                  children: [
                    Text(
                      "123",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.diamond, size: 18),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildUploadButton() {
    return Container(
      width: 65,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(
        Icons.file_upload_outlined,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  Widget _buildFilePreview(String type) {
    return Container(
      width: 65,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey[800],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.6,
            child: SafeNetworkImage(
              'https://via.placeholder.com/100',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              type.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
