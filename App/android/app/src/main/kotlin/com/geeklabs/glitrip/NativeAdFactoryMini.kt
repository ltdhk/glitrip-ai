package com.geeklabs.glitrip

import android.view.LayoutInflater
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class NativeAdFactoryMini(
    private val layoutInflater: LayoutInflater
) : GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = layoutInflater.inflate(R.layout.native_ad_layout_mini, null) as NativeAdView

        // 设置广告标题
        val headlineView = adView.findViewById<TextView>(R.id.ad_headline_mini)
        headlineView.text = nativeAd.headline
        adView.headlineView = headlineView

        // 设置广告描述
        val bodyView = adView.findViewById<TextView>(R.id.ad_body_mini)
        bodyView?.text = nativeAd.body
        adView.bodyView = bodyView

        // 设置广告图标
        val iconView = adView.findViewById<ImageView>(R.id.ad_app_icon_mini)
        if (nativeAd.icon != null) {
            iconView?.setImageDrawable(nativeAd.icon?.drawable)
            adView.iconView = iconView
        }

        // 设置广告媒体视图
        val mediaView = adView.findViewById<com.google.android.gms.ads.nativead.MediaView>(R.id.ad_media_mini)
        adView.mediaView = mediaView

        // 设置广告操作按钮
        val callToActionView = adView.findViewById<Button>(R.id.ad_call_to_action_mini)
        callToActionView?.text = nativeAd.callToAction
        adView.callToActionView = callToActionView

        adView.setNativeAd(nativeAd)

        return adView
    }
}

