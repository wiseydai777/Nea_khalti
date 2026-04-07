import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ── Theme colors ─────────────────────────────────────────────────────────────
const kBg = Color(0xFF0D0F14);
const kSurface = Color(0xFF13161D);
const kSurface2 = Color(0xFF1A1E28);
const kBorder = Color(0x12FFFFFF);
const kBorder2 = Color(0x20FFFFFF);
const kText = Color(0xFFE8EAF0);
const kMuted = Color(0xFF6B7280);
const kAccent = Color(0xFF4ADE80);
const kAccentDim = Color(0x1F4ADE80);
const kAmber = Color(0xFFFBBF24);
const kAmberDim = Color(0x1FFBBF24);
const kRed = Color(0xFFF87171);
const kRedDim = Color(0x1FF87171);
const kBlue = Color(0xFF60A5FA);
const kBlueDim = Color(0x1960A5FA);

final kNpr =
    NumberFormat.currency(locale: 'ne_NP', symbol: 'NPR ', decimalDigits: 2);

// ── NeaCard ───────────────────────────────────────────────────────────────────
class NeaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const NeaCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: kSurface,
          border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: padding ?? const EdgeInsets.all(20),
        child: child,
      );
}

// ── Section label ─────────────────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Text(text.toUpperCase(),
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.9,
                  color: kMuted)),
          const SizedBox(width: 10),
          const Expanded(
              child: Divider(color: kBorder, thickness: 1, height: 1)),
        ]),
      );
}

// ── Primary button ────────────────────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  const PrimaryButton(
      {super.key, required this.label, this.onTap, this.loading = false});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: loading ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: kAccent,
            foregroundColor: kBg,
            disabledBackgroundColor: kAccent.withValues(alpha: 0.4),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          child: loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: kBg))
              : Text(label),
        ),
      );
}

// ── Ghost button ──────────────────────────────────────────────────────────────
class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const GhostButton({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) => OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: kMuted,
          side: const BorderSide(color: kBorder2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        child: Text(label),
      );
}

// ── Text field ─────────────────────────────────────────────────────────────────
class NeaTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final bool readOnly;
  final bool obscure;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;

  const NeaTextField({
    super.key,
    required this.label,
    this.hint,
    this.readOnly = false,
    this.obscure = false,
    this.controller,
    this.onChanged,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w500, color: kMuted)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            readOnly: readOnly,
            obscureText: obscure,
            onChanged: onChanged,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 13,
              color: readOnly ? kMuted : kText,
              fontFamily: readOnly ? 'monospace' : null,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: kMuted, fontSize: 13),
              filled: true,
              fillColor: kSurface2,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: kBorder2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: kAccent),
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
      );
}

// ── Version tab ───────────────────────────────────────────────────────────────
class VersionToggle extends StatelessWidget {
  final bool isV2;
  final ValueChanged<bool> onChanged;
  const VersionToggle({super.key, required this.isV2, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: kSurface2,
          border: Border.all(color: kBorder2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          _Tab('V1 flow', !isV2, () => onChanged(false)),
          _Tab('V2 flow', isV2, () => onChanged(true)),
        ]),
      );
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Tab(this.label, this.active, this.onTap);

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: active ? kSurface : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active ? kText : kMuted,
                )),
          ),
        ),
      );
}

// ── Version badge ─────────────────────────────────────────────────────────────
class VersionBadge extends StatelessWidget {
  final bool isV2;
  const VersionBadge({super.key, required this.isV2});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isV2 ? kAccentDim : kAmberDim,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isV2
                  ? kAccent.withValues(alpha: 0.2)
                  : kAmber.withValues(alpha: 0.2)),
        ),
        child: Text(isV2 ? 'V2' : 'V1',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isV2 ? kAccent : kAmber,
            )),
      );
}

// ── Callout ────────────────────────────────────────────────────────────────────
class Callout extends StatelessWidget {
  final String text;
  final CalloutType type;
  const Callout({super.key, required this.text, this.type = CalloutType.info});

  @override
  Widget build(BuildContext context) {
    final (bg, border, fg) = switch (type) {
      CalloutType.info => (kBlueDim, kBlue.withValues(alpha: 0.2), kBlue),
      CalloutType.warn => (kAmberDim, kAmber.withValues(alpha: 0.2), kAmber),
      CalloutType.error => (kRedDim, kRed.withValues(alpha: 0.2), kRed),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Text(text, style: TextStyle(fontSize: 13, color: fg, height: 1.5)),
    );
  }
}

enum CalloutType { info, warn, error }

// ── Amount row ────────────────────────────────────────────────────────────────
class AmountRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isTotal;
  const AmountRow(
      {super.key,
      required this.label,
      required this.value,
      this.isTotal = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                  fontSize: isTotal ? 14 : 13,
                  fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
                  color: isTotal ? kText : kMuted,
                )),
            Text(kNpr.format(value),
                style: TextStyle(
                  fontSize: isTotal ? 16 : 13,
                  fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
                  color: isTotal ? kAccent : kText,
                  fontFamily: 'monospace',
                )),
          ],
        ),
      );
}

// ── Bill tile ─────────────────────────────────────────────────────────────────
class BillTile extends StatelessWidget {
  final String month;
  final String status;
  final double payableAmount;
  final double baseAmount;
  final bool selected;
  final ValueChanged<bool> onChanged;

  const BillTile({
    super.key,
    required this.month,
    required this.status,
    required this.payableAmount,
    required this.baseAmount,
    required this.selected,
    required this.onChanged,
  });

  bool get isNormal => status == 'Normal' || status.isEmpty;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => onChanged(!selected),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? kAccentDim : kSurface2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selected ? kAccent : kBorder),
          ),
          child: Row(children: [
            Checkbox(
              value: selected,
              onChanged: (v) => onChanged(v ?? false),
              activeColor: kAccent,
              checkColor: kBg,
              side: const BorderSide(color: kBorder2),
            ),
            const SizedBox(width: 8),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(month,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: kText)),
                const SizedBox(height: 2),
                Text(status,
                    style: TextStyle(
                        fontSize: 11, color: isNormal ? kMuted : kRed)),
              ],
            )),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(kNpr.format(payableAmount),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kText,
                      fontFamily: 'monospace')),
              Text('base: ${kNpr.format(baseAmount)}',
                  style: const TextStyle(
                      fontSize: 11, color: kMuted, fontFamily: 'monospace')),
            ]),
          ]),
        ),
      );
}

// ── Step progress bar ─────────────────────────────────────────────────────────
class StepBar extends StatelessWidget {
  final int currentStep; // 0-based
  final int totalSteps;
  final List<String> labels;
  const StepBar(
      {super.key,
      required this.currentStep,
      required this.totalSteps,
      required this.labels});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: kSurface,
          border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: List.generate(
              totalSteps,
              (i) => Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            i == currentStep ? kSurface2 : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      alignment: Alignment.center,
                      child: Text(labels[i],
                          style: TextStyle(
                            fontSize: 11,
                            color: i < currentStep
                                ? kAccent
                                : i == currentStep
                                    ? kText
                                    : kMuted,
                            fontWeight: i == currentStep
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis),
                    ),
                  )),
        ),
      );
}

// ── Error snackbar ────────────────────────────────────────────────────────────
void showNeaError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message, style: const TextStyle(color: kRed)),
    backgroundColor: const Color(0xFF2A1515),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: kRed, width: 0.5),
    ),
    duration: const Duration(seconds: 5),
  ));
}
