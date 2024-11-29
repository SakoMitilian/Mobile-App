import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const BudgetTrackerApp());
}

class BudgetTrackerApp extends StatelessWidget {
  const BudgetTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Professional Budget Tracker',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const BudgetTrackerScreen(),
    );
  }
}

class BudgetTrackerScreen extends StatefulWidget {
  const BudgetTrackerScreen({Key? key}) : super(key: key);

  @override
  State<BudgetTrackerScreen> createState() => _BudgetTrackerScreenState();
}

class _BudgetTrackerScreenState extends State<BudgetTrackerScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> _categories = ['Salary', 'Business', 'Groceries', 'Bills', 'Entertainment'];
  String? _selectedCategory;
  String _selectedType = 'Income';

  final List<Map<String, dynamic>> _transactions = [];
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;

  void _addTransaction() {
    final double amount = double.tryParse(_amountController.text) ?? 0.0;

    if (amount > 0 && _selectedCategory != null) {
      setState(() {
        _transactions.add({
          'type': _selectedType,
          'category': _selectedCategory,
          'amount': amount,
          'description': _descriptionController.text,
          'date': DateTime.now(),
        });

        if (_selectedType == 'Income') {
          _totalIncome += amount;
        } else {
          _totalExpense += amount;
        }

        _amountController.clear();
        _descriptionController.clear();
        _selectedCategory = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double savings = _totalIncome - _totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Tracker'),
        centerTitle: true,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummary(savings),
            const SizedBox(height: 20),
            _buildChart(),
            const SizedBox(height: 20),
            _buildTransactionForm(),
            const SizedBox(height: 20),
            _buildTransactionHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(double savings) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Savings: \$${savings.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: savings >= 0 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Total Income: \$${_totalIncome.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
            Text(
              'Total Expenses: \$${_totalExpense.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Expense Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final Map<String, double> categoryTotals = {};

    for (var transaction in _transactions) {
      if (transaction['type'] == 'Expense') {
        categoryTotals[transaction['category']] =
            (categoryTotals[transaction['category']] ?? 0) + transaction['amount'];
      }
    }

    final List<PieChartSectionData> sections = [];
    categoryTotals.forEach((category, amount) {
      final percentage = amount / _totalExpense * 100;
      sections.add(PieChartSectionData(
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        color: _getCategoryColor(category),
        radius: 50,
      ));
    });

    return sections;
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Groceries':
        return Colors.orange;
      case 'Bills':
        return Colors.blue;
      case 'Entertainment':
        return Colors.purple;
      case 'Salary':
        return Colors.green;
      case 'Business':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTransactionForm() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Transaction',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: ['Income', 'Expense']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              value: _selectedType,
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: _categories
                  .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                  .toList(),
              value: _selectedCategory,
              onChanged: (value) => setState(() => _selectedCategory = value),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addTransaction,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Add Transaction'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistory() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transaction History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final transaction = _transactions[index];
                return ListTile(
                  leading: Icon(
                    transaction['type'] == 'Income'
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: transaction['type'] == 'Income' ? Colors.green : Colors.red,
                  ),
                  title: Text(
                    '${transaction['category']} - \$${transaction['amount'].toStringAsFixed(2)}',
                  ),
                  subtitle: Text(transaction['description']),
                  trailing: Text(
                    '${transaction['date'].hour}:${transaction['date'].minute}',
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}