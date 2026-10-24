import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/pincode_service.dart';

class PincodeVerifyField extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController? addressController;
  final TextEditingController? cityController;
  final TextEditingController? stateController;
  final TextEditingController? districtController;
  final TextEditingController? countryController;
  final String labelText;
  final String? countryCode;
  final ValueChanged<PincodeResult>? onVerified;
  final VoidCallback? onChanged;

  const PincodeVerifyField({
    super.key,
    required this.controller,
    this.addressController,
    this.cityController,
    this.stateController,
    this.districtController,
    this.countryController,
    this.labelText = 'PIN Code / Postal Code',
    this.countryCode,
    this.onVerified,
    this.onChanged,
  });

  @override
  State<PincodeVerifyField> createState() => _PincodeVerifyFieldState();
}

class _PincodeVerifyFieldState extends State<PincodeVerifyField> {
  bool _isVerifying = false;
  PincodeResult? _result;
  String? _errorText;

  static const Color _primaryGreen = Color(0xFF1B4D3E);

  Future<void> _verifyCode([String? codeOverride]) async {
    final code = codeOverride ?? widget.controller.text.trim();
    if (code.isEmpty) {
      setState(() {
        _result = null;
        _errorText = 'Please enter a PIN or postal code.';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorText = null;
      _result = null;
    });

    final res = await PincodeService.verifyAndFetch(
      code,
      preferredCountryCode: widget.countryCode,
    );

    if (!mounted) return;

    setState(() {
      _isVerifying = false;
      if (res.isValid) {
        _result = res;
        _errorText = null;

        // Auto-fill address controller if provided
        if (widget.addressController != null && res.formattedAddress.isNotEmpty) {
          widget.addressController!.text = res.formattedAddress;
        }
        if (widget.cityController != null && res.city.isNotEmpty) {
          widget.cityController!.text = res.city;
        }
        if (widget.stateController != null && res.state.isNotEmpty) {
          widget.stateController!.text = res.state;
        }
        if (widget.districtController != null && res.district.isNotEmpty) {
          widget.districtController!.text = res.district;
        }
        if (widget.countryController != null && res.country.isNotEmpty) {
          widget.countryController!.text = res.country;
        }

        if (widget.onVerified != null) {
          widget.onVerified!(res);
        }
      } else {
        _result = null;
        _errorText = res.errorMessage ?? 'Invalid PIN code. Please enter again.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: widget.controller,
          keyboardType: TextInputType.text,
          maxLength: 10,
          onChanged: (val) {
            if (widget.onChanged != null) widget.onChanged!();
            if (_result != null || _errorText != null) {
              setState(() {
                _result = null;
                _errorText = null;
              });
            }
            // Auto-verify if user types a 6-digit Indian PIN code or complete 5-digit US ZIP code
            final clean = val.trim();
            if (RegExp(r'^\d{6}$').hasMatch(clean) || RegExp(r'^\d{5}$').hasMatch(clean)) {
              _verifyCode(clean);
            }
          },
          decoration: InputDecoration(
            labelText: widget.labelText,
            prefixIcon: const Icon(Icons.pin_drop, color: _primaryGreen),
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            suffixIcon: _isVerifying
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(_primaryGreen),
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.check_circle_outline, color: _primaryGreen),
                    tooltip: 'Verify PIN Code',
                    onPressed: () => _verifyCode(),
                  ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: _primaryGreen, width: 2),
            ),
            errorText: _errorText,
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'PIN code is required';
            }
            if (_errorText != null) {
              return _errorText;
            }
            return null;
          },
        ),
        if (_isVerifying) ...[
          SizedBox(height: 6.h),
          Row(
            children: [
              SizedBox(
                width: 14.r,
                height: 14.r,
                child: const CircularProgressIndicator(strokeWidth: 2, color: _primaryGreen),
              ),
              SizedBox(width: 8.w),
              Text(
                'Verifying PIN / Postal code with API...',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ],
        if (_result != null && _result!.isValid) ...[
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.verified, color: Colors.green.shade700, size: 20.r),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verified PIN Code',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${_result!.city.isNotEmpty ? '${_result!.city}, ' : ''}${_result!.district.isNotEmpty ? '${_result!.district}, ' : ''}${_result!.state.isNotEmpty ? '${_result!.state}, ' : ''}${_result!.country}',
                        style: TextStyle(fontSize: 12.sp, color: Colors.green.shade800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
