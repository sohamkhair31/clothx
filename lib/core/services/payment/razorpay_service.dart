import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../constants/app_secrets.dart';

class RazorpayService {
  late Razorpay _razorpay;

  final Function(PaymentSuccessResponse)?
      onSuccess;

  final Function(PaymentFailureResponse)?
      onFailure;

  final Function(ExternalWalletResponse)?
      onExternalWallet;

  RazorpayService({
    this.onSuccess,
    this.onFailure,
    this.onExternalWallet,
  }) {
    _razorpay = Razorpay();

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      _handlePaymentSuccess,
    );

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      _handlePaymentError,
    );

    _razorpay.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      _handleExternalWallet,
    );
  }

  // ================= OPEN CHECKOUT =================
  void openCheckout({
    required double amount,
    required String name,
    required String description,
    required String email,
    required String phone,
    required String razorpayOrderId,
  }) {
    final options = {
      "key":
          AppSecrets.razorpayKey,

      "amount":
          (amount * 100).toInt(),

      "order_id":
          razorpayOrderId,

      "name": name,
      "description": description,

      "timeout": 300,

      "retry": {
        "enabled": true,
        "max_count": 2,
      },

      "prefill": {
        "contact": phone,
        "email": email,
      },

      "theme": {
        "color": "#111111",
      },

      "external": {
        "wallets": [
          "paytm",
        ]
      }
    };

    _razorpay.open(options);
  }

  // ================= SUCCESS =================
  void _handlePaymentSuccess(
    PaymentSuccessResponse response,
  ) {
    onSuccess?.call(response);
  }

  // ================= FAILURE =================
  void _handlePaymentError(
    PaymentFailureResponse response,
  ) {
    onFailure?.call(response);
  }

  // ================= EXTERNAL =================
  void _handleExternalWallet(
    ExternalWalletResponse response,
  ) {
    onExternalWallet?.call(response);
  }

  // ================= DISPOSE =================
  void dispose() {
    _razorpay.clear();
  }
}