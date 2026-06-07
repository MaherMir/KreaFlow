import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'state/app_state.dart';
import 'screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();
  runApp(MyApp(appState: appState));
}

class MyApp extends StatelessWidget {
  final AppState appState;
  const MyApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      notifier: appState,
      child: MaterialApp(
        title: 'KreaFlow - Creatine & Gym Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0B0D17),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00E5FF),
            secondary: Color(0xFFD400FF),
            surface: Color(0xFF131722),
          ),
          textTheme: GoogleFonts.interTextTheme(
            ThemeData.dark().textTheme,
          ),
        ),
        home: ListenableBuilder(
          listenable: appState,
          builder: (context, child) {
            if (!appState.isInitialized) {
              return const Scaffold(
                backgroundColor: Color(0xFF0B0D17),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFF00E5FF),
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Igniting KreaFlow...',
                        style: TextStyle(
                          color: Color(0xFF8E92A0),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const MainNavigation();
          },
        ),
      ),
    );
  }
}
