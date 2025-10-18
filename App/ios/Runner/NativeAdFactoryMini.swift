import Foundation
import google_mobile_ads
import GoogleMobileAds
import UIKit

class NativeAdFactoryMini: NSObject, FLTNativeAdFactory {
    
    func createNativeAd(_ nativeAd: NativeAd,
                       customOptions: [AnyHashable: Any]? = nil) -> NativeAdView? {
        
        // 创建小尺寸 NativeAdView - 调整高度以容纳120x120的媒体视图
        let adView = NativeAdView()
        adView.frame = CGRect(x: 0, y: 0, width: 343, height: 128)
        adView.backgroundColor = .white
        adView.clipsToBounds = true
        
        // 添加广告标识（左上角小标签）
        let adBadge = UILabel()
        adBadge.frame = CGRect(x: 4, y: 2, width: 16, height: 12)
        adBadge.text = "Ad"
        adBadge.font = UIFont.boldSystemFont(ofSize: 7)
        adBadge.textColor = UIColor(red: 0.0, green: 0.737, blue: 0.831, alpha: 1.0)
        adBadge.backgroundColor = UIColor(red: 0.878, green: 0.969, blue: 0.980, alpha: 1.0)
        adBadge.textAlignment = .center
        adBadge.clipsToBounds = true
        adView.addSubview(adBadge)
        
        // 创建图标（小圆形）
        let iconView = UIImageView()
        iconView.frame = CGRect(x: 8, y: 18, width: 40, height: 40)
        iconView.contentMode = .scaleAspectFit
        iconView.clipsToBounds = true
        iconView.layer.cornerRadius = 4
        if let icon = nativeAd.icon {
            iconView.image = icon.image
        }
        adView.addSubview(iconView)
        adView.iconView = iconView
        
        // 创建标题标签（单行）
        let headlineLabel = UILabel()
        headlineLabel.frame = CGRect(x: 56, y: 16, width: 155, height: 18)
        headlineLabel.font = UIFont.boldSystemFont(ofSize: 12)
        headlineLabel.numberOfLines = 1
        headlineLabel.text = nativeAd.headline
        headlineLabel.clipsToBounds = true
        adView.addSubview(headlineLabel)
        adView.headlineView = headlineLabel
        
        // 创建描述标签（单行，小字）
        let bodyLabel = UILabel()
        bodyLabel.frame = CGRect(x: 56, y: 36, width: 155, height: 14)
        bodyLabel.font = UIFont.systemFont(ofSize: 10)
        bodyLabel.textColor = .darkGray
        bodyLabel.numberOfLines = 1
        bodyLabel.text = nativeAd.body
        bodyLabel.clipsToBounds = true
        adView.addSubview(bodyLabel)
        adView.bodyView = bodyLabel
        
        // 创建操作按钮（小按钮）
        let ctaButton = UIButton(type: .system)
        ctaButton.frame = CGRect(x: 8, y: 64, width: 70, height: 20)
        ctaButton.setTitle(nativeAd.callToAction ?? "Install", for: .normal)
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.backgroundColor = UIColor(red: 0.0, green: 0.737, blue: 0.831, alpha: 1.0)
        ctaButton.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        ctaButton.layer.cornerRadius = 3
        ctaButton.clipsToBounds = true
        adView.addSubview(ctaButton)
        adView.callToActionView = ctaButton
        
        // 创建媒体视图 - 调整为120x120以满足AdMob要求
        let mediaView = MediaView()
        mediaView.frame = CGRect(x: 219, y: 4, width: 120, height: 120)
        mediaView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        mediaView.clipsToBounds = true
        mediaView.layer.cornerRadius = 4
        mediaView.mediaContent = nativeAd.mediaContent
        adView.addSubview(mediaView)
        adView.mediaView = mediaView
        
        // 设置广告
        adView.nativeAd = nativeAd
        
        return adView
    }
}
