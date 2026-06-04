import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/data/service_catalog.dart';
import 'package:superbai/models/maid_record.dart';
import 'package:superbai/repositories/maid_repository.dart';
import 'package:superbai/theme.dart';

class AddMaidScreen extends StatefulWidget {
  const AddMaidScreen({super.key, this.maidId});

  final String? maidId;

  @override
  State<AddMaidScreen> createState() => _AddMaidScreenState();
}

class _AddMaidScreenState extends State<AddMaidScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _buildingController = TextEditingController();
  final _clientController = TextEditingController();
  final _wingFlatController = TextEditingController();
  final _slotFromController = TextEditingController();
  final _slotToController = TextEditingController();

  final MaidRepository _maidRepository = MaidRepository();
  final Set<String> _selectedServices = {};

  bool _isLoading = true;
  bool _isSaving = false;

  static final List<String> _serviceOptions = ServiceCatalog.all
      .map((s) => s.title)
      .toList();

  @override
  void initState() {
    super.initState();
    if (widget.maidId != null) {
      _loadMaid();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadMaid() async {
    try {
      final maid = await _maidRepository.getById(widget.maidId!);
      if (maid != null && mounted) {
        _nameController.text = maid.name;
        _phoneController.text = maid.phoneNumber;
        _selectedServices.addAll(maid.services);
        if (maid.workplaces.isNotEmpty) {
          final w = maid.workplaces.first;
          _buildingController.text = w.buildingAddress;
          _clientController.text = w.clientName;
          _wingFlatController.text = w.wingAndFlat;
          _slotFromController.text = w.timeslotFrom;
          _slotToController.text = w.timeslotTo;
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _buildingController.dispose();
    _clientController.dispose();
    _wingFlatController.dispose();
    _slotFromController.dispose();
    _slotToController.dispose();
    super.dispose();
  }

  List<MaidWorkplace> _buildWorkplaces() {
    if (_buildingController.text.trim().isEmpty &&
        _clientController.text.trim().isEmpty &&
        _wingFlatController.text.trim().isEmpty) {
      return [];
    }
    return [
      MaidWorkplace(
        buildingAddress: _buildingController.text.trim(),
        clientName: _clientController.text.trim(),
        wingAndFlat: _wingFlatController.text.trim(),
        timeslotFrom: _slotFromController.text.trim(),
        timeslotTo: _slotToController.text.trim(),
      ),
    ];
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one service.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final workplaces = _buildWorkplaces();
      final services = _selectedServices.toList()..sort();

      if (widget.maidId != null) {
        await _maidRepository.update(
          id: widget.maidId!,
          name: _nameController.text,
          phoneNumber: _phoneController.text,
          services: services,
          workplaces: workplaces,
        );
      } else {
        await _maidRepository.create(
          name: _nameController.text,
          phoneNumber: _phoneController.text,
          services: services,
          workplaces: workplaces,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save maid: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteMaid() async {
    final id = widget.maidId;
    if (id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete maid?', style: GoogleFonts.poppins()),
        content: Text(
          'This removes the maid from Firestore.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _isSaving = true);
    try {
      await _maidRepository.delete(id);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.maidId != null;

    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple,
        title: Text(
          isEdit ? 'Edit Maid' : 'Add Maid',
          style: GoogleFonts.poppins(color: AppColors.neutralWhite),
        ),
        iconTheme: IconThemeData(color: AppColors.neutralWhite),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _isSaving ? null : _deleteMaid,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Name*'),
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration('Maid name'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _fieldLabel('Phone*'),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration('10-digit mobile'),
                      validator: (v) {
                        final digits =
                            (v ?? '').replaceAll(RegExp(r'\D'), '');
                        if (digits.length < 10) return 'Enter valid phone';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _fieldLabel('Services*'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _serviceOptions.map((service) {
                        final selected = _selectedServices.contains(service);
                        return FilterChip(
                          label: Text(service),
                          selected: selected,
                          onSelected: (v) {
                            setState(() {
                              if (v) {
                                _selectedServices.add(service);
                              } else {
                                _selectedServices.remove(service);
                              }
                            });
                          },
                          selectedColor:
                              AppColors.primaryPurple.withValues(alpha: 0.2),
                          checkmarkColor: AppColors.primaryPurple,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    _fieldLabel('Workplace (optional)'),
                    TextFormField(
                      controller: _buildingController,
                      decoration: _inputDecoration('Building address'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _clientController,
                      decoration: _inputDecoration('Client name'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _wingFlatController,
                      decoration: _inputDecoration('Wing / flat'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _slotFromController,
                            decoration: _inputDecoration('From (e.g. 10:00)'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _slotToController,
                            decoration: _inputDecoration('To (e.g. 11:30)'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isEdit ? 'SAVE CHANGES' : 'ADD MAID',
                                style: GoogleFonts.poppins(
                                  color: AppColors.neutralWhite,
                                  letterSpacing: 1.2,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          color: AppColors.neutralBlack,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.neutralWhite,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
