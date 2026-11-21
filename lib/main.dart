import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/tracker_shell.dart';
import 'theme.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
const _redirectUrl = 'com.neerajsawant.neerajexpense://login-callback/';
final _navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (_supabaseUrl.isNotEmpty && _supabaseKey.isNotEmpty) {
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseKey);
  }
  runApp(const NeerajExpenseApp());
}

class NeerajExpenseApp extends StatelessWidget {
  const NeerajExpenseApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    navigatorKey: _navigatorKey,
    title: 'Neeraj Expense',
    debugShowCheckedModeBanner: false,
    theme: appTheme(),
    home:
        _isSupabaseConfigured &&
            Supabase.instance.client.auth.currentSession != null
        ? TrackerShell(
            name:
                Supabase.instance.client.auth.currentUser?.email
                    ?.split('@')
                    .first ??
                'Friend',
            accountEmail: Supabase.instance.client.auth.currentUser?.email,
            provider: _providerFor(Supabase.instance.client.auth.currentUser),
            onAccountAction: _returnToLogin,
          )
        : const WelcomePage(),
  );
}

bool get _isSupabaseConfigured =>
    _supabaseUrl.isNotEmpty && _supabaseKey.isNotEmpty;

String? _providerFor(User? user) {
  if (user == null) return null;
  final provider =
      user.appMetadata['provider']?.toString() ??
      (user.identities?.isNotEmpty == true
          ? user.identities!.first.provider
          : null);
  return switch (provider?.toLowerCase()) {
    'github' => 'GitHub',
    'google' => 'Google',
    'email' => 'Email and password',
    null => 'Signed in',
    _ => provider,
  };
}

Future<void> _returnToLogin() async {
  if (_isSupabaseConfigured &&
      Supabase.instance.client.auth.currentSession != null) {
    await Supabase.instance.client.auth.signOut();
  }
  _navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: (_) => const WelcomePage()),
    (_) => false,
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
  bool busy = false;
  bool createAccount = false;
  StreamSubscription<AuthState>? authSubscription;

  @override
  void initState() {
    super.initState();
    if (_isSupabaseConfigured) {
      authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
        (data) {
          if (data.event == AuthChangeEvent.signedIn && mounted) {
            final name = data.session?.user.email?.split('@').first ?? 'Friend';
            _open(name, user: data.session?.user);
          }
        },
      );
    }
  }

  @override
  void dispose() {
    authSubscription?.cancel();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> enter() async {
    if (!_isSupabaseConfigured) {
      _message(
        'Add your Supabase project URL and publishable key to run sign-in.',
      );
      return;
    }
    if (email.text.trim().isEmpty || password.text.length < 6) {
      _message('Enter your email and a password with at least 6 characters.');
      return;
    }
    setState(() => busy = true);
    try {
      final auth = Supabase.instance.client.auth;
      if (createAccount) {
        final response = await auth.signUp(
          email: email.text.trim(),
          password: password.text,
        );
        if (response.session == null && mounted) {
          _message('Check your email to confirm your account, then sign in.');
        }
      } else {
        await auth.signInWithPassword(
          email: email.text.trim(),
          password: password.text,
        );
      }
    } on AuthException catch (error) {
      _message(error.message);
    } catch (error) {
      _message('Could not sign in. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _open(String name, {User? user}) =>
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TrackerShell(
            name: name.isEmpty ? 'Friend' : name,
            accountEmail: user?.email,
            provider: _providerFor(user),
            onAccountAction: _returnToLogin,
          ),
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
                        onPressed: busy ? null : enter,
                        style: FilledButton.styleFrom(
                          backgroundColor: ink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          busy
                              ? 'Please wait…'
                              : createAccount
                              ? 'Create account'
                              : 'Sign in with email',
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
                          child: _social(
                            'G',
                            'Google',
                            () => _oauth(OAuthProvider.google),
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: _social(
                            '●',
                            'GitHub',
                            () => _oauth(OAuthProvider.github),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 11),
                    Center(
                      child: TextButton(
                        onPressed: busy
                            ? null
                            : () => setState(
                                () => createAccount = !createAccount,
                              ),
                        child: Text(
                          createAccount
                              ? 'Already have an account? Sign in'
                              : 'New here? Create an account',
                        ),
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
  Future<void> _oauth(OAuthProvider provider) async {
    if (!_isSupabaseConfigured) {
      _message(
        'Add your Supabase project URL and publishable key to run sign-in.',
      );
      return;
    }
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        provider,
        redirectTo: _redirectUrl,
      );
    } on AuthException catch (error) {
      _message(error.message);
    } catch (error) {
      _message(
        'Could not start sign-in. Check the provider settings and try again.',
      );
    }
  }
}
