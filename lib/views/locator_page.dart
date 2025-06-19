import 'package:digi4_mobile/blocs/locator/locator_bloc.dart';
import 'package:digi4_mobile/models/locator_model.dart';
import 'package:digi4_mobile/routes.dart';
import 'package:digi4_mobile/styles/color.dart';
import 'package:digi4_mobile/styles/shared_typography.dart';
import 'package:digi4_mobile/views/cabinets_page.dart';
import 'package:digi4_mobile/views/locator_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:digi4_mobile/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocatorPage extends StatefulWidget {
  const LocatorPage({super.key});

  @override
  State<LocatorPage> createState() => _LocatorPageState();
}

class _LocatorPageState extends State<LocatorPage> with RouteAware {
  late LocatorBloc _locatorBloc;
  // Data dummy sebagai fallback jika API gagal
  final List<Map<String, dynamic>> fallbackPlants = [
    // {
    //   'name': 'East Plant',
    //   'address': 'Jl. Industri Timur No. 123, Jakarta Timur',
    //   'total_cabinets': 8,
    // },
    // {
    //   'name': 'West Plant',
    //   'address': 'Jl. Teknologi Barat No. 456, Tangerang',
    //   'total_cabinets': 12,
    // },
  ];

  @override
  void initState() {
    super.initState();
    _locatorBloc = LocatorBloc()..add(LoadPlants());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe ke observer
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    // Unsubscribe saat halaman dihapus
    routeObserver.unsubscribe(this);
    _locatorBloc.close();
    super.dispose();
  }

  @override
  void didPopNext() {
    // Halaman muncul kembali dari push (misalnya setelah nambah plant)
    _locatorBloc.add(LoadPlants());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocatorBloc()..add(LoadPlants()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Locator: Plants',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonPrimary,
                        foregroundColor: AppColors.buttonText,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        // Navigate ke halaman create plant
                        final result = await Navigator.pushNamed(
                          context,
                          AppRoutes.plantsCreate,
                        );

                        // Jika berhasil menambah plant, refresh list
                        if (result == true) {
                          context.read<LocatorBloc>().add(LoadPlants());
                        }
                      },
                      child: Text(
                        'Add New Plant',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.buttonText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Plant List dengan BlocBuilder
              Expanded(
                child: BlocBuilder<LocatorBloc, LocatorState>(
                  builder: (context, state) {
                    // Loading state
                    if (state is PlantsLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.buttonPrimary,
                        ),
                      );
                    }
                    // Success state - convert Plants to Map format
                    else if (state is PlantsLoadedSuccess) {
                      print('plants in state, after plantsloadedsuccess: ${state.plants.length}');
                      for (var plant in state.plants) {
                        print('Plant, after plantsloadedsuccess: ${plant.plantId}, ${plant.plantName}, ${plant.address}');
                      }
                      final plantsData = state.plants
                          .map(
                            (plant) => {
                              'name': plant.plantName,
                              'address': plant.address,
                              'total_cabinets':
                                  0, // Default value karena tidak ada di model
                              'plantId':
                                  plant.plantId, // Tambahan untuk referensi
                            },
                          )
                          .toList();
                      print('plantsData: $plantsData');

                      return _buildPlantsList(plantsData);
                    }
                    // Error state - gunakan data fallback
                    else if (state is PlantsLoadedFailure) {
                      return Column(
                        children: [
                          // Error message (optional, bisa di-comment jika tidak ingin ditampilkan)
                          Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.error.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_outlined,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Using offline data - ${state.error}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.refresh,
                                    color: AppColors.error,
                                  ),
                                  onPressed: () {
                                    context.read<LocatorBloc>().add(
                                      LoadPlants(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          // Tampilkan fallback data
                          Expanded(child: _buildPlantsList(fallbackPlants)),
                        ],
                      );
                    }
                    // Initial state atau unknown state
                    else {
                      return _buildPlantsList(fallbackPlants);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlantsList(List<Map<String, dynamic>> plants) {
    return RefreshIndicator(
      color: AppColors.buttonPrimary,
      onRefresh: () async {
        // Implementasi refresh akan dipanggil dari parent context
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: plants.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildPlantItem(plants[index], context);
        },
      ),
    );
  }

  Widget _buildPlantItem(Map<String, dynamic> plant, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plant Name and Address
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    plant['name'] ?? 'Unknown Plant',
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              plant['address'] ?? 'No address available',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.buttonPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(Icons.visibility_outlined, size: 18),
                  label: Text('View Cabinets'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: context.read<LocatorBloc>(),
                          child: CabinetsPage(
                            plantId: plant['plantId']?.toString(),
                            plantName: plant['name'],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                // Di LocatorPage, pada tombol Edit:
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.warning,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(Icons.edit_outlined, size: 18),
                  label: Text('Edit'),
                  onPressed: () async {
                    // Convert Map to Plants object if needed
                    final Plants plantToEdit = Plants(
                      plantId: plant['plantId'] ?? 0,
                      plantName: plant['name'] ?? '',
                      address: plant['address'] ?? '',
                    );

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(
                          create: (context) => LocatorBloc(),
                          child: LocatorEditPage(plant: plantToEdit),
                        ),
                      ),
                    );

                    // Refresh plants jika berhasil mengedit
                    if (result == true) {
                      context.read<LocatorBloc>().add(LoadPlants());
                    }
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Update LocatorPage untuk StatefulWidget jika ingin menambahkan refresh functionality
class LocatorPageWithRefresh extends StatefulWidget {
  const LocatorPageWithRefresh({super.key});

  @override
  _LocatorPageWithRefreshState createState() => _LocatorPageWithRefreshState();
}

class _LocatorPageWithRefreshState extends State<LocatorPageWithRefresh> {
  late LocatorBloc _locatorBloc;

  @override
  void initState() {
    super.initState();
    _locatorBloc = LocatorBloc()..add(LoadPlants());
  }

  @override
  void dispose() {
    _locatorBloc.close();
    super.dispose();
  }

  Future<void> _refreshPlants() async {
    _locatorBloc.add(LoadPlants());
    // Wait for the bloc to complete
    await Future.delayed(Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _locatorBloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Header Section (sama seperti sebelumnya)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Locator: Plants',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonPrimary,
                        foregroundColor: AppColors.buttonText,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () async {
                        // Navigate ke halaman create plant
                        final result = await Navigator.pushNamed(
                          context,
                          AppRoutes.plantsCreate,
                        );

                        // Jika berhasil menambah plant, refresh list
                        if (result == true) {
                          context.read<LocatorBloc>().add(LoadPlants());
                        }
                      },
                      child: Text(
                        'Add New Plant',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.buttonText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Plant List dengan RefreshIndicator yang bekerja
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.buttonPrimary,
                  onRefresh: _refreshPlants,
                  child: BlocBuilder<LocatorBloc, LocatorState>(
                    builder: (context, state) {
                      // Implementasi sama seperti di atas...
                      if (state is PlantsLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.buttonPrimary,
                          ),
                        );
                      }
                      // ... rest of the implementation
                      return Container(); // Placeholder
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
