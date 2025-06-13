import 'package:flutter/material.dart';
import '../bank_logic.dart';
import '../nav_drawer.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

// ...move the rest of your _DashboardPageState code here...

class _DashboardPageState extends State<DashboardPage> {
  void _showAmountDialog(String title, Function(double) onSubmit) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: amountController,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Enter amount"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Back")),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(amountController.text);
              if (amt == null || amt <= 0) {
                _showError("Please enter a valid positive number.");
                return;
              }
              onSubmit(amt);
              Navigator.pop(context);
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _changePincode() {
    final TextEditingController currentPinController = TextEditingController();
    final TextEditingController newPinController = TextEditingController();
    final TextEditingController confirmNewPinController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text("Change Pincode"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: currentPinController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Current Pincode"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: newPinController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "New Pincode"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: confirmNewPinController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Confirm New Pincode"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Back")),
            ElevatedButton(
              onPressed: () {
                if (currentPinController.text != pincode) {
                  _showError("Incorrect current pincode.");
                  return;
                }
                if (newPinController.text.isEmpty || confirmNewPinController.text.isEmpty) {
                  _showError("New pincode cannot be empty.");
                  return;
                }
                if (newPinController.text != confirmNewPinController.text) {
                  _showError("New pincode does not match.");
                  return;
                }
                setState(() {
                  pincode = newPinController.text;
                });
                Navigator.pop(context);
                _showInfo("Pincode changed successfully.");
              },
              child: const Text("Change"),
            ),
          ],
        ),
      ),
    );
  }

  void _showPayBillsMenu() {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text("Pay Bills"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < billsToPay.length; i++)
                ListTile(
                  title: Text("${billsToPay[i][0]} (Due: ${billsToPay[i][1]})"),
                  onTap: () {
                    Navigator.pop(context);
                    _showAmountDialog("Pay ${billsToPay[i][0]}", (amount) {
                      if (amount > Balance.money) {
                        _showError("Insufficient funds.");
                        return;
                      }
                      if (amount > billsToPay[i][1]) {
                        amount = billsToPay[i][1].toDouble(); // cap at due amount
                      }
                      setState(() {                     
                        Balance.money -= amount;
                        billsToPay[i][1] -= amount.toInt();
                      });
                      _showInfo("Paid ${amount.toStringAsFixed(2)} for ${billsToPay[i][0]}. Remaining bill: ${billsToPay[i][1]}");
                    });
                  },
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Back")),
          ],
        ),
      ),
    );
  }

  void _showTransferDialog() {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController recipientController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Transfer Money"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: recipientController,
                decoration: const InputDecoration(labelText: "Recipient"),
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Amount"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Back")),
          ElevatedButton(
            onPressed: () {
              final amount = int.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                _showError("Please enter a valid positive amount.");
                return;
              }
              if (amount > Balance.money) {
                _showError("Insufficient funds.");
                return;
              }
              // For simplicity, we won't track recipient logic
              setState(() {
                Balance.money -= amount;
              });
              Navigator.pop(context);
              _showInfo("Transferred ${amount.toStringAsFixed(2)} successfully.");
            },
            child: const Text("Transfer"),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog() {
    _showAmountDialog("Withdraw Cash", (amount) {
      if (amount > Balance.money) {
        _showError("Insufficient funds.");
        return;
      }
      setState(() {
        Balance.money -= amount;
      });
      _showInfo("Withdrawal successful. Remaining balance: ${Balance.money.toStringAsFixed(2)}");
    });
  }

  void _showDepositDialog() {
    _showAmountDialog("Deposit Money", (amount) {
      setState(() {
        Balance.money += amount;
      });
      _showInfo("Deposit successful. New balance: ${Balance.money.toStringAsFixed(2)}");
    });
  }
  
  @override
  Widget build(BuildContext context) {
    const cardTextStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
    const cardSubTextStyle =  TextStyle(fontSize: 10);
    const cardBalanceStyle = TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(179, 0, 0, 0));
    return Scaffold(
      drawer: const AppNavDrawer(),
      appBar: AppBar(
        title: const Text("Bank Dashboard"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Balance Inquiry Card (full width)
            Card(
              color: Colors.orange.shade400,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: () {
                  _showInfo("Your current balance is: ${Balance.money.toStringAsFixed(2)}");
                },
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                       const Text("Balance Inquiry", style: cardTextStyle),
                        const SizedBox(height: 8),
                        Text("₱${Balance.money.toStringAsFixed(2)}", style: cardBalanceStyle,),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // The rest of the cards in a 2-column grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  Card(
                    color: Colors.red.shade400,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      onTap: _showWithdrawDialog,
                      borderRadius: BorderRadius.circular(12),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children:const [
                              Text("Withdraw Money", style: cardTextStyle),
                              SizedBox(height: 8),
                              Text("Withdraw funds", style: cardSubTextStyle),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.green.shade400,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      onTap: _showTransferDialog,
                      borderRadius: BorderRadius.circular(12),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children:const  [
                              Text("Transfer Money", style: cardTextStyle),
                              SizedBox(height: 8),
                              Text("Send money", style: cardSubTextStyle),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.blue.shade300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      onTap: _showDepositDialog,
                      borderRadius: BorderRadius.circular(12),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [ 
                              Text("Deposit Money", style: cardTextStyle),
                               SizedBox(height: 8),
                              Text("Add money to account", style: cardSubTextStyle),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.purple.shade300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      onTap: _changePincode,
                      borderRadius: BorderRadius.circular(12),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const[
                              Text("Change Pincode", style: cardTextStyle),
                               SizedBox(height: 8),
                              Text("Update security code", style: cardSubTextStyle),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.teal.shade300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      onTap: _showPayBillsMenu,
                      borderRadius: BorderRadius.circular(12),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children:const [
                              Text("Pay Bills", style: cardTextStyle),
                               SizedBox(height: 8),
                              Text("Electricity, Water, Internet", style: cardSubTextStyle),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}