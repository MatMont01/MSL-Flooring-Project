// lib/features/analytics/presentation/screens/analytics_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../presentation/screens/enhanced_analytics_screen.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔧 REDIRIGIR A LA NUEVA PANTALLA MEJORADA
    return const EnhancedAnalyticsScreen();
  }
}
