import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_comercial/features/purchases/domain/purchase_calculation_service.dart';

void main() {
  late PurchaseCalculationService service;

  setUp(() {
    service = PurchaseCalculationService();
  });

  group('PurchaseCalculationService - cálculo de líneas', () {
    test('calcula correctamente una línea sin descuentos ni impuestos', () {
      final result = service.calculateLine(
        const PurchaseLineCalculationInput(
          quantityMilliUnits: 2500,
          unitCostMinorUnits: 10000,
        ),
      );

      expect(result.grossAmountMinorUnits, 25000);
      expect(result.discountMinorUnits, 0);
      expect(result.taxableBaseMinorUnits, 25000);
      expect(result.taxMinorUnits, 0);
      expect(result.totalMinorUnits, 25000);
    });

    test('calcula un descuento fijo', () {
      final result = service.calculateLine(
        const PurchaseLineCalculationInput(
          quantityMilliUnits: 1000,
          unitCostMinorUnits: 100000,
          discount: PurchaseAdjustmentInput.fixed(1000),
        ),
      );

      expect(result.grossAmountMinorUnits, 100000);
      expect(result.discountMinorUnits, 1000);
      expect(result.taxableBaseMinorUnits, 99000);
      expect(result.totalMinorUnits, 99000);
    });

    test('calcula un descuento porcentual', () {
      final result = service.calculateLine(
        PurchaseLineCalculationInput(
          quantityMilliUnits: 1000,
          unitCostMinorUnits: 100000,
          discount: PurchaseAdjustmentInput.percentage(Decimal.parse('10')),
        ),
      );

      expect(result.grossAmountMinorUnits, 100000);
      expect(result.discountMinorUnits, 10000);
      expect(result.taxableBaseMinorUnits, 90000);
      expect(result.totalMinorUnits, 90000);
    });

    test('calcula impuesto fijo después del descuento', () {
      final result = service.calculateLine(
        const PurchaseLineCalculationInput(
          quantityMilliUnits: 1000,
          unitCostMinorUnits: 100000,
          discount: PurchaseAdjustmentInput.fixed(10000),
          tax: PurchaseAdjustmentInput.fixed(5000),
        ),
      );

      expect(result.grossAmountMinorUnits, 100000);
      expect(result.discountMinorUnits, 10000);
      expect(result.taxableBaseMinorUnits, 90000);
      expect(result.taxMinorUnits, 5000);
      expect(result.totalMinorUnits, 95000);
    });

    test('calcula impuesto porcentual sobre la base descontada', () {
      final result = service.calculateLine(
        PurchaseLineCalculationInput(
          quantityMilliUnits: 1000,
          unitCostMinorUnits: 100000,
          discount: PurchaseAdjustmentInput.percentage(Decimal.parse('10')),
          tax: PurchaseAdjustmentInput.percentage(Decimal.parse('10')),
        ),
      );

      expect(result.grossAmountMinorUnits, 100000);
      expect(result.discountMinorUnits, 10000);
      expect(result.taxableBaseMinorUnits, 90000);
      expect(result.taxMinorUnits, 9000);
      expect(result.totalMinorUnits, 99000);
    });

    test('permite descuento del 100 %', () {
      final result = service.calculateLine(
        PurchaseLineCalculationInput(
          quantityMilliUnits: 1000,
          unitCostMinorUnits: 10000,
          discount: PurchaseAdjustmentInput.percentage(Decimal.fromInt(100)),
        ),
      );

      expect(result.discountMinorUnits, 10000);
      expect(result.taxableBaseMinorUnits, 0);
      expect(result.totalMinorUnits, 0);
    });

    test('redondea HALF_UP en importes positivos', () {
      final result = service.calculateLine(
        PurchaseLineCalculationInput(
          quantityMilliUnits: 1000,
          unitCostMinorUnits: 1,
          tax: PurchaseAdjustmentInput.percentage(Decimal.parse('50')),
        ),
      );

      expect(result.grossAmountMinorUnits, 1);
      expect(result.taxMinorUnits, 1);
      expect(result.totalMinorUnits, 2);
    });
  });

  group('PurchaseCalculationService - validaciones', () {
    test('rechaza cantidades iguales a cero', () {
      expect(
        () => service.calculateLine(
          const PurchaseLineCalculationInput(
            quantityMilliUnits: 0,
            unitCostMinorUnits: 1000,
          ),
        ),
        throwsArgumentError,
      );
    });

    test('rechaza cantidades negativas', () {
      expect(
        () => service.calculateLine(
          const PurchaseLineCalculationInput(
            quantityMilliUnits: -1000,
            unitCostMinorUnits: 1000,
          ),
        ),
        throwsArgumentError,
      );
    });

    test('rechaza costos negativos', () {
      expect(
        () => service.calculateLine(
          const PurchaseLineCalculationInput(
            quantityMilliUnits: 1000,
            unitCostMinorUnits: -1000,
          ),
        ),
        throwsArgumentError,
      );
    });

    test('rechaza descuentos superiores al importe bruto', () {
      expect(
        () => service.calculateLine(
          const PurchaseLineCalculationInput(
            quantityMilliUnits: 1000,
            unitCostMinorUnits: 10000,
            discount: PurchaseAdjustmentInput.fixed(10001),
          ),
        ),
        throwsArgumentError,
      );
    });

    test('rechaza descuentos porcentuales superiores al 100 %', () {
      expect(
        () => service.calculateLine(
          PurchaseLineCalculationInput(
            quantityMilliUnits: 1000,
            unitCostMinorUnits: 10000,
            discount: PurchaseAdjustmentInput.percentage(
              Decimal.parse('100.01'),
            ),
          ),
        ),
        throwsArgumentError,
      );
    });

    test('rechaza porcentajes negativos', () {
      expect(
        () => service.calculateLine(
          PurchaseLineCalculationInput(
            quantityMilliUnits: 1000,
            unitCostMinorUnits: 10000,
            tax: PurchaseAdjustmentInput.percentage(Decimal.parse('-1')),
          ),
        ),
        throwsArgumentError,
      );
    });

    test('rechaza una compra sin detalles', () {
      expect(() => service.calculatePurchase([]), throwsArgumentError);
    });
  });

  group('PurchaseCalculationService - compra completa', () {
    test('consolida correctamente los importes de varios detalles', () {
      final result = service.calculatePurchase([
        const PurchaseLineCalculationInput(
          quantityMilliUnits: 1000,
          unitCostMinorUnits: 25000,
          discount: PurchaseAdjustmentInput.fixed(1000),
          tax: PurchaseAdjustmentInput.fixed(1200),
        ),
        const PurchaseLineCalculationInput(
          quantityMilliUnits: 1000,
          unitCostMinorUnits: 15000,
          tax: PurchaseAdjustmentInput.fixed(750),
        ),
      ]);

      expect(result.subtotalMinorUnits, 40000);
      expect(result.discountMinorUnits, 1000);
      expect(result.taxMinorUnits, 1950);
      expect(result.totalMinorUnits, 40950);
      expect(result.lines.length, 2);
    });

    test('rechaza resultados que superan el límite de SQLite', () {
      expect(
        () => service.calculateLine(
          const PurchaseLineCalculationInput(
            quantityMilliUnits: 1000,
            unitCostMinorUnits: 9223372036854775807,
            tax: PurchaseAdjustmentInput.fixed(1),
          ),
        ),
        throwsRangeError,
      );
    });
  });
}
