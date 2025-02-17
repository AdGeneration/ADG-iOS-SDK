//
//  ADGNativeAdView.swift
//  NativeAdsSwift
//
//  Copyright © 2017年 Supership Inc. All rights reserved.
//
import UIKit

import ADG

class ADGNativeAdView: UIView {
    @IBOutlet var iconImageView: UIImageView! {
        didSet {
            iconImageView.contentMode = .scaleAspectFit
            iconImageView.clipsToBounds = true
        }
    }

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var mediaViewContainerView: UIView!
    @IBOutlet var sponsoredLabel: UILabel!
    @IBOutlet var ctaLabel: UILabel! {
        didSet {
            ctaLabel.backgroundColor = UIColor.white
            ctaLabel.clipsToBounds = true
            ctaLabel.textColor = ctaLabel.tintColor
            ctaLabel.layer.borderWidth = 1.0
            ctaLabel.layer.borderColor = ctaLabel.tintColor.cgColor
            ctaLabel.layer.cornerRadius = 5.0
        }
    }

    static func view() -> ADGNativeAdView {
        let className = String(describing: self)
        return Bundle.main.loadNibNamed(className, owner: nil, options: nil)?
            .first as! ADGNativeAdView
    }

    func apply(nativeAd: ADGNativeAd, viewController: UIViewController) {
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.lightGray.cgColor

        // タイトル
        titleLabel.text = nativeAd.title?.text ?? ""

        // リード文
        descriptionLabel.text = nativeAd.desc?.value ?? ""

        // アイコン画像
        if let urlStr = nativeAd.iconImage?.url,
           let url = URL(string: urlStr)
        {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async { [weak self] in
                        self?.iconImageView.image = UIImage(data: data)
                    }
                }
            }
        }

        // メイン画像・動画
        mediaViewContainerView.subviews.forEach {
            $0.removeFromSuperview()
        }

        if nativeAd.canLoadMedia {
            let frame = CGRect(x: 0, y: 0,
                               width: mediaViewContainerView.bounds.size.width,
                               height: mediaViewContainerView.bounds.size.height)
            let mediaView = ADGMediaView(frame: frame)
            mediaView.nativeAd = nativeAd
            mediaView.viewController = viewController
            mediaViewContainerView.addSubview(mediaView)
            mediaView.load()
        }

        // インフォメーションアイコン
        let infoIconView = ADGInformationIconView(nativeAd: nativeAd)
        mediaViewContainerView.addSubview(infoIconView)
        infoIconView.updateFrame(fromSuperview: .topRight)

        // 広告主
        if let sponsoredText = nativeAd.sponsored?.value,
           !sponsoredText.isEmpty
        {
            sponsoredLabel.text = "sponsored by \(sponsoredText)"
        } else {
            sponsoredLabel.text = "sponsored"
        }

        // CTAボタン
        if let ctaText = nativeAd.ctatext?.value {
            ctaLabel.text = ctaText.isEmpty ? ctaText : "詳しくはこちら"
        }

        // クリックイベント
        nativeAd.setTapEvent(self, handler: nil)
    }
}
