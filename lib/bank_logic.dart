// ==== BANK LOGIC ====

String pincode = "";
bool loggedIn = false;

List<List<dynamic>> billsToPay = [
  ["Electricity", 100],
  ["Water", 50],
  ["Internet", 75],
];

class Balance {
  static double money = 0.00; 
}
