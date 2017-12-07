//
//  FBNativeAdCustomView.swift
//  NativeAdsSwift
//
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

import UIKit
import FBAudienceNetwork

class FBNativeAdCustomView: UIView {

    @IBOutlet weak var iconImageView: UIImageView! {
        didSet {
            iconImageView.contentMode = .scaleAspectFit
            iconImageView.clipsToBounds = true
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mediaViewContainer: UIView! {
        didSet {
            mediaViewContainer.clipsToBounds = true
        }
    }
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var adLabel: UILabel!
    @IBOutlet weak var socialLabel: UILabel!
    @IBOutlet weak var ctaLabel: UILabel! {
        didSet {
            ctaLabel.layer.cornerRadius = 5.0
        }
    }
    
    static func view() -> FBNativeAdCustomView {
        let className = String(describing: self)
        return Bundle.main.loadNibNamed(className, owner: nil, options: nil)?.first as! FBNativeAdCustomView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func apply(nativeAd: FBNativeAd, viewController: UIViewController) {
        // アイコン画像
        if let url = nativeAd.icon?.url,
            let data = try? Data(contentsOf: url) {
            iconImageView.image = UIImage(data: data)
        }
        
        // タイトル
        titleLabel.text = nativeAd.title
        
        // FBMediaView
        let mediaView = FBMediaView(frame: CGRect(x: 0, y: 0, width: mediaViewContainer.frame.width, height: mediaViewContainer.frame.height))
        mediaView.nativeAd = nativeAd
        mediaViewContainer.addSubview(mediaView)
        
        // FBMediaViewを使用せず静止画のみ使用する場合
//        let coverImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: mediaViewContainer.frame.width, height: mediaViewContainer.frame.height))
//        coverImageView.clipsToBounds = true
//        if let url = nativeAd.coverImage?.url,
//            let data = try? Data(contentsOf: url) {
//            let image = UIImage(data: data)
//            coverImageView.image = image
//            mediaViewContainer.addSubview(coverImageView)
//        }
        
        // AdChoices（AudienceNetworkの広告オプトアウトへの導線です）
        let adChoices = FBAdChoicesView(nativeAd: nativeAd, expandable: true)
        adChoices.isBackgroundShown = false
        mediaViewContainer.addSubview(adChoices)
        adChoices.updateFrame(fromSuperview: .topRight)
        
        // 本文
        bodyLabel.text = nativeAd.body
        
        // socialContext
        socialLabel.text = nativeAd.socialContext
        
        // CTA
        ctaLabel.text = nativeAd.callToAction
        
        // クリック領域
        let clickableViews:[UIView] = [titleLabel, mediaViewContainer, socialLabel, ctaLabel]
        nativeAd.registerView(forInteraction: self, with: viewController, withClickableViews: clickableViews)
    }
}
