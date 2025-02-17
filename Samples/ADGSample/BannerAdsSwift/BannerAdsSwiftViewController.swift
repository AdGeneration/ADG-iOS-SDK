//
//  BannerAdsSwiftViewController.swift
//  BannerAdsSwift
//
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

import AdSupport
import AppTrackingTransparency
import CoreTelephony
import UIKit

import ADG

class BannerAdsSwiftViewController: UIViewController {
    let locationIDSp: String = "48547"
    let locationIDRect: String = "48549"

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var attButton: UIButton!
    @IBOutlet var attStatusLabel: UILabel!
    @IBOutlet var adViewSp: UIView!
    @IBOutlet var adViewRect: UIView!
    @IBOutlet var locationIDLabelSp: UILabel!
    @IBOutlet var locationIDLabelRect: UILabel!
    @IBOutlet var testModeLabel: UILabel!

    private var adgSp: ADGManagerViewController?
    private var adgRect: ADGManagerViewController?
    private let testMode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        loadAd()
    }

    override func viewWillAppear(_ animated: Bool) {
        titleLabel.text = "BannerAdsSwift"
        locationIDLabelSp.text = locationIDSp
        locationIDLabelRect.text = locationIDRect
        testModeLabel.text = "Test Mode: \(testMode ? "ON" : "OFF")"
        reloadATTViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 画面復帰時のローテーション再開
        adgSp?.resumeRefresh()
        adgRect?.resumeRefresh()
    }

    @IBAction func tappedInfo() {
        let alertController = UIAlertController(title: "Info", message: getInfoText(),
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "閉じる", style: .cancel))
        present(alertController, animated: true)
    }

    @IBAction func tappedATT() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization {
                _ in
                DispatchQueue.main.async { [weak self] in
                    self?.reloadATTViews()
                }
            }
        }
    }

    @IBAction func tappedAdReload() {
        reloadATTViews()
        DispatchQueue.main.async {
            self.loadAd()
        }
    }
}

extension BannerAdsSwiftViewController: ADGManagerViewControllerDelegate {
    func adgManagerViewControllerReceiveAd(_ adgManagerViewController: ADGManagerViewController) {
        print("Received an ad.")
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

    func adgManagerViewControllerDidTapAd(_ adgManagerViewController: ADGManagerViewController) {
        print("Did tap an ad.")
    }
}

private extension BannerAdsSwiftViewController {
    func initADG(locationID: String, adType: ADGAdType,
                 adView: UIView) -> ADGManagerViewController
    {
        let adg = ADGManagerViewController(locationID: locationID, adType: adType,
                                           rootViewController: self)
        // trueを指定した場合、テストモードが有効になります
        // テストモードのままリリースしないようにご注意ください。配信する広告によっては収益が発生しない場合があります
        adg.isTestModeEnabled = testMode

        // 広告Viewを配置するViewを指定
        adg.addAdContainerView(adView)

        // デリゲートの設定
        adg.delegate = self

        // 広告リクエストの開始
        adg.loadRequest()

        return adg
    }

    func loadAd() {
        /*
         locationID:  管理画面から払い出された広告枠ID
         adType:      枠サイズ
                      adType_Sp:     320x50
                      adType_Large:  320x100
                      adType_Rect:   300x250
                      adType_Tablet: 728x90
                      adType_Free:   自由設定
         rootViewController: 広告を配置するViewController
         */
        adgSp = initADG(locationID: locationIDSp, adType: .adType_Sp, adView: adViewSp)
        adgRect = initADG(locationID: locationIDRect, adType: .adType_Rect, adView: adViewRect)
    }

    func reloadATTViews() {
        var newText = "エラー"
        if #available(iOS 14, *) {
            self.attButton.isEnabled = true
            switch ATTrackingManager.trackingAuthorizationStatus {
                case .authorized:
                    newText = "Authorized"
                case .restricted:
                    newText = "Restricted"
                case .denied:
                    newText = "Denied"
                case .notDetermined:
                    newText = "NotDetermined"
                @unknown default:
                    fatalError()
            }
        } else {
            attButton.isEnabled = false
            newText = "OS非対応"
        }
        attStatusLabel.text = newText
    }

    func getInfoText() -> String {
        let provider = CTTelephonyNetworkInfo().subscriberCellularProvider
        return """
        ADG SDK: v\(ADG_SDK_VERSION)
        enableInAppBrowser: \(ADGSettings.enableInAppBrowser())
        device name: \(UIDevice.current.name)
        system name: \(UIDevice.current.systemName)
        system version: \(UIDevice.current.systemVersion)
        OS model: \(UIDevice.current.model)
        carrier name: \(provider?.carrierName ?? "nil")
        ISO Country code: \(provider?.isoCountryCode ?? "nil")
        PreferredLanguage: \(NSLocale.preferredLanguages.first ?? "nil")
        code: \(NSLocale.current.identifier)
        BundleID: \(Bundle.main.bundleIdentifier ?? "nil")
        ChildDirected: \(ADGSettings.isChildDirectedEnabled())
        IDFA: \(ASIdentifierManager.shared().advertisingIdentifier.uuidString)
        IDFV: \(UIDevice.current.identifierForVendor?.uuidString ?? "nil")
        """
    }
}
