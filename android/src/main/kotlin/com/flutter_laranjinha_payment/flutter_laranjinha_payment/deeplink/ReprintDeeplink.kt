package com.flutter_laranjinha_payment.flutter_laranjinha_payment.deeplink

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import com.flutter_laranjinha_payment.flutter_laranjinha_payment.deeplink.RefundDeeplink.Companion
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import rede.smartrede.sdk.RedePayments
import rede.smartrede.sdk.api.IRedeSdk

class ReprintDeeplink: Deeplink() {
    companion object {
        const val REQUEST_CODE = 10005
    }

    override fun startDeeplink(redeSdk: IRedeSdk, binding: ActivityPluginBinding, bundle: Bundle): Bundle {
        try {
            val redePayments: RedePayments = redeSdk.getRedePayments(binding.activity)
            val reprint: Intent = redePayments.intentForReprint()

            binding.activity.startActivityForResult(reprint, REQUEST_CODE)

            return Bundle().apply {
                putString("code", "SUCCESS")
            }
        }  catch (e: ActivityNotFoundException) {
            return Bundle().apply {
                putString("code", "ERROR")
                putString("message", e.message)
            }
        } catch (e: IllegalArgumentException) {
            return Bundle().apply {
                putString("code", "ERROR")
                putString("message", e.message)
            }
        } catch (e: Exception) {
            return Bundle().apply {
                putString("code", "ERROR")
                putString("message", e.message ?: "An unexpected error occurred")
            }
        }
    }
}