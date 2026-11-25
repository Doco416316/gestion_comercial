import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_comercial/features/sales/domain/sale_payment_service.dart';

void main() {
  late SalePaymentService service;

  setUp(() {
    service = SalePaymentService();
  });

  group('SalePaymentService - pago inicial', () {
    test(
      'permite una venta de contado sin cliente si está pagada completa',
      () {
        final result = service.calculateInitialPayment(
          const SalePaymentInput(
            paymentType: SalePaymentType.cash,
            totalMinorUnits: 12500,
            initialPaymentMinorUnits: 12500,
          ),
        );

        expect(result.paidMinorUnits, 12500);
        expect(result.balanceMinorUnits, 0);
        expect(result.status, SalePaymentStatus.paid);
      },
    );

    test('permite una venta a crédito con abono inicial y cliente', () {
      final result = service.calculateInitialPayment(
        const SalePaymentInput(
          paymentType: SalePaymentType.credit,
          customerId: 'customer-1',
          totalMinorUnits: 10000,
          initialPaymentMinorUnits: 2500,
        ),
      );

      expect(result.paidMinorUnits, 2500);
      expect(result.balanceMinorUnits, 7500);
      expect(result.status, SalePaymentStatus.partial);
    });

    test('permite una venta a crédito sin abono inicial', () {
      final result = service.calculateInitialPayment(
        const SalePaymentInput(
          paymentType: SalePaymentType.credit,
          customerId: 'customer-1',
          totalMinorUnits: 10000,
          initialPaymentMinorUnits: 0,
        ),
      );

      expect(result.balanceMinorUnits, 10000);
      expect(result.status, SalePaymentStatus.unpaid);
    });

    test('rechaza una venta a crédito sin cliente', () {
      expect(
        () => service.calculateInitialPayment(
          const SalePaymentInput(
            paymentType: SalePaymentType.credit,
            totalMinorUnits: 10000,
            initialPaymentMinorUnits: 0,
          ),
        ),
        throwsArgumentError,
      );
    });

    test('rechaza una venta de contado con pago incompleto', () {
      expect(
        () => service.calculateInitialPayment(
          const SalePaymentInput(
            paymentType: SalePaymentType.cash,
            totalMinorUnits: 10000,
            initialPaymentMinorUnits: 5000,
          ),
        ),
        throwsArgumentError,
      );
    });

    test('rechaza pagos iniciales superiores al total', () {
      expect(
        () => service.calculateInitialPayment(
          const SalePaymentInput(
            paymentType: SalePaymentType.credit,
            customerId: 'customer-1',
            totalMinorUnits: 10000,
            initialPaymentMinorUnits: 10001,
          ),
        ),
        throwsArgumentError,
      );
    });
  });

  group('SalePaymentService - abonos posteriores', () {
    test('actualiza el saldo al registrar un abono parcial', () {
      final result = service.registerPayment(
        totalMinorUnits: 10000,
        paidMinorUnits: 2500,
        paymentMinorUnits: 3000,
      );

      expect(result.paidMinorUnits, 5500);
      expect(result.balanceMinorUnits, 4500);
      expect(result.status, SalePaymentStatus.partial);
    });

    test('marca la deuda como pagada al completar el saldo', () {
      final result = service.registerPayment(
        totalMinorUnits: 10000,
        paidMinorUnits: 7500,
        paymentMinorUnits: 2500,
      );

      expect(result.balanceMinorUnits, 0);
      expect(result.status, SalePaymentStatus.paid);
    });

    test('rechaza abonos iguales a cero o negativos', () {
      expect(
        () => service.registerPayment(
          totalMinorUnits: 10000,
          paidMinorUnits: 1000,
          paymentMinorUnits: 0,
        ),
        throwsArgumentError,
      );
      expect(
        () => service.registerPayment(
          totalMinorUnits: 10000,
          paidMinorUnits: 1000,
          paymentMinorUnits: -1,
        ),
        throwsArgumentError,
      );
    });

    test('rechaza abonos superiores al saldo pendiente', () {
      expect(
        () => service.registerPayment(
          totalMinorUnits: 10000,
          paidMinorUnits: 9000,
          paymentMinorUnits: 1001,
        ),
        throwsArgumentError,
      );
    });
  });
}
