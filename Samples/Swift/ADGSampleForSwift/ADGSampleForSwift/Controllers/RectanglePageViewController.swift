//
//  RectanglePageViewController.swift
//  ADGSampleForSwift
//
//  Created on 2016/07/04.
//  Copyright © 2016年 Supership. All rights reserved.
//

import UIKit

class RectanglePageViewController: UIViewController {

    @IBOutlet weak var adView: UIView!
    @IBOutlet weak var logTextView: LogTextView!
    fileprivate var adg: ADGManagerViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        /*
         locationid: 管理画面から払い出された広告枠ID
         adtype: 管理画面にて入力した枠サイズ
         - Sp(0): 320x50,
         - Large(1): 320x100,
         - Rect(2): 300x250,
         - Tablet(3): 728x90,
         - Free(4): フリー
         originx: 広告枠設置起点のx座標
         originy: 広告枠設置起点のy座標
         w: 広告枠横幅（adtype Freeのとき有効）
         h: 広告枠高さ（adtype Freeのとき有効）
         */
        let adgParam: [String: Any] = [
            "locationid": "18031",
            "adtype": ADGAdType(2).rawValue,
            "originx": 0,
            "originy": 0,
            "w": 0,
            "h": 0
        ]

        // インスタンスを生成
        adg = ADGManagerViewController(adParams: adgParam, adView: self.adView)

        // デリゲートを指定します
        adg?.delegate = self

        // falseを指定すると白板の場合にADGManagerViewControllerFailedToReceiveAdを呼び出されます
        adg?.setFillerRetry(false)

        // 広告をリクエストします
        adg?.loadRequest()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        adg?.resumeRefresh()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        adg?.pauseRefresh()
    }

    @IBAction func didTapRefreshButton(_ sender: AnyObject) {
        adg?.loadRequest()
    }
}

extension RectanglePageViewController: ADGManagerViewControllerDelegate {

    /**
     広告の取得に成功した場合に呼び出されます
     - parameter adgManagerViewController: ADGManagerViewController
     */
    func adgManagerViewControllerReceiveAd(_ adgManagerViewController: ADGManagerViewController!) {
        self.logTextView.appendLog("バナー広告をロードしました")
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
            adgManagerViewController.loadRequest()
        }
    }
}
