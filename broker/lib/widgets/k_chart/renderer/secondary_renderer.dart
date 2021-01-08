import 'dart:ui';

import 'package:flutter/material.dart';
import '../entity/macd_entity.dart';
import '../k_chart_widget.dart' show SecondaryState;

import 'base_chart_renderer.dart';

class SecondaryRenderer extends BaseChartRenderer<MACDEntity> {
  double mMACDWidth = ChartStyle.macdWidth;
  SecondaryState state;

  SecondaryRenderer(Rect mainRect, double maxValue, double minValue,
      double topPadding, this.state, int fixedLength)
      : super(
            chartRect: mainRect,
            maxValue: maxValue,
            minValue: minValue,
            topPadding: topPadding,
            fixedLength: fixedLength);

  @override
  void drawChart(MACDEntity lastPoint, MACDEntity curPoint, double lastX,
      double curX, Size size, Canvas canvas) {
    switch (state) {
      case SecondaryState.MACD:
        drawMACD(curPoint, canvas, curX, lastPoint, lastX);
        break;
      case SecondaryState.KDJ:
        drawLine(
            lastPoint.k, curPoint.k, canvas, lastX, curX, ChartColors.kColor);
        drawLine(
            lastPoint.d, curPoint.d, canvas, lastX, curX, ChartColors.dColor);
        drawLine(
            lastPoint.j, curPoint.j, canvas, lastX, curX, ChartColors.jColor);
        break;
      case SecondaryState.RSI: //RSI
        drawLine(lastPoint.rsi, curPoint.rsi, canvas, lastX, curX,
            ChartColors.rsiColor);
        drawLine(20, 20, canvas, lastX, curX, Colors.white);
        drawLine(70, 70, canvas, lastX, curX, Colors.red);
        break;
      case SecondaryState.ADX: //ADX
        drawLine(lastPoint.adx, curPoint.adx, canvas, lastX, curX,
            ChartColors.adxColor);
        drawLine(lastPoint.minusDi, curPoint.minusDi, canvas, lastX, curX,
            Colors.red);
        drawLine(lastPoint.plusDi, curPoint.plusDi, canvas, lastX, curX,
            Colors.green);

        drawLine(20, 20, canvas, lastX, curX, Colors.blue);
        break;
      case SecondaryState.STOCH:
        drawLine(lastPoint.slowK, curPoint.slowK, canvas, lastX, curX,
            ChartColors.dnColor);
        drawLine(
            lastPoint.slowD, curPoint.slowD, canvas, lastX, curX, Colors.blue);

        drawLine(20, 20, canvas, lastX, curX, Colors.pink);
        drawLine(70, 70, canvas, lastX, curX, Colors.pink);

        break;
      case SecondaryState.WR:
        drawLine(
            lastPoint.r, curPoint.r, canvas, lastX, curX, ChartColors.rsiColor);
        break;
      default:
        break;
    }
  }

  void drawMACD(MACDEntity curPoint, Canvas canvas, double curX,
      MACDEntity lastPoint, double lastX) {
    double macdY = getY(curPoint.macd);
    double r = mMACDWidth / 2;
    double zeroy = getY(0);
    if (curPoint.macd > 0) {
      canvas.drawRect(Rect.fromLTRB(curX - r, macdY, curX + r, zeroy),
          chartPaint..color = ChartColors.upColor);
    } else {
      canvas.drawRect(Rect.fromLTRB(curX - r, zeroy, curX + r, macdY),
          chartPaint..color = ChartColors.dnColor);
    }
    if (lastPoint.dif != 0) {
      drawLine(lastPoint.dif, curPoint.dif, canvas, lastX, curX,
          ChartColors.difColor);
    }
    if (lastPoint.dea != 0) {
      drawLine(lastPoint.dea, curPoint.dea, canvas, lastX, curX,
          ChartColors.deaColor);
    }
  }

  @override
  void drawText(Canvas canvas, MACDEntity data, double x) {
    List<TextSpan> children;
    switch (state) {
      case SecondaryState.MACD:
        children = [
          TextSpan(
              text: "MACD(12,26,9)    ",
              style: getTextStyle(ChartColors.defaultTextColor)),
          if (data.macd != 0)
            TextSpan(
                text: "MACD:${format(data.macd)}    ",
                style: getTextStyle(ChartColors.macdColor)),
          if (data.dif != 0)
            TextSpan(
                text: "DIF:${format(data.dif)}    ",
                style: getTextStyle(ChartColors.difColor)),
          if (data.dea != 0)
            TextSpan(
                text: "DEA:${format(data.dea)}    ",
                style: getTextStyle(ChartColors.deaColor)),
        ];
        break;
      case SecondaryState.KDJ:
        children = [
          TextSpan(
              text: "KDJ(14,1,3)    ",
              style: getTextStyle(ChartColors.defaultTextColor)),
          if (data.macd != 0)
            TextSpan(
                text: "K:${format(data.k)}    ",
                style: getTextStyle(ChartColors.kColor)),
          if (data.dif != 0)
            TextSpan(
                text: "D:${format(data.d)}    ",
                style: getTextStyle(ChartColors.dColor)),
          if (data.dea != 0)
            TextSpan(
                text: "J:${format(data.j)}    ",
                style: getTextStyle(ChartColors.jColor)),
        ];
        break;
      case SecondaryState.RSI:
        children = [
          TextSpan(
              text: "RSI(14):${format(data.rsi)}    ",
              style: getTextStyle(ChartColors.rsiColor)),
          TextSpan(
              text: "Upper Band:${format(70)}    ",
              style: getTextStyle(Colors.red)),
          TextSpan(
              text: "Lower Band:${format(20)}    ",
              style: getTextStyle(Colors.white)),
        ];
        break;
      case SecondaryState.ADX:
        children = [
          TextSpan(
              text: "ADX(14):${format(data.adx)}    ",
              style: getTextStyle(Colors.white)),
          TextSpan(
              text: "BAND_ADX(14):${format(20.00)}    ",
              style: getTextStyle(Colors.blue)),
          TextSpan(
              text: "-DI(14):${format(data.minusDi)}    ",
              style: getTextStyle(Colors.red)),
          TextSpan(
              text: "+DI(14):${format(data.plusDi)}    ",
              style: getTextStyle(Colors.green)),
        ];
        break;
      case SecondaryState.STOCH:
        children = [
          TextSpan(
              text: "SlowD(%D):${format(data.slowD)}    ",
              style: getTextStyle(Colors.blue)),
          TextSpan(
              text: "SlowK(%K):${format(data.slowK)} (14,3,3)   ",
              style: getTextStyle(ChartColors.dnColor)),
          TextSpan(
              text: "Upper Band:${format(70)}    ",
              style: getTextStyle(Colors.pink)),
          TextSpan(
              text: "Lower Band:${format(20)}    ",
              style: getTextStyle(Colors.pink)),
        ];
        break;
      case SecondaryState.WR:
        children = [
          TextSpan(
              text: "WR(14):${format(data.r)}    ",
              style: getTextStyle(ChartColors.rsiColor)),
        ];
        break;
      default:
        break;
    }
    TextPainter tp = TextPainter(
        text: TextSpan(children: children ?? []),
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(x, chartRect.top - topPadding));
  }

  @override
  void drawRightText(canvas, textStyle, int gridRows) {
    TextPainter maxTp = TextPainter(
        text: TextSpan(text: "${format(maxValue)}", style: textStyle),
        textDirection: TextDirection.ltr);
    maxTp.layout();
    TextPainter minTp = TextPainter(
        text: TextSpan(text: "${format(minValue)}", style: textStyle),
        textDirection: TextDirection.ltr);
    minTp.layout();

    maxTp.paint(canvas,
        Offset(chartRect.width - maxTp.width, chartRect.top - topPadding));
    minTp.paint(canvas,
        Offset(chartRect.width - minTp.width, chartRect.bottom - minTp.height));
  }

  @override
  void drawGrid(Canvas canvas, int gridRows, int gridColumns) {
    canvas.drawLine(Offset(0, chartRect.top),
        Offset(chartRect.width, chartRect.top), gridPaint);
    canvas.drawLine(Offset(0, chartRect.bottom),
        Offset(chartRect.width, chartRect.bottom), gridPaint);
    double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      //mSecondaryRect垂直线
      canvas.drawLine(Offset(columnSpace * i, chartRect.top - topPadding),
          Offset(columnSpace * i, chartRect.bottom), gridPaint);
    }
  }
}
