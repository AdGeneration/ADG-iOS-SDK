//
//  FBNativeAdRectangle.swift
//  ADGNativeSampleForSwift
//
//  Created on 2016/06/13.
//  Copyright © 2016年 Supership. All rights reserved.
//

import UIKit
import FBAudienceNetwork

class FBNativeAdRectangle: UIView {
    
    var clickableViews: [UIView] = []
    
    required init(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    init(adgManagerViewController: ADGManagerViewController, nativeAd: FBNativeAd, rootViewController: UIViewController) {
        // 広告を貼り付けるViewを生成
        super.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250))
        
        // アイコン
        if let adIcon = nativeAd.icon {
            if let iconImageData = try? Data(contentsOf: adIcon.url) {
                let iconImageView = UIImageView(frame: CGRect(x: 4, y: 2, width: 30, height: 30))
                iconImageView.image = UIImage(data: iconImageData)
                self.addSubview(iconImageView)
            }
        }
        
        // タイトル
        if let adTitle = nativeAd.title {
            let titleLabel = UILabel(frame: CGRect(x: 38, y: 2, width: 258, height: 30))
            titleLabel.text = adTitle;
            titleLabel.baselineAdjustment = UIBaselineAdjustment.alignCenters
            titleLabel.numberOfLines = 1
            titleLabel.font = titleLabel.font.withSize(16)
            titleLabel.textColor = UIColor.black
            self.addSubview(titleLabel)
            clickableViews.append(titleLabel)
        }
        
        
        // 広告イメージ
        let adMedia = FBMediaView(frame: CGRect(x: 0, y: 34, width: 300, height: 157))
        adMedia.nativeAd = nativeAd
        adMedia.clipsToBounds = true
        self.addSubview(adMedia)
        clickableViews.append(adMedia)
        
        // Ad Choices(FANの広告オプトアウトへの導線です)
        let adChoices = FBAdChoicesView(nativeAd: nativeAd, expandable: true)
        adChoices.isBackgroundShown = false
        adMedia.addSubview(adChoices)
        adChoices.updateFrame(fromSuperview: UIRectCorner.topRight)
        
        /*
         静止画のみのコード例
         静止画のみのときはnativeAd.coverImage.urlを元にUIImageを生成する
         */
//        if let adImage = nativeAd.coverImage {
//            if let imageData = try? Data(contentsOf: adImage.url) {
//                let image = UIImage(data: imageData)
//                let imageView = UIImageView(frame: CGRect(x: 0, y: 65, width: 300, height: 156))
//                imageView.clipsToBounds = true
//                imageView.image = image
//                self.addSubview(imageView)
//                clickableViews.append(imageView)
//                
//                let adChoices = FBAdChoicesView(nativeAd: nativeAd)
//                adChoices.isBackgroundShown = false
//                imageView.addSubview(adChoices)
//                adChoices.updateFrame(fromSuperview: UIRectCorner.topRight)
//            }
//        }
        
        // 本文
        if let adDesc = nativeAd.body {
            let descLabel = UILabel(frame: CGRect(x: 4, y: 192, width: 296, height: 30))
            descLabel.text = adDesc
            descLabel.numberOfLines = 2
            descLabel.font = descLabel.font.withSize(11)
            descLabel.textColor = UIColor.black
            self.addSubview(descLabel)
        }
        
        // 広告マーク
        let adMarkLabel = UILabel(frame: CGRect(x: 4, y: 225, width: 28, height: 20))
        adMarkLabel.text = "AD";
        adMarkLabel.backgroundColor = UIColor.orange
        adMarkLabel.textAlignment = NSTextAlignment.center
        adMarkLabel.font = adMarkLabel.font.withSize(11)
        adMarkLabel.textColor = UIColor.white
        self.addSubview(adMarkLabel)
        
        // social context
        if let adSocial = nativeAd.socialContext {
            let socialLabel = UILabel(frame: CGRect(x: 38, y: 226, width: 100, height: 20))
            socialLabel.text = adSocial
            socialLabel.numberOfLines = 1
            socialLabel.font = socialLabel.font.withSize(10)
            socialLabel.textColor = UIColor.black
            self.addSubview(socialLabel)
            clickableViews.append(socialLabel)
        }
        
        // CTA
        if let adCTA = nativeAd.callToAction {
            let ctaMainColor = UIColor(red: 0.20, green: 0.80, blue: 0.40, alpha: 1.0)
            let actionButton = UIButton(frame: CGRect(x: 150, y: 223, width: 144, height: 25))
            actionButton.setTitle(adCTA, for: UIControlState())
            actionButton.setTitleColor(UIColor.white, for: UIControlState())
            actionButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
            actionButton.titleLabel?.numberOfLines = 1
            actionButton.titleLabel?.lineBreakMode = NSLineBreakMode.byTruncatingTail
            actionButton.titleEdgeInsets = UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
            actionButton.backgroundColor = ctaMainColor
            actionButton.layer.borderWidth = 1.0
            actionButton.layer.borderColor = ctaMainColor.cgColor
            actionButton.layer.cornerRadius = 5.0
            
            self.addSubview(actionButton)
            clickableViews.append(actionButton)
        }
        
        // クリック領域の指定。
        // 詳細はリファレンスのregisterViewForInteractionを参照。
        // https://developers.facebook.com/docs/reference/ios/current/class/FBNativeAd/
        nativeAd.registerView(forInteraction: self, with: rootViewController, withClickableViews: clickableViews)
        
        // ViewのADGManagerViewControllerクラスインスタンスへのセット（ローテーション時等の破棄制御並びに表示のため）
        adgManagerViewController.delegateViewManagement(self)
    }
}
