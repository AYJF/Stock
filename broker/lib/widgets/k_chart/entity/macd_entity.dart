import 'package:broker/widgets/k_chart/entity/adx_entity.dart';
import 'package:broker/widgets/k_chart/entity/stoch_entity.dart';

import 'kdj_entity.dart';
import 'rsi_entity.dart';
import 'rw_entity.dart';

mixin MACDEntity on KDJEntity, RSIEntity, WREntity, ADXEntity, STOCHEntity {
  double dea;
  double dif;
  double macd;
}
