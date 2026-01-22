import 'package:flutter/material.dart';
import '../data/mock_categories.dart';
import '../data/mock_services.dart';

class ServicesHomeScreen extends StatelessWidget {
  const ServicesHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find Services')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for services',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Categories', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: mockCategories.length,
                itemBuilder: (context, index) {
                  final cat = mockCategories[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          child: Text(cat.icon),
                        ),
                        const SizedBox(height: 4),
                        Text(cat.name, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text('Popular Services', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: mockServices.length,
                itemBuilder: (context, index) {
                  final s = mockServices[index];
                  return Card(
                    child: ListTile(
                      title: Text(s.name),
                      subtitle: Text('${s.category} • ${s.subCategory}'),
                      trailing: Text('\$${s.price}/hr'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
