//
//  ADGNativeAdTableViewCellContent.swift
//  ADGNativeSampleForSwift
//
//  Created on 2016/10/17.
//  Copyright © 2016年 Supership. All rights reserved.
//

import UIKit
import FBAudienceNetwork
import Kingfisher

class ADGNativeAdTableViewCellContent: UIView {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var sponsoredLabel: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
        
    override func awakeFromNib() {
        iconImageView.image = nil
        titleLabel.text = nil
        descriptionLabel.text = nil
        sponsoredLabel.text = nil
        mainImageView.image = nil
        mainImageView.subviews.forEach{ $0.removeFromSuperview()}
    }
    
    func setADGNativeAd(_ adgManagerViewController: ADGManagerViewController, adgNativeAd: ADGNativeAd) {
        
        // アイコン
        if let urlStr = adgNativeAd.iconImage?.url, let url = URL(string: urlStr) {
            iconImageView.kf.setImage(with: url)
        }
        
        // タイトル
        if let adTitle = adgNativeAd.title?.text, !adTitle.isEmpty {
            titleLabel.text = adTitle;
        }
        
        // 本文
        if let adDesc = adgNativeAd.desc?.value, !adDesc.isEmpty {
            descriptionLabel.text = adDesc
        }
        
        // 広告イメージ
        if let urlStr = adgNativeAd.mainImage?.url, let url = URL(string: urlStr) {
            mainImageView.kf.setImage(with: url)
        } else if let urlStr = adgNativeAd.iconImage?.url, let url = URL(string: urlStr) {
            mainImageView.kf.setImage(with: url)
        }
        
        // スポンサー
        if let adSponsored = adgNativeAd.sponsored?.value {
            if !adSponsored.isEmpty {
                sponsoredLabel.text = "sponsored by " + adSponsored
            } else {
                sponsoredLabel.text = "sponsored"
            }
        }
                
        // Viewへのタップ制御やローテーション制御
        // 必ず記述してください
        adgManagerViewController.delegateViewManagement(self, nativeAd: adgNativeAd)
    }
    
    func setFBNativeAd(_ adgManagerViewController: ADGManagerViewController, fbNativeAd: FBNativeAd, rootViewController: UIViewController) {
        
        // アイコン
        if let icon = fbNativeAd.icon {
            iconImageView.kf.setImage(with: icon.url)
        }
        
        // タイトル
        if let title = fbNativeAd.title {
            titleLabel.text = title
        }
        
        // 本文
        if let desc = fbNativeAd.body {
            descriptionLabel.text = desc
        }
        
        // 広告イメージ
        let fbMedia = FBMediaView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        fbMedia.nativeAd = fbNativeAd
        fbMedia.clipsToBounds = true
        mainImageView.addSubview(fbMedia)
        
        // Ad Choices
        let adChoices = FBAdChoicesView(nativeAd: fbNativeAd, expandable: true)
        adChoices.isBackgroundShown = false
        fbMedia.addSubview(adChoices)
        adChoices.updateFrame(fromSuperview: UIRectCorner.topRight)
        
        // social context
        if let social = fbNativeAd.socialContext {
            sponsoredLabel.text = social
        }
        
        // クリック領域の指定。詳細はリファレンスのregisterViewForInteractionを参照。
        // https://developers.facebook.com/docs/reference/ios/current/class/FBNativeAd/
        fbNativeAd.registerView(forInteraction: self, with: rootViewController, withClickableViews: [iconImageView, titleLabel, descriptionLabel, mainImageView])
        
        // Viewへのタップ制御やローテーション制御
        // 必ず記述してください
        adgManagerViewController.delegateViewManagement(self)
    }
    
}
