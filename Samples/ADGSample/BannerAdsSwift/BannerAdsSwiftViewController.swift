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
         locationID:  管理画面から払い出された広告枠ID
         adType:      枠サイズ
                      adType_Sp：320x50, adType_Large:320x100,
                      adType_Rect:300x250, adType_Tablet:728x90,
                      adType_Free:自由設定
         rootViewController: 広告を配置するViewController
         */
        adg = ADGManagerViewController(locationID: "48547", adType: .adType_Sp, rootViewController: self)
        adg?.addAdContainerView(self.adView) // 広告Viewを配置するViewを指定
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

    func adgManagerViewControllerReceiveAd(_ adgManagerViewController: ADGManagerViewController) {
        print("Received an ad.")
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

    func adgManagerViewControllerDidTapAd(_ adgManagerViewController: ADGManagerViewController) {
        print("Did tap an ad.")
    }
}
