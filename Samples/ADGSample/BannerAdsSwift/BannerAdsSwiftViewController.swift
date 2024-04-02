//
//  BannerAdsSwiftViewController.swift
//  BannerAdsSwift
//
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

import UIKit
import CoreTelephony
import AdSupport
import AppTrackingTransparency
import ADG

class BannerAdsSwiftViewController: UIViewController {
    
    
    let locationID: String = "48547"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var attButton: UIButton!
    @IBOutlet weak var attStatusLabel: UILabel!
    @IBOutlet weak var adView: UIView!
    private var adg: ADGManagerViewController?
    
    func loadAd() {
        /*
         locationID:  管理画面から払い出された広告枠ID
         adType:      枠サイズ
                      adType_Sp：320x50, adType_Large:320x100,
                      adType_Rect:300x250, adType_Tablet:728x90,
                      adType_Free:自由設定
         rootViewController: 広告を配置するViewController
         */
        adg = ADGManagerViewController(locationID: self.locationID, adType: .adType_Sp, rootViewController: self)
        // test mode 設定
        //adg?.setEnableTestMode(true)
        // geolocation 設定
        //ADGSettings.setGeolocationEnabled(true)
        // in app browser 設定
        //ADGSettings.setEnableInAppBrowser(false)
        // child directed であると指定
        //ADGSettings.setChildDirectedEnabled(true)
        // child directed でないと指定
        //ADGSettings.setChildDirectedEnabled(false)
        // hyper id 設定
        //ADGSettings.setHyperIdEnabled(false)
        adg?.addAdContainerView(self.adView) // 広告Viewを配置するViewを指定
        adg?.delegate = self
        adg?.loadRequest() // 広告リクエスト
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadAd()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.titleLabel?.text = "Swift - 広告枠id: " + self.locationID
        self.reloadATTViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 画面復帰時のローテーション再開
        adg?.resumeRefresh()
    }
    
    func getInfoText() -> String {
        let provider = CTTelephonyNetworkInfo().subscriberCellularProvider
        return """
ADG SDK: v\(ADG_SDK_VERSION)
isHyperIdEnabled: \(ADGSettings.isHyperIdEnabled())
isGeolocationEnabled: \(ADGSettings.isGeolocationEnabled())
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
    
    func reloadATTViews() {
        var newText: String = "エラー"
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
            }
        } else {
            self.attButton.isEnabled = false
            newText = "OS非対応"
        }
        self.attStatusLabel.text = newText
    }
    
    @IBAction func tappedInfo() {
        let alertController = UIAlertController(title: "Info", message: self.getInfoText(), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "閉じる", style: .cancel))
        self.present(alertController, animated: true)
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
        self.reloadATTViews()
        DispatchQueue.main.async {
            self.loadAd()
        }
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
