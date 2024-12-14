// Mocks generated by Mockito 5.4.4 from annotations
// in kitchenowl/test/cubits/mock_transaction_handler.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i2;

import 'package:kitchenowl/services/transaction.dart' as _i4;
import 'package:kitchenowl/services/transaction_handler.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i5;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeFuture_0<T1> extends _i1.SmartFake implements _i2.Future<T1> {
  _FakeFuture_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [TransactionHandler].
///
/// See the documentation for Mockito's code generation for more information.
class MockTransactionHandler extends _i1.Mock
    implements _i3.TransactionHandler {
  MockTransactionHandler() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.Future<void> runOpenTransactions() => (super.noSuchMethod(
        Invocation.method(
          #runOpenTransactions,
          [],
        ),
        returnValue: _i2.Future<void>.value(),
        returnValueForMissingStub: _i2.Future<void>.value(),
      ) as _i2.Future<void>);

  @override
  _i2.Future<T> runTransaction<T>(
    _i4.Transaction<T>? t, {
    bool? forceOffline = false,
    bool? saveTransaction = true,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #runTransaction,
          [t],
          {
            #forceOffline: forceOffline,
            #saveTransaction: saveTransaction,
          },
        ),
        returnValue: _i5.ifNotNull(
              _i5.dummyValueOrNull<T>(
                this,
                Invocation.method(
                  #runTransaction,
                  [t],
                  {
                    #forceOffline: forceOffline,
                    #saveTransaction: saveTransaction,
                  },
                ),
              ),
              (T v) => _i2.Future<T>.value(v),
            ) ??
            _FakeFuture_0<T>(
              this,
              Invocation.method(
                #runTransaction,
                [t],
                {
                  #forceOffline: forceOffline,
                  #saveTransaction: saveTransaction,
                },
              ),
            ),
      ) as _i2.Future<T>);
}