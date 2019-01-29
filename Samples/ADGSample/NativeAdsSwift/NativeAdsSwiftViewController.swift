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
         locationID:  管理画面から払い出された広告枠ID
         adType:      枠サイズ kADG_AdType_Free:自由設定
         rootViewController: 広告を配置するViewController
         */
        adg = ADGManagerViewController(locationID: "48635",
                                       adType: .adType_Free,
                                       rootViewController: self)
        
        // HTMLテンプレートを使用したネイティブ広告を表示するためには以下のように配置するViewを指定します
        adg?.adSize = CGSize(width: 300, height: 250)
        adg?.addAdContainerView(self.adView)
        
        adg?.delegate = self
        
        // ネイティブ広告パーツ取得を有効
        adg?.usePartsResponse = true
        
        // インフォメーションアイコンのデフォルト表示
        // デフォルト表示しない場合は必ずADGInformationIconViewの設置を実装してください
        adg?.informationIconViewDefault = false
        
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
    
    deinit {
        // インスタンスの破棄
        adg = nil
    }

    @IBAction func didTapLoadRequestButton(_ sender: Any) {
        // 広告リクエスト
        adg?.loadRequest()
    }
}

extension NativeAdsSwiftViewController: ADGManagerViewControllerDelegate {
    
    func adgManagerViewControllerReceiveAd(_ adgManagerViewController: ADGManagerViewController) {
        print("Received an ad.")
    }
    
    func adgManagerViewControllerReceiveAd(_ adgManagerViewController: ADGManagerViewController, mediationNativeAd: Any) {
        print("Received an ad.")
        
        var nativeAdView: UIView?
        switch mediationNativeAd {
        case let nativeAd as ADGNativeAd:
            let adgNativeAdView = ADGNativeAdView.view()
            adgNativeAdView.apply(nativeAd: nativeAd, viewController: self)
            nativeAdView = adgNativeAdView
        case let nativeAd as FBNativeAd:
            let fbNativeAdView = FBNativeAdCustomView.view()
            fbNativeAdView.apply(nativeAd: nativeAd, viewController: self)
            nativeAdView = fbNativeAdView
        case let nativeAd as FBNativeBannerAd:
            let fbNativeBannerAdView = FBNativeBannerAdCustomView.view()
            fbNativeBannerAdView.apply(nativeAd: nativeAd, viewController: self)
            nativeAdView = fbNativeBannerAdView
        default:
            return
        }
        
        if let nativeAdView = nativeAdView {
            // ローテーション時に自動的にViewを削除します
            adgManagerViewController.setAutomaticallyRemoveOnReload(nativeAdView)
            
            adView.addSubview(nativeAdView)
        }
    }
    
    func adgManagerViewControllerFailed(toReceiveAd adgManagerViewController: ADGManagerViewController, code: kADGErrorCode) {
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

