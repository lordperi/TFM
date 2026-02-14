import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/constants/diabetes_type.dart';
import 'package:frontend/core/constants/therapy_type.dart';
import 'package:frontend/presentation/widgets/conditional_medical_fields.dart';

void main() {
  group('ConditionalMedicalFields Widget Tests', () {
    late TextEditingController isfController;
    late TextEditingController icrController;
    late TextEditingController targetController;

    setUp(() {
      isfController = TextEditingController();
      icrController = TextEditingController();
      targetController = TextEditingController();
    });

    tearDown(() {
      isfController.dispose();
      icrController.dispose();
      targetController.dispose();
    });

    testWidgets('hides all fields when diabetes type is NONE',
        (WidgetTester tester) async {
      DiabetesType selectedDiabetesType = DiabetesType.none;
      TherapyType? selectedTherapyType;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConditionalMedicalFields(
              diabetesType: selectedDiabetesType,
              therapyType: selectedTherapyType,
              onTherapyTypeChanged: (value) {
                selectedTherapyType = value;
              },
              isfController: isfController,
              icrController: icrController,
              targetController: targetController,
            ),
          ),
        ),
      );

      // Should not show any fields
      expect(find.byType(TextFormField), findsNothing);
      expect(find.text('Tipo de Tratamiento'), findsNothing);
    });

    testWidgets('shows therapy selector for Type 1 diabetes',
        (WidgetTester tester) async {
      DiabetesType selectedDiabetesType = DiabetesType.type1;
      TherapyType? selectedTherapyType;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConditionalMedicalFields(
              diabetesType: selectedDiabetesType,
              therapyType: selectedTherapyType,
              onTherapyTypeChanged: (value) {
                selectedTherapyType = value;
              },
              isfController: isfController,
              icrController: icrController,
              targetController: targetController,
            ),
          ),
        ),
      );

      // Should show therapy type selector
      expect(find.text('Tipo de Tratamiento'), findsOneWidget);
      expect(find.text('Insulina Inyectable'), findsOneWidget);
      expect(find.text('Sin tratamiento'), findsOneWidget);
    });

    testWidgets('shows insulin fields when therapy is INSULIN',
        (WidgetTester tester) async {
      DiabetesType selectedDiabetesType = DiabetesType.type1;
      TherapyType? selectedTherapyType = TherapyType.insulin;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConditionalMedicalFields(
              diabetesType: selectedDiabetesType,
              therapyType: selectedTherapyType,
              onTherapyTypeChanged: (value) {},
              isfController: isfController,
              icrController: icrController,
              targetController: targetController,
            ),
          ),
        ),
      );

      // Should show insulin fields (ISF, ICR, Target)
      expect(find.text('ISF (Insulin Sensitivity Factor)'), findsOneWidget);
      expect(find.text('ICR (Insulin-to-Carb Ratio)'), findsOneWidget);
      expect(find.text('Glucosa Objetivo (mg/dL)'), findsOneWidget);
    });

    testWidgets('hides insulin fields when therapy is ORAL',
        (WidgetTester tester) async {
      DiabetesType selectedDiabetesType = DiabetesType.type2;
      TherapyType? selectedTherapyType = TherapyType.oral;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConditionalMedicalFields(
              diabetesType: selectedDiabetesType,
              therapyType: selectedTherapyType,
              onTherapyTypeChanged: (value) {},
              isfController: isfController,
              icrController: icrController,
              targetController: targetController,
            ),
          ),
        ),
      );

      // Should NOT show insulin fields
      expect(find.text('ISF (Insulin Sensitivity Factor)'), findsNothing);
      expect(find.text('ICR (Insulin-to-Carb Ratio)'), findsNothing);
    });

    testWidgets('validates ISF range (1-500)', (WidgetTester tester) async {
      DiabetesType selectedDiabetesType = DiabetesType.type1;
      TherapyType? selectedTherapyType = TherapyType.insulin;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: ConditionalMedicalFields(
                diabetesType: selectedDiabetesType,
                therapyType: selectedTherapyType,
                onTherapyTypeChanged: (value) {},
                isfController: isfController,
                icrController: icrController,
                targetController: targetController,
              ),
            ),
          ),
        ),
      );

      // Test validation directly
      final formField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'ISF (Insulin Sensitivity Factor)'),
      );
      
      // Invalid value (>500)
      final invalidResult = formField.validator!('600');
      expect(invalidResult, contains('500'));
      
      // Valid value
      final validResult = formField.validator!('50');
      expect(validResult, isNull);
    });

    testWidgets('validates ICR range (1-150)', (WidgetTester tester) async {
      DiabetesType selectedDiabetesType = DiabetesType.type1;
      TherapyType? selectedTherapyType = TherapyType.insulin;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: ConditionalMedicalFields(
                diabetesType: selectedDiabetesType,
                therapyType: selectedTherapyType,
                onTherapyTypeChanged: (value) {},
                isfController: isfController,
                icrController: icrController,
                targetController: targetController,
              ),
            ),
          ),
        ),
      );

      final formField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'ICR (Insulin-to-Carb Ratio)'),
      );
      
      // Invalid value
      expect(formField.validator!('200'), isNotNull);
      // Valid value
      expect(formField.validator!('10'), isNull);
    });
  });
}
