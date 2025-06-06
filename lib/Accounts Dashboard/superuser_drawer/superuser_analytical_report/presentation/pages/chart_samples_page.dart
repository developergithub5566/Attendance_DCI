import 'package:attendance_app/Accounts%20Dashboard/superuser_drawer/superuser_analytical_report/presentation/resources/app_resources.dart';
import 'package:attendance_app/Accounts%20Dashboard/superuser_drawer/superuser_analytical_report/presentation/samples/chart_samples.dart';
import 'package:attendance_app/Accounts%20Dashboard/superuser_drawer/superuser_analytical_report/presentation/widgets/chart_holder.dart';
import 'package:attendance_app/Accounts%20Dashboard/superuser_drawer/superuser_analytical_report/util/app_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ChartSamplesPage extends StatelessWidget {
  final ChartType chartType;

  final samples = ChartSamples.samples;

  ChartSamplesPage({
    super.key,
    required this.chartType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MasonryGridView.builder(
        itemCount: samples[chartType]!.length,
        key: ValueKey(chartType),
        padding: const EdgeInsets.only(
          left: AppDimens.chartSamplesSpace,
          right: AppDimens.chartSamplesSpace,
          top: AppDimens.chartSamplesSpace,
          bottom: AppDimens.chartSamplesSpace + 68,
        ),
        crossAxisSpacing: AppDimens.chartSamplesSpace,
        mainAxisSpacing: AppDimens.chartSamplesSpace,
        itemBuilder: (BuildContext context, int index) {
          return ChartHolder(chartSample: samples[chartType]![index]);
        },
        gridDelegate: const SliverSimpleGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 600,
        ),
      ),
    );
  }
}
