package com.flutter_laranjinha_payment.flutter_laranjinha_payment
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import com.flutter_laranjinha_payment.flutter_laranjinha_payment.deeplink.Deeplink
import com.flutter_laranjinha_payment.flutter_laranjinha_payment.deeplink.PaymentDeeplink
import com.flutter_laranjinha_payment.flutter_laranjinha_payment.deeplink.RefundDeeplink
import com.flutter_laranjinha_payment.flutter_laranjinha_payment.deeplink.ReprintDeeplink
import com.flutter_laranjinha_payment.flutter_laranjinha_payment.services.DeviceInfo
import com.flutter_laranjinha_payment.flutter_laranjinha_payment.services.PrintService
import com.flutter_laranjinha_payment.flutter_laranjinha_payment.services.RedeSdkHolder
import rede.smartrede.sdk.api.IRedeSdk

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import rede.smartrede.commons.callback.IPrinterCallback

class FlutterLaranjinhaPaymentPlugin :
    FlutterPlugin,
    MethodCallHandler, ActivityAware {
    companion object {
        private const val TAG = "FlutterLaranjinha"
    }

    private lateinit var channel: MethodChannel
    private lateinit var applicationContext: Context
    private var binding: ActivityPluginBinding? = null
    private var resultScope: Result? = null
    private val paymentDeeplink: PaymentDeeplink = PaymentDeeplink()
    private val refundDeeplink: RefundDeeplink = RefundDeeplink()
    private val reprintDeeplink: ReprintDeeplink = ReprintDeeplink()

    private val activityResultListener = PluginRegistry.ActivityResultListener { requestCode: Int, resultCode: Int, intent: Intent? ->
        val knownRequest = requestCode == PaymentDeeplink.REQUEST_CODE ||
            requestCode == RefundDeeplink.REQUEST_CODE ||
            requestCode == ReprintDeeplink.REQUEST_CODE

        if (!knownRequest) {
            return@ActivityResultListener false
        }

        if (Activity.RESULT_OK == resultCode) {
            val responseMap: Map<String, Any?> = when (requestCode) {
                PaymentDeeplink.REQUEST_CODE -> paymentDeeplink.validateIntent(intent)
                RefundDeeplink.REQUEST_CODE -> refundDeeplink.validateIntent(intent)
                ReprintDeeplink.REQUEST_CODE -> reprintDeeplink.validateIntent(intent)
                else -> mapOf("code" to "ERROR", "message" to "Unknown request")
            }
            sendResultData(responseMap)
        } else {
            val message = when (resultCode) {
                Activity.RESULT_CANCELED -> "Operação cancelada na maquininha."
                else -> "Pagamento sem retorno da maquininha (resultCode=$resultCode)."
            }
            resultScope?.error("CANCELLED", message, null)
            resultScope = null
        }
        true
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_laranjinha_payment")
        channel.setMethodCallHandler(this)
        RedeSdkHolder.get(applicationContext)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        resultScope = result

        if (call.method == "getSerialNumberAndDeviceModel") {
            val deviceInfo = DeviceInfo().getSerialNumberAndDeviceModel()
            resultScope?.success(mapOf(
                "code" to "SUCCESS",
                "data" to deviceInfo
            ))
            resultScope = null
            return
        }

        val activityBinding: ActivityPluginBinding = binding ?: run {
            Log.e(TAG, "${call.method}: nenhuma Activity anexada ao plugin")
            resultScope?.error("NO_ACTIVITY", "Tela do aplicativo indisponível. Feche e abra o app e tente novamente.", null)
            resultScope = null
            return
        }

        val redeSdk: IRedeSdk = RedeSdkHolder.get(applicationContext) ?: run {
            Log.e(TAG, "${call.method}: IRedeSdk indisponível")
            resultScope?.error("SDK_UNAVAILABLE", "Serviço da Rede indisponível na maquininha. Aguarde alguns segundos e tente novamente.", null)
            resultScope = null
            return
        }

        when (call.method) {
            "pay" -> {
                val bundle = Bundle().apply {
                    putInt("amount", call.argument<Int>("amount") ?: 0)
                    putString("paymentType", call.argument<String>("paymentType"))
                    putInt("installments", call.argument<Int>("installments") ?: 0)
                }
                starDeeplink(paymentDeeplink, redeSdk, activityBinding, bundle)
            }
            "refund" -> {
                val bundle = Bundle().apply {
                    putString("nsu", call.argument<String>("nsu"))
                }
                starDeeplink(refundDeeplink, redeSdk, activityBinding, bundle)
            }
            "print" -> {
                val listPrintContent: List<HashMap<String, Any?>>? = call.argument<List<HashMap<String, Any?>>>("printable_content")

                val bundleResult = PrintService().start(
                    redeSdk,
                    PrinterCallback(
                        onSuccess = {
                            resultScope?.success(mapOf(
                                "code" to "SUCCESS",
                                "data" to true
                            ))
                            resultScope = null
                        },
                        onFailure = { message ->
                            resultScope?.error("ERROR", message, null)
                            resultScope = null
                        }
                    ),
                    listPrintContent?.toBundleList(),
                    activityBinding
                )

                if (bundleResult.getString("code") == "ERROR") {
                    val message: String = (bundleResult.getString("message") ?: "result error").toString()
                    resultScope?.error((bundleResult.getString("code") ?: "ERROR").toString(), message, null)
                    resultScope = null
                }
            }
            "reprint" -> {
                starDeeplink(reprintDeeplink, redeSdk, activityBinding, Bundle())
            }
            else ->  {
                resultScope?.error("ERROR", "Value of ", null)
            }
        }
    }

    private fun List<Map<String, Any?>>.toBundleList(): ArrayList<Bundle> {
        val bundleList = ArrayList<Bundle>()
        for (map in this) {
            bundleList.add(map.toBundle())
        }
        return bundleList
    }

    private fun Map<String, Any?>.toBundle(): Bundle {
        val bundle = Bundle()
        for ((key, value) in this) {
            when (value) {
                is String -> bundle.putString(key, value)
                is Int -> bundle.putInt(key, value)
                is Boolean -> bundle.putBoolean(key, value)
                is Double -> bundle.putDouble(key, value)
                is Float -> bundle.putFloat(key, value)
                is Long -> bundle.putLong(key, value)
                is Map<*, *> -> {
                    @Suppress("UNCHECKED_CAST")
                    bundle.putBundle(key, (value as? Map<String, Any?>)?.toBundle())
                }
            }
        }
        return bundle
    }

    private fun starDeeplink(deeplink: Deeplink, redeSdk: IRedeSdk, activityBinding: ActivityPluginBinding, bundle: Bundle) {
        val bundleStartDeeplink: Bundle = deeplink.startDeeplink(redeSdk, activityBinding, bundle)
        val code: String = bundleStartDeeplink.getString("code") ?: "ERROR"

        if (code == "ERROR") {
            val message: String = (bundleStartDeeplink.getString("message") ?: "start deeplink error").toString()
            Log.e(TAG, "Falha ao iniciar ${deeplink.javaClass.simpleName}: $message")
            resultScope?.error(code, message, null)
            resultScope = null
        }
    }

    private fun sendResultData(paymentData: Map<String, Any?>) {
        if (paymentData["code"] == "SUCCESS" && paymentData["data"] != null) {
            resultScope?.success(paymentData)
            resultScope = null
        } else  {
            val message: String = (paymentData["message"] ?: "result error").toString()
            resultScope?.error((paymentData["code"] ?: "ERROR").toString(), message, null)
            resultScope = null
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(newBinding: ActivityPluginBinding) {
        binding = newBinding
        newBinding.addActivityResultListener(activityResultListener)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        detachActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        detachActivity()
    }

    private fun detachActivity() {
        binding?.removeActivityResultListener(activityResultListener)
        binding = null
    }
}

class PrinterCallback(
    private val onSuccess: () -> Unit,
    private val onFailure: ( String) -> Unit
) : IPrinterCallback {

    override fun onError(errorMessage: String) {
        onFailure(errorMessage)
    }

    override fun onCompleted() {
        onSuccess()
    }
}
