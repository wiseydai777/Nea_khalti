class NeatCounter {
  final String name;
  final String value;
  final String orgNo;
  final bool migratedToV2;

  const NeatCounter({
    required this.name,
    required this.value,
    required this.orgNo,
    required this.migratedToV2,
  });

  factory NeatCounter.fromJson(Map<String, dynamic> json) => NeatCounter(
        name: json['name'] as String,
        value: json['value'] as String,
        orgNo: (json['org_no'] as String?) ?? '',
        migratedToV2: (json['migrated_to_v2'] as bool?) ?? false,
      );

  String get orgName => value.contains(':') ? value.split(':')[1] : value;
}

// ── V2 models ────────────────────────────────────────────────────────────────

class DueBillV2 {
  final String feeType;
  final String feeSubType;
  final String rcvblID;
  final double feeAmount;
  final double payableAmount;
  final String billDate;
  final String billMonth;
  final String days;
  final double rebate;
  final double penalty;
  final String status;
  final double rcvedAmount;

  const DueBillV2({
    required this.feeType,
    required this.feeSubType,
    required this.rcvblID,
    required this.feeAmount,
    required this.payableAmount,
    required this.billDate,
    required this.billMonth,
    required this.days,
    required this.rebate,
    required this.penalty,
    required this.status,
    required this.rcvedAmount,
  });

  factory DueBillV2.fromJson(Map<String, dynamic> json) => DueBillV2(
        feeType: json['feeType'] as String? ?? '',
        feeSubType: json['feeSubType'] as String? ?? '',
        rcvblID: json['rcvblID'] as String,
        feeAmount: double.tryParse(json['feeAmount'].toString()) ?? 0,
        payableAmount: double.tryParse(json['payableAmount'].toString()) ?? 0,
        billDate: json['billDate'] as String? ?? '',
        billMonth: json['billMonth'] as String? ?? '',
        days: json['days']?.toString() ?? '',
        rebate: double.tryParse(json['rebate'].toString()) ?? 0,
        penalty: double.tryParse(json['penalty'].toString()) ?? 0,
        status: json['status'] as String? ?? '',
        rcvedAmount: double.tryParse(json['rcvedAmount'].toString()) ?? 0,
      );

  bool get hasNormalStatus => status == 'Normal' || status.isEmpty;
}

class BillDetailV2 {
  final int sessionId;
  final String consumerName;
  final double totalDueAmount;
  final List<DueBillV2> dueBills;
  final Map<String, dynamic>? paidUptoBill;

  const BillDetailV2({
    required this.sessionId,
    required this.consumerName,
    required this.totalDueAmount,
    required this.dueBills,
    this.paidUptoBill,
  });

  factory BillDetailV2.fromJson(Map<String, dynamic> json) {
    final bills = (json['due_bills'] as List<dynamic>? ?? [])
        .map((e) => DueBillV2.fromJson(e as Map<String, dynamic>))
        .toList();
    return BillDetailV2(
      sessionId: json['session_id'] as int,
      consumerName: json['consumer_name'] as String,
      totalDueAmount: double.tryParse(json['total_due_amount'].toString()) ?? 0,
      dueBills: bills,
      paidUptoBill: json['paid_upto_bill'] is Map
          ? json['paid_upto_bill'] as Map<String, dynamic>
          : null,
    );
  }
}

// ── V1 models ────────────────────────────────────────────────────────────────

class DueBillV1 {
  final double billAmount;
  final String billDate;
  final int days;
  final double payableAmount;
  final String dueBillOf;
  final String status;

  const DueBillV1({
    required this.billAmount,
    required this.billDate,
    required this.days,
    required this.payableAmount,
    required this.dueBillOf,
    required this.status,
  });

  factory DueBillV1.fromJson(Map<String, dynamic> json) => DueBillV1(
        billAmount: double.tryParse(json['bill_amount'].toString()) ?? 0,
        billDate: json['bill_date'] as String? ?? '',
        days: (json['days'] as num?)?.toInt() ?? 0,
        payableAmount: double.tryParse(json['payable_amount'].toString()) ?? 0,
        dueBillOf: json['due_bill_of'] as String? ?? '',
        status: json['status'] as String? ?? '',
      );

  bool get hasNormalStatus => status == 'Normal';
}

class BillDetailV1 {
  final int sessionId;
  final String consumerName;
  final double totalDueAmount;
  final List<DueBillV1> dueBills;

  const BillDetailV1({
    required this.sessionId,
    required this.consumerName,
    required this.totalDueAmount,
    required this.dueBills,
  });

  factory BillDetailV1.fromJson(Map<String, dynamic> json) {
    final bills = (json['due_bills'] as List<dynamic>? ?? [])
        .map((e) => DueBillV1.fromJson(e as Map<String, dynamic>))
        .toList();
    return BillDetailV1(
      sessionId: json['session_id'] as int,
      consumerName: json['consumer_name'] as String,
      totalDueAmount: double.tryParse(json['total_due_amount'].toString()) ?? 0,
      dueBills: bills,
    );
  }
}

// ── Shared ────────────────────────────────────────────────────────────────────

class PaymentResult {
  final bool status;
  final String state;
  final String message;
  final String detail;
  final double creditsConsumed;
  final int id;

  const PaymentResult({
    required this.status,
    required this.state,
    required this.message,
    required this.detail,
    required this.creditsConsumed,
    required this.id,
  });

  factory PaymentResult.fromJson(Map<String, dynamic> json) => PaymentResult(
        status: json['status'] as bool? ?? false,
        state: json['state'] as String? ?? '',
        message: json['message'] as String? ?? '',
        detail: json['detail'] as String? ?? '',
        creditsConsumed:
            double.tryParse(json['credits_consumed'].toString()) ?? 0,
        id: (json['id'] as num?)?.toInt() ?? 0,
      );
}

class ServiceCharge {
  final double charge;
  final double amount;

  const ServiceCharge({required this.charge, required this.amount});

  factory ServiceCharge.fromJson(Map<String, dynamic> json) => ServiceCharge(
        charge: double.tryParse(json['service_charge'].toString()) ?? 0,
        amount: double.tryParse(json['amount'].toString()) ?? 0,
      );
}

// Unified selected bill for both V1/V2
class SelectedBill {
  final String id; // rcvblID for V2, index for V1
  final double amount;
  final String label;

  const SelectedBill(
      {required this.id, required this.amount, required this.label});
}
