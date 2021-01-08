import 'dart:math';

import '../utils/number_util.dart';

import '../entity/k_line_entity.dart';

// ignore_for_file: non_constant_identifier_names,library_prefixes,unused_import,camel_case_types
class DataUtil {
  static calculate(List<KLineEntity> dataList,
      [List<int> maDayList = const [5, 10, 20], int n = 20, k = 2]) {
    calcMA(dataList, maDayList);
    calcBOLL(dataList, n, k);
    calcVolumeMA(dataList);
    calcKDJ(dataList);
    calcMACD(dataList);
    calcRSI(dataList);
    calcWR(dataList);
    calcSTOCH(dataList, 14);
    calcADX(dataList);
  }

  /* The DM1 (one period) is base on the largest part of
    * today's range that is outside of yesterdays range.
    * 
    * The following 7 cases explain how the +DM and -DM are
    * calculated on one period:
    *
    * Case 1:                       Case 2:
    *    C|                        A|
    *     |                         | C|
    *     | +DM1 = (C-A)           B|  | +DM1 = 0
    *     | -DM1 = 0                   | -DM1 = (B-D)
    * A|  |                           D| 
    *  | D|                    
    * B|
    *
    * Case 3:                       Case 4:
    *    C|                           C|
    *     |                        A|  |
    *     | +DM1 = (C-A)            |  | +DM1 = 0
    *     | -DM1 = 0               B|  | -DM1 = (B-D)
    * A|  |                            | 
    *  |  |                           D|
    * B|  |
    *    D|
    * 
    * Case 5:                      Case 6:
    * A|                           A| C|
    *  | C| +DM1 = 0                |  |  +DM1 = 0
    *  |  | -DM1 = 0                |  |  -DM1 = 0
    *  | D|                         |  |
    * B|                           B| D|
    *
    *
    * Case 7:
    * 
    *    C|
    * A|  |
    *  |  | +DM=0
    * B|  | -DM=0
    *    D|
    *
    * In case 3 and 4, the rule is that the smallest delta between
    * (C-A) and (B-D) determine which of +DM or -DM is zero.
    *
    * In case 7, (C-A) and (B-D) are equal, so both +DM and -DM are
    * zero.
    *
    * The rules remain the same when A=B and C=D (when the highs
    * equal the lows).
    *
    * When calculating the DM over a period > 1, the one-period DM
    * for the desired period are initialy sum. In other word, 
    * for a -DM14, sum the -DM1 for the first 14 days (that's 
    * 13 values because there is no DM for the first day!)
    * Subsequent DM are calculated using the Wilder's
    * smoothing approach:
    * 
    *                                    Previous -DM14
    *  Today's -DM14 = Previous -DM14 -  -------------- + Today's -DM1
    *                                         14
    *
    * (Same thing for +DM14)
    *
    * Calculation of a -DI14 is as follow:
    * 
    *               -DM14
    *     -DI14 =  --------
    *                TR14
    *
    * (Same thing for +DI14)
    *
    * Calculation of the TR14 is:
    *
    *                                   Previous TR14
    *    Today's TR14 = Previous TR14 - -------------- + Today's TR1
    *                                         14
    *
    *    The first TR14 is the summation of the first 14 TR1. See the
    *    TA_TRANGE function on how to calculate the true range.
    *
    * Calculation of the DX14 is:
    *    
    *    diffDI = ABS( (-DI14) - (+DI14) )
    *    sumDI  = (-DI14) + (+DI14)
    *
    *    DX14 = 100 * (diffDI / sumDI)
    *
    * Calculation of the first ADX:
    *
    *    ADX14 = SUM of the first 14 DX
    *
    * Calculation of subsequent ADX:
    *
    *            ((Previous ADX14)*(14-1))+ Today's DX
    *    ADX14 = -------------------------------------
    *                             14
    *
    * Reference:
    *    New Concepts In Technical Trading Systems, J. Welles Wilder Jr
    */

  /* Original implementation from Wilder's book was doing some integer
    * rounding in its calculations.
    *
    * This was understandable in the context that at the time the book
    * was written, most user were doing the calculation by hand.
    * 
    * For a computer, rounding is unnecessary (and even problematic when inputs
    * are close to 1).
    *
    * TA-Lib does not do the rounding. Still, if you want to reproduce Wilder's examples,
    * you can comment out the following #undef/#define and rebuild the library.
    */
  static calcADX(List<KLineEntity> dataList) {
    int len = dataList.length;
    // int len = 25;
    List<double> mdPlusDM = List<double>.filled(len, 0);
    List<double> mdMinusDM = List<double>.filled(len, 0);
    List<double> dTrueRange = List<double>.filled(len, 0);

    List<double> mdSPDM = List<double>.filled(len, 0);
    List<double> mdSMDM = List<double>.filled(len, 0);
    List<double> dSTrueRange = List<double>.filled(len, 0);

    List<double> mdSPDI = List<double>.filled(len, 0);
    List<double> mdSMDI = List<double>.filled(len, 0);
    List<double> mdSMDX = List<double>.filled(len, 0);
    List<double> mdADX = List<double>.filled(len, 0);

    int miPeriod = 14;
    if (dataList != null && dataList.isNotEmpty) {
      for (int i = 0; i < len; i++) {
        if (i < 1) {
          continue;
        }

        KLineEntity today = dataList[i];
        KLineEntity yesterday = dataList[i - 1];

        double dHighDiff = (today.high - yesterday.close).abs();
        double dLowDiff = (today.low - yesterday.close).abs();
        double dOut = (today.high - today.low);
        dTrueRange[i] = max(dOut, max(dHighDiff, dLowDiff));

        // If (Today's high - Yesterday's High) > (Yesterday's Low - Today's Low), then
        // +DM = (Today's high - Yesterday's High)
        mdPlusDM[i] =
            ((today.high - yesterday.high) > (yesterday.low - today.low) &&
                    (today.high - yesterday.high) > 0)
                ? (today.high - yesterday.high)
                : 0;
        mdMinusDM[i] =
            ((yesterday.low - today.low) > (today.high - yesterday.high) &&
                    (yesterday.low - today.low) > 0)
                ? (yesterday.low - today.low)
                : 0;

        //Smoothed values
        if (i > 13) {
          mdSPDM[i] = mdSPDM[i - 1] - (mdSPDM[i - 1] / 14.0) + mdPlusDM[i];
          mdSMDM[i] = mdSMDM[i - 1] - (mdSMDM[i - 1] / 14.0) + mdMinusDM[i];
          dSTrueRange[i] =
              dSTrueRange[i - 1] - (dSTrueRange[i - 1] / 14.0) + dTrueRange[i];

          mdSPDI[i] = 100 * mdSPDM[i] / dSTrueRange[i];
          mdSMDI[i] = 100 * mdSMDM[i] / dSTrueRange[i];
          mdSMDX[i] = 100 *
              (mdSPDI[i] - mdSMDI[i]).abs() /
              (mdSPDI[i] + mdSMDI[i]).abs();
        } else if (i == 13) {
          double dPlusDMSuma = 0.0;
          double dMinusDMSuma = 0.0;
          double dSTRSuma = 0.0;
          while (miPeriod-- > 0) {
            dPlusDMSuma += mdPlusDM[i - miPeriod];
            dMinusDMSuma += mdMinusDM[i - miPeriod];
            dSTRSuma += dTrueRange[i - miPeriod];
          }
          mdSPDM[i] = dPlusDMSuma;
          mdSMDM[i] = dMinusDMSuma;
          dSTrueRange[i] = dSTRSuma;

          mdSPDI[i] = 100 * mdSPDM[i] / dSTrueRange[i];
          mdSMDI[i] = 100 * mdSMDM[i] / dSTrueRange[i];
          mdSMDX[i] = 100 *
              (mdSPDI[i] - mdSMDI[i]).abs() /
              (mdSPDI[i] + mdSMDI[i]).abs();
        }

        if (i == 26) {
          double dSTRSuma = 0.0;
          while (miPeriod-- > 0) {
            dSTRSuma += mdSMDX[i - miPeriod];
          }
          mdADX[i] = dSTRSuma / 14.0;
        } else if (i > 26) {
          mdADX[i] = (mdADX[i - 1] * 13 + mdSMDX[i]) / 14.0;
        }

        //Update +DI -DI ADX (14, 14) for drawing
        today.minusDi = mdSMDI[i];
        today.plusDi = mdSPDI[i];
        today.adx = mdADX[i];
      }
    }
  }

  static calcSTOCH(List<KLineEntity> dataList, int nDay) {
    List<double> klow = List<double>.filled(nDay, 0);
    List<double> kh = List<double>.filled(nDay, 0);
    List<double> auxk = [];

    dataList = dataList.reversed.toList();
    if (dataList != null && dataList.isNotEmpty) {
      for (int i = 0; i < dataList.length; i++) {
        final closePrice = dataList[i].close;
        for (int j = 0; j < nDay; j++) {
          if (i + j < dataList.length) {
            klow[j] = dataList[i + j].low;
            kh[j] = dataList[i + j].high;
          } else {
            klow[j] = 0.00000001;
            kh[j] = 0.00000001;
          }
        }

        double numerator = (closePrice - klow.reduce(min));
        double denomina = (kh.reduce((max)) - klow.reduce(min));
        auxk.add((numerator / ((denomina == 0) ? 0.000001 : denomina)) * 100);
      }

      for (var i = 0; i < auxk.length; i++) {
        if (i < auxk.length - 3)
          dataList[i].slowK = (auxk[i] + auxk[i + 1] + auxk[i + 2]) / 3.0;
        else
          dataList[i].slowK = 0.0001;
      }

      for (var i = 0; i < auxk.length; i++) {
        if (i < auxk.length - 3)
          dataList[i].slowD = (dataList[i].slowK +
                  dataList[i + 1].slowK +
                  dataList[i + 2].slowK) /
              3.0;
        else
          dataList[i].slowD = 0.00001;
      }
    }
  }

  static calcMA(List<KLineEntity> dataList, List<int> maDayList) {
    List<double> ma = List<double>.filled(maDayList.length, 0);

    if (dataList != null && dataList.isNotEmpty) {
      for (int i = 0; i < dataList.length; i++) {
        KLineEntity entity = dataList[i];
        final closePrice = entity.close;
        entity.maValueList = List<double>(maDayList.length);

        for (int j = 0; j < maDayList.length; j++) {
          ma[j] += closePrice;
          if (i == maDayList[j] - 1) {
            entity.maValueList[j] = ma[j] / maDayList[j];
          } else if (i >= maDayList[j]) {
            ma[j] -= dataList[i - maDayList[j]].close;
            entity.maValueList[j] = ma[j] / maDayList[j];
          } else {
            entity.maValueList[j] = 0;
          }
        }
      }
    }
  }

  static void calcBOLL(List<KLineEntity> dataList, int n, int k) {
    _calcBOLLMA(n, dataList);
    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      if (i >= n) {
        double md = 0;
        for (int j = i - n + 1; j <= i; j++) {
          double c = dataList[j].close;
          double m = entity.BOLLMA;
          double value = c - m;
          md += value * value;
        }
        md = md / (n - 1);
        md = sqrt(md);
        entity.mb = entity.BOLLMA;
        entity.up = entity.mb + k * md;
        entity.dn = entity.mb - k * md;
      }
    }
  }

  static void _calcBOLLMA(int day, List<KLineEntity> dataList) {
    double ma = 0;
    for (int i = 0; dataList != null && i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      ma += entity.close;
      if (i == day - 1) {
        entity.BOLLMA = ma / day;
      } else if (i >= day) {
        ma -= dataList[i - day].close;
        entity.BOLLMA = ma / day;
      } else {
        entity.BOLLMA = null;
      }
    }
  }

  static void calcMACD(List<KLineEntity> dataList) {
    double ema12 = 0;
    double ema26 = 0;
    double dif = 0;
    double dea = 0;
    double macd = 0;

    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      final closePrice = entity.close;
      if (i == 0) {
        ema12 = closePrice;
        ema26 = closePrice;
      } else {
        // EMA（12） = 前一日EMA（12） X 11/13 + 今日收盘价 X 2/13
        ema12 = ema12 * 11 / 13 + closePrice * 2 / 13;
        // EMA（26） = 前一日EMA（26） X 25/27 + 今日收盘价 X 2/27
        ema26 = ema26 * 25 / 27 + closePrice * 2 / 27;
      }
      // DIF = EMA（12） - EMA（26） 。
      // 今日DEA = （前一日DEA X 8/10 + 今日DIF X 2/10）
      // 用（DIF-DEA）*2即为MACD柱状图。
      dif = ema12 - ema26;
      dea = dea * 8 / 10 + dif * 2 / 10;
      macd = (dif - dea) * 2;
      entity.dif = dif;
      entity.dea = dea;
      entity.macd = macd;
    }
  }

  static void calcVolumeMA(List<KLineEntity> dataList) {
    double volumeMa5 = 0;
    double volumeMa10 = 0;

    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entry = dataList[i];

      volumeMa5 += entry.vol;
      volumeMa10 += entry.vol;

      if (i == 4) {
        entry.MA5Volume = (volumeMa5 / 5);
      } else if (i > 4) {
        volumeMa5 -= dataList[i - 5].vol;
        entry.MA5Volume = volumeMa5 / 5;
      } else {
        entry.MA5Volume = 0;
      }

      if (i == 9) {
        entry.MA10Volume = volumeMa10 / 10;
      } else if (i > 9) {
        volumeMa10 -= dataList[i - 10].vol;
        entry.MA10Volume = volumeMa10 / 10;
      } else {
        entry.MA10Volume = 0;
      }
    }
  }

  static void calcRSI(List<KLineEntity> dataList) {
    double rsi;
    double rsiABSEma = 0;
    double rsiMaxEma = 0;
    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      final double closePrice = entity.close;
      if (i == 0) {
        rsi = 0;
        rsiABSEma = 0;
        rsiMaxEma = 0;
      } else {
        double Rmax = max(0, closePrice - dataList[i - 1].close);
        double RAbs = (closePrice - dataList[i - 1].close).abs();

        rsiMaxEma = (Rmax + (14 - 1) * rsiMaxEma) / 14;
        rsiABSEma = (RAbs + (14 - 1) * rsiABSEma) / 14;
        rsi = (rsiMaxEma / rsiABSEma) * 100;
      }
      if (i < 13) rsi = null;
      if (rsi != null && rsi.isNaN) rsi = null;
      entity.rsi = rsi;
    }
  }

  // static void calcADX(List<KLineEntity> dataList, List<double> adx,
  //     List<double> minusDI, List<double> plusDI) {
  //   for (var i = 0; i < dataList.length; i++) {
  //     dataList[i].adx = adx[i];
  //     dataList[i].minusDi = minusDI[i];
  //     dataList[i].plusDi = plusDI[i];
  //   }
  // }

  // static void calcSTOCH(
  //     List<KLineEntity> dataList, List<double> slowD, List<double> slowK) {
  //   for (var i = 0; i < dataList.length; i++) {
  //     dataList[i].slowD = slowD[i];
  //     dataList[i].slowK = slowK[i];
  //   }
  // }

  static void calcKDJ(List<KLineEntity> dataList) {
    double k = 0;
    double d = 0;
    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      final double closePrice = entity.close;
      int startIndex = i - 13;
      if (startIndex < 0) {
        startIndex = 0;
      }
      double max14 = double.minPositive;
      double min14 = double.maxFinite;
      for (int index = startIndex; index <= i; index++) {
        max14 = max(max14, dataList[index].high);
        min14 = min(min14, dataList[index].low);
      }
      double rsv = 100 * (closePrice - min14) / (max14 - min14);
      if (rsv.isNaN) {
        rsv = 0;
      }
      if (i == 0) {
        k = 50;
        d = 50;
      } else {
        k = (rsv + 2 * k) / 3;
        d = (k + 2 * d) / 3;
      }
      if (i < 13) {
        entity.k = null;
        entity.d = null;
        entity.j = null;
      } else if (i == 13 || i == 14) {
        entity.k = k;
        entity.d = null;
        entity.j = null;
      } else {
        entity.k = k;
        entity.d = d;
        entity.j = 3 * k - 2 * d;
      }
    }
  }

  static void calcWR(List<KLineEntity> dataList) {
    double r;
    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      int startIndex = i - 14;
      if (startIndex < 0) {
        startIndex = 0;
      }
      double max14 = double.minPositive;
      double min14 = double.maxFinite;
      for (int index = startIndex; index <= i; index++) {
        max14 = max(max14, dataList[index].high);
        min14 = min(min14, dataList[index].low);
      }
      if (i < 13) {
        entity.r = -10;
      } else {
        r = -100 * (max14 - dataList[i].close) / (max14 - min14);
        if (r.isNaN) {
          entity.r = null;
        } else {
          entity.r = r;
        }
      }
    }
  }
}
