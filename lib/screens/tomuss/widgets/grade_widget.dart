import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dartus/tomuss.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onyx/core/res.dart';
import 'package:onyx/core/theme/theme_export.dart';
import 'package:onyx/screens/settings/settings_export.dart';
import 'package:onyx/screens/tomuss/tomuss_export.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

class GradeWidget extends StatefulWidget {
  final List<Grade> grades;
  final String text1;
  final String text2;
  final bool isSeen;
  final VoidCallback? onTap;
  final int depth;
  final bool compact;

  const GradeWidget({
    Key? key,
    required this.grades,
    required this.text1,
    required this.text2,
    required this.depth,
    this.isSeen = false,
    this.compact = false,
    this.onTap,
  }) : super(key: key);

  @override
  State<GradeWidget> createState() => _GradeWidgetState();
}

class _GradeWidgetState extends State<GradeWidget> {
  ScreenshotController screenshotController = ScreenshotController();

  Color _mainGradeColor(BuildContext context) {
    if (context.read<SettingsCubit>().state.settings.forceGreen) {
      return widget.isSeen ? GradeColor.seenGreen : GradeColor.unseenGreen;
    } else {
      if (widget.grades.isEmpty) {
        return widget.isSeen ? GradeColor.seenGreen : GradeColor.unseenGreen;
      } else {
        if (widget.grades.length == 1) {
          return _gradeColor(context, widget.grades.first);
        }
        double a = 0;
        double r = 0;
        double g = 0;
        double b = 0;
        double coefSum = 0;
        for (var i in widget.grades) {
          Color tmpColor = _gradeColor(context, i);
          a += tmpColor.alpha * (i.coef);
          r += tmpColor.red * (i.coef);
          g += tmpColor.green * (i.coef);
          b += tmpColor.blue * (i.coef);
          coefSum += i.coef;
        }
        if (coefSum == 0) {
          coefSum = 1;
        }
        a = (a / coefSum);
        r = (r / coefSum);
        g = (g / coefSum);
        b = (b / coefSum);
        return Color.fromARGB(a.round(), r.round(), g.round(), b.round());
      }
    }
  }

  /* original tomuss code
  function rank_to_color(rank, nr) {
    var x = Math.floor(511 * rank / nr);
    var b, c = '';
    if (rank > nr / 2) {
        b = '255,' + (511 - x) + ',' + (511 - x);
        if (rank > 3 * nr / 4)
            c = ';color:#FFF';
    }
    else
        b = x + ',255,' + x;

    return 'background: rgb(' + b + ')' + c
  }
   */
  Color _gradeColor(BuildContext context, Grade grade) {
    if (context.read<SettingsCubit>().state.settings.forceGreen ||
        !grade.isValid) {
      return widget.isSeen ? GradeColor.seenGreen : GradeColor.unseenGreen;
    } else {
      var x = (511 * grade.rank / grade.groupeSize).floor();
      Color b = Colors.red;
      if (grade.rank > grade.groupeSize / 2) {
        b = Color.fromARGB(255, 255, 511 - x, 511 - x);
      } else {
        b = Color.fromARGB(255, x, 255, x);
      }
      return b;
    }
  }

  @override
  Widget build(BuildContext context) {
    double numerator = 0;
    double denominator = 0;
    if (widget.depth != 0) {
      numerator = widget.grades.first.numerator;
      denominator = widget.grades.first.denominator;
    } else {
      if (widget.grades.length == 1) {
        denominator = widget.grades.first.denominator;
      } else {
        denominator = 20;
      }
      double coefSum = 0.0;
      for (var i in widget.grades) {
        if (!i.numerator.isNaN && !i.denominator.isNaN) {
          numerator += (i.numerator / i.denominator) * (i.coef);
          coefSum += (i.coef);
        }
      }
      numerator = (numerator / ((coefSum != 0) ? coefSum : 1)) * denominator;
    }
    String gradeNumerator =
        ((widget.grades.isNotEmpty) ? numerator.toStringAsPrecision(3) : '-');
    if (widget.compact) {
      return TomussCompactElementWidget(
        onTap: widget.onTap,
        color: _mainGradeColor(context),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      gradeNumerator,
                      style: TextStyle(
                        color: OnyxTheme.darkTheme().colorScheme.background,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '/${denominator.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: OnyxTheme.darkTheme().colorScheme.background,
                        fontSize: 6.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              width: Res.bottomNavBarItemWidth,
              height: Res.bottomNavBarHeight / 4,
              child: AutoSizeText(
                widget.text1,
                maxLines: 1,
                minFontSize: 7,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.clip,
                  color: OnyxTheme.darkTheme().colorScheme.background,
                ),
              ),
            ),
            SizedBox(
              width: Res.bottomNavBarItemWidth,
              height: Res.bottomNavBarHeight / 4,
              child: AutoSizeText(
                widget.text2,
                maxLines: 1,
                minFontSize: 8,
                textAlign: TextAlign.center,
                style: TextStyle(
                  overflow: TextOverflow.clip,
                  color: OnyxTheme.darkTheme().colorScheme.background,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return GestureDetector(
          onTap: (widget.onTap != null) ? () => widget.onTap!() : null,
          child: TomussElementWidget(
            color: _mainGradeColor(context),
            left: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    gradeNumerator,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: OnyxTheme.darkTheme().colorScheme.background,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
                Container(
                  width: 15.w,
                  height: 0.2.h,
                  color: OnyxTheme.darkTheme().colorScheme.background,
                ),
                Text(
                  ((widget.grades.isNotEmpty) ? denominator : '-').toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: OnyxTheme.darkTheme().colorScheme.background,
                      fontSize: 15),
                ),
              ],
            ),
            right: Row(
              children: [
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 3.h,
                        width: 70.w,
                        child: Text(
                          widget.text1,
                          maxLines: 1,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 7.h,
                        width: 70.w,
                        child: Text(
                          widget.text2,
                          textAlign: TextAlign.start,
                          maxLines: 3,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 7.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.depth == 1)
                  GradeCoefWidget(grade: widget.grades.first),
                IconButton(
                    onPressed: () async {
                      Directory tmpDir = await getTemporaryDirectory();
                      await screenshotController.captureAndSave(
                        tmpDir.path,
                        pixelRatio: 3.0,
                        fileName: 'screenshot.png',
                      );
                      Share.shareXFiles(
                          [XFile("${tmpDir.path}/screenshot.png")],
                          text:
                              "Voici ma note en ${widget.grades.first.name} !");
                    },
                    icon: Icon(
                      Icons.share_rounded,
                      size: 20.sp,
                    )),
              ],
            ),
            onTap: widget.onTap,
          ));
    }
  }
}
