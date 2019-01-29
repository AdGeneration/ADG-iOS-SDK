//
//  ADGNativeAdView.swift
//  NativeAdsSwift
//
//  Copyright © 2017年 Supership Inc. All rights reserved.
//
import UIKit
import ADG

class ADGNativeAdView: UIView {
    
    @IBOutlet weak var iconImageView: UIImageView! {
        didSet {
            iconImageView.contentMode = .scaleAspectFit
            iconImageView.clipsToBounds = true
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var mediaViewContainerView: UIView!
    @IBOutlet weak var sponsoredLabel: UILabel!
    @IBOutlet weak var ctaLabel: UILabel! {
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
        return Bundle.main.loadNibNamed(className, owner: nil, options: nil)?.first as! ADGNativeAdView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func apply(nativeAd: ADGNativeAd, viewController: UIViewController) {
        // タイトル
        titleLabel.text = nativeAd.title?.text ?? ""
        
        // リード文
        descriptionLabel.text = nativeAd.desc?.value ?? ""
        
        // アイコン画像
        if let urlStr = nativeAd.iconImage?.url,
            let url = URL(string: urlStr),
            let data = try? Data(contentsOf: url) {
            iconImageView.image = UIImage(data: data)
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
                !sponsoredText.isEmpty {
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
