import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductionActivity {
  const ProductionActivity({this.printed = 0, this.lastJob, this.lastStatus});
  final int printed;
  final DateTime? lastJob;
  final String? lastStatus;
}

class ProductionActivityController extends Notifier<ProductionActivity> {
  @override
  ProductionActivity build() => const ProductionActivity();

  void recordPrint(int copies) => state = ProductionActivity(
    printed: state.printed + copies,
    lastJob: DateTime.now(),
    lastStatus: 'Printed successfully',
  );
}

final productionActivityProvider =
    NotifierProvider<ProductionActivityController, ProductionActivity>(
      ProductionActivityController.new,
    );
