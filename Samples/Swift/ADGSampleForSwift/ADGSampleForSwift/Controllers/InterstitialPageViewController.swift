//
//  InterstitialPageViewController.swift
//  ADGSampleForSwift
//
//  Created on 2016/07/04.
//  Copyright © 2016年 Supership. All rights reserved.
//

import UIKit

class InterstitialPageViewController: UIViewController {
    
    @IBOutlet weak var logTextView: LogTextView!
    fileprivate var adg: ADGInterstitial?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // インスタンスを生成
        adg = ADGInterstitial()
        
        // デリゲートを指定します
        adg?.delegate = self
        
        // 広告枠IDを指定します
        adg?.setLocationId("18031")
        
        // 広告をロードします
        adg?.preload()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        adg?.dismiss()
    }
    
    @IBAction func didTapShowButton(_ sender: AnyObject) {
        adg?.show()
    }
}

extension InterstitialPageViewController: ADGInterstitialDelegate {
    
    /**
     広告の取得に成功した場合に呼び出されます
     - parameter adgManagerViewController: ADGManagerViewController
     */
    func adgManagerViewControllerReceiveAd(_ adgManagerViewController: ADGManagerViewController!) {
        self.logTextView.appendLog("インターステシャル広告をロードしました")
    }
    
    /**
     広告の取得に失敗した場合に呼び出されます
     - parameter adgManagerViewController: ADGManagerViewController
     - parameter code: エラーコード
     */
    func adgManagerViewControllerFailed(toReceiveAd adgManagerViewController: ADGManagerViewController!, code: kADGErrorCode) {
        switch code {
        case .adgErrorCodeNeedConnection:
            self.logTextView.appendLog("エラーが発生しました ネットワーク接続不通")
        case .adgErrorCodeNoAd:
            self.logTextView.appendLog("エラーが発生しました レスポンス無し")
        case .adgErrorCodeReceivedFiller:
            self.logTextView.appendLog("エラーが発生しました 白板検知")
        case .adgErrorCodeCommunicationError:
            self.logTextView.appendLog("エラーが発生しました サーバ間通信エラー")
        case .adgErrorCodeExceedLimit:
            self.logTextView.appendLog("エラーが発生しました エラー多発")
        default:
            self.logTextView.appendLog("エラーが発生しました 不明なエラー")
        }
        
        // ネットワーク不通/エラー多発/広告レスポンスなし 以外はリトライしてください
        switch code {
        case .adgErrorCodeNeedConnection, .adgErrorCodeExceedLimit, .adgErrorCodeNoAd:
            break
        default:
            adg?.preload()
        }
    }
    
    /**
     広告をタップした際に呼び出されます
     - parameter adgManagerViewController: ADGManagerViewController
     */
    func adgManagerViewControllerOpenUrl(_ adgManagerViewController: ADGManagerViewController!) {
        self.logTextView.appendLog("インターステシャル広告をタップしました")
    }
    
    /**
     インターステシャル広告を閉じた際に呼び出されます
     */
    func adgInterstitialClose() {
        self.logTextView.appendLog("インターステシャル広告を閉じました")
    }
}
