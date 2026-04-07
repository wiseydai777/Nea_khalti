import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nea_payment/cubits/auth_cubit.dart';
import 'package:nea_payment/cubits/payment_cubit.dart';
import 'screens/login_screen.dart';
import 'screens/payment_screens.dart';
import 'widgets/shared_widgets.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => PaymentCubit()),
      ],
      child: const NeaApp(),
    ),
  );
}

class NeaApp extends StatelessWidget {
  const NeaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'NEA Payment',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: kBg,
          colorScheme:
              const ColorScheme.dark(primary: kAccent, surface: kSurface),
          fontFamily: 'sans-serif',
          useMaterial3: true,
        ),
        home: const _RootGate(),
      );
}

/// Switches between LoginScreen and PaymentShell based on auth state.
class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          showNeaError(context, state.message);
        }
        // Reset payment flow on logout
        if (state is AuthLoggedOut || state is AuthInitial) {
          context.read<PaymentCubit>().reset();
        }
      },
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: state is AuthAuthenticated
              ? const PaymentShell(key: ValueKey('shell'))
              : const LoginScreen(key: ValueKey('login')),
        );
      },
    );
  }
}

// ── Payment shell ─────────────────────────────────────────────────────────────

class PaymentShell extends StatelessWidget {
  const PaymentShell({super.key});

  static const _stepLabels = ['Counters', 'Lookup', 'Bills', 'Charge', 'Pay'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentCubit, PaymentState>(
      builder: (context, payState) {
        return BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            final session =
                authState is AuthAuthenticated ? authState.session : null;

            final stepIndex = switch (payState.step) {
              PaymentStep.counters => 0,
              PaymentStep.lookup => 1,
              PaymentStep.bills => 2,
              PaymentStep.charge => 3,
              PaymentStep.confirm => 4,
              PaymentStep.success => 4,
            };

            return Scaffold(
              appBar: AppBar(
                backgroundColor: kSurface,
                elevation: 0,
                titleSpacing: 0,
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(children: [
                    const SizedBox(height: 20),
                    Image.asset('assets/images/khalti_logo.png', height: 30),
                    const Spacer(),
                    if (session != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: kSurface2,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: kBorder2),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.person, size: 13, color: kAccent),
                          const SizedBox(width: 5),
                          Text(
                            session.mobileNumber.isNotEmpty
                                ? session.mobileNumber
                                : session.subscriberId,
                            style: const TextStyle(
                                fontSize: 11,
                                color: kText,
                                fontFamily: 'monospace'),
                          ),
                        ]),
                      ),
                      const SizedBox(width: 8),
                    ],
                    IconButton(
                      icon: const Icon(Icons.logout, size: 18, color: kMuted),
                      tooltip: 'Sign out',
                      onPressed: () async {
                        final authCubit = context.read<AuthCubit>();
                        final paymentCubit = context.read<PaymentCubit>();
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: kSurface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: kBorder2),
                            ),
                            title: const Text('Sign out',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: kText)),
                            content: const Text(
                              'Are you sure you want to sign out?\nYour current progress will be lost.',
                              style: TextStyle(
                                  fontSize: 13, color: kMuted, height: 1.6),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel',
                                    style:
                                        TextStyle(color: kMuted, fontSize: 13)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style:
                                    TextButton.styleFrom(foregroundColor: kRed),
                                child: const Text('Sign out',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          authCubit.logout();
                          paymentCubit.reset();
                        }
                      },
                    ),
                  ]),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1),
                  child: Container(height: 1, color: kBorder),
                ),
              ),
              body: Column(children: [
                if (payState.step != PaymentStep.success)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: StepBar(
                      currentStep: stepIndex,
                      totalSteps: _stepLabels.length,
                      labels: _stepLabels,
                    ),
                  ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: switch (payState.step) {
                      PaymentStep.counters =>
                        const CountersScreen(key: ValueKey('counters')),
                      PaymentStep.lookup =>
                        const LookupScreen(key: ValueKey('lookup')),
                      PaymentStep.bills =>
                        const BillsScreen(key: ValueKey('bills')),
                      PaymentStep.charge =>
                        const ChargeScreen(key: ValueKey('charge')),
                      PaymentStep.confirm =>
                        const ConfirmScreen(key: ValueKey('confirm')),
                      PaymentStep.success =>
                        const SuccessScreen(key: ValueKey('success')),
                    },
                  ),
                ),
              ]),
            );
          },
        );
      },
    );
  }
}
