import 'package:flutter/material.dart';
import 'package:my_expense/core/constant/secure_store.dart';
import 'package:my_expense/page/auth/login/login.dart';
import 'package:my_expense/page/dashboard/dashboard_view_model.dart';
import 'package:my_expense/page/expense/detail_expense.dart';
import 'package:my_expense/page/expense/expense.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Replace with the logged-in user's name later
  static const String userName = 'Arun Kumar';

  @override
  void initState() {
    super.initState();
    // Fetch once, after the first frame (context is ready for Provider)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().fetchExpenseList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ProfileHeader(name: userName),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ExpenseCreditCard(
                userName: userName,
                balance: 24580.50,
                cardNumber: '4582  ••••  ••••  7391',
                expiry: '09/29',
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Recent Expenses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B1B2F),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              // Rebuilds automatically when the view model calls notifyListeners()
              child: Consumer<DashboardViewModel>(
                builder: (context, vm, _) {
                  if (vm.isLoading && vm.expenseDataList.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (vm.errorMessage != null && vm.expenseDataList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(vm.errorMessage!),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: vm.fetchExpenseList,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: vm.fetchExpenseList,
                    child: ExpenseList(
                      expenses: vm.expenseDataList,
                      onDelete: vm.removeExpense,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpensePage()),
          );

          // Expense added -> reload the list from the API
          if (result != null && context.mounted) {
            context.read<DashboardViewModel>().fetchExpenseList();
          }
        },
        backgroundColor: const Color(0xFF3D2C8D),
        foregroundColor: Colors.white,
        elevation: 6,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Expense',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/* ------------------------------ Profile header ------------------------------ */

class _ProfileHeader extends StatelessWidget {
  final String name;
  const _ProfileHeader({required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF7F5AF0), Color(0xFF2CB67D)],
              ),
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3D2C8D),
                ),
              ),
              // For a network image use:
              // backgroundImage: NetworkImage(url),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B1B2F),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              onPressed: () async {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false,
                );
                await TokenStorage.clearToken();
              },
              icon: const Icon(Icons.power_settings_new),
            ),
          ),
        ],
      ),
    );
  }
}

/* ------------------------------ Credit card UI ------------------------------ */

class ExpenseCreditCard extends StatelessWidget {
  final String userName;
  final double balance;
  final String cardNumber;
  final String expiry;

  const ExpenseCreditCard({
    super.key,
    required this.userName,
    required this.balance,
    required this.cardNumber,
    required this.expiry,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.62, // real credit card ratio
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3D2C8D), Color(0xFF7F5AF0), Color(0xFFB57BFF)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3D2C8D).withAlpha(100),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -50,
                right: -30,
                child: _circle(160, Colors.white.withAlpha(28)),
              ),
              Positioned(
                bottom: -70,
                left: -40,
                child: _circle(190, Colors.white.withAlpha(22)),
              ),
              Positioned(
                top: 40,
                right: 70,
                child: _circle(60, Colors.white.withAlpha(18)),
              ),

              // Card content
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'MY EXPENSE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Icon(
                          Icons.contactless_rounded,
                          color: Colors.white.withAlpha(220),
                          size: 28,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _chip(),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Total Balance',
                              style: TextStyle(
                                color: Colors.white.withAlpha(190),
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              '₹ ${balance.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      cardNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.w600,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('CARD HOLDER'),
                              Text(
                                userName.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('EXPIRES'),
                            Text(
                              expiry,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 18),
                        _brandLogo(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  Widget _label(String text) => Text(
    text,
    style: TextStyle(
      color: Colors.white.withAlpha(170),
      fontSize: 9,
      letterSpacing: 1.2,
    ),
  );

  // Gold EMV chip
  Widget _chip() {
    return Container(
      width: 42,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE082), Color(0xFFFFB300)],
        ),
      ),
      child: CustomPaint(painter: _ChipLinesPainter()),
    );
  }

  // Overlapping circles logo (Mastercard style)
  Widget _brandLogo() {
    return SizedBox(
      width: 44,
      height: 28,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: _circle(28, const Color(0xFFEB001B).withAlpha(230)),
          ),
          Positioned(
            right: 0,
            child: _circle(28, const Color(0xFFF79E1B).withAlpha(210)),
          ),
        ],
      ),
    );
  }
}

class _ChipLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.brown.withAlpha(110)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      p,
    );
    canvas.drawLine(
      Offset(size.width / 3, 0),
      Offset(size.width / 3, size.height),
      p,
    );
    canvas.drawLine(
      Offset(size.width * 2 / 3, 0),
      Offset(size.width * 2 / 3, size.height),
      p,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width / 3,
          size.height / 4,
          size.width / 3,
          size.height / 2,
        ),
        const Radius.circular(4),
      ),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
