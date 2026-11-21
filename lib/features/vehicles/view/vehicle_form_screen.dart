import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/app_exceptions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_asset_image.dart';
import '../../../core/widgets/empty_state.dart';
import '../domain/vehicle.dart';
import '../domain/vehicle_status.dart';
import '../viewmodel/vehicle_detail_viewmodel.dart';
import '../viewmodel/vehicle_form_viewmodel.dart';

const _companies = ['Stark Logistics', 'Stark Transport', 'Stark Motors'];
const _types = ['Van', 'Car', 'Bus', 'Truck', 'Pickup'];
const _brands = ['Toyota', 'Honda', 'Yutong', 'Hino', 'Hyundai', 'Tata', 'Mercedes'];

/// Dedicated Screen for Registering a new vehicle or Updating an existing one.
class VehicleFormScreen extends ConsumerWidget {
  const VehicleFormScreen({super.key, this.vehicleId});

  final int? vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (vehicleId == null) {
      return const _VehicleForm();
    }

    final detail = ref.watch(vehicleDetailProvider(vehicleId!));
    return detail.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(64),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => EmptyState(
        icon: Icons.error_outline,
        title: 'Vehicle not found',
        message: e is AppException ? e.message : 'Could not load this vehicle.',
        action: OutlinedButton.icon(
          onPressed: () => context.go('/vehicles'),
          icon: const Icon(Icons.arrow_back, size: 16),
          label: const Text('Back to Vehicle List'),
        ),
      ),
      data: (v) => _VehicleForm(initial: v),
    );
  }
}

class _VehicleForm extends ConsumerStatefulWidget {
  const _VehicleForm({this.initial});

  final Vehicle? initial;

  @override
  ConsumerState<_VehicleForm> createState() => _VehicleFormState();
}

class _VehicleFormState extends ConsumerState<_VehicleForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _number;
  late final TextEditingController _brand;
  late final TextEditingController _model;
  String? _company;
  String? _type;
  VehicleStatus? _status;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final v = widget.initial;
    _number = TextEditingController(text: v?.vehicleNumber ?? '');
    _brand = TextEditingController(text: v?.brand ?? '');
    _model = TextEditingController(text: v?.model ?? '');
    _company = v?.company ?? _companies.first;
    _type = v?.type ?? _types.first;
    _status = v?.status ?? VehicleStatus.active;

    _number.addListener(() => setState(() {}));
    _brand.addListener(() => setState(() {}));
    _model.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _number.dispose();
    _brand.dispose();
    _model.dispose();
    super.dispose();
  }

  void _resetForm() {
    _number.clear();
    _brand.clear();
    _model.clear();
    setState(() {
      _company = _companies.first;
      _type = _types.first;
      _status = VehicleStatus.active;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final vehicle = Vehicle(
      id: widget.initial?.id,
      vehicleNumber: _number.text.trim().toUpperCase(),
      company: _company!,
      type: _type!,
      brand: _brand.text.trim(),
      model: _model.text.trim(),
      status: _status!,
    );
    final ok = await ref.read(vehicleFormProvider.notifier).save(vehicle);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit ? 'Vehicle updated successfully!' : 'Vehicle registered successfully!'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      context.go('/vehicles');
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(vehicleFormProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Banner
          _buildTopBanner(context),
          const SizedBox(height: 20),

          // 2. Register / Edit Form Card matching Image 1
          _buildFormCard(context, formState),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Top Banner matching Image 1
  Widget _buildTopBanner(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFE0EAFC),
            Color(0xFFCFDEF3),
            Color(0xFFE8F1FC),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 650;
          const bannerHeight = 125.0;
          final fleetWidth = isNarrow ? 320.0 : (constraints.maxWidth * 0.54).clamp(460.0, 600.0);

          return SizedBox(
            height: bannerHeight,
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                if (!isNarrow)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: FleetBanner(
                      width: fleetWidth,
                      height: bannerHeight,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x331E60FF),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: Icon(
                          _isEdit ? Icons.edit_note_rounded : Icons.directions_car_filled_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isEdit ? 'Update Vehicle' : 'Register Vehicle',
                              style: const TextStyle(
                                color: AppColors.charcoal,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isEdit
                                  ? 'Update vehicle specifications for ${_number.text.isNotEmpty ? _number.text : widget.initial!.vehicleNumber}'
                                  : 'Add a new vehicle to your fleet with ease.',
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isNarrow) const SizedBox(width: 320),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Register / Edit Form Card matching Image 1
  Widget _buildFormCard(BuildContext context, VehicleFormState formState) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Blue Header Bar matching Image 1
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F3B77), Color(0xFF1E60FF)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(_isEdit ? Icons.edit_note_rounded : Icons.add_circle_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _isEdit ? 'Update Vehicle Information' : 'Register New Vehicle',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      _isEdit ? 'Modify vehicle specifications' : 'Add a new vehicle to your fleet',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Body with Car Shield Illustration on Left & Inputs on Right
          Padding(
            padding: const EdgeInsets.all(26),
            child: Form(
              key: _formKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 760;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left: Car Illustration with Shield
                      if (isWide) ...[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CarShieldIllustration(width: 130, height: 110),
                            const SizedBox(height: 8),
                            if (_number.text.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFBFDBFE)),
                                ),
                                child: Text(
                                  _number.text,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 26),
                      ],

                      // Right: Form Fields (6 fields matching Image 1)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row 1: Vehicle Number, Company, Type, Brand
                            _buildResponsiveFieldRow(
                              context,
                              [
                                _buildTextField(
                                  label: 'Vehicle Number *',
                                  hint: 'e.g. DHK-1234',
                                  controller: _number,
                                  icon: Icons.directions_car_outlined,
                                  errorText: formState.vehicleNumberError,
                                  validator: (v) => Validators.required(v, 'Required'),
                                ),
                                _buildDropdownField<String>(
                                  label: 'Company *',
                                  hint: 'Select Company',
                                  icon: Icons.business_rounded,
                                  value: _company,
                                  items: _companies,
                                  onChanged: (val) => setState(() => _company = val),
                                ),
                                _buildDropdownField<String>(
                                  label: 'Type *',
                                  hint: 'Select Type',
                                  icon: Icons.directions_car_filled_rounded,
                                  value: _type,
                                  items: _types,
                                  onChanged: (val) => setState(() => _type = val),
                                ),
                                _buildDropdownField<String>(
                                  label: 'Brand *',
                                  hint: 'Select Brand',
                                  icon: Icons.sell_outlined,
                                  value: _brands.contains(_brand.text) ? _brand.text : null,
                                  items: _brands,
                                  onChanged: (val) => setState(() => _brand.text = val ?? ''),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Row 2: Model, Status, Action Buttons
                            LayoutBuilder(
                              builder: (context, rowConstraints) {
                                final isRowNarrow = rowConstraints.maxWidth < 600;

                                final modelAndStatus = [
                                  _buildTextField(
                                    label: 'Model *',
                                    hint: 'Enter Model',
                                    controller: _model,
                                    icon: Icons.directions_car_outlined,
                                    validator: (v) => Validators.required(v, 'Required'),
                                  ),
                                  _buildDropdownField<VehicleStatus>(
                                    label: 'Status *',
                                    hint: 'Select Status',
                                    icon: Icons.check_circle_outline_rounded,
                                    value: _status,
                                    items: VehicleStatus.values,
                                    itemLabel: (s) => s.label,
                                    onChanged: (val) => setState(() => _status = val),
                                  ),
                                ];

                                final buttons = Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.muted,
                                        side: const BorderSide(color: AppColors.border),
                                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: _isEdit ? () => context.go('/vehicles') : _resetForm,
                                      icon: Icon(_isEdit ? Icons.arrow_back : Icons.refresh_rounded, size: 16),
                                      label: Text(_isEdit ? 'Back' : 'Reset', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryBlue,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        elevation: 0,
                                      ),
                                      onPressed: formState.isSaving ? null : _save,
                                      icon: formState.isSaving
                                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                          : Icon(_isEdit ? Icons.check_circle_outline : Icons.send_rounded, size: 16),
                                      label: Text(
                                        _isEdit ? 'Update Vehicle' : 'Register Vehicle',
                                        style: const TextStyle(fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                );

                                if (isRowNarrow) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      ...modelAndStatus,
                                      const SizedBox(height: 16),
                                      buttons,
                                    ],
                                  );
                                }

                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(child: modelAndStatus[0]),
                                    const SizedBox(width: 16),
                                    Expanded(child: modelAndStatus[1]),
                                    const SizedBox(width: 16),
                                    buttons,
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveFieldRow(BuildContext context, List<Widget> widgets) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        int cols = 4;
        if (widgets.length == 2) {
          cols = w >= 600 ? 2 : 1;
        } else {
          if (w < 500) {
            cols = 1;
          } else if (w < 800) {
            cols = 2;
          } else {
            cols = 4;
          }
        }

        const gap = 16.0;
        final itemW = (w - ((cols - 1) * gap)) / cols;

        return Wrap(
          spacing: gap,
          runSpacing: 16,
          children: [
            for (final item in widgets)
              SizedBox(width: itemW, child: item),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    String? errorText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.charcoal),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: errorText != null ? AppColors.red : AppColors.inputBorder),
          ),
          child: TextFormField(
            controller: controller,
            validator: validator,
            style: const TextStyle(fontSize: 13, color: AppColors.charcoal),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSubtle),
              prefixIcon: Icon(icon, size: 18, color: AppColors.muted),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(errorText, style: const TextStyle(fontSize: 11, color: AppColors.red)),
          ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required String hint,
    required IconData icon,
    required T? value,
    required List<T> items,
    String Function(T)? itemLabel,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.charcoal),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              hint: Row(
                children: [
                  Icon(icon, size: 18, color: AppColors.muted),
                  const SizedBox(width: 8),
                  Text(hint, style: const TextStyle(fontSize: 13, color: AppColors.textSubtle)),
                ],
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.muted),
              items: items.map((item) {
                final text = itemLabel != null ? itemLabel(item) : item.toString();
                return DropdownMenuItem<T>(
                  value: item,
                  child: Row(
                    children: [
                      Icon(icon, size: 16, color: AppColors.muted),
                      const SizedBox(width: 8),
                      Text(text, style: const TextStyle(fontSize: 13, color: AppColors.charcoal)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
