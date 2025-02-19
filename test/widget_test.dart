import 'package:authenticationapp/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
 // Ensure the path is correct

void main() {
  testWidgets('Front page loads and displays correctly', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title or any key widget from the front page is found.
    expect(find.text('Welcome to To-Do List'), findsOneWidget); // Replace with actual text if different
    expect(find.byType(ElevatedButton), findsWidgets);  // Assuming buttons are on the page

    // Example for button tap if you have navigation.
    await tester.tap(find.byType(ElevatedButton).first); // Tap on the first button
    await tester.pump(); // Triggers a rebuild

    // Verify navigation or any action triggered by the button tap.
    // Use appropriate checks depending on what should happen next.
  });
}
