//
//  ADGNativeAdRectangle.swift
//  ADGNativeSampleForSwift
//
//  Created on 2016/06/10.
//  Copyright © 2016年 Supership. All rights reserved.
//

import UIKit

class ADGNativeAdRectangle: UIView {

    required init(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }

    init (adgManagerViewController: ADGManagerViewController, nativeAd: ADGNativeAd) {
        // 広告を貼り付けるViewを生成
        super.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250))

        // アイコン
        if let urlStr = nativeAd.iconImage?.url,
            let url = URL(string: urlStr),
            let data = try? Data(contentsOf: url) {
                let iconImageView = UIImageView(frame: CGRect(x: 4, y: 6, width: 30, height: 30))
                iconImageView.image = UIImage(data: data)
                self.addSubview(iconImageView)
        }

        // タイトル
        if let adtitle = nativeAd.title?.text, !adtitle.isEmpty {
            let titleLabel = UILabel(frame: CGRect(x: 38, y: 4, width: 258, height: 15))
            titleLabel.text = adtitle;
            titleLabel.numberOfLines = 1
            titleLabel.font = titleLabel.font.withSize(13)
            self.addSubview(titleLabel)
        }

        // 広告マーク
        let adMarkLabel = UILabel(frame: CGRect(x: 38, y: 22, width: 28, height: 14))
        adMarkLabel.text = "AD"
        adMarkLabel.font = adMarkLabel.font.withSize(11)
        adMarkLabel.textColor = UIColor.lightGray
        self.addSubview(adMarkLabel)

        // 本文
        if let adDesc = nativeAd.desc?.value, !adDesc.isEmpty {
            let descLabel = UILabel(frame: CGRect(x: 4, y: 30, width: 296, height: 40))
            descLabel.text = adDesc
            descLabel.numberOfLines = 2
            descLabel.font = descLabel.font.withSize(11)
            descLabel.textColor = UIColor.lightGray
            self.addSubview(descLabel)
        }

        // 広告イメージ
        if let urlStr = nativeAd.mainImage?.url,
            let url = URL(string: urlStr),
            let data = try? Data(contentsOf: url) {
                let imageView = UIImageView(frame: CGRect(x: 0, y: 65, width: 300, height: 156))
                imageView.image = UIImage(data: data)
                imageView.contentMode = UIViewContentMode.scaleAspectFit
                imageView.clipsToBounds = true
                self.addSubview(imageView)
        }

        // スポンサー
        if let adSponsored = nativeAd.sponsored?.value {
            let sponsoredLabel = UILabel(frame: CGRect(x: 4, y: 226, width: 150, height: 20))
            if !(adSponsored.isEmpty) {
                sponsoredLabel.text = "sponsored by " + adSponsored
            } else {
                sponsoredLabel.text = "sponsored"
            }
            sponsoredLabel.numberOfLines = 1
            sponsoredLabel.font = sponsoredLabel.font.withSize(10)
            sponsoredLabel.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
            self.addSubview(sponsoredLabel)
        }

        // CTA
        let adCTA = nativeAd.ctatext?.value ?? "詳しくはこちら"
        let actionButton = UIButton(frame: CGRect(x: 182, y: 223, width: 114, height: 25))
        actionButton.setTitle(adCTA, for: UIControlState())
        actionButton.setTitleColor(UIColor(red: 0.12, green: 0.56, blue: 1.00, alpha: 1.0), for: UIControlState())
        actionButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        actionButton.titleLabel?.adjustsFontSizeToFitWidth = true
        actionButton.titleEdgeInsets = UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
        actionButton.backgroundColor = UIColor.white
        actionButton.layer.borderWidth = 1.0
        actionButton.layer.borderColor = UIColor(red: 0.12, green: 0.56, blue: 1.00, alpha: 1.0).cgColor
        actionButton.layer.cornerRadius = 5.0

        // ボタンへのタップ反応追加
        nativeAd.setTapEvent(actionButton)
        self.addSubview(actionButton)

        // Viewへのタップ制御やローテーション制御
        // 必ず記述してください
        adgManagerViewController.delegateViewManagement(self, nativeAd: nativeAd)
    }
}
