//
//  FBNativeAdCustomView.swift
//  NativeAdsSwift
//
//  Copyright © 2018年 Supership Inc. All rights reserved.
//

import UIKit
import FBAudienceNetwork

class FBNativeBannerAdCustomView: UIView {
    
    
    @IBOutlet weak var iconViewContainer: UIView! {
        didSet {
            iconViewContainer.clipsToBounds = true
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var socialLabel: UILabel!
    @IBOutlet weak var ctaLabel: UILabel!
    
    static func view() -> FBNativeBannerAdCustomView {
        let className = String(describing: self)
        return Bundle.main.loadNibNamed(className, owner: nil, options: nil)?.first as! FBNativeBannerAdCustomView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.lightGray.cgColor
        iconViewContainer.clipsToBounds = true
    }
    
    func apply(nativeAd: FBNativeBannerAd, viewController: UIViewController) {
        
        // アイコン
        let iconView = FBAdIconView(frame: CGRect(x: 0, y: 0, width: iconViewContainer.frame.width, height: iconViewContainer.frame.height))
        iconViewContainer.addSubview(iconView)
        
        // タイトル
        titleLabel.text = nativeAd.headline
        
        // AdChoices（AudienceNetworkの広告オプトアウトへの導線です）
        let adChoices = FBAdChoicesView(nativeAd: nativeAd, expandable: true)
        adChoices.isBackgroundShown = false
        self.addSubview(adChoices)
        adChoices.updateFrame(fromSuperview: .topLeft)
        
        // socialContext
        socialLabel.text = nativeAd.socialContext
        
        // CTA
        ctaLabel.text = nativeAd.callToAction
        
        // クリック領域
        let clickableViews:[UIView] = [iconViewContainer, titleLabel, socialLabel, ctaLabel]
        nativeAd.registerView(forInteraction: self, iconView: iconView, viewController: viewController, clickableViews: clickableViews)
    }
}
