// lib/features/analytics/presentation/screens/enhanced_analytics_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/enhanced_analytics_provider.dart';
import '../widgets/kpi_card.dart';
import '../widgets/chart_card.dart';
import '../widgets/progress_chart.dart';
import '../widgets/financial_summary_card.dart';

class EnhancedAnalyticsScreen extends ConsumerStatefulWidget {
  const EnhancedAnalyticsScreen({super.key});

  @override
  ConsumerState<EnhancedAnalyticsScreen> createState() =>
      _EnhancedAnalyticsScreenState();
}

class _EnhancedAnalyticsScreenState
    extends ConsumerState<EnhancedAnalyticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // 🎭 Animaciones minimalistas
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutQuart),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Cargar datos al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(enhancedAnalyticsProvider.notifier).fetchAllAnalytics();
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analyticsState = ref.watch(enhancedAnalyticsProvider);

    return Theme(
      data: _buildMinimalDarkTheme(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F14), // 🌙 Fondo minimalista
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [_buildMinimalSliverAppBar(innerBoxIsScrolled)];
          },
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDashboardTab(analyticsState),
                  _buildProjectsTab(analyticsState),
                  _buildFinancesTab(analyticsState),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🌙 Tema minimalista oscuro
  ThemeData _buildMinimalDarkTheme() {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF0F0F14),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1A1F).withOpacity(0.9),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color(0xFF2A2A2F).withOpacity(0.6),
            width: 1,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  // 🎯 SliverAppBar minimalista
  Widget _buildMinimalSliverAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 140.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1A1F).withOpacity(0.95),
              const Color(0xFF2A2A2F).withOpacity(0.90),
              const Color(0xFF1F1F24).withOpacity(0.95),
            ],
          ),
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFF2A2A2F).withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: FlexibleSpaceBar(
          title: const Text(
            'Analytics',
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 24,
              color: Color(0xFFE5E5E7),
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: true,
        ),
      ),
      actions: [
        _buildMinimalIconButton(Icons.refresh_outlined, () {
          ref.read(enhancedAnalyticsProvider.notifier).refreshAnalytics();
          _fadeController.reset();
          _fadeController.forward();
        }),
        _buildMinimalIconButton(
          Icons.share_outlined,
          () => _showExportOptions(context),
        ),
        const SizedBox(width: 8),
      ],
      bottom: _buildMinimalTabBar(),
    );
  }

  // 🔘 Botones minimalistas
  Widget _buildMinimalIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF2A2A2F).withOpacity(0.6),
        border: Border.all(
          color: const Color(0xFF3A3A3F).withOpacity(0.4),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFFE5E5E7), size: 20),
        onPressed: onPressed,
        splashRadius: 20,
      ),
    );
  }

  // 📑 TabBar minimalista
  PreferredSize _buildMinimalTabBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 8, 24, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF1A1A1F).withOpacity(0.8),
          border: Border.all(
            color: const Color(0xFF2A2A2F).withOpacity(0.5),
            width: 1,
          ),
        ),
        child: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFE5E5E7),
          unselectedLabelColor: const Color(0xFF8E8E93),
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xFF2A2A2F).withOpacity(0.8),
          ),
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Projects'),
            Tab(text: 'Finance'),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab(EnhancedAnalyticsState state) {
    return switch (state) {
      EnhancedAnalyticsLoading() => _buildMinimalLoader(),
      EnhancedAnalyticsSuccess(
        kpis: final kpis,
        projectStatus: final projectStatus,
        progressOverTime: final progressOverTime,
      ) =>
        RefreshIndicator(
          color: const Color(0xFF8E8E93),
          backgroundColor: const Color(0xFF1A1A1F),
          onRefresh: () async {
            ref.read(enhancedAnalyticsProvider.notifier).refreshAnalytics();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMinimalSectionTitle('Key Metrics'),
                const SizedBox(height: 20),
                _buildAnimatedKpiGrid(kpis),
                const SizedBox(height: 40),
                _buildMinimalSectionTitle('Project Status'),
                const SizedBox(height: 20),
                _buildMinimalCard(
                  child: SizedBox(
                    height: 280,
                    child: ChartCard(
                      title: 'Distribution by Status',
                      data: projectStatus,
                      chartType: ChartType.pie,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                _buildMinimalSectionTitle('Progress Over Time'),
                const SizedBox(height: 20),
                _buildMinimalCard(
                  child: SizedBox(
                    height: 260,
                    child: ProgressChart(data: progressOverTime),
                  ),
                ),
              ],
            ),
          ),
        ),
      EnhancedAnalyticsFailure(message: final message) =>
        _buildMinimalErrorState(message),
      _ => const SizedBox(),
    };
  }

  Widget _buildProjectsTab(EnhancedAnalyticsState state) {
    return switch (state) {
      EnhancedAnalyticsLoading() => _buildMinimalLoader(),
      EnhancedAnalyticsSuccess(
        budgetAnalysis: final budgetAnalysis,
        workerProductivity: final workerProductivity,
        materialUsage: final materialUsage,
      ) =>
        RefreshIndicator(
          color: const Color(0xFF8E8E93),
          backgroundColor: const Color(0xFF1A1A1F),
          onRefresh: () async {
            ref.read(enhancedAnalyticsProvider.notifier).refreshAnalytics();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMinimalSectionTitle('Budget Distribution'),
                const SizedBox(height: 20),
                _buildMinimalCard(
                  child: SizedBox(
                    height: 300,
                    child: ChartCard(
                      title: 'Budget by Category',
                      data: budgetAnalysis,
                      chartType: ChartType.donut,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                _buildMinimalSectionTitle('Worker Productivity'),
                const SizedBox(height: 20),
                _buildMinimalCard(
                  child: SizedBox(
                    height: 320,
                    child: ChartCard(
                      title: 'Individual Performance',
                      data: workerProductivity,
                      chartType: ChartType.bar,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                _buildMinimalSectionTitle('Material Usage'),
                const SizedBox(height: 20),
                _buildMinimalCard(
                  child: SizedBox(
                    height: 300,
                    child: ChartCard(
                      title: 'Most Used Materials',
                      data: materialUsage,
                      chartType: ChartType.pie,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      EnhancedAnalyticsFailure(message: final message) =>
        _buildMinimalErrorState(message),
      _ => const SizedBox(),
    };
  }

  Widget _buildFinancesTab(EnhancedAnalyticsState state) {
    return switch (state) {
      EnhancedAnalyticsLoading() => _buildMinimalLoader(),
      EnhancedAnalyticsSuccess(
        financialSummary: final financialSummary,
        budgetAnalysis: final budgetAnalysis,
      ) =>
        RefreshIndicator(
          color: const Color(0xFF8E8E93),
          backgroundColor: const Color(0xFF1A1A1F),
          onRefresh: () async {
            ref.read(enhancedAnalyticsProvider.notifier).refreshAnalytics();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMinimalSectionTitle('Financial Summary'),
                const SizedBox(height: 20),
                _buildMinimalCard(
                  child: FinancialSummaryCard(data: financialSummary),
                ),
                const SizedBox(height: 40),
                _buildMinimalSectionTitle('Expense Breakdown'),
                const SizedBox(height: 20),
                _buildMinimalCard(
                  child: SizedBox(
                    height: 300,
                    child: ChartCard(
                      title: 'Expenses by Category',
                      data: budgetAnalysis,
                      chartType: ChartType.donut,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                _buildMinimalSectionTitle('Financial Metrics'),
                const SizedBox(height: 20),
                _buildMinimalFinancialMetrics(financialSummary),
              ],
            ),
          ),
        ),
      EnhancedAnalyticsFailure(message: final message) =>
        _buildMinimalErrorState(message),
      _ => const SizedBox(),
    };
  }

  // 🏷️ Título de sección minimalista
  Widget _buildMinimalSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: Color(0xFFE5E5E7),
        letterSpacing: 0.3,
      ),
    );
  }

  // 📱 Card minimalista
  Widget _buildMinimalCard({required Widget child}) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF1A1A1F).withOpacity(0.9),
                border: Border.all(
                  color: const Color(0xFF2A2A2F).withOpacity(0.6),
                  width: 1,
                ),
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }

  // 📊 Grid de KPIs animado
  Widget _buildAnimatedKpiGrid(List<dynamic> kpis) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        final childAspectRatio = constraints.maxWidth > 600 ? 1.4 : 1.35;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: kpis.length,
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                final delay = index * 0.1;
                final animValue = Curves.easeOutQuart.transform(
                  ((_fadeAnimation.value - delay).clamp(0.0, 1.0)),
                );

                return Transform.translate(
                  offset: Offset(0, 30 * (1 - animValue)),
                  child: Opacity(
                    opacity: animValue,
                    child: KpiCard(kpi: kpis[index]),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ⏳ Loader minimalista
  Widget _buildMinimalLoader() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8E8E93)),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Loading analytics...',
            style: TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ❌ Error state minimalista
  Widget _buildMinimalErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1A1A1F),
              border: Border.all(
                color: const Color(0xFF8E8E93).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 40,
              color: Color(0xFF8E8E93),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Color(0xFFE5E5E7),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 14),
            ),
          ),
          const SizedBox(height: 32),
          _buildMinimalButton('Try Again', () {
            ref.read(enhancedAnalyticsProvider.notifier).refreshAnalytics();
          }),
        ],
      ),
    );
  }

  // 💰 Métricas financieras minimalistas
  Widget _buildMinimalFinancialMetrics(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1A1A1F).withOpacity(0.9),
        border: Border.all(
          color: const Color(0xFF2A2A2F).withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildMinimalMetricRow(
            'Profit Margin',
            '${data['profitMargin']?.toStringAsFixed(1) ?? '0'}%',
            Icons.trending_up_outlined,
            const Color(0xFF32D74B),
          ),
          _buildMinimalDivider(),
          _buildMinimalMetricRow(
            'Monthly Growth',
            '+${data['monthlyGrowth']?.toStringAsFixed(1) ?? '0'}%',
            Icons.calendar_month_outlined,
            const Color(0xFF007AFF),
          ),
          _buildMinimalDivider(),
          _buildMinimalMetricRow(
            'Annual Growth',
            '+${data['yearlyGrowth']?.toStringAsFixed(1) ?? '0'}%',
            Icons.calendar_today_outlined,
            const Color(0xFFAF52DE),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalMetricRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: color.withOpacity(0.1),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0xFFE5E5E7),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: const Color(0xFF2A2A2F).withOpacity(0.5),
    );
  }

  // 🔘 Botón minimalista
  Widget _buildMinimalButton(String text, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF2A2A2F),
        border: Border.all(
          color: const Color(0xFF3A3A3F).withOpacity(0.6),
          width: 1,
        ),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFFE5E5E7),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          color: const Color(0xFF1A1A1F),
          border: Border.all(
            color: const Color(0xFF2A2A2F).withOpacity(0.6),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: const Color(0xFF3A3A3F),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Export Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFFE5E5E7),
              ),
            ),
            const SizedBox(height: 24),
            _buildExportOption(
              Icons.picture_as_pdf_outlined,
              'Export as PDF',
              () {
                Navigator.pop(context);
                _showSnackBar('Exporting to PDF...');
              },
            ),
            _buildExportOption(
              Icons.table_chart_outlined,
              'Export as Excel',
              () {
                Navigator.pop(context);
                _showSnackBar('Exporting to Excel...');
              },
            ),
            _buildExportOption(Icons.share_outlined, 'Share Summary', () {
              Navigator.pop(context);
              _showSnackBar('Sharing summary...');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF2A2A2F).withOpacity(0.6),
        border: Border.all(
          color: const Color(0xFF3A3A3F).withOpacity(0.4),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF8E8E93), size: 22),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFFE5E5E7),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2A2A2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
