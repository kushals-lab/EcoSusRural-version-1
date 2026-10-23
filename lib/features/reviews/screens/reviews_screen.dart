import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReviewModel {
  final String id;
  final String userName;
  final String productName;
  final double rating;
  final String comment;
  final String date;
  final bool isVerifiedPurchase;

  const ReviewModel({
    required this.id,
    required this.userName,
    required this.productName,
    required this.rating,
    required this.comment,
    required this.date,
    this.isVerifiedPurchase = false,
  });
}

const List<ReviewModel> kSampleReviews = [
  ReviewModel(
    id: 'r1',
    userName: 'Priya Sharma',
    productName: 'Banarasi Silk Saree',
    rating: 5,
    comment: 'Absolutely stunning saree! The zari work is exquisite and the craftsmanship is world-class. Worth every rupee.',
    date: 'Aug 28, 2026',
    isVerifiedPurchase: true,
  ),
  ReviewModel(
    id: 'r2',
    userName: 'Rahul Mehta',
    productName: 'Organic A2 Gir Cow Ghee',
    rating: 5,
    comment: 'Pure and authentic ghee. You can taste the difference. Lab reports are transparently available.',
    date: 'Aug 25, 2026',
    isVerifiedPurchase: true,
  ),
  ReviewModel(
    id: 'r3',
    userName: 'Ananya Iyer',
    productName: 'Chikankari Hand-Embroidered Kurta',
    rating: 4,
    comment: 'Beautiful embroidery and soft fabric. Slight delay in delivery but the quality made up for it.',
    date: 'Aug 22, 2026',
    isVerifiedPurchase: true,
  ),
  ReviewModel(
    id: 'r4',
    userName: 'Vikram Singh',
    productName: 'Naga King Chilli Pickle',
    rating: 5,
    comment: 'Fiery and flavourful! Authentic Naga taste. Packaging was secure and leak-proof.',
    date: 'Aug 20, 2026',
    isVerifiedPurchase: true,
  ),
];

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final Color _primaryGreen = const Color(0xFF1B4D3E);
  double _myRating = 0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Reviews & Ratings',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Write a Review Card
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Write a Review', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
                  SizedBox(height: 12.h),

                  // Star Rating
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _myRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () => setState(() => _myRating = index + 1),
                      );
                    }),
                  ),

                  SizedBox(height: 8.h),

                  TextField(
                    controller: _reviewController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Share your experience (minimum 20 characters)...',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      minimumSize: Size(double.infinity, 44.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    onPressed: () {
                      if (_myRating > 0 && _reviewController.text.length >= 20) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Review submitted! Thank you for your feedback.')),
                        );
                        _reviewController.clear();
                        setState(() => _myRating = 0);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please provide a rating and at least 20 characters.')),
                        );
                      }
                    },
                    child: Text('Submit Review',
                        style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Recent Reviews
            Text('Recent Reviews', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
            SizedBox(height: 12.h),

            ...kSampleReviews.map(_buildReviewCard),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: _primaryGreen.withValues(alpha: 0.15),
                child: Text(
                  review.userName.isNotEmpty ? review.userName[0] : 'U',
                  style: TextStyle(color: _primaryGreen, fontWeight: FontWeight.bold, fontSize: 14.sp),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 2,
                      children: [
                        Text(review.userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                        if (review.isVerifiedPurchase) ...[
                          const Icon(Icons.verified, color: Colors.blue, size: 14),
                          const Text('Verified Purchase', style: TextStyle(fontSize: 10, color: Colors.blue)),
                        ],
                      ],
                    ),
                    Text('${review.productName} | ${review.date}',
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 14,
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(review.comment, style: TextStyle(fontSize: 13.sp, color: Colors.grey[800], height: 1.4)),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 4.w,
            runSpacing: 2.h,
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.thumb_up_outlined, size: 14),
                label: const Text('Helpful', style: TextStyle(fontSize: 12)),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.thumb_down_outlined, size: 14),
                label: const Text('Not Helpful', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}