//
//  RectanglePageViewController.swift
//  ADGNativeSampleForSwift
//
//  Created on 2016/06/10.
//  Copyright © 2016年 Supership. All rights reserved.
//

import UIKit
import FBAudienceNetwork

class RectanglePageViewController: UIViewController {
    
    @IBOutlet weak var adView: UIView!
    @IBOutlet weak var logTextView: UITextView!
    var rectAd: ADGNativeAdRectangle?
    
    fileprivate var adg: ADGManagerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (adg == nil) {
            let adgParam = [
                "locationid": "32792",
                "adtype": String(ADGAdType.free.rawValue),
                "originx": "0",
                "originy": "0",
                "w": "300",
                "h": "250"
            ]
            
            if let adgManagerViewController = ADGManagerViewController(adParams: adgParam, adView: adView) {
                adgManagerViewController.delegate = self
                adgManagerViewController.usePartsResponse = true
                adgManagerViewController.setFillerRetry(false)
                
                // == Facebook Audience Networkの場合の設定 ==
                // Facebook Audience Networkの広告表示には、
                // FBAudienceNetwork.frameworkとFBAudienceNetwork.frameworkに必要なframeworkを追加する必要があります。
                // 詳しくはマニュアルを参照してください。
                
                // 広告タップ時のアプリ内ブラウザ起動」「動画のインビュー判定」のため、最前面にあるUIRootViewControllerをセットしてください。
                adgManagerViewController.rootViewController = self
                
                // 実機でFANのテスト広告を表示する場合以下のメソッドを実行してください。
                // FBAdSettings.addTestDevice("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
                // == Facebook Audience Networkの場合の設定 ==
                adgManagerViewController.loadRequest()
                adg = adgManagerViewController
                
            }
        } else {
            rectAd?.adgVideoView?.play()
            adg?.resumeRefresh()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        adg?.pauseRefresh()
        rectAd?.adgVideoView?.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func appendLog(_ log: String) {
        self.logTextView.text.append(Log.format(log))
    }
    
    @IBAction func didTapRefreshButton(_ sender: AnyObject) {
        adg?.loadRequest()
    }
}

extension RectanglePageViewController: ADGManagerViewControllerDelegate {
    /**
     バナー広告の取得に成功した場合に呼び出されます
     */
    func adgManagerViewControllerReceiveAd(_ adgManagerViewController: ADGManagerViewController!) {
        appendLog("バナー広告をロードしました \(adgManagerViewController.locationid ?? "")")
    }
    
    /**
     ネイティブ広告の取得に成功した場合に呼び出されます
     - parameter adgManagerViewController: ADGManagerViewController
     - parameter mediationNativeAd: ネイティブ広告のインスタンス
     */
    func adgManagerViewControllerReceiveAd(_ adgManagerViewController: ADGManagerViewController!, mediationNativeAd: Any!) {
        appendLog("ネイティブ広告をロードしました \(adgManagerViewController.locationid ?? "")")
        
        if let nativeAd = mediationNativeAd as? ADGNativeAd {
            let rectAd = ADGNativeAdRectangle(adgManagerViewController: adgManagerViewController, nativeAd: nativeAd)
            self.rectAd = rectAd
            adView.addSubview(rectAd)
            
        } else if let nativeAd = mediationNativeAd as? FBNativeAd {
            let rectAd = FBNativeAdRectangle(adgManagerViewController: adgManagerViewController, nativeAd: nativeAd, rootViewController: self)
            adView.addSubview(rectAd)
        }
    }
    
    /**
     広告の取得に失敗した場合に呼び出されます
     - parameter adgManagerViewController: ADGManagerViewController
     - parameter code: エラーコード
     */
    func adgManagerViewControllerFailed(toReceiveAd adgManagerViewController: ADGManagerViewController!, code: kADGErrorCode) {
        switch code {
        case .adgErrorCodeNeedConnection:
            appendLog("エラーが発生しました ネットワーク接続不通 \(adgManagerViewController.locationid ?? "")")
        case .adgErrorCodeNoAd:
            appendLog("エラーが発生しました レスポンス無し \(adgManagerViewController.locationid ?? "")")
        case .adgErrorCodeReceivedFiller:
            appendLog("エラーが発生しました 白板検知 \(adgManagerViewController.locationid ?? "")")
        case .adgErrorCodeCommunicationError:
            appendLog("エラーが発生しました サーバ間通信エラー \(adgManagerViewController.locationid ?? "")")
        case .adgErrorCodeExceedLimit:
            appendLog("エラーが発生しました エラー多発 \(adgManagerViewController.locationid ?? "")")
        default:
            appendLog("エラーが発生しました 不明なエラー \(adgManagerViewController.locationid ?? "")")
        }
        
        // 不通とエラー過多のとき以外はリトライしてください
        switch code {
        case .adgErrorCodeNeedConnection, .adgErrorCodeExceedLimit, .adgErrorCodeNoAd:
            break
        default:
            adgManagerViewController.loadRequest()
        }
    }
}
