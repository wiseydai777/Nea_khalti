import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nea_payment/models/nea_api_models.dart';
import '../cubits/payment_cubit.dart';
import '../widgets/shared_widgets.dart';

// ── Screen shell ──────────────────────────────────────────────────────────────
class StepShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const StepShell(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.child});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: kText,
                  letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(fontSize: 14, color: kMuted, height: 1.6)),
          const SizedBox(height: 20),
          child,
        ]),
      );
}

// ══ STEP 0 — Counters ════════════════════════════════════════════════════════
class CountersScreen extends StatefulWidget {
  const CountersScreen({super.key});
  @override
  State<CountersScreen> createState() => _CountersScreenState();
}

class _CountersScreenState extends State<CountersScreen> {
  final _tokenCtrl = TextEditingController(text: 'TEST:WJdB2Wdb3hWB6bTZDvt9');

  @override
  void dispose() {
    _tokenCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentCubit, PaymentState>(
      listener: (context, state) {
        if (state.error != null) {
          showNeaError(context, state.error!);
          context.read<PaymentCubit>().clearError();
        }
      },
      builder: (context, state) {
        return StepShell(
          title: 'Get counters',
          subtitle: 'Fetch all available NEA counters.',
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Callout(
              text: 'This requires your Khalti service token',
              type: CalloutType.warn,
            ),
            NeaCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const SectionLabel('Request'),
                  NeaTextField(
                    label: 'Endpoint',
                    readOnly: true,
                    controller: TextEditingController(
                        text: '/api/servicegroup/counters/nea/'),
                  ),
                  NeaTextField(
                    label: 'Khalti token *',
                    hint: 'TEST:WJdB2Wdb3hWB6bTZDvt9',
                    obscure: true,
                    controller: _tokenCtrl,
                    onChanged: (v) => context.read<PaymentCubit>().setToken(v),
                  ),
                ])),
            PrimaryButton(
              label: 'Fetch counters',
              loading: state.loadingCounters,
              onTap: () {
                context.read<PaymentCubit>()
                  ..setToken(_tokenCtrl.text)
                  ..fetchCounters();
              },
            ),
            if (state.counters.isNotEmpty) ...[
              const SizedBox(height: 20),
              const SectionLabel('Select counter'),
              ...state.counters.map((c) => _CounterTile(
                    counter: c,
                    selected: state.selectedCounter == c,
                    onTap: () => context.read<PaymentCubit>().selectCounter(c),
                  )),
              if (state.selectedCounter != null) ...[
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Continue →',
                  onTap: () =>
                      context.read<PaymentCubit>().goTo(PaymentStep.lookup),
                ),
              ],
            ],
          ]),
        );
      },
    );
  }
}

class _CounterTile extends StatelessWidget {
  final NeatCounter counter;
  final bool selected;
  final VoidCallback onTap;
  const _CounterTile(
      {required this.counter, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
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
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(counter.name,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: kText)),
                  const SizedBox(height: 2),
                  Text(counter.value,
                      style: const TextStyle(
                          fontSize: 11,
                          color: kMuted,
                          fontFamily: 'monospace')),
                ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              VersionBadge(isV2: counter.migratedToV2),
              const SizedBox(height: 4),
              Text('org: ${counter.orgNo}',
                  style: const TextStyle(fontSize: 10, color: kMuted)),
            ]),
          ]),
        ),
      );
}

// ══ STEP 1 — Lookup ═══════════════════════════════════════════════════════════
class LookupScreen extends StatefulWidget {
  const LookupScreen({super.key});
  @override
  State<LookupScreen> createState() => _LookupScreenState();
}

class _LookupScreenState extends State<LookupScreen> {
  final _scCtrl = TextEditingController();
  final _cidCtrl = TextEditingController();
  final _oldScCtrl = TextEditingController();
  final _oldCidCtrl = TextEditingController();
  final _consumerNoCtrl = TextEditingController();

  @override
  void dispose() {
    _scCtrl.dispose();
    _cidCtrl.dispose();
    _oldScCtrl.dispose();
    _oldCidCtrl.dispose();
    _consumerNoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentCubit, PaymentState>(
      listener: (context, state) {
        if (state.error != null) {
          showNeaError(context, state.error!);
          context.read<PaymentCubit>().clearError();
        }
        // Auto-fill consumer no when fetched
        if (state.newConsumerNo.isNotEmpty && _consumerNoCtrl.text.isEmpty) {
          _consumerNoCtrl.text = state.newConsumerNo;
        }
      },
      builder: (context, state) {
        final cubit = context.read<PaymentCubit>();
        return StepShell(
          title: 'Consumer lookup',
          subtitle: state.isV2
              ? 'V2 flow: enter consumer number. Use migration only for old credentials.'
              : 'V1 flow: enter SC number and consumer ID.',
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            VersionToggle(isV2: state.isV2, onChanged: cubit.setIsV2),
            const SizedBox(height: 4),
            if (!state.isV2) ...[
              NeaCard(
                  child: Column(children: [
                const SectionLabel('V1 — Consumer details'),
                NeaTextField(
                    label: 'SC Number *',
                    hint: '024.12.512',
                    controller: _scCtrl,
                    onChanged: cubit.setScNo),
                NeaTextField(
                    label: 'Consumer ID *',
                    hint: '3042',
                    controller: _cidCtrl,
                    onChanged: cubit.setConsumerId),
                NeaTextField(
                    label: 'Office code',
                    readOnly: true,
                    controller: TextEditingController(
                        text: state.selectedCounter?.value ?? '')),
              ])),
              const Callout(
                  text:
                      'SC number: 3 alphanumeric parts separated by dots e.g. 024.12.512'),
            ] else ...[
              const Callout(
                text:
                    'If the user has a new consumer number from NEA, enter it directly. '
                    'Use migration only for old SC + consumer ID credentials.',
                type: CalloutType.warn,
              ),
              NeaCard(
                  child: Column(children: [
                const SectionLabel('Migrate old credentials (optional)'),
                NeaTextField(
                    label: 'Old SC number',
                    hint: '216.29.013A1',
                    controller: _oldScCtrl,
                    onChanged: cubit.setOldScNo),
                NeaTextField(
                    label: 'Old consumer ID',
                    hint: '21907',
                    controller: _oldCidCtrl,
                    onChanged: cubit.setOldConsumerId),
                NeaTextField(
                    label: 'Org name',
                    readOnly: true,
                    controller: TextEditingController(
                        text: state.selectedCounter?.orgName ?? '')),
                GhostButton(
                  label: state.loadingConsumerId
                      ? 'Fetching...'
                      : 'Get new consumer ID',
                  onTap:
                      state.loadingConsumerId ? null : cubit.fetchNewConsumerID,
                ),
              ])),
              NeaCard(
                  child: Column(children: [
                const SectionLabel('Consumer number'),
                NeaTextField(
                    label: 'Consumer number *',
                    hint: '1001595737',
                    controller: _consumerNoCtrl,
                    onChanged: cubit.setNewConsumerNo),
                NeaTextField(
                    label: 'Confirm type',
                    readOnly: true,
                    controller: TextEditingController(text: 'E')),
                NeaTextField(
                    label: 'Confirm ID type',
                    readOnly: true,
                    controller: TextEditingController(text: 'CN')),
              ])),
            ],
            Row(children: [
              GhostButton(
                  label: '← Back',
                  onTap: () => cubit.goTo(PaymentStep.counters)),
              const SizedBox(width: 10),
              Expanded(
                  child: PrimaryButton(
                label: 'Fetch bills →',
                onTap: () => cubit.goTo(PaymentStep.bills),
              )),
            ]),
          ]),
        );
      },
    );
  }
}

// ══ STEP 2 — Bills ════════════════════════════════════════════════════════════
class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});
  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentCubit>().fetchBills();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentCubit, PaymentState>(
      listener: (context, state) {
        if (state.error != null) {
          showNeaError(context, state.error!);
          context.read<PaymentCubit>().clearError();
        }
      },
      builder: (context, state) {
        final cubit = context.read<PaymentCubit>();
        return StepShell(
          title: 'Bill details',
          subtitle:
              'Review outstanding bills. The oldest bill is the minimum required payment.',
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (state.loadingBills)
              const NeaCard(
                  child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child:
                      CircularProgressIndicator(color: kAccent, strokeWidth: 2),
                ),
              ))
            else ...[
              NeaCard(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(state.consumerName,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: kText)),
                        const SizedBox(height: 2),
                        Text('Session: ${state.sessionId}',
                            style:
                                const TextStyle(fontSize: 12, color: kMuted)),
                      ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    const Text('Total due',
                        style: TextStyle(fontSize: 12, color: kMuted)),
                    Text(kNpr.format(state.totalDue),
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: kRed,
                            fontFamily: 'monospace')),
                  ]),
                ],
              )),
              NeaCard(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const SectionLabel('Due bills'),
                    if (state.isV2) ...[
                      if ((state.billDetailV2?.dueBills ?? []).isEmpty)
                        const Center(
                            child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                              'No outstanding bills. You may make an advance payment.',
                              style: TextStyle(fontSize: 13, color: kMuted)),
                        ))
                      else
                        ...state.billDetailV2!.dueBills.map((bill) => BillTile(
                              month: 'Month ${bill.billMonth}',
                              status: bill.status,
                              payableAmount: bill.payableAmount,
                              baseAmount: bill.feeAmount,
                              selected: state.isBillSelected(bill.rcvblID),
                              onChanged: (sel) => cubit.toggleBill(
                                  SelectedBill(
                                      id: bill.rcvblID,
                                      amount: bill.payableAmount,
                                      label: 'Month ${bill.billMonth}'),
                                  sel),
                            )),
                    ] else ...[
                      if ((state.billDetailV1?.dueBills ?? []).isEmpty)
                        const Center(
                            child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text('No outstanding bills.',
                              style: TextStyle(fontSize: 13, color: kMuted)),
                        ))
                      else
                        ...state.billDetailV1!.dueBills
                            .asMap()
                            .entries
                            .map((entry) {
                          final i = entry.key;
                          final bill = entry.value;
                          return BillTile(
                            month: bill.dueBillOf,
                            status: bill.status,
                            payableAmount: bill.payableAmount,
                            baseAmount: bill.billAmount,
                            selected: state.isBillSelected(i.toString()),
                            onChanged: (sel) => cubit.toggleBill(
                                SelectedBill(
                                    id: i.toString(),
                                    amount: bill.payableAmount,
                                    label: bill.dueBillOf),
                                sel),
                          );
                        }),
                    ],
                  ])),
              Row(children: [
                GhostButton(
                    label: '← Back',
                    onTap: () => cubit.goTo(PaymentStep.lookup)),
                const SizedBox(width: 10),
                Expanded(
                    child: PrimaryButton(
                  label: 'Calculate charge →',
                  onTap: () => cubit.goTo(PaymentStep.charge),
                )),
              ]),
            ],
          ]),
        );
      },
    );
  }
}

// ══ STEP 3 — Service Charge ═══════════════════════════════════════════════════
class ChargeScreen extends StatefulWidget {
  const ChargeScreen({super.key});
  @override
  State<ChargeScreen> createState() => _ChargeScreenState();
}

class _ChargeScreenState extends State<ChargeScreen> {
  late final TextEditingController _amountCtrl;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
        text: context.read<PaymentCubit>().state.payAmount.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentCubit, PaymentState>(
      listener: (context, state) {
        if (state.error != null) {
          showNeaError(context, state.error!);
          context.read<PaymentCubit>().clearError();
        }
      },
      builder: (context, state) {
        final cubit = context.read<PaymentCubit>();
        return StepShell(
          title: 'Service charge',
          subtitle:
              'Calculate the applicable service charge before confirming payment.',
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            NeaCard(
                child: Column(children: [
              const SectionLabel('Payment amount'),
              NeaTextField(
                label: 'Amount (NPR) *',
                hint: '0',
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                onChanged: (v) => cubit.setPayAmount(double.tryParse(v) ?? 0),
              ),
            ])),
            if (!state.isV2) ...[
              const Callout(
                  text:
                      'V1: Service charge applies for amounts > 500. Fetch the exact charge from the API.'),
              GhostButton(
                label: state.loadingCharge
                    ? 'Calculating...'
                    : 'Calculate service charge',
                onTap: state.loadingCharge ? null : cubit.fetchServiceCharge,
              ),
              const SizedBox(height: 12),
            ],
            NeaCard(
                child: Column(children: [
              const SectionLabel('Breakdown'),
              AmountRow(label: 'Bill amount', value: state.payAmount),
              const Divider(color: kBorder, height: 1),
              AmountRow(label: 'Service charge', value: state.serviceCharge),
              const Divider(color: kBorder, height: 1),
              AmountRow(
                  label: 'Total payable',
                  value: state.totalPayable,
                  isTotal: true),
            ])),
            Row(children: [
              GhostButton(
                  label: '← Back', onTap: () => cubit.goTo(PaymentStep.bills)),
              const SizedBox(width: 10),
              Expanded(
                  child: PrimaryButton(
                label: 'Confirm & pay →',
                onTap: () => cubit.goTo(PaymentStep.confirm),
              )),
            ]),
          ]),
        );
      },
    );
  }
}

// ══ STEP 4 — Confirm ══════════════════════════════════════════════════════════
class ConfirmScreen extends StatelessWidget {
  const ConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentCubit, PaymentState>(
      listener: (context, state) {
        if (state.error != null) {
          showNeaError(context, state.error!);
          context.read<PaymentCubit>().clearError();
        }
      },
      builder: (context, state) {
        final cubit = context.read<PaymentCubit>();
        return StepShell(
          title: 'Make payment',
          subtitle: 'Review the transaction details and confirm.',
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            NeaCard(
                child: Column(children: [
              const SectionLabel('Transaction summary'),
              _SummaryRow('Consumer', state.consumerName),
              const Divider(color: kBorder, height: 1),
              _SummaryRow('Flow', state.isV2 ? 'NEA V2' : 'NEA V1'),
              const Divider(color: kBorder, height: 1),
              _SummaryRow(
                  'Bills',
                  state.selectedBills.isEmpty
                      ? 'Advance payment'
                      : state.selectedBills.map((b) => b.label).join(', ')),
              const Divider(color: kBorder, height: 1),
              AmountRow(label: 'Amount', value: state.payAmount),
              const Divider(color: kBorder, height: 1),
              AmountRow(label: 'Service charge', value: state.serviceCharge),
              const Divider(color: kBorder, height: 1),
              AmountRow(
                  label: 'Total', value: state.totalPayable, isTotal: true),
            ])),
            const Callout(
              text:
                  'This action will process a real payment. Ensure all details are correct.',
              type: CalloutType.warn,
            ),
            Row(children: [
              GhostButton(
                  label: '← Back', onTap: () => cubit.goTo(PaymentStep.charge)),
              const SizedBox(width: 10),
              Expanded(
                  child: PrimaryButton(
                label: 'Confirm payment',
                loading: state.loadingPayment,
                onTap: cubit.makePayment,
              )),
            ]),
          ]),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(fontSize: 13, color: kMuted)),
          Flexible(
              child: Text(value,
                  style: const TextStyle(fontSize: 13, color: kText),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis)),
        ]),
      );
}

// ══ SUCCESS ═══════════════════════════════════════════════════════════════════
class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentCubit, PaymentState>(
      builder: (context, state) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: kAccentDim,
                shape: BoxShape.circle,
                border: Border.all(color: kAccent.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.check, color: kAccent, size: 28),
            ),
            const SizedBox(height: 20),
            const Text('Payment successful',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: kText,
                    letterSpacing: -0.5)),
            const SizedBox(height: 8),
            const Text('The transaction has been processed successfully.',
                style: TextStyle(fontSize: 14, color: kMuted),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  color: kSurface2, borderRadius: BorderRadius.circular(6)),
              child: Text('TX ID: #${state.paymentResult?.id ?? '—'}',
                  style: const TextStyle(
                      fontSize: 12, color: kMuted, fontFamily: 'monospace')),
            ),
            const SizedBox(height: 28),
            GhostButton(
              label: 'New payment',
              onTap: () => context.read<PaymentCubit>().reset(),
            ),
          ]),
        ),
      ),
    );
  }
}
