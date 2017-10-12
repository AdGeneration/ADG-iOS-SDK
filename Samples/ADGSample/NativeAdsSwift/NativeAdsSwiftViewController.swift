//
//  NativeAdsSwiftViewController.swift
//  NativeAdsSwift
//
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

import UIKit
import ADG
import FBAudienceNetwork

class NativeAdsSwiftViewController: UIViewController {

    @IBOutlet weak var adView: UIView!
    private var adg: ADGManagerViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        /*
         locationid:  管理画面から払い出された広告枠ID
         adtype:      枠サイズ kADG_AdType_Free:自由設定
         w:           広告枠横幅
         h:           広告枠高さ
         */
        let params: [String: Any] = [
            "locationid": "48635",
            "adtype": ADGAdType.adType_Sp.rawValue,
            "w": 300,
            "h": 250,
        ]
        
        // HTMLテンプレートを使用したネイティブ広告を表示のためにはadViewを指定する必要があります
        if let adg = ADGManagerViewController(adParams: params, adView: self.adView) {
            adg.delegate = self
        
            // ネイティブ広告パーツ取得を有効
            adg.usePartsResponse = true
            
            // インフォメーションアイコンのデフォルト表示
            // デフォルト表示しない場合は必ずADGInformationIconViewの設置を実装してください
            adg.informationIconViewDefault = false
            
            /*
             Audience Networkを配信する場合は、
             最前面にあるUIViewControllerに対して以下のように設定をおこなってください。
             */
            addChildViewController(adg)
            adg.rootViewController = self;
        
            self.adg = adg
        }
        
        /*
         実機でAudience Networkのテスト広告を表示する場合、
         1. 以下のsetLogLevelメソッドを実行してください
             FBAdSettings.setLogLevel(.notification)
         2. ログに出力されるデバイスハッシュを取得し、addTestDeviceを実行してください
             FBAdSettings.addTestDevice("{device_hash}")
         */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTapLoadRequestButton(_ sender: Any) {
        // 広告リクエスト
        adg?.loadRequest()
    }
}

extension NativeAdsSwiftViewController: ADGManagerViewControllerDelegate {
    
    func adgManagerViewControllerReceiveAd(_ adgManagerViewController: ADGManagerViewController!) {
        print("Received an ad.")
    }
    
    func adgManagerViewControllerReceiveAd(_ adgManagerViewController: ADGManagerViewController!, mediationNativeAd: Any!) {
        print("Received an ad.")
        
        var nativeAdView: UIView?
        switch mediationNativeAd {
        case let nativeAd as ADGNativeAd:
            let adgNativeAdView = ADGNativeAdView.view()
            adgNativeAdView.apply(nativeAd: nativeAd)
            nativeAdView = adgNativeAdView
        case let nativeAd as FBNativeAd:
            let fbNativeAdView = FBNativeAdCustomView.view()
            fbNativeAdView.apply(nativeAd: nativeAd, viewController: self)
            nativeAdView = fbNativeAdView
        default:
            return
        }
        
        if let nativeAdView = nativeAdView {
            // ローテーション時に自動的にViewを削除します
            adgManagerViewController.setAutomaticallyRemoveOnReload(nativeAdView)
            
            adView.addSubview(nativeAdView)
        }
    }
    
    func adgManagerViewControllerFailed(toReceiveAd adgManagerViewController: ADGManagerViewController!, code: kADGErrorCode) {
        print("Failed to receive an ad.")
        // エラー時のリトライは特段の理由がない限り必ず記述するようにしてください。
        switch code {
        case .adgErrorCodeNeedConnection, // ネットワーク不通
        .adgErrorCodeExceedLimit, // エラー多発
        .adgErrorCodeNoAd: // 広告レスポンスなし
            break
        default:
            adgManagerViewController.loadRequest()
        }
    }
}

