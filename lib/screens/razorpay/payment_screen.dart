import 'dart:js_interop';

@JS('Razorpay')
external JSFunction get _razorpayConstructor;

extension type RazorpayOptions._(JSObject _) implements JSObject {
  external factory RazorpayOptions({
    String key,
    int amount,
    String name,
    String description,
    JSObject prefill,
    JSFunction handler,
    String? order_id,
  });
}

@JS()
extension type Razorpay._(JSObject _) implements JSObject {
  external factory Razorpay(RazorpayOptions options);

  external void open();
}

void openWebCheckout({
  required String key,
  required double amount,
  required String name,
  required String description,
  required String email,
  required String phone,
  String? orderId,
  required Function(String paymentId) onSuccess,
}) {
  final options = RazorpayOptions(
    key: key,
    amount: (amount * 100).toInt(),
    name: name,
    description: description,
    order_id: orderId,
    prefill: {
      "email": email,
      "contact": phone,
    }.jsify() as JSObject,
    handler: ((JSObject response) {
      final paymentId =
          (response.dartify()
              as Map)["razorpay_payment_id"];

      onSuccess(paymentId);
    }).toJS,
  );

  Razorpay(options).open();
}