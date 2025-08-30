import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              "Overview",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            _buildMetricsGrid(),

            _buildSectionHeader("Properties Last Month"),
            _buildLastMonthPropertiesList(),
            _buildSectionHeader("Recent Activity"),
            const SizedBox(height: 20),
            _buildRecentActivityList(),

            const SizedBox(height: 20),
            _buildSectionHeader("Quick Actions"),
            _buildQuickActionsGrid(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildMetricCard(
          icon: Icons.home_work,
          label: "Total Properties",
          value: "125",
        ),
        _buildMetricCard(
          icon: Icons.check_circle_outline,
          label: "Active",
          value: "98",
          color: Colors.green.shade600,
        ),
        _buildMetricCard(
          icon: Icons.vpn_key_outlined,
          label: "Available Tokens",
          value: "45",
          color: Colors.blue.shade600,
        ),
        _buildMetricCard(
          icon: Icons.shopping_bag_outlined,
          label: "Tokens Bought",
          value: "150",
          color: Colors.purple.shade600,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    Color color = Colors.indigo,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 36, color: color),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.indigo,
      ),
    );
  }

  Widget _buildLastMonthPropertiesList() {
    // This is a placeholder list. Replace with dynamic data.
    final List<Map<String, dynamic>> properties = [
      {
        'title': 'Luxury Villa',
        'location': 'Downtown',
        'image':
            'https://images.pexels.com/photos/164558/pexels-photo-164558.jpeg',
      },
      {
        'title': 'Modern Apartment',
        'location': 'Suburbs',
        'image':
            'https://images.pexels.com/photos/164558/pexels-photo-164558.jpeg',
      },
      {
        'title': 'Family House',
        'location': 'Old Town',
        'image':
            'https://images.pexels.com/photos/164558/pexels-photo-164558.jpeg',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final prop = properties[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                prop['image'],
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(prop['title']),
            subtitle: Text(prop['location']),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to property details
            },
          ),
        );
      },
    );
  }

  Widget _buildRecentActivityList() {
    // Placeholder for recent activity items
    final List<String> activities = [
      'Property "Modern Apartment" status changed to Active.',
      'A new user purchased 10 tokens.',
      'Property "Luxury Villa" received 5 new views.',
    ];
    return Column(
      children: activities.map((activity) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_active,
                  color: Colors.indigo,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    activity,
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActionsGrid() {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildActionButton(
          icon: Icons.add_business,
          label: 'Add Property',
          onTap: () {},
        ),
        _buildActionButton(
          icon: Icons.bar_chart,
          label: 'Analytics',
          onTap: () {},
        ),
        _buildActionButton(
          icon: Icons.subscriptions,
          label: 'My Subscriptions',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.indigo),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[800]),
            ),
          ],
        ),
      ),
    );
  }
}
