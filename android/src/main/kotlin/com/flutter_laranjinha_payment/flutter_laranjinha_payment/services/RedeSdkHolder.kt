package com.flutter_laranjinha_payment.flutter_laranjinha_payment.services

import android.content.Context
import android.util.Log
import rede.smartrede.sdk.api.IRedeSdk

// A Rede exige uma única instância do SDK, criada com applicationContext e mantida enquanto o app estiver em memória.
object RedeSdkHolder {
    private const val TAG = "FlutterLaranjinha"

    @Volatile
    private var instance: IRedeSdk? = null

    fun get(context: Context): IRedeSdk? {
        instance?.let { return it }

        return synchronized(this) {
            instance ?: runCatching { IRedeSdk.newInstance(context.applicationContext) }
                .onFailure { Log.e(TAG, "Falha ao instanciar IRedeSdk", it) }
                .getOrNull()
                ?.also { instance = it }
        }
    }
}
