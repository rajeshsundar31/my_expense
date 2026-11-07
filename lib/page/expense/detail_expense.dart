import 'package:flutter/material.dart';

/* ============================== Model & styles ============================== */

class Expense {
  final int id;
  final int amount;
  final String category;
  final String note;
  final DateTime date;

  const Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
  });

  // Adjust keys to match your backend response
  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'] ?? 0,
    amount: json['amount'] ?? 0,
    category: json['category'] ?? 'Other',
    note: json['note'] ?? '',
    date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
  );
}

class CategoryStyle {
  final IconData icon;
  final Color color;
  const CategoryStyle(this.icon, this.color);

  static const Map<String, CategoryStyle> _styles = {
    'Groceries': CategoryStyle(
      Icons.shopping_basket_rounded,
      Color(0xFF26A69A),
    ),
    'Food': CategoryStyle(Icons.restaurant_rounded, Color(0xFF7E57C2)),
    'Travel': CategoryStyle(Icons.local_taxi_rounded, Color(0xFF66BB6A)),
    'Fuel': CategoryStyle(Icons.local_gas_station_rounded, Color(0xFFFFA726)),
    'Bills': CategoryStyle(Icons.bolt_rounded, Color(0xFF42A5F5)),
    'Shopping': CategoryStyle(Icons.shopping_bag_rounded, Color(0xFFEC407A)),
    'Movies': CategoryStyle(Icons.movie_filter_rounded, Color(0xFFEF5350)),
    'Health': CategoryStyle(Icons.favorite_rounded, Color(0xFFFF7043)),
    'Other': CategoryStyle(Icons.category_rounded, Color(0xFF78909C)),
  };

  static CategoryStyle of(String category) =>
      _styles[category] ?? _styles['Other']!;
}

const _months = [
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
const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')} ${_months[d.month - 1]} ${d.year}';

String formatFullDate(DateTime d) =>
    '${_weekdays[d.weekday - 1]}, ${formatDate(d)}';

String dayLabel(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(d.year, d.month, d.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return formatDate(d);
}

/* ================================ Expense list ================================ */

class _DayHeader {
  final DateTime date;
  final int total;
  _DayHeader(this.date, this.total);
}

class ExpenseList extends StatelessWidget {
  final List<Expense> expenses;

  /// Called when the user deletes an expense from the detail page.
  final void Function(Expense expense)? onDelete;

  /// Called when the user taps Edit on the detail page.
  final void Function(Expense expense)? onEdit;

  const ExpenseList({
    super.key,
    required this.expenses,
    this.onDelete,
    this.onEdit,
  });

  /// Groups expenses by day (newest first) into a flat list of headers + items.
  List<Object> _buildItems() {
    final sorted = [...expenses]..sort((a, b) => b.date.compareTo(a.date));
    final Map<DateTime, List<Expense>> grouped = {};

    for (final e in sorted) {
      final key = DateTime(e.date.year, e.date.month, e.date.day);
      grouped.putIfAbsent(key, () => []).add(e);
    }

    final items = <Object>[];
    for (final entry in grouped.entries) {
      final total = entry.value.fold<int>(0, (sum, e) => sum + e.amount);
      items.add(_DayHeader(entry.key, total));
      items.addAll(entry.value);
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const _EmptyState();
    }

    final items = _buildItems();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        if (item is _DayHeader) {
          return _DayHeaderTile(header: item);
        }

        final expense = item as Expense;
        return _AnimatedIn(
          index: index,
          child: _ExpenseTile(
            expense: expense,
            onTap: () async {
              final result = await Navigator.push<String>(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 400),
                  pageBuilder: (_, __, ___) =>
                      ExpenseDetailPage(expense: expense),
                  transitionsBuilder: (_, animation, __, child) =>
                      FadeTransition(opacity: animation, child: child),
                ),
              );

              if (result == 'delete') onDelete?.call(expense);
              if (result == 'edit') onEdit?.call(expense);
            },
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'No expenses yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap "Add Expense" to get started',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

/// Fade + slide-up entrance, slightly staggered by index.
class _AnimatedIn extends StatelessWidget {
  final int index;
  final Widget child;
  const _AnimatedIn({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    final ms = 350 + (index.clamp(0, 8) * 60);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: ms),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

class _DayHeaderTile extends StatelessWidget {
  final _DayHeader header;
  const _DayHeaderTile({required this.header});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF7F5AF0),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            dayLabel(header.date),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Container(height: 1, color: Colors.grey.shade300)),
          const SizedBox(width: 10),
          Text(
            '₹${header.total}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;

  const _ExpenseTile({required this.expense, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final style = CategoryStyle.of(expense.category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: style.color.withAlpha(30),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    // Colored accent stripe
                    Container(width: 6, color: style.color),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Hero(
                              tag: 'expense-icon-${expense.id}',
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      style.color,
                                      style.color.withAlpha(170),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(style.icon, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    expense.category,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1B1B2F),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    expense.note,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: style.color.withAlpha(30),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '- ₹${expense.amount}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: style.color,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 18,
                                  color: Colors.grey.shade400,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ============================== Expense detail ============================== */

class ExpenseDetailPage extends StatelessWidget {
  final Expense expense;
  const ExpenseDetailPage({super.key, required this.expense});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete expense?'),
        content: Text(
          '₹${expense.amount} spent on ${expense.category} will be removed permanently.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.pop(context, 'delete');
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = CategoryStyle.of(expense.category);

    return Scaffold(
      backgroundColor: style.color,
      body: Column(
        children: [
          // ---------- Colored header ----------
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  style.color,
                  Color.lerp(style.color, Colors.black, 0.25)!,
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 20, 36),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Hero(
                      tag: 'expense-icon-${expense.id}',
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(45),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: Colors.white.withAlpha(90),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(style.icon, color: Colors.white, size: 40),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      expense.category,
                      style: TextStyle(
                        color: Colors.white.withAlpha(220),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₹${expense.amount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ---------- White detail sheet ----------
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF4F5FB),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Expense Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B1B2F),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.payments_rounded,
                            color: style.color,
                            label: 'Amount',
                            value: '₹${expense.amount}',
                          ),
                          _divider(),
                          _DetailRow(
                            icon: style.icon,
                            color: style.color,
                            label: 'Category',
                            value: expense.category,
                          ),
                          _divider(),
                          _DetailRow(
                            icon: Icons.calendar_month_rounded,
                            color: style.color,
                            label: 'Date',
                            value: formatFullDate(expense.date),
                          ),
                          _divider(),
                          _DetailRow(
                            icon: Icons.notes_rounded,
                            color: style.color,
                            label: 'Note',
                            value: expense.note.isEmpty ? '-' : expense.note,
                          ),
                          _divider(),
                          _DetailRow(
                            icon: Icons.tag_rounded,
                            color: style.color,
                            label: 'Expense ID',
                            value: '#${expense.id}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pop(context, 'edit'),
                            icon: const Icon(Icons.edit_rounded),
                            label: const Text('Edit'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: style.color,
                              side: BorderSide(color: style.color),
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _confirmDelete(context),
                            icon: const Icon(Icons.delete_rounded),
                            label: const Text('Delete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE53935),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey.shade200);
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B1B2F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
