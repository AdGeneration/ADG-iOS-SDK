//
//  InterstitialAdsSwiftViewController.swift
//  InterstitialAdsSwift
//
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

import UIKit
import ADG

class InterstitialAdsSwiftViewController: UIViewController {

    private var interstitial: ADGInterstitial?

    override func viewDidLoad() {
        super.viewDidLoad()

        interstitial = ADGInterstitial()
        interstitial?.setLocationId("48549")    // 管理画面から払い出された広告枠ID
        interstitial?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTapPreloadButton(_ sender: Any) {
        // 広告リクエスト
        interstitial?.preload()
    }

    @IBAction func didTapShowButton(_ sender: Any) {
        // 広告表示
        interstitial?.show()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 広告非表示
        interstitial?.dismiss()
    }

}

extension InterstitialAdsSwiftViewController: ADGInterstitialDelegate {

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

    func adgInterstitialClose() {
        print("Closed interstitial ads")
    }

}
