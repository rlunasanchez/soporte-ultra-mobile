import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SoporteUltraApp());
}

class SoporteUltraApp extends StatelessWidget {
  const SoporteUltraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..checkLoginStatus(),
      child: MaterialApp(
        title: 'Carga de OS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0C4A8C),
            primary: const Color(0xFF0C4A8C),
            secondary: const Color(0xFF009EE3),
          ),
          useMaterial3: true,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return auth.isLoggedIn
                ? const _ActivityWrapper(child: HomeScreen())
                : const LoginScreen();
          },
        ),
      ),
    );
  }
}

class _ActivityWrapper extends StatefulWidget {
  final Widget child;

  const _ActivityWrapper({required this.child});

  @override
  State<_ActivityWrapper> createState() => _ActivityWrapperState();
}

class _ActivityWrapperState extends State<_ActivityWrapper> {
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        context.read<AuthProvider>().resetActivityTimer();
      },
      behavior: HitTestBehavior.translucent,
      child: GestureDetector(
        onTap: () {
          context.read<AuthProvider>().resetActivityTimer();
        },
        onPanUpdate: (_) {
          context.read<AuthProvider>().resetActivityTimer();
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            context.read<AuthProvider>().resetActivityTimer();
            return false;
          },
          child: widget.child,
        ),
      ),
    );
  }
}
