import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nea_payment/models/nea_api_models.dart';
import 'package:nea_payment/nea_api_services/nea_api.dart';

// ── Step enum ─────────────────────────────────────────────────────────────────

enum PaymentStep { counters, lookup, bills, charge, confirm, success }

// ── State ─────────────────────────────────────────────────────────────────────

class PaymentState {
  final String baseUrl;
  final String token;
  final PaymentStep step;
  final bool isV2;
  final bool loadingCounters;
  final List<NeatCounter> counters;
  final NeatCounter? selectedCounter;
  final bool loadingConsumerId;
  final String scNo;
  final String consumerId;
  final String newConsumerNo;
  final String oldScNo;
  final String oldConsumerId;
  final bool loadingBills;
  final BillDetailV1? billDetailV1;
  final BillDetailV2? billDetailV2;
  final List<SelectedBill> selectedBills;
  final bool loadingCharge;
  final double payAmount;
  final double serviceCharge;
  final bool loadingPayment;
  final PaymentResult? paymentResult;
  final String? error;

  const PaymentState({
    this.baseUrl = 'https://uatservices.khalti.com',
    this.token = 'TEST:WJdB2Wdb3hWB6bTZDvt9',
    this.step = PaymentStep.counters,
    this.isV2 = false,
    this.loadingCounters = false,
    this.counters = const [],
    this.selectedCounter,
    this.loadingConsumerId = false,
    this.scNo = '',
    this.consumerId = '',
    this.newConsumerNo = '',
    this.oldScNo = '',
    this.oldConsumerId = '',
    this.loadingBills = false,
    this.billDetailV1,
    this.billDetailV2,
    this.selectedBills = const [],
    this.loadingCharge = false,
    this.payAmount = 0,
    this.serviceCharge = 0,
    this.loadingPayment = false,
    this.paymentResult,
    this.error,
  });

  int? get sessionId =>
      isV2 ? billDetailV2?.sessionId : billDetailV1?.sessionId;
  String get consumerName => isV2
      ? (billDetailV2?.consumerName ?? '')
      : (billDetailV1?.consumerName ?? '');
  double get totalDue => isV2
      ? (billDetailV2?.totalDueAmount ?? 0)
      : (billDetailV1?.totalDueAmount ?? 0);
  double get totalPayable => payAmount + serviceCharge;
  bool isBillSelected(String id) => selectedBills.any((b) => b.id == id);

  PaymentState copyWith({
    String? baseUrl,
    String? token,
    PaymentStep? step,
    bool? isV2,
    bool? loadingCounters,
    List<NeatCounter>? counters,
    NeatCounter? selectedCounter,
    bool clearSelectedCounter = false,
    bool? loadingConsumerId,
    String? scNo,
    String? consumerId,
    String? newConsumerNo,
    String? oldScNo,
    String? oldConsumerId,
    bool? loadingBills,
    BillDetailV1? billDetailV1,
    BillDetailV2? billDetailV2,
    List<SelectedBill>? selectedBills,
    bool? loadingCharge,
    double? payAmount,
    double? serviceCharge,
    bool? loadingPayment,
    PaymentResult? paymentResult,
    String? error,
    bool clearError = false,
    bool clearPaymentResult = false,
  }) {
    return PaymentState(
      baseUrl: baseUrl ?? this.baseUrl,
      token: token ?? this.token,
      step: step ?? this.step,
      isV2: isV2 ?? this.isV2,
      loadingCounters: loadingCounters ?? this.loadingCounters,
      counters: counters ?? this.counters,
      selectedCounter: clearSelectedCounter
          ? null
          : (selectedCounter ?? this.selectedCounter),
      loadingConsumerId: loadingConsumerId ?? this.loadingConsumerId,
      scNo: scNo ?? this.scNo,
      consumerId: consumerId ?? this.consumerId,
      newConsumerNo: newConsumerNo ?? this.newConsumerNo,
      oldScNo: oldScNo ?? this.oldScNo,
      oldConsumerId: oldConsumerId ?? this.oldConsumerId,
      loadingBills: loadingBills ?? this.loadingBills,
      billDetailV1: billDetailV1 ?? this.billDetailV1,
      billDetailV2: billDetailV2 ?? this.billDetailV2,
      selectedBills: selectedBills ?? this.selectedBills,
      loadingCharge: loadingCharge ?? this.loadingCharge,
      payAmount: payAmount ?? this.payAmount,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      loadingPayment: loadingPayment ?? this.loadingPayment,
      paymentResult:
          clearPaymentResult ? null : (paymentResult ?? this.paymentResult),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit() : super(const PaymentState());

  // Token is passed into NeaApi constructor — it injects it into every
  // request body automatically via _withToken(). No need to pass per-call.
  NeaApi get _api => NeaApi(baseUrl: state.baseUrl, token: state.token);

  // ── Config ─────────────────────────────────────────────────────────────────

  void setToken(String token) => emit(state.copyWith(token: token));
  void setBaseUrl(String url) => emit(state.copyWith(baseUrl: url));

  // ── Navigation ─────────────────────────────────────────────────────────────

  void goTo(PaymentStep step) =>
      emit(state.copyWith(step: step, clearError: true));

  void reset() => emit(const PaymentState());

  void clearError() => emit(state.copyWith(clearError: true));

  // ── Step 1: Counters ───────────────────────────────────────────────────────

  Future<void> fetchCounters() async {
    emit(state.copyWith(loadingCounters: true, clearError: true));
    try {
      final counters = await _api.getCounters();
      emit(state.copyWith(loadingCounters: false, counters: counters));
    } on NeaApiException catch (e) {
      emit(state.copyWith(loadingCounters: false, error: e.message));
    } catch (e) {
      emit(state.copyWith(
          loadingCounters: false, error: 'Error: ${e.runtimeType}'));
    }
  }

  void selectCounter(NeatCounter counter) {
    emit(state.copyWith(
      selectedCounter: counter,
      isV2: counter.migratedToV2,
    ));
  }

  // ── Step 2: Lookup ─────────────────────────────────────────────────────────

  void setScNo(String v) => emit(state.copyWith(scNo: v));
  void setConsumerId(String v) => emit(state.copyWith(consumerId: v));
  void setNewConsumerNo(String v) => emit(state.copyWith(newConsumerNo: v));
  void setOldScNo(String v) => emit(state.copyWith(oldScNo: v));
  void setOldConsumerId(String v) => emit(state.copyWith(oldConsumerId: v));
  void setIsV2(bool v) => emit(state.copyWith(isV2: v));

  Future<void> fetchNewConsumerID() async {
    emit(state.copyWith(loadingConsumerId: true, clearError: true));
    try {
      final consumerNo = await _api.getNewConsumerID(
        scNo: state.oldScNo,
        oldConsumerId: state.oldConsumerId,
        orgName: state.selectedCounter?.orgName ?? '',
      );
      emit(state.copyWith(loadingConsumerId: false, newConsumerNo: consumerNo));
    } on NeaApiException catch (e) {
      emit(state.copyWith(loadingConsumerId: false, error: e.message));
    } catch (e) {
      emit(state.copyWith(
          loadingConsumerId: false, error: 'Error: ${e.runtimeType}'));
    }
  }

  // ── Step 3: Bills ──────────────────────────────────────────────────────────

  Future<void> fetchBills() async {
    emit(state.copyWith(
        loadingBills: true, selectedBills: [], clearError: true));
    try {
      if (state.isV2) {
        final detail =
            await _api.getBillDetailsV2(consumerNo: state.newConsumerNo);
        final preSelected = detail.dueBills.isNotEmpty
            ? [
                SelectedBill(
                  id: detail.dueBills.first.rcvblID,
                  amount: detail.dueBills.first.payableAmount,
                  label: 'Month ${detail.dueBills.first.billMonth}',
                )
              ]
            : <SelectedBill>[];
        emit(state.copyWith(
          loadingBills: false,
          billDetailV2: detail,
          selectedBills: preSelected,
          payAmount: preSelected.isNotEmpty ? preSelected.first.amount : 0,
        ));
      } else {
        final detail = await _api.getBillDetailsV1(
          scNo: state.scNo,
          consumerId: state.consumerId,
          officeCode: state.selectedCounter?.value ?? '',
        );
        final preSelected = detail.dueBills.isNotEmpty
            ? [
                SelectedBill(
                  id: '0',
                  amount: detail.dueBills.first.payableAmount,
                  label: detail.dueBills.first.dueBillOf,
                )
              ]
            : <SelectedBill>[];
        emit(state.copyWith(
          loadingBills: false,
          billDetailV1: detail,
          selectedBills: preSelected,
          payAmount: preSelected.isNotEmpty ? preSelected.first.amount : 0,
        ));
      }
    } on NeaApiException catch (e) {
      emit(state.copyWith(loadingBills: false, error: e.message));
    } catch (e) {
      emit(state.copyWith(
          loadingBills: false, error: 'Error: ${e.runtimeType}'));
    }
  }

  void toggleBill(SelectedBill bill, bool selected) {
    final updated = List<SelectedBill>.from(state.selectedBills);
    if (selected) {
      if (!updated.any((b) => b.id == bill.id)) updated.add(bill);
    } else {
      updated.removeWhere((b) => b.id == bill.id);
    }
    final total = updated.fold(0.0, (sum, b) => sum + b.amount);
    emit(state.copyWith(selectedBills: updated, payAmount: total));
  }

  // ── Step 4: Charge ─────────────────────────────────────────────────────────

  void setPayAmount(double amount) {
    emit(state.copyWith(
      payAmount: amount,
      serviceCharge: state.isV2 ? 0 : state.serviceCharge,
    ));
  }

  Future<void> fetchServiceCharge() async {
    if (state.sessionId == null) return;
    emit(state.copyWith(loadingCharge: true, clearError: true));
    try {
      final result = await _api.getServiceCharge(
        amount: state.payAmount,
        sessionId: state.sessionId!,
      );
      emit(state.copyWith(loadingCharge: false, serviceCharge: result.charge));
    } on NeaApiException catch (e) {
      emit(state.copyWith(loadingCharge: false, error: e.message));
    } catch (e) {
      emit(state.copyWith(
          loadingCharge: false, error: 'Error: ${e.runtimeType}'));
    }
  }

  // ── Step 5: Payment ────────────────────────────────────────────────────────

  Future<void> makePayment() async {
    if (state.sessionId == null) return;
    emit(state.copyWith(loadingPayment: true, clearError: true));
    try {
      final PaymentResult result;
      if (state.isV2) {
        result = await _api.makePaymentV2(
          sessionId: state.sessionId!,
          amount: state.payAmount,
          billIds: state.selectedBills.isEmpty
              ? null
              : state.selectedBills.map((b) => b.id).toList(),
        );
      } else {
        result = await _api.makePaymentV1(
          sessionId: state.sessionId!,
          amount: state.payAmount,
        );
      }
      emit(state.copyWith(
        loadingPayment: false,
        paymentResult: result,
        step: PaymentStep.success,
      ));
    } on NeaApiException catch (e) {
      emit(state.copyWith(loadingPayment: false, error: e.message));
    } catch (e) {
      emit(state.copyWith(
          loadingPayment: false, error: 'Error: ${e.runtimeType}'));
    }
  }
}
