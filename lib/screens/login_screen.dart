import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nea_payment/cubits/auth_cubit.dart';
import '../widgets/shared_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _mobileCtrl = TextEditingController(text: '9803000838');
  final _passCtrl = TextEditingController(text: 'Ndpc@2026');
  final _deviceCtrl = TextEditingController(text: 'AP31.240517.022');
  final _ipCtrl = TextEditingController(text: '103.164.158.193');
  bool _showAdvanced = false;
  bool _obscurePass = true;

  @override
  void dispose() {
    _mobileCtrl.dispose();
    _passCtrl.dispose();
    _deviceCtrl.dispose();
    _ipCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) showNeaError(context, state.message);
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Scaffold(
          backgroundColor: kBg,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Image.asset('assets/images/khalti_logo.png', height: 24),
                      const SizedBox(height: 32),
                      const Text('Sign in',
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: kText,
                              letterSpacing: -0.5)),
                      const SizedBox(height: 4),
                      const Text(
                          'Authenticate with your Namaste Pay subscriber credentials.',
                          style: TextStyle(
                              fontSize: 14, color: kMuted, height: 1.6)),
                      const SizedBox(height: 28),
                      NeaCard(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            const SectionLabel('Credentials'),
                            NeaTextField(
                              label: 'Mobile number / Login ID *',
                              hint: '9803300032',
                              controller: _mobileCtrl,
                              keyboardType: TextInputType.phone,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Password *',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: kMuted)),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _passCtrl,
                                    obscureText: _obscurePass,
                                    style: const TextStyle(
                                        fontSize: 13, color: kText),
                                    decoration: InputDecoration(
                                      hintText: 'your password',
                                      hintStyle: const TextStyle(
                                          color: kMuted, fontSize: 13),
                                      filled: true,
                                      fillColor: kSurface2,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 13, vertical: 10),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide:
                                            const BorderSide(color: kBorder2),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide:
                                            const BorderSide(color: kAccent),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                            _obscurePass
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: kMuted,
                                            size: 18),
                                        onPressed: () => setState(
                                            () => _obscurePass = !_obscurePass),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                ]),
                          ])),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _showAdvanced = !_showAdvanced),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(children: [
                            Text(
                                _showAdvanced
                                    ? 'Hide device info'
                                    : 'Show device info',
                                style: const TextStyle(
                                    fontSize: 12, color: kMuted)),
                            const SizedBox(width: 4),
                            Icon(
                                _showAdvanced
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                size: 16,
                                color: kMuted),
                          ]),
                        ),
                      ),
                      if (_showAdvanced) ...[
                        const SizedBox(height: 8),
                        NeaCard(
                            child: Column(children: [
                          const SectionLabel('Device info'),
                          NeaTextField(
                              label: 'Device ID', controller: _deviceCtrl),
                          NeaTextField(
                              label: 'Provider IP',
                              controller: _ipCtrl,
                              keyboardType: TextInputType.number),
                        ])),
                      ],
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: 'Sign in',
                        loading: isLoading,
                        onTap: isLoading
                            ? null
                            : () => context.read<AuthCubit>().login(
                                  mobileNumber: _mobileCtrl.text.trim(),
                                  password: _passCtrl.text,
                                  deviceId: _deviceCtrl.text.trim(),
                                  providerIp: _ipCtrl.text.trim(),
                                ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kSurface2,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: kBorder),
                        ),
                        child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Endpoint',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: kMuted,
                                      letterSpacing: 0.8)),
                              SizedBox(height: 6),
                              Text(
                                  'POST /mobiquitypay/v3/user/subscriberApp/login',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: kAccent,
                                      fontFamily: 'monospace')),
                              SizedBox(height: 4),
                              Text('Auth: Basic (client credentials)',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: kMuted,
                                      fontFamily: 'monospace')),
                            ]),
                      ),
                      const SizedBox(height: 20),
                    ]),
              ),
            ),
          ),
        );
      },
    );
  }
}
