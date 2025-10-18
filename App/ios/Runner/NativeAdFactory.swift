import Foundation
import google_mobile_ads
import GoogleMobileAds
import UIKit

class NativeAdFactory: NSObject, FLTNativeAdFactory {
    
    func createNativeAd(_ nativeAd: NativeAd,
                       customOptions: [AnyHashable: Any]? = nil) -> NativeAdView? {
        
        // 创建 NativeAdView - 设置明确的大小，确保足够容纳所有元素
        let adView = NativeAdView()
        adView.frame = CGRect(x: 0, y: 0, width: 359, height: 167)
        adView.backgroundColor = .white
        adView.clipsToBounds = true
        
        // 添加广告标识（放在最上方）
        let adBadge = UILabel()
        adBadge.frame = CGRect(x: 8, y: 4, width: 20, height: 14)
        adBadge.text = "Ad"
        adBadge.font = UIFont.boldSystemFont(ofSize: 8)
        adBadge.textColor = UIColor(red: 0.0, green: 0.737, blue: 0.831, alpha: 1.0)
        adBadge.backgroundColor = UIColor(red: 0.878, green: 0.969, blue: 0.980, alpha: 1.0)
        adBadge.textAlignment = .center
        adBadge.clipsToBounds = true
        adView.addSubview(adBadge)
        
        // 创建标题标签
        let headlineLabel = UILabel()
        headlineLabel.frame = CGRect(x: 8, y: 22, width: 193, height: 40)
        headlineLabel.font = UIFont.boldSystemFont(ofSize: 13)
        headlineLabel.numberOfLines = 2
        headlineLabel.text = nativeAd.headline
        headlineLabel.clipsToBounds = true
        adView.addSubview(headlineLabel)
        adView.headlineView = headlineLabel
        
        // 创建描述标签
        let bodyLabel = UILabel()
        bodyLabel.frame = CGRect(x: 8, y: 66, width: 193, height: 28)
        bodyLabel.font = UIFont.systemFont(ofSize: 11)
        bodyLabel.textColor = .darkGray
        bodyLabel.numberOfLines = 2
        bodyLabel.text = nativeAd.body
        bodyLabel.clipsToBounds = true
        adView.addSubview(bodyLabel)
        adView.bodyView = bodyLabel
        
        // 创建图标
        let iconView = UIImageView()
        iconView.frame = CGRect(x: 8, y: 98, width: 20, height: 20)
        iconView.contentMode = .scaleAspectFit
        iconView.clipsToBounds = true
        if let icon = nativeAd.icon {
            iconView.image = icon.image
        }
        adView.addSubview(iconView)
        adView.iconView = iconView
        
        // 创建操作按钮
        let ctaButton = UIButton(type: .system)
        ctaButton.frame = CGRect(x: 8, y: 124, width: 90, height: 30)
        ctaButton.setTitle(nativeAd.callToAction ?? "Install", for: .normal)
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.backgroundColor = UIColor(red: 0.0, green: 0.737, blue: 0.831, alpha: 1.0)
        ctaButton.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        ctaButton.layer.cornerRadius = 4
        ctaButton.clipsToBounds = true
        adView.addSubview(ctaButton)
        adView.callToActionView = ctaButton
        
        // 创建媒体视图 - 确保完全在边界内
        let mediaView = MediaView()
        mediaView.frame = CGRect(x: 209, y: 22, width: 142, height: 133)
        mediaView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        mediaView.clipsToBounds = true
        mediaView.mediaContent = nativeAd.mediaContent
        adView.addSubview(mediaView)
        adView.mediaView = mediaView
        
        // 设置广告
        adView.nativeAd = nativeAd
        
        return adView
    }
}
