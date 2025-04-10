import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cvhat/core/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toastification/toastification.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

  static pushWithReplacement(Widget widget) {
    Navigator.of(navKey.currentContext!)
        .pushReplacement(SlideTransition1(widget));
  }

  static pushWidget(Widget widget) {
    Navigator.of(navKey.currentContext!).push(SlideTransition1(widget));
  }

  static popWidget() {
    if (Navigator.canPop(navKey.currentContext!)) {
      Navigator.pop(navKey.currentContext!);
    }
  }

  static pushAndRemoveUntil(Widget widget) {
    Navigator.of(navKey.currentContext!).pushAndRemoveUntil(
      SlideTransition1(widget),
      (Route<dynamic> route) => false, // This removes all previous routes
    );
  }

  static canPopWidget() {
    return Navigator.canPop(navKey.currentContext!);
  }

  static animatedSwitcher(Widget widget) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(animation);

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(animation);

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
      child: widget,
    );
  }

  static awesomeSnackBar(
      String title, String message, ContentType contentType) {
    ScaffoldMessenger.of(navKey.currentContext!)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: title,
          message: message,
          contentType: contentType,
        ),
      ));
  }

  static ToastificationItem? _currentToast;
  static bool _isShowing = false;

  static toastificationSnackBar(
      String title, String description, ToastificationType type) async {
    if (_isShowing) return;
    _isShowing = true;

    if (_currentToast != null) {
      toastification.dismiss(_currentToast!);
      _currentToast = null;
    }

    final backgroundColor = _getBackgroundColor(type);
    final icon = _getIcon(type, backgroundColor);

    _currentToast = toastification.showCustom(
      context: navKey.currentContext,
      overlayState: navKey.currentState?.overlay,
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topCenter,
      builder: (context, toastItem) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 25.w, vertical: 0),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withValues(alpha: 0.1),
                offset: const Offset(0, 4),
                blurRadius: 6,
                spreadRadius: 2,
              ),
            ],
            color: AppColors.bgWhite,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Container(
            alignment: Alignment.topCenter,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            decoration: BoxDecoration(
                color: backgroundColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: backgroundColor)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                icon,
                SizedBox(
                  width: 270.w,
                  child: Text(description,
                      maxLines: 3,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: AppColors.textBlack, fontSize: 14.sp)),
                ),
                SizedBox(
                  width: 10.w,
                )
              ],
            ),
          ),
        );
      },
    );
    //return _currentToast;
    await Future.delayed(const Duration(seconds: 3));
    _isShowing = false;
  }
}

Color _getBackgroundColor(ToastificationType type) {
  switch (type) {
    case ToastificationType.success:
      return Colors.green;
    case ToastificationType.error:
      return Colors.red;
    case ToastificationType.warning:
      return Colors.orange;
    case ToastificationType.info:
    default:
      return Colors.blue;
  }
}

Icon _getIcon(ToastificationType type, Color color) {
  switch (type) {
    case ToastificationType.success:
      return Icon(Icons.check_circle_outline_rounded, color: color);
    case ToastificationType.error:
      return Icon(
        Icons.cancel_outlined,
        color: color,
      );
    case ToastificationType.warning:
      return Icon(Icons.warning_amber_rounded, color: color);
    case ToastificationType.info:
    default:
      return Icon(Icons.info_outline_rounded, color: color);
  }
}

class SlideTransition1 extends PageRouteBuilder {
  final Widget page;

  SlideTransition1(this.page)
      : super(
            pageBuilder: (context, animation, anotherAnimation) => page,
            transitionDuration: const Duration(milliseconds: 1000),
            reverseTransitionDuration: const Duration(milliseconds: 400),
            transitionsBuilder: (context, animation, anotherAnimation, child) {
              animation = CurvedAnimation(
                  curve: Curves.fastLinearToSlowEaseIn,
                  parent: animation,
                  reverseCurve: Curves.fastOutSlowIn);
              return SlideTransition(
                position: Tween(
                        begin: const Offset(1.0, 0.0),
                        end: const Offset(0.0, 0.0))
                    .animate(animation),
                child: page,
              );
            });
}
