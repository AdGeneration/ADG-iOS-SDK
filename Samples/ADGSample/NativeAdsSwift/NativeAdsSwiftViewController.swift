//
//  NativeAdsSwiftViewController.swift
//  NativeAdsSwift
//
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

import UIKit

import ADG

class NativeAdsSwiftViewController: UIViewController {
    @IBOutlet var adView: UIView!
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
        adg?.addAdContainerView(adView)

        adg?.delegate = self

        // ネイティブ広告パーツ取得を有効
        adg?.usePartsResponse = true

        // インフォメーションアイコンのデフォルト表示
        // デフォルト表示しない場合は必ずADGInformationIconViewの設置を実装してください
        adg?.informationIconViewDefault = false
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
    func adgManagerViewControllerReceiveAd(_ adgManagerViewController: ADGManagerViewController) {
        print("Received an ad.")
    }

    func adgManagerViewControllerReceiveAd(_ adgManagerViewController: ADGManagerViewController,
                                           mediationNativeAd: Any)
    {
        print("Received an ad.")

        var nativeAdView: UIView?
        switch mediationNativeAd {
            case let nativeAd as ADGNativeAd:
                let adgNativeAdView = ADGNativeAdView.view()
                adgNativeAdView.apply(nativeAd: nativeAd, viewController: self)
                nativeAdView = adgNativeAdView
            default:
                return
        }

        if let nativeAdView {
            // ローテーション時に自動的にViewを削除します
            adgManagerViewController.setAutomaticallyRemoveOnReload(nativeAdView)

            adView.addSubview(nativeAdView)
        }
    }

    func adgManagerViewControllerFailed(toReceiveAd adgManagerViewController: ADGManagerViewController,
                                        code: kADGErrorCode)
    {
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
