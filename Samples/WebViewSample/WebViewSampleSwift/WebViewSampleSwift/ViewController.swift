//
//  ViewController.m
//
//  Created by Supership.inc on 2024/08/09.
//  Copyright © 2024 Supership Inc. All rights reserved.
//

import AdSupport
import AppTrackingTransparency
import SafariServices
import UIKit
import WebKit

let USE_LOCAL = true // localファイルを利用してテストするか
let LOAD_URL = "https://*****/" // テストで利用する外部のURL
let ALL_ZERO_UUID = "00000000-0000-0000-0000-000000000000"

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    var webView: WKWebView!
    var userContentController: WKUserContentController!
    var backButton: UIButton!
    var nextButton: UIButton!
    var reloadButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureWebView()
        layoutView()

        if USE_LOCAL {
            // テストのためにローカルファイルを閲覧
            if let url = Bundle.main.url(forResource: "test", withExtension: "html") {
                webView.loadFileURL(url, allowingReadAccessTo: url)
            }
        } else {
            if let url = URL(string: LOAD_URL) {
                let request = URLRequest(url: url)
                webView.load(request)
            }
        }
    }

    func configureWebView() {
        let configuration = WKWebViewConfiguration()

        // インライン再生を許可
        configuration.allowsInlineMediaPlayback = true
        // すべてのメディアについてユーザインタラクションなしの自動再生を許可
        configuration.mediaTypesRequiringUserActionForPlayback = []

        // jsのコンテンツを差し込むことで、idfaやappbundleをjsから取得できるようにする
        userContentController = WKUserContentController()
        configuration.userContentController = userContentController

        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self

        // web inspectorでデバックできるようにする
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
    }

    func layoutView() {
        webView.translatesAutoresizingMaskIntoConstraints = false

        // カスタムの戻るボタンを作成
        backButton = UIButton(type: .system)
        backButton.setTitle("Back", for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(tappedBackButton), for: .touchUpInside)
        view.addSubview(backButton)
        NSLayoutConstraint
            .activate([backButton.bottomAnchor
                    .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                constant: -20),
                backButton.leftAnchor.constraint(equalTo: view.leftAnchor,
                                                 constant: 20),
                backButton.heightAnchor.constraint(equalToConstant: 50),
                backButton.widthAnchor.constraint(equalToConstant: 100)])

        // 進むボタンを作成
        nextButton = UIButton(type: .system)
        nextButton.setTitle("Next", for: .normal)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addTarget(self, action: #selector(tappedNextButton), for: .touchUpInside)
        view.addSubview(nextButton)
        NSLayoutConstraint
            .activate([nextButton.bottomAnchor
                    .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                constant: -20),
                nextButton.leftAnchor
                    .constraint(equalTo: backButton.rightAnchor,
                                constant: 5),
                nextButton.heightAnchor.constraint(equalToConstant: 50),
                nextButton.widthAnchor.constraint(equalToConstant: 100)])

        // Reloadボタンを作成
        reloadButton = UIButton(type: .system)
        reloadButton.setTitle("Reload", for: .normal)
        reloadButton.translatesAutoresizingMaskIntoConstraints = false
        reloadButton.addTarget(self, action: #selector(tappedReloadButton), for: .touchUpInside)
        view.addSubview(reloadButton)
        NSLayoutConstraint
            .activate([reloadButton.bottomAnchor
                    .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                constant: -20),
                reloadButton.rightAnchor.constraint(equalTo: view.rightAnchor,
                                                    constant: -20),
                reloadButton.heightAnchor.constraint(equalToConstant: 50),
                reloadButton.widthAnchor.constraint(equalToConstant: 100)])

        view.addSubview(webView)

        NSLayoutConstraint
            .activate([webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                       webView.leftAnchor.constraint(equalTo: view.leftAnchor),
                       webView.bottomAnchor.constraint(equalTo: nextButton.topAnchor,
                                                       constant: -1),
                       webView.rightAnchor.constraint(equalTo: view.rightAnchor)])
    }

    @objc func tappedBackButton() {
        webView.goBack()
    }

    @objc func tappedNextButton() {
        webView.goForward()
    }

    @objc func tappedReloadButton() {
        clearCacheAndReload()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if #available(iOS 14.0, *) {
            // iOS 14 以降では AppTrackingTransparency を利用して IDFA 取得に関する判定をする
            ATTrackingManager.requestTrackingAuthorization { status in
                let statusString: String
                switch status {
                    case .denied:
                        statusString = "ATTrackingManagerAuthorizationStatusDenied"
                    case .authorized:
                        statusString = "ATTrackingManagerAuthorizationStatusAuthorized"
                    case .restricted:
                        statusString = "ATTrackingManagerAuthorizationStatusRestricted"
                    case .notDetermined:
                        statusString = "ATTrackingManagerAuthorizationStatusNotDetermined"
                    @unknown default:
                        statusString = "unknown"
                }

                print("ATT status: \(statusString)")
            }
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 戻る、進むボタンの有効化
        DispatchQueue.main.async {
            self.backButton.isEnabled = self.webView.canGoBack
            self.backButton.alpha = self.webView.canGoBack ? 1.0 : 0.4
            self.nextButton.isEnabled = self.webView.canGoForward
            self.nextButton.alpha = self.webView.canGoForward ? 1.0 : 0.4
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        // URL遷移時に呼ばれる
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        let currentDomain = webView.url?.host
        let targetDomain = url.host

        if handleClick(url: url, currentDomain: currentDomain, targetDomain: targetDomain,
                       navigationAction: navigationAction)
        {
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView?
    {
        // window.openの時などに呼ばれる
        print("createWebViewWithConfiguration")
        guard let url = navigationAction.request.url else {
            return nil
        }
        let currentDomain = webView.url?.host
        let targetDomain = url.host

        if handleClick(url: url, currentDomain: currentDomain, targetDomain: targetDomain,
                       navigationAction: navigationAction)
        {
            print("URL opened in SFSafariViewController.")
        }
        return nil
    }

    func handleClick(url: URL, currentDomain: String?, targetDomain: String?,
                     navigationAction: WKNavigationAction) -> Bool
    {
        // http(s) 以外のプロトコル: 他のアプリへ移動する場合
        if !url.absoluteString.hasPrefix("http://") && !url.absoluteString
            .hasPrefix("https://") && UIApplication.shared.canOpenURL(url)
        {
            print("NOT HTTP/HTTPS : \(url.absoluteString)")
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return true
        }

        guard let currentDomain, let targetDomain else {
            return false
        }

        // hrefが指定された場合、新しいwindowで開こうとしている場合
        // 現在のドメインとは別のドメインのページを開こうとしている場合
        // 外部サイトへの遷移としてSFSafariViewで表示する。
        if (navigationAction.navigationType == .linkActivated || navigationAction
            .targetFrame == nil) && currentDomain != targetDomain
        {
            // SFSafariView
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true, completion: nil)
            return true
        }
        return false
    }

    func clearCacheAndReload() {
        // キャッシュを削除する
        let websiteDataTypes: Set<String> = [WKWebsiteDataTypeDiskCache,
                                             WKWebsiteDataTypeMemoryCache]

        let dateFrom = Date(timeIntervalSince1970: 0)

        WKWebsiteDataStore.default()
            .removeData(ofTypes: websiteDataTypes, modifiedSince: dateFrom) {
                // キャッシュ削除後にリロード
                self.webView.reload()
            }
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // ページの読み込み準備開始
        updateUserScript()
    }

    // MARK: - HTMLの読み込み前に動作するスクリプトの作成

    func updateUserScript() {
        let script = createUserScript()

        // 登録されているスクリプトを削除
        userContentController.removeAllUserScripts()

        // 新規のスクリプトを登録
        userContentController.addUserScript(script)
    }

    func createUserScript() -> WKUserScript {
        // bundleId
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        // IDFA, ATTダイアルの表示は別に行う必要があります
        var idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        if idfa == ALL_ZERO_UUID {
            idfa = ""
        }

        // iOSバージョンを取得
        let platformv = UIDevice.current.systemVersion

        // js
        let jsString =
            "window.adgAdParams = {idfa:'\(idfa)', appbundle:'\(bundleId)', platformv:'\(platformv)'};"

        let userScript = WKUserScript(source: jsString, injectionTime: .atDocumentStart,
                                      forMainFrameOnly: true)
        return userScript
    }
}
