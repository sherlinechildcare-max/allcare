import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ClientHomeTabScreen extends StatefulWidget {
  const ClientHomeTabScreen({super.key});

  @override
  State<ClientHomeTabScreen> createState() => _ClientHomeTabScreenState();
}

class _ClientHomeTabScreenState extends State<ClientHomeTabScreen> {
  final _search = TextEditingController();
  final _scroll = ScrollController();

  String _selectedFilter = 'All';
  String _selectedArea = 'Your area';

  // --- UI-first "production states" placeholders (wire to real state later) ---
  bool _isLoading = false; // flip to true later when fetching from Supabase
  bool _hasError = false; // flip true on fetch error
  bool _isOffline = false; // flip true when connectivity says offline
  bool _locationDenied = false; // flip true when location permission denied
  bool _needsSetup = true; // profile incomplete/payment missing/etc.
  bool _needsPayment = false; // show payment reminder when needed
  bool _needsSubscription = false; // monetization hook placeholder

  // UI-first placeholder data (wire Supabase later)
  final List<_Category> _categories = const [
    _Category('Personal Care', Icons.accessibility_new),
    _Category('Home Support', Icons.home_outlined),
    _Category('Nursing', Icons.medical_services_outlined),
    _Category('Therapy', Icons.healing_outlined),
    _Category('Child Care', Icons.child_friendly_outlined),
    _Category('Transportation', Icons.directions_car_outlined),
    _Category('Companionship', Icons.favorite_outline),
  ];

  final List<_CaregiverCardData> _top = const [
    _CaregiverCardData(
      id: 'cg_001',
      name: 'Sarah Johnson',
      specialty: 'Senior Care • Dementia',
      rating: 4.8,
      reviewsCount: 120,
      distanceKm: 1.1,
      pricePerHour: 18,
      verified: true,
      availableToday: true,
    ),
    _CaregiverCardData(
      id: 'cg_002',
      name: 'Michael Green',
      specialty: 'Disability Support',
      rating: 4.6,
      reviewsCount: 86,
      distanceKm: 2.4,
      pricePerHour: 16,
      verified: true,
      availableToday: false,
    ),
    _CaregiverCardData(
      id: 'cg_003',
      name: 'Amina Yusuf',
      specialty: 'Child Care • Special Needs',
      rating: 4.7,
      reviewsCount: 44,
      distanceKm: 4.1,
      pricePerHour: 14,
      verified: false,
      availableToday: true,
    ),
  ];

  final List<_CaregiverCardData> _recentlyViewed = const [
    _CaregiverCardData(
      id: 'cg_004',
      name: 'Grace Kim',
      specialty: 'Post-op Care • Mobility',
      rating: 4.9,
      reviewsCount: 52,
      distanceKm: 3.2,
      pricePerHour: 20,
      verified: true,
      availableToday: true,
    ),
    _CaregiverCardData(
      id: 'cg_005',
      name: 'Daniel Ahmed',
      specialty: 'Companionship • Light chores',
      rating: 4.5,
      reviewsCount: 31,
      distanceKm: 2.9,
      pricePerHour: 15,
      verified: false,
      availableToday: false,
    ),
  ];

  final List<_RequestPreview> _recentRequests = const [
    _RequestPreview('Help with shower + meal prep', 'Today • 2 hrs', 'Pending'),
    _RequestPreview('Night shift companionship', 'Tomorrow • 8 hrs', 'Sent'),
  ];

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    // UI-only refresh placeholder
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      // keep error/offline flags as-is (wired later)
    });
  }

  void _openDevMenu() => context.push('/dev');

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => _FiltersSheet(
        selected: _selectedFilter,
        onSelect: (v) => setState(() => _selectedFilter = v),
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _openVerifiedInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('What does “Verified” mean?'),
        content: const Text(
          'Verified caregivers have completed identity and credential checks.\n\n'
          'UI-only placeholder: later we’ll show exactly which checks were completed.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  void _openCaregiver(_CaregiverCardData c) {
    // UI-only profile detail placeholder (real screen later)
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => _CaregiverPreviewSheet(
        caregiver: c,
        onMessage: () {
          Navigator.pop(context);
          context.go('/client/messages');
        },
        onRequest: () {
          Navigator.pop(context);
          context.go('/client/requests');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Decide which list to show (UI-first “production states”)
    final showEmptyCaregivers = !_isLoading && !_hasError && !_isOffline && _top.isEmpty;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            children: [
              // Top row (location + bell)
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        // UI-only location picker later
                        setState(() => _selectedArea = _selectedArea == 'Your area' ? 'New York' : 'Your area');
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          _selectedArea,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Notifications',
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifications (UI-only for now)')),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Offline / error / permission banners (production UX placeholders)
              if (_isOffline) ...[
                _BannerCard(
                  icon: Icons.wifi_off,
                  title: 'You’re offline',
                  subtitle: 'Some features may not work. Check your connection.',
                  actionLabel: 'Retry',
                  onAction: _refresh,
                ),
                const SizedBox(height: 10),
              ],
              if (_locationDenied) ...[
                _BannerCard(
                  icon: Icons.location_off_outlined,
                  title: 'Location is off',
                  subtitle: 'Enable location to see nearby caregivers.',
                  actionLabel: 'Enable',
                  onAction: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Location permission flow (UI-only placeholder)')),
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],
              if (_hasError) ...[
                _BannerCard(
                  icon: Icons.error_outline,
                  title: 'Something went wrong',
                  subtitle: 'Couldn’t load caregivers. Please try again.',
                  actionLabel: 'Retry',
                  onAction: _refresh,
                ),
                const SizedBox(height: 10),
              ],
              if (_needsSetup) ...[
                _BannerCard(
                  icon: Icons.checklist_outlined,
                  title: 'Finish setup',
                  subtitle: 'Add details to get faster matches and better recommendations.',
                  actionLabel: 'Continue',
                  onAction: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Setup flow (UI-only placeholder)')),
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],
              if (_needsPayment) ...[
                _BannerCard(
                  icon: Icons.credit_card_outlined,
                  title: 'Add a payment method',
                  subtitle: 'So you can book quickly when you find the right caregiver.',
                  actionLabel: 'Add',
                  onAction: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment method screen (UI-only placeholder)')),
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],
              if (_needsSubscription) ...[
                _BannerCard(
                  icon: Icons.lock_outline,
                  title: 'Unlock contact details',
                  subtitle: 'Upgrade to message caregivers directly.',
                  actionLabel: 'View plans',
                  onAction: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Subscription plans (UI-only placeholder)')),
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],

              // Search row + filter button
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _search,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Search caregivers, services…',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filledTonal(
                    tooltip: 'Filter & sort',
                    onPressed: _openFilters,
                    icon: const Icon(Icons.tune),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Filter chips (horizontal scroll)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _chip('All'),
                    const SizedBox(width: 8),
                    _chip('Verified'),
                    const SizedBox(width: 8),
                    _chip('Top Rated'),
                    const SizedBox(width: 8),
                    _chip('Near me'),
                    const SizedBox(width: 8),
                    _chip('Lowest price'),
                    const SizedBox(width: 8),
                    _chip('Available today'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Quick actions header
              Row(
                children: [
                  Expanded(
                    child: Text('Quick actions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  TextButton(onPressed: _openDevMenu, child: const Text('Dev Menu')),
                ],
              ),

              const SizedBox(height: 10),

              // Quick actions (2x2)
              Row(
                children: [
                  Expanded(
                    child: _actionCard(
                      icon: Icons.add_circle_outline,
                      title: 'Create request',
                      subtitle: 'Describe what you need',
                      onTap: () => context.go('/client/requests'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _actionCard(
                      icon: Icons.chat_bubble_outline,
                      title: 'Messages',
                      subtitle: 'Check replies',
                      onTap: () => context.go('/client/messages'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _actionCard(
                      icon: Icons.bookmark_border,
                      title: 'Saved',
                      subtitle: 'Favorites & shortlists',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Saved (UI-only for now)')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _actionCard(
                      icon: Icons.emergency_outlined,
                      title: 'Emergency',
                      subtitle: 'Quick help info',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Emergency'),
                            content: const Text(
                              'If this is an emergency, call your local emergency number.\n\n(UI-only placeholder)',
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Promo banner (main funnel)
              _promoBanner(context),

              const SizedBox(height: 18),

              // Categories header
              Row(
                children: [
                  Expanded(
                    child: Text('Categories', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Categories screen (UI-only for now)')),
                      );
                    },
                    child: const Text('See all'),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ✅ FIX: Categories row (no overflow) + proper ellipsis + horizontal scroll
              SizedBox(
                height: 72,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final c in _categories) ...[
                        _categoryBubble(c),
                        const SizedBox(width: 12),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Top caregivers near you
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Top caregivers near you',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Map view (UI-only placeholder)')),
                      );
                    },
                    child: const Text('Map'),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('See all caregivers (UI-only for now)')),
                      );
                    },
                    child: const Text('See all'),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              if (_isLoading) ...[
                const _SkeletonRow(),
              ] else if (showEmptyCaregivers) ...[
                const _EmptyHint(text: 'No caregivers found. Try changing filters or your area.'),
              ] else ...[
                SizedBox(
                  height: 170,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _top.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => _topCaregiverCard(context, _top[i]),
                  ),
                ),
              ],

              const SizedBox(height: 18),

              // Recommended
              Row(
                children: [
                  Expanded(
                    child: Text('Recommended', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      _selectedFilter = 'All';
                      _selectedArea = 'Your area';
                      _search.text = '';
                    }),
                    child: const Text('Reset'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              for (final c in _top)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _recommendedTile(context, c),
                ),

              const SizedBox(height: 18),

              // Recently viewed (personalization)
              Row(
                children: [
                  Expanded(
                    child: Text('Recently viewed',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Recently viewed list (UI-only placeholder)')),
                      );
                    },
                    child: const Text('See all'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _recentlyViewed.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => _recentViewedChip(_recentlyViewed[i]),
                ),
              ),

              const SizedBox(height: 18),

              // Recent requests preview
              Row(
                children: [
                  Expanded(
                    child: Text('Recent requests',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  TextButton(onPressed: () => context.go('/client/requests'), child: const Text('Open')),
                ],
              ),
              const SizedBox(height: 8),
              if (_recentRequests.isEmpty)
                const _EmptyHint(text: 'No requests yet. Create your first request to start getting offers.')
              else
                for (final r in _recentRequests)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.assignment_outlined),
                      title: Text(r.title),
                      subtitle: Text(r.whenText),
                      trailing: Chip(label: Text(r.status)),
                      onTap: () => context.go('/client/requests'),
                    ),
                  ),

              const SizedBox(height: 18),

              // Safety tips
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_user_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Safety tips',
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            const Text('Use verified caregivers, keep chat in-app, and review profiles before booking.'),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: _openVerifiedInfo,
                                child: const Text('What does “Verified” mean?'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ✅ PERSISTENT PRIMARY CTA (main funnel)
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: SafeArea(
            top: false,
            child: FilledButton.icon(
              onPressed: () => context.go('/client/requests'),
              icon: const Icon(Icons.add),
              label: const Text('Post a request'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _chip(String label) {
    final selected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false),
      selected: selected,
      onSelected: (_) => setState(() => _selectedFilter = label),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            CircleAvatar(child: Icon(icon)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _promoBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer_outlined),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Tip: Create a detailed request to get better matches faster. (UI-only placeholder)',
            ),
          ),
          TextButton(onPressed: () => context.go('/client/requests'), child: const Text('Create')),
        ],
      ),
    );
  }

  // ✅ FIXED: category bubble (72px height, single-line label ellipsis)
  Widget _categoryBubble(_Category c) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${c.label} (UI-only for now)')),
        );
      },
      child: Container(
        width: 92,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black12),
        ),
        child: SizedBox(
          height: 72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(radius: 18, child: Icon(c.icon, size: 20)),
              const SizedBox(height: 6),
              Text(
                c.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topCaregiverCard(BuildContext context, _CaregiverCardData c) {
    return SizedBox(
      width: 240,
      child: Card(
        child: InkWell(
          onTap: () => _openCaregiver(c),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(child: Icon(Icons.person_outline)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700))),
                    if (c.verified)
                      Tooltip(
                        message: 'Verified caregiver',
                        child: const Icon(Icons.verified, size: 18),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(c.specialty, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                _AvailabilityPill(available: c.availableToday),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.star, size: 18),
                    const SizedBox(width: 6),
                    Text('${c.rating} (${c.reviewsCount})'),
                    const SizedBox(width: 10),
                    Text('${c.distanceKm} km'),
                    const Spacer(),
                    Text('\$${c.pricePerHour}/hr', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _recommendedTile(BuildContext context, _CaregiverCardData c) {
    return Card(
      child: ListTile(
        onTap: () => _openCaregiver(c),
        leading: const CircleAvatar(child: Icon(Icons.person_outline)),
        title: Row(
          children: [
            Expanded(child: Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
            if (c.verified)
              Tooltip(
                message: 'Verified caregiver',
                child: const Icon(Icons.verified, size: 18),
              ),
          ],
        ),
        subtitle: Text('${c.specialty}\nNear you', maxLines: 2, overflow: TextOverflow.ellipsis),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('\$${c.pricePerHour}/hr'),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 16),
                const SizedBox(width: 4),
                Text('${c.rating}'),
              ],
            ),
            const SizedBox(height: 2),
            Text('(${c.reviewsCount})', style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }

  Widget _recentViewedChip(_CaregiverCardData c) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _openCaregiver(c),
      child: Ink(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            const CircleAvatar(child: Icon(Icons.person_outline)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(c.specialty, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16),
                      const SizedBox(width: 4),
                      Text('${c.rating}'),
                      const SizedBox(width: 8),
                      Text('${c.distanceKm} km'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FiltersSheet extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onClose;

  const _FiltersSheet({
    required this.selected,
    required this.onSelect,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final options = const [
      'All',
      'Verified',
      'Top Rated',
      'Near me',
      'Lowest price',
      'Available today',
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Filter & sort', style: TextStyle(fontWeight: FontWeight.w700))),
              IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final o in options)
                ChoiceChip(
                  label: Text(o),
                  selected: selected == o,
                  onSelected: (_) => onSelect(o),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.sort),
            title: const Text('Sort (placeholder)'),
            subtitle: const Text('Distance • Price • Rating • Availability'),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sort options (UI-only placeholder)')),
            ),
          ),
        ],
      ),
    );
  }
}

class _CaregiverPreviewSheet extends StatelessWidget {
  final _CaregiverCardData caregiver;
  final VoidCallback onMessage;
  final VoidCallback onRequest;

  const _CaregiverPreviewSheet({
    required this.caregiver,
    required this.onMessage,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const CircleAvatar(child: Icon(Icons.person_outline)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(caregiver.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(caregiver.specialty, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (caregiver.verified)
                Tooltip(message: 'Verified caregiver', child: const Icon(Icons.verified)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star, size: 18),
              const SizedBox(width: 6),
              Text('${caregiver.rating} (${caregiver.reviewsCount} reviews)'),
              const Spacer(),
              Text('\$${caregiver.pricePerHour}/hr', style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          _AvailabilityPill(available: caregiver.availableToday),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onRequest,
                  icon: const Icon(Icons.add),
                  label: const Text('Request'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onMessage,
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Message'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'UI-only placeholder: Full caregiver profile screen will be built after we finish all client tabs.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AvailabilityPill extends StatelessWidget {
  final bool available;
  const _AvailabilityPill({required this.available});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.black12),
        ),
        child: Text(
          available ? 'Available today' : 'Next available soon',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _BannerCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle),
                ],
              ),
            ),
            TextButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => SizedBox(
          width: 240,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(width: 40, height: 40, decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.black12)),
                      const SizedBox(width: 10),
                      Expanded(child: Container(height: 14, color: Colors.black12)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(height: 12, color: Colors.black12),
                  const SizedBox(height: 8),
                  Container(height: 12, width: 160, color: Colors.black12),
                  const Spacer(),
                  Row(
                    children: [
                      Container(width: 80, height: 12, color: Colors.black12),
                      const Spacer(),
                      Container(width: 60, height: 12, color: Colors.black12),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Center(child: Text(text, textAlign: TextAlign.center)),
    );
  }
}

class _Category {
  final String label;
  final IconData icon;
  const _Category(this.label, this.icon);
}

class _RequestPreview {
  final String title;
  final String whenText;
  final String status;
  const _RequestPreview(this.title, this.whenText, this.status);
}

class _CaregiverCardData {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int reviewsCount;
  final double distanceKm;
  final int pricePerHour;
  final bool verified;
  final bool availableToday;

  const _CaregiverCardData({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviewsCount,
    required this.distanceKm,
    required this.pricePerHour,
    required this.verified,
    required this.availableToday,
  });
}
