import 'package:ai_millionaire_course/widgets/menu/settings/notification_time_picker_dialog.dart';
import 'package:ai_millionaire_course/widgets/menu/settings/time_picker_wheels.dart';
import 'package:flutter/material.dart';
import 'package:ai_millionaire_course/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('notification time picker confirms selected time', (
    tester,
  ) async {
    int? selectedHour;
    int? selectedMinute;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 375,
            height: 812,
            child: NotificationTimePickerDialog(
              currentHour: 20,
              currentMinute: 0,
              onConfirm: (hour, minute) {
                selectedHour = hour;
                selectedMinute = minute;
              },
              onDismiss: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Notification Time'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.drag(
      find.byType(ListWheelScrollView).first,
      const Offset(0, -80),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));

    expect(selectedHour, isNotNull);
    expect(selectedHour, isNot(20));
    expect(selectedMinute, 0);
  });

  testWidgets('notification time picker cancel dismisses without confirm', (
    tester,
  ) async {
    var dismissCount = 0;
    var confirmCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 375,
            height: 812,
            child: NotificationTimePickerDialog(
              currentHour: 20,
              currentMinute: 0,
              onConfirm: (_, _) => confirmCount++,
              onDismiss: () => dismissCount++,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Cancel'));
    await tester.pump();

    expect(dismissCount, 1);
    expect(confirmCount, 0);
  });

  testWidgets('time picker wheels fit compact width', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 170,
              child: TimePickerWheels(
                currentHour: 20,
                currentMinute: 0,
                onHourChanged: (_) {},
                onMinuteChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(ListWheelScrollView), findsNWidgets(2));
  });
}
