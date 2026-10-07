package com.paw.tether

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Android 15+ (SDK 35) enforces edge-to-edge. This call makes it
        // explicit (and backports transparent system bars pre-15) so the
        // Flutter UI draws behind status/nav bars and handles insets itself
        // via SafeArea / MediaQuery. Satisfies Play's edge-to-edge check.
        WindowCompat.enableEdgeToEdge(window)
    }
}
