package com.bytes.zoovana.cms.zoovana_cms

import android.os.Bundle
import android.view.Window
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Flutter owns the whole screen. Explicitly disable the framework
        // title bar as a safeguard for devices that restore a cached/default
        // Activity theme instead of respecting the NoTitleBar XML parent.
        requestWindowFeature(Window.FEATURE_NO_TITLE)
        super.onCreate(savedInstanceState)
        actionBar?.hide()
    }
}
