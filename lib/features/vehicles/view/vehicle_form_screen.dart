import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/app_exceptions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_dropdown.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/page_header.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../domain/vehicle.dart';
import '../domain/vehicle_status.dart';
import '../viewmodel/vehicle_detail_viewmodel.dart';
import '../viewmodel/vehicle_form_viewmodel.dart';

const _companies = ['Stark Logistics', 'Stark Transport', 'Stark Motors'];
const _types = ['Truck', 'Van', 'Pickup', 'Car', 'Bus'];

/// Screen for both Register (vehicleId == null) and Edit.
class VehicleFormScreen extends ConsumerWidget {
  const VehicleFormScreen({super.key, this.vehicleId});

  final int? vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (vehicleId == null) return const _VehicleForm();

    final detail = ref.watch(vehicleDetailProvider(vehicleId!));
    return detail.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(48),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => EmptyState(
        icon: Icons.error_outline,
        title: 'Vehicle not found',
        message: e is AppException ? e.message : 'Could not load this vehicle.',
        action: OutlinedButton.icon(
          onPressed: () => context.go('/vehicles'),
          icon: const Icon(Icons.arrow_back, size: 16),
          label: const Text('Back to list'),
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

    // Listen to changes for live preview
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final vehicle = Vehicle(
      id: widget.initial?.id,
      vehicleNumber: _number.text.trim(),
      company: _company!,
      type: _type!,
      brand: _brand.text.trim(),
      model: _model.text.trim(),
      status: _status!,
    );
    final ok = await ref.read(vehicleFormProvider.notifier).save(vehicle);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEdit ? 'Vehicle updated successfully' : 'Vehicle registered successfully'),
      ));
      context.go('/vehicles');
    }
  }

  Widget _sectionTitle(String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8, bottom: 18),
      padding: const EdgeInsets.only(bottom: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.tableBorder, width: 1.2)),
      ),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.deepBlue,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(vehicleFormProvider);

    // Header Back button with back icon
    final backButton = OutlinedButton.icon(
      onPressed: () => context.go('/vehicles'),
      icon: const Icon(Icons.arrow_back, size: 16),
      label: const Text('Back to list'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.deepBlue,
        side: const BorderSide(color: AppColors.inputBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page Header
        PageHeader(
          title: _isEdit ? 'Edit Vehicle' : 'Register Vehicle',
          subtitle: _isEdit
              ? 'Update vehicle details for ${_number.text.isNotEmpty ? _number.text : widget.initial!.vehicleNumber}'
              : 'Add a new vehicle to the fleet',
          action: backButton,
        ),

        // 2-Column Responsive Layout: Form on Left, Compact Live Preview on Right
        LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 740;
            final isSmallMobile = constraints.maxWidth < 420;

            final formCard = Container(
              padding: EdgeInsets.all(isDesktop ? 36 : 20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x140F1F33),
                    blurRadius: 32,
                    offset: Offset(0, 12),
                    spreadRadius: -16,
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fields marked * are required.',
                      style: TextStyle(fontSize: 13, color: AppColors.muted),
                    ),
                    const SizedBox(height: 16),

                    // Section 1: Identification
                    _sectionTitle('Vehicle Identification'),
                    _buildTwoColRow(
                      context,
                      CustomTextField(
                        label: 'Vehicle Number *',
                        controller: _number,
                        hint: 'e.g. DHK-METRO-1021',
                        errorText: form.vehicleNumberError,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) =>
                            ref.read(vehicleFormProvider.notifier).clearVehicleNumberError(),
                        validator: (v) => Validators.required(v, 'Vehicle Number is required'),
                      ),
                      CustomDropdown<String>(
                        label: 'Company *',
                        hint: 'Select company',
                        items: _companies,
                        value: _company,
                        onChanged: (v) => setState(() => _company = v),
                        validator: (v) => v == null ? 'Please select a company' : null,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 2: Details
                    _sectionTitle('Vehicle Details'),
                    _buildTwoColRow(
                      context,
                      CustomDropdown<String>(
                        label: 'Type *',
                        hint: 'Select type',
                        items: _types,
                        value: _type,
                        onChanged: (v) => setState(() => _type = v),
                        validator: (v) => v == null ? 'Please select a type' : null,
                      ),
                      CustomTextField(
                        label: 'Brand *',
                        controller: _brand,
                        hint: 'e.g. Tata, Toyota',
                        textInputAction: TextInputAction.next,
                        validator: (v) => Validators.required(v, 'Brand is required'),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildTwoColRow(
                      context,
                      CustomTextField(
                        label: 'Model *',
                        controller: _model,
                        hint: 'e.g. Prima, HiAce',
                        textInputAction: TextInputAction.next,
                        validator: (v) => Validators.required(v, 'Model is required'),
                      ),
                      CustomDropdown<VehicleStatus>(
                        label: 'Status *',
                        hint: 'Select status',
                        items: VehicleStatus.values,
                        value: _status,
                        itemLabel: (s) => s.label,
                        onChanged: (v) => setState(() => _status = v),
                        validator: (v) => v == null ? 'Please select a status' : null,
                      ),
                    ),

                    if (form.generalError != null) ...[
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.errorBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, size: 18, color: AppColors.red),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                form.generalError!,
                                style: const TextStyle(
                                  color: AppColors.red,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Buttons
                    if (isSmallMobile)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: form.isSaving ? null : () => context.go('/vehicles'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.deepBlue,
                                side: const BorderSide(color: AppColors.inputBorder),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: PrimaryButton(
                              label: _isEdit ? 'Update' : 'Save',
                              isLoading: form.isSaving,
                              onPressed: _save,
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: form.isSaving ? null : () => context.go('/vehicles'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.deepBlue,
                              side: const BorderSide(color: AppColors.inputBorder),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          PrimaryButton(
                            label: _isEdit ? 'Update Vehicle' : 'Save Vehicle',
                            isLoading: form.isSaving,
                            onPressed: _save,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );

            // Small compact live preview sidebar matching reference image
            final previewSidebar = SizedBox(
              width: isDesktop ? 270 : double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLivePreviewCard(isDesktop: isDesktop),
                  if (form.vehicleNumberError != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.errorBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.red.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        'Duplicate found. ${_number.text.trim().isNotEmpty ? _number.text.trim() : widget.initial?.vehicleNumber ?? ""} is already registered. Use a different Vehicle Number to continue.',
                        style: const TextStyle(
                          color: AppColors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );

            if (isDesktop) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: formCard),
                  const SizedBox(width: 24),
                  previewSidebar,
                ],
              );
            }

            // On Mobile: stack with Preview card above form
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                previewSidebar,
                const SizedBox(height: 20),
                formCard,
              ],
            );
          },
        ),
      ],
    );
  }

  /// 2-Column Responsive Row for Fields inside form
  Widget _buildTwoColRow(BuildContext context, Widget left, Widget right) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 540) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              left,
              const SizedBox(height: 16),
              right,
            ],
          );
        }
        final halfWidth = (constraints.maxWidth - 20) / 2;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: halfWidth, child: left),
            const SizedBox(width: 20),
            SizedBox(width: halfWidth, child: right),
          ],
        );
      },
    );
  }

  /// Live Preview Dark Card matching the user's uploaded reference image
  Widget _buildLivePreviewCard({required bool isDesktop}) {
    final vehicleNo = _number.text.trim().isNotEmpty ? _number.text.trim() : 'DHK-00-0000';
    final brand = _brand.text.trim().isNotEmpty ? _brand.text.trim() : 'Tata';
    final model = _model.text.trim().isNotEmpty ? _model.text.trim() : 'Prima';
    final type = _type ?? 'Truck';
    final company = _company ?? 'Stark Logistics';
    final status = _status ?? VehicleStatus.active;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2642),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3D0A1F36),
            blurRadius: 24,
            offset: Offset(0, 10),
            spreadRadius: -6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Eyebrow tag
          const Text(
            'LIVE PREVIEW',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: AppColors.goldAccent,
            ),
          ),
          const SizedBox(height: 14),

          // License Plate Container Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF0A1F36), width: 2.5),
            ),
            child: Text(
              vehicleNo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF0A1F36),
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Vehicle Details text
          Text(
            '$brand $model',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$type · $company',
            style: const TextStyle(
              color: Color(0xBFFFFFFF),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),

          // Status Badge Pill
          StatusBadge(status, isDark: true),
        ],
      ),
    );
  }
}
