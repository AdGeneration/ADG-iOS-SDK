//
//  BannerAdsSwiftViewController.swift
//  BannerAdsSwift
//
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

import UIKit
import ADG

class BannerAdsSwiftViewController: UIViewController {

    @IBOutlet weak var adView: UIView!
    private var adg: ADGManagerViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        /*
         locationid:  管理画面から払い出された広告枠ID
         adtype:      枠サイズ
                      adType_Sp：320x50, adType_Large:320x100,
                      adType_Rect:300x250, adType_Tablet:728x90,
                      adType_Free:自由設定
         originx:     広告枠設置起点のx座標(optional)
         originy:     広告枠設置起点のy座標(optional)
         w:           広告枠横幅(kADG_AdType_Freeのとき有効 optional)
         h:           広告枠高さ(kADG_AdType_Freeのとき有効 optional)
         */
        let params: [String: Any] = [
            "locationid": "48547",
            "adtype": ADGAdType.adType_Sp.rawValue,
//            "originx": 0,
//            "originy": 0,
//            "w": 0,
//            "h": 0,
        ]
        adg = ADGManagerViewController(adParams: params, adView: self.adView)
        adg?.delegate = self
        adg?.loadRequest() // 広告リクエスト
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 画面復帰時のローテーション再開
        adg?.resumeRefresh()
    }
    
    deinit {
        // インスタンスの破棄
        adg = nil
    }
}

extension BannerAdsSwiftViewController: ADGManagerViewControllerDelegate {

    func adgManagerViewControllerReceiveAd(_ adgManagerViewController: ADGManagerViewController!) {
        print("Received an ad.")
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

    func adgManagerViewControllerDidTapAd(_ adgManagerViewController: ADGManagerViewController!) {
        print("Did tap an ad.")
    }
}
