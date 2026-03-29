import 'package:flutter/material.dart';

void main() {
  runApp(const SareeBoutiqueApp());
}

class SareeBoutiqueApp extends StatelessWidget {
  const SareeBoutiqueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Handmade Sarees',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8A2BE2),
          brightness: Brightness.light,
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 2,
          shadowColor: Colors.black12,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Saree> sarees = const [
    Saree(
      name: 'Banarasi Royal Weave',
      price: 12999,
      colorTag: 'Magenta Gold',
      artisan: 'Shivani Crafts, Varanasi',
      description: 'Handwoven silk saree with pure zari floral motifs.',
      deliveryDays: 6,
    ),
    Saree(
      name: 'Kanchipuram Temple Elegance',
      price: 15499,
      colorTag: 'Emerald Copper',
      artisan: 'Lakshmi Looms, Kanchipuram',
      description: 'Traditional contrast border with peacock pallu artistry.',
      deliveryDays: 8,
    ),
    Saree(
      name: 'Linen Jamdani Breeze',
      price: 7499,
      colorTag: 'Powder Blue',
      artisan: 'Nabanna Weaves, Kolkata',
      description: 'Lightweight handloom linen with contemporary jamdani work.',
      deliveryDays: 4,
    ),
  ];

  final List<Vendor> vendors = const [
    Vendor(
      name: 'Shivani Crafts',
      city: 'Varanasi',
      years: 22,
      specialty: 'Banarasi handloom silk',
      contact: '+91 90000 11001',
    ),
    Vendor(
      name: 'Lakshmi Looms',
      city: 'Kanchipuram',
      years: 30,
      specialty: 'Kanchipuram bridal sarees',
      contact: '+91 90000 11002',
    ),
    Vendor(
      name: 'Nabanna Weaves',
      city: 'Kolkata',
      years: 15,
      specialty: 'Jamdani and linen fusion',
      contact: '+91 90000 11003',
    ),
  ];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: [
            _buildShowcaseTab(),
            const EnquiryOrderTab(),
            VendorRequestTab(vendors: vendors),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => setState(() => selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.storefront), label: 'Showcase'),
          NavigationDestination(icon: Icon(Icons.shopping_bag), label: 'Enquire & Order'),
          NavigationDestination(icon: Icon(Icons.groups), label: 'Vendors'),
        ],
      ),
    );
  }

  Widget _buildShowcaseTab() {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          pinned: true,
          title: const Text('Handmade Saree Studio'),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.favorite_outline),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD8C2FF), Color(0xFFF8E8FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Exclusive Festival Collection',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Authentic handcrafted sarees curated from master artisans.'),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const Text('Featured Sarees',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.builder(
            itemCount: sarees.length,
            itemBuilder: (context, index) {
              final saree = sarees[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              saree.name,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w700),
                            ),
                          ),
                          Chip(label: Text('₹${saree.price}')),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(saree.description),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _metaPill(Icons.palette_outlined, saree.colorTag),
                          _metaPill(Icons.handyman_outlined, saree.artisan),
                          _metaPill(Icons.local_shipping_outlined,
                              '${saree.deliveryDays} day delivery'),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _metaPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0FF),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 6), Text(label)],
      ),
    );
  }
}

class EnquiryOrderTab extends StatefulWidget {
  const EnquiryOrderTab({super.key});

  @override
  State<EnquiryOrderTab> createState() => _EnquiryOrderTabState();
}

class _EnquiryOrderTabState extends State<EnquiryOrderTab> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final contactController = TextEditingController();
  final requestController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    contactController.dispose();
    requestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text('Enquire & Place Order',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text(
              'Fill your details and our saree experts will contact you for customization, pricing, and payment options.',
            ),
            const SizedBox(height: 18),
            _styledField(
              controller: nameController,
              label: 'Your Name',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 12),
            _styledField(
              controller: contactController,
              label: 'Phone / WhatsApp',
              icon: Icons.phone_outlined,
            ),
            const SizedBox(height: 12),
            _styledField(
              controller: requestController,
              label: 'Saree preference or order notes',
              icon: Icons.chat_bubble_outline,
              maxLines: 4,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.send),
              label: const Text('Submit enquiry'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _quickOrder,
              icon: const Icon(Icons.bolt_outlined),
              label: const Text('Quick order request'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _styledField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (value) =>
          value == null || value.trim().isEmpty ? 'Please enter $label' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enquiry received! We will contact you shortly.')),
      );
    }
  }

  void _quickOrder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quick order initiated. Our team will call you soon.')),
    );
  }
}

class VendorRequestTab extends StatelessWidget {
  const VendorRequestTab({super.key, required this.vendors});

  final List<Vendor> vendors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vendor Details', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Request verified vendor details to build trust before purchase.'),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.separated(
              itemCount: vendors.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final vendor = vendors[index];
                return Card(
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(vendor.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        '${vendor.city} • ${vendor.years} yrs • ${vendor.specialty}'),
                    trailing: TextButton(
                      onPressed: () => _showVendor(context, vendor),
                      child: const Text('Request'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showVendor(BuildContext context, Vendor vendor) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(vendor.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('City: ${vendor.city}'),
            Text('Experience: ${vendor.years} years'),
            Text('Specialty: ${vendor.specialty}'),
            Text('Contact: ${vendor.contact}'),
            const SizedBox(height: 12),
            const Text('All vendors are background-verified and quality checked.'),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}

class Saree {
  final String name;
  final int price;
  final String colorTag;
  final String artisan;
  final String description;
  final int deliveryDays;

  const Saree({
    required this.name,
    required this.price,
    required this.colorTag,
    required this.artisan,
    required this.description,
    required this.deliveryDays,
  });
}

class Vendor {
  final String name;
  final String city;
  final int years;
  final String specialty;
  final String contact;

  const Vendor({
    required this.name,
    required this.city,
    required this.years,
    required this.specialty,
    required this.contact,
  });
}
