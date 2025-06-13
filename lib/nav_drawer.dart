import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/pin_setup_or_login_page.dart';

class AppNavDrawer extends StatelessWidget {
  const AppNavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            //User Account Header
            UserAccountsDrawerHeader(
              accountName: const Text("User Name"),
              accountEmail: const Text("user@example.com"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Color.fromARGB(255, 255, 255, 255),
                child: Icon(Icons.person, color: Color.fromARGB(255, 0, 0, 0), size: 36),
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
              ),
            ),

            //Navigation List
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("Dashboard"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardPage()),
                );
              },
            ),

            const Spacer(),

            //Logout Option
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const PinSetupOrLoginPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
