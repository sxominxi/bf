package com.barrier_free

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import android.util.Log

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.barrier_free/tmap"

    companion object{
        private const val TAG = "TMapChannel"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Flutter 메인화면에 보여지는 Android Native View 설정
        flutterEngine.platformViewsController
                .registry
                .registerViewFactory("showTMap", NativeViewFactory(this))

        //chnnel로 직접 전달하기
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.barrier_free/tmap").setMethodCallHandler { call, result ->
            when (call.method) {
                "showTMap" -> {
                    val intent = Intent(this@MainActivity, TMapActivity::class.java)
                    startActivity(intent)
                    result.success("TMap activity 시작")
                }

                "enableTrackingMode" -> {
                    val intent = Intent(this@MainActivity, TMapActivity::class.java).apply {
                        putExtra("enableTrackingMode", true)
                    }
//                    startActivity(intent)
                    result.success("TMap 추적 모드 활성화 요청 날렸음")
                    print(result)
                }

                "setCurrentLocation" -> {
                    val longitude = call.argument<Double>("longitude")
                    val latitude = call.argument<Double>("latitude")

                    Log.d(TAG, "위치 설정: 위도 = $latitude, 경도 = $longitude")
                    val intent = Intent(this@MainActivity, TMapActivity::class.java).apply {
                        putExtra("longitude", longitude)
                        putExtra("latitude", latitude)
                        putExtra("enableTrackingMode", true) // 추적 모드 활성화를 위한 추가 정보
                    }
                    startActivity(intent)
                    result.success("TMap 위치 설정, 활성화 요청 완")
                }

                else -> result.notImplemented()
            }
        }

    }

}
