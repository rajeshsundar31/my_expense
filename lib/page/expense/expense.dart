import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_expense/page/dashboard/dashboard.dart';
import 'package:my_expense/page/expense/expense_view_model.dart';
import 'package:provider/provider.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  bool _categoryError = false;

  static const List<_Category> _categories = [
    _Category('Groceries', Icons.shopping_basket_rounded, Color(0xFF26A69A)),
    _Category('Food', Icons.restaurant_rounded, Color(0xFF7E57C2)),
    _Category('Travel', Icons.local_taxi_rounded, Color(0xFF66BB6A)),
    _Category('Fuel', Icons.local_gas_station_rounded, Color(0xFFFFA726)),
    _Category('Bills', Icons.bolt_rounded, Color(0xFF42A5F5)),
    _Category('Shopping', Icons.shopping_bag_rounded, Color(0xFFEC407A)),
    _Category('Movies', Icons.movie_filter_rounded, Color(0xFFEF5350)),
    _Category('Health', Icons.favorite_rounded, Color(0xFFFF7043)),
    _Category('Other', Icons.category_rounded, Color(0xFF78909C)),
  ];

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String get _displayDate =>
      '${_selectedDate.day.toString().padLeft(2, '0')} '
      '${_months[_selectedDate.month - 1]} ${_selectedDate.year}';

  // yyyy-MM-dd, handy for sending to the API
  String get _apiDate =>
      '${_selectedDate.year}-'
      '${_selectedDate.month.toString().padLeft(2, '0')}-'
      '${_selectedDate.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF3D2C8D),
            onPrimary: Colors.white,
            onSurface: Color(0xFF1B1B2F),
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: const Color(0xFF1B1B2F),
        title: const Text(
          'Add Expense',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              _amountCard(),
              const SizedBox(height: 24),
              _sectionTitle('Category'),
              const SizedBox(height: 12),
              _categoryGrid(),
              if (_categoryError)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Text(
                    'Please select a category',
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 24),
              _sectionTitle('Date'),
              const SizedBox(height: 12),
              _dateField(),
              const SizedBox(height: 24),
              _sectionTitle('Note'),
              const SizedBox(height: 12),
              _noteField(),
              const SizedBox(height: 32),
              _saveButton(),
            ],
          ),
        ),
      ),
    );
  }

  /* ------------------------------ Widgets ------------------------------ */

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: Color(0xFF1B1B2F),
    ),
  );

  Widget _amountCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3D2C8D), Color(0xFF7F5AF0)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3D2C8D).withAlpha(90),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amount',
            style: TextStyle(color: Colors.white.withAlpha(190), fontSize: 13),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '₹',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  cursorColor: Colors.white,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(color: Colors.white.withAlpha(110)),
                    border: InputBorder.none,
                    errorStyle: const TextStyle(color: Color(0xFFFFCDD2)),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter an amount';
                    }
                    final amount = int.tryParse(value.trim());
                    if (amount == null || amount <= 0) {
                      return 'Amount must be greater than 0';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _categoryGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _categories.map((c) {
        final selected = _selectedCategory == c.name;
        return GestureDetector(
          onTap: () => setState(() {
            _selectedCategory = c.name;
            _categoryError = false;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? c.color : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: selected ? c.color : Colors.grey.shade300,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: c.color.withAlpha(90),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  c.icon,
                  size: 18,
                  color: selected ? Colors.white : c.color,
                ),
                const SizedBox(width: 6),
                Text(
                  c.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : const Color(0xFF1B1B2F),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _dateField() {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded, color: Color(0xFF3D2C8D)),
            const SizedBox(width: 12),
            Text(
              _displayDate,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B1B2F),
              ),
            ),
            const Spacer(),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _noteField() {
    return TextFormField(
      controller: _noteController,
      maxLines: 3,
      maxLength: 150,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: 'What was this purchase for?',
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF3D2C8D), width: 1.5),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please add a short note';
        }
        return null;
      },
    );
  }

  Widget _saveButton() {
    return SizedBox(
      height: 54,
      child: ChangeNotifierProvider(
        create: (context) => ExpenseViewModel(),
        child: Consumer<ExpenseViewModel>(
          builder: (context, viewmodel, _) {
            return ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  setState(() => _categoryError = _selectedCategory == null);

                  final formInputs = await viewmodel.addExpenseDetail(
                    int.parse(_amountController.text.trim()),
                    _selectedCategory!,
                    _noteController.text.trim(),
                    _apiDate,
                  );
                  if (!context.mounted) return;

                  if (formInputs) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DashboardPage()),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3D2C8D),
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Save Expense',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _Category {
  final String name;
  final IconData icon;
  final Color color;

  const _Category(this.name, this.icon, this.color);
}
