import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            children: [
              // Avatar
              Container(
                padding: EdgeInsets.all(0.8.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF7C6FF0), width: 2),
                ),
                child: CircleAvatar(
                  radius: 10.w,
                  backgroundImage: const NetworkImage(
                    'https://randomuser.me/api/portraits/men/32.jpg',
                  ),
                ),
              ),
              SizedBox(height: 1.5.h),

              // Name
              Text(
                'John Mathew',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 1.h),

              // Investor ID badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF8579F5),
                  borderRadius: BorderRadius.circular(5.w),
                ),
                child: Text(
                  'INV - 10254',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 2.5.h),

              // Total Collection / Total Commitment
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.account_balance_wallet_outlined,
                      iconColor: const Color(0xFF8579F5),
                      label: 'Total Collection',
                      value: '₹50,000',
                      valueColor: Colors.black87,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.sell_outlined,
                      iconColor: const Color(0xFF8579F5),
                      label: 'Total Commitment',
                      value: '₹2,50,000',
                      valueColor: const Color(0xFF2FB380),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.5.h),

              // Email & Phone
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _InfoTile(
                      icon: Icons.email_outlined,
                      label: 'Email Address',
                      value: 'john.mathew@investor.com',
                    ),
                    Divider(height: 1, indent: 4.w, endIndent: 4.w),
                    _InfoTile(
                      icon: Icons.phone_outlined,
                      label: 'Phone Number',
                      value: '+91 9847685269',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.5.h),

              // Menu items
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _MenuTile(
                      icon: Icons.person_outline,
                      label: 'Personal Info',
                      onTap: () {},
                    ),
                    // Divider(height: 1, indent: 4.w, endIndent: 4.w),
                    _MenuTile(
                      icon: Icons.insert_chart_outlined_rounded,
                      label: 'Investment Details',
                      onTap: () {},
                    ),
                    // Divider(height: 1, indent: 4.w, endIndent: 4.w),
                    _MenuTile(
                      icon: Icons.description_outlined,
                      label: 'Documents',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.5.h),

              // Logout
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _MenuTile(
                  icon: Icons.logout,
                  label: 'Logout',
                  color: Colors.redAccent,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color valueColor;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(1.8.w),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2.5.w),
            ),
            child: Icon(icon, color: iconColor, size: 4.5.w),
          ),
          SizedBox(height: 1.2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 4.5.w,
            backgroundColor: const Color(0xFF8579F5).withOpacity(0.1),
            child: Icon(icon, color: const Color(0xFF8579F5), size: 4.5.w),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[500],
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
        child: Row(
          children: [
            Icon(icon, size: 5.w, color: color == Colors.redAccent ? color : const Color(0xFF8579F5)),
            SizedBox(width: 3.5.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: 5.w, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}