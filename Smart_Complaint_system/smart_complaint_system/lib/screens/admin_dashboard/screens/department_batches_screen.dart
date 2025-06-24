import 'package:flutter/material.dart';
import '../controllers/admin_dashboard_controller.dart';

class DepartmentBatchesScreen extends StatelessWidget {
  final AdminDashboardController controller;
  final ThemeData theme;

  const DepartmentBatchesScreen({
    super.key,
    required this.controller,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // Using passed theme
    return DepartmentBatchesContent(controller: controller, theme: theme);
  }
}

class DepartmentBatchesContent extends StatefulWidget {
  final AdminDashboardController controller;
  final ThemeData theme;

  const DepartmentBatchesContent({
    super.key,
    required this.controller,
    required this.theme,
  });

  @override
  _DepartmentBatchesContentState createState() =>
      _DepartmentBatchesContentState();
}

class _DepartmentBatchesContentState extends State<DepartmentBatchesContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEditingDepartment = false;
  bool _isEditingBatches = false;

  final TextEditingController _departmentNameController =
      TextEditingController();
  final TextEditingController _departmentDescriptionController =
      TextEditingController();
  final TextEditingController _customDepartmentController =
      TextEditingController();

  String _selectedDepartment = 'CS';
  bool _isCustomDepartment = false;
  Map<String, dynamic>? _currentDepartment;
  List<Map<String, dynamic>> _batches = [];

  final List<String> _predefinedDepartments = [
    'CS',
    'SE',
    'English',
    'E-commerce',
    'Bio Tech',
    'Environmental',
    'Business',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _departmentNameController.dispose();
    _departmentDescriptionController.dispose();
    _customDepartmentController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadDepartmentData(),
      _loadBatchesData(),
    ]);
  }

  Future<void> _loadDepartmentData() async {
    try {
      print('Loading department data...');
      final department = await widget.controller.getCurrentDepartment();
      print('Loaded department: $department');

      if (mounted) {
        setState(() {
          if (department != null) {
            _currentDepartment = department;
            _selectedDepartment = department['name'] ?? '';
            _departmentDescriptionController.text =
                department['description'] ?? '';
            print('Set department: $_selectedDepartment');
            print('Set description: ${_departmentDescriptionController.text}');
          } else {
            _currentDepartment = null;
            _selectedDepartment = '';
            _departmentDescriptionController.clear();
            print('No department found, cleared fields');
          }
        });
      }
    } catch (e) {
      print('Error loading department data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load department data: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _loadBatchesData() async {
    try {
      print('Loading batches data...');
      final batches = await widget.controller.getAllBatches();
      print('Loaded ${batches.length} batches');

      if (mounted) {
        setState(() {
          _batches = batches;
        });
      }
    } catch (e) {
      print('Error loading batches data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load batches data: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using passed theme from the widget
    final theme = widget.theme;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Department & Batches',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: _loadData,
                  tooltip: 'Refresh Data',
                ),
              ],
            ),
          ),
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor:
                  theme.colorScheme.onSurface.withOpacity(0.6),
              indicatorColor: theme.colorScheme.primary,
              tabs: const [
                Tab(
                  icon: Icon(Icons.business),
                  text: 'Department',
                ),
                Tab(
                  icon: Icon(Icons.class_),
                  text: 'Batches',
                ),
              ],
            ),
          ),
          // Tab Content
          SizedBox(
            height: MediaQuery.of(context).size.height -
                250, // Adjust height as needed
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDepartmentTab(),
                _buildBatchesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentTab() {
    final theme = widget.theme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.business,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Department Management',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage your institution\'s department information',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Department Information Card
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Current Department',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: theme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Edit Department',
                        icon: Icon(
                          Icons.edit_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        onPressed: () {
                          setState(() {
                            _isEditingDepartment = true;
                          });
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (!_isEditingDepartment) ...[
                    _buildInfoRow(
                        'Department Name', _currentDepartment?['name'] ?? 'CS'),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                        'Description',
                        _currentDepartment?['description'] ??
                            'Computer Science Department'),
                    const SizedBox(height: 12),
                    _buildInfoRow('Status', 'Active'),
                  ] else ...[
                    _buildDepartmentEditForm(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentEditForm() {
    final theme = widget.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Department Selection
        Text(
          'Department Name',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedDepartment,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              style: TextStyle(
                color: theme.colorScheme.onSurface,
              ),
              dropdownColor: theme.colorScheme.surface,
              items: _predefinedDepartments.map((dept) {
                return DropdownMenuItem(
                  value: dept,
                  child: Text(
                    dept,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDepartment = value!;
                  _isCustomDepartment = value == 'Other';
                  if (_isCustomDepartment) {
                    _customDepartmentController.clear();
                  }
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Custom Department Input
        if (_isCustomDepartment) ...[
          Text(
            'Custom Department Name',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: TextField(
              controller: _customDepartmentController,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Enter custom department name',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Description
        Text(
          'Description',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: TextField(
            controller: _departmentDescriptionController,
            maxLines: 3,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Enter department description',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isEditingDepartment = false;
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  side: BorderSide(color: theme.colorScheme.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  // Save department changes
                  try {
                    final departmentName = _isCustomDepartment &&
                            _customDepartmentController.text.isNotEmpty
                        ? _customDepartmentController.text
                        : _selectedDepartment;

                    if (departmentName.isEmpty) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a department name'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      return;
                    }

                    print('Updating department: $departmentName');
                    print(
                        'Description: ${_departmentDescriptionController.text}');

                    await widget.controller.updateDepartment(
                      name: departmentName,
                      description: _departmentDescriptionController.text,
                    );

                    setState(() {
                      _isEditingDepartment = false;
                      _selectedDepartment = departmentName;
                    });

                    // Reload data
                    await _loadDepartmentData();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Department updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    print('Error updating department: $e');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to update department: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBatchesTab() {
    final theme = widget.theme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.class_,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Batch Management',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage academic batches and their details',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Batches List
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.list_alt,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Current Batches',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: theme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isEditingBatches = !_isEditingBatches;
                          });
                        },
                        icon: Icon(
                          _isEditingBatches ? Icons.save : Icons.edit,
                          color: Colors.white,
                        ),
                        label: Text(
                          _isEditingBatches ? 'Save' : 'Edit',
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Batches Grid
                  _buildBatchesGrid(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchesGrid() {
    final theme = widget.theme;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2,
        crossAxisSpacing: 0,
        mainAxisSpacing: 18,
      ),
      itemCount: _batches.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _batches[index]['batch_name'] ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_isEditingBatches)
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () {
                      _showBatchEditDialog(_batches[index]);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = widget.theme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  void _showBatchEditDialog(Map<String, dynamic> batch) {
    final TextEditingController batchController =
        TextEditingController(text: batch['batch_name'] ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Batch'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(dialogContext).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(dialogContext)
                      .colorScheme
                      .outline
                      .withOpacity(0.3),
                ),
              ),
              child: TextField(
                controller: batchController,
                decoration: InputDecoration(
                  labelText: 'Batch Name',
                  labelStyle: TextStyle(
                    color: Theme.of(dialogContext)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Close dialog first
                Navigator.of(dialogContext).pop();

                // Then perform the update
                await widget.controller.updateBatch(
                  batchId: batch['id'],
                  batchName: batchController.text.trim(),
                );

                // Reload batches data
                await _loadBatchesData();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Batch ${batch['batch_name']} updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update batch: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
