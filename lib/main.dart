import 'package:material_ui/material_ui.dart';

import 'screens/tracker_shell.dart';
import 'theme.dart';

void main() => runApp(const NeerajExpenseApp());

class NeerajExpenseApp extends StatelessWidget {
  const NeerajExpenseApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Neeraj Expense',
    debugShowCheckedModeBanner: false,
    theme: appTheme(),
    home: const WelcomePage(),
  );
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});
  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final email = TextEditingController(), password = TextEditingController();
  bool hide = true;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void enter() {
    if (email.text.trim().isEmpty || password.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter an email and a password of at least 4 characters.',
          ),
        ),
      );
      return;
    }
    _open(email.text.trim().split('@').first);
  }

  void _open(String name) => Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (_) => TrackerShell(name: name.isEmpty ? 'Friend' : name),
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        Positioned(
          top: -100,
          right: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: green.withValues(alpha: .12),
            ),
          ),
        ),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 850),
                      builder: (c, v, ch) => Transform.translate(
                        offset: Offset(0, 20 * (1 - v)),
                        child: Opacity(opacity: v, child: ch),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 78,
                            height: 78,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: ink.withValues(alpha: .12),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/neeraj_expense_logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Text(
                            'Neeraj Expense',
                            style: TextStyle(
                              color: ink,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Make money\nmake sense.',
                      style: TextStyle(
                        fontSize: 40,
                        height: 1.05,
                        fontWeight: FontWeight.w800,
                        color: ink,
                        letterSpacing: -1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Your spending, lending and little wins — all in one calm place.',
                      style: TextStyle(color: muted, fontSize: 15, height: 1.5),
                    ),
                    const SizedBox(height: 30),
                    _field(email, 'Email address', Icons.mail_outline_rounded),
                    const SizedBox(height: 12),
                    TextField(
                      controller: password,
                      obscureText: hide,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => hide = !hide),
                          icon: Icon(
                            hide
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 53,
                      child: FilledButton(
                        onPressed: enter,
                        style: FilledButton.styleFrom(
                          backgroundColor: ink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Continue with email',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'or',
                            style: TextStyle(color: muted, fontSize: 12),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 13),
                    Row(
                      children: [
                        Expanded(
                          child: _social('G', 'Google', () => _oauth('Google')),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: _social('●', 'GitHub', () => _oauth('GitHub')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 11),
                    const Center(
                      child: Text(
                        'Preview only — account sign-in is not connected yet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: muted, fontSize: 11),
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () => _open('Friend'),
                        child: const Text(
                          'Explore as guest',
                          style: TextStyle(
                            color: green,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const Center(
                      child: Text(
                        'Your entries are saved on this device.',
                        style: TextStyle(color: muted, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
  Widget _field(TextEditingController c, String hint, IconData icon) =>
      TextField(
        controller: c,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      );
  Widget _social(String mark, String label, VoidCallback onTap) =>
      OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          backgroundColor: Colors.white,
          side: BorderSide.none,
          minimumSize: const Size(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(mark, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(width: 9),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      );
  void _oauth(String provider) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        '$provider sign-in needs an authentication service and OAuth credentials.',
      ),
    ),
  );
}
