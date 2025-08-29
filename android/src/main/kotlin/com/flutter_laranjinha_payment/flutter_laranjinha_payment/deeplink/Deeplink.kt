package com.flutter_laranjinha_payment.flutter_laranjinha_payment.deeplink

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import rede.smartrede.sdk.api.IRedeSdk

interface Deeplink {
    fun startDeeplink(redeSdk: IRedeSdk, binding: ActivityPluginBinding, bundle: Bundle) : Bundle
    fun validateIntent(intent: Intent?): Map<String, Any?>
}