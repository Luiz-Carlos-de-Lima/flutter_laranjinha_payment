## 1.0.0
* First release of the plugin.

* Implementação inicial com funcionalidades de pagamento, estorno e impressão.

## 1.0.1

* Printing adjustments:
    - Moved execution to a separate thread to avoid UI blocking
    - Automatically resized images to the printer's standard width
    - Ensured consistent sizing between text and images

## 1.0.2

* Printing improvements:
    - Optimized bitmap generation for faster performance
    - Reduced processing time when creating print content
    - Maintained consistency in text and image rendering

## 1.0.3

* Reduced `compileSdk` requirement to improve compatibility with older projects.

## 1.0.4

* Updated `smartrede-sdk` to 4.3.28 (L400).
* `IRedeSdk` is now created once with `applicationContext` and kept for the app lifetime, as recommended by Rede (fixes intermittent "Activity is not available").
* Activity binding is cleared on detach and the activity result listener is removed, avoiding duplicated listeners after config changes.
* Distinct errors: `NO_ACTIVITY` and `SDK_UNAVAILABLE`, with Portuguese messages and logcat logs (tag `FlutterLaranjinha`).
* `setInstallments` is only called for installment credit payments.
* `packageName` is now sent on payment and reversal intents.
* Cancelled or unanswered operations on the terminal now return a `CANCELLED` error instead of leaving the call pending.