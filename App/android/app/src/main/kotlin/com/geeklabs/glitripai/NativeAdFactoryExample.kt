package com.geeklabs.glitripai

import android.view.LayoutInflater
import android.widget.Button
import android.widget.ImageView
import android.widget.RatingBar
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class NativeAdFactoryExample(
    private val layoutInflater: LayoutInflater
) : GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = layoutInflater.inflate(R.layout.native_ad_layout, null) as NativeAdView

        // 设置广告标题
        val headlineView = adView.findViewById<TextView>(R.id.ad_headline)
        headlineView.text = nativeAd.headline
        adView.headlineView = headlineView

        // 设置广告描述
        val bodyView = adView.findViewById<TextView>(R.id.ad_body)
        bodyView?.text = nativeAd.body
        adView.bodyView = bodyView

        // 设置广告图标
        val iconView = adView.findViewById<ImageView>(R.id.ad_app_icon)
        if (nativeAd.icon != null) {
            iconView?.setImageDrawable(nativeAd.icon?.drawable)
            adView.iconView = iconView
        }

        // 设置广告媒体视图（图片或视频）- 固定120x120dp满足AdMob要求
        val mediaView = adView.findViewById<com.google.android.gms.ads.nativead.MediaView>(R.id.ad_media)
        adView.mediaView = mediaView

        // 设置广告评分
        val starRatingView = adView.findViewById<RatingBar>(R.id.ad_stars)
        if (nativeAd.starRating != null && nativeAd.starRating!! > 0) {
            starRatingView?.rating = nativeAd.starRating!!.toFloat()
            starRatingView?.visibility = android.view.View.VISIBLE
            adView.starRatingView = starRatingView
        } else {
            starRatingView?.visibility = android.view.View.GONE
        }

        // 设置广告操作按钮
        val callToActionView = adView.findViewById<Button>(R.id.ad_call_to_action)
        callToActionView?.text = nativeAd.callToAction
        adView.callToActionView = callToActionView

        // 设置广告商信息
        val advertiserView = adView.findViewById<TextView>(R.id.ad_advertiser)
        if (nativeAd.advertiser != null) {
            advertiserView?.text = nativeAd.advertiser
            advertiserView?.visibility = android.view.View.VISIBLE
            adView.advertiserView = advertiserView
        } else {
            advertiserView?.visibility = android.view.View.GONE
        }

        adView.setNativeAd(nativeAd)

        return adView
    }
}
