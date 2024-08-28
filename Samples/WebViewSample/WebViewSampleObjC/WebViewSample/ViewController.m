//
//  ViewController.m
//
//  Created by Supership.inc on 2024/08/09.
//  Copyright © 2024 Supership Inc. All rights reserved.
//


#import <AdSupport/ASIdentifierManager.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <Foundation/Foundation.h>
#import <SafariServices/SafariServices.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

static const BOOL USE_LOCAL = YES; // localファイルを利用してテストするか
static NSString * const LOAD_URL = @"https://********/"; // テストで利用する外部のURL
static NSString * const ALL_ZERO_UUID = @"00000000-0000-0000-0000-000000000000";

@interface ViewController : UIViewController <WKUIDelegate, WKNavigationDelegate>

@property (strong, nonatomic) WKWebView *webView;
@property (strong, nonatomic) WKUserContentController *userContentController;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UIButton *reloadButton;

@end

@implementation ViewController

- (void) tappedBackButton {
    [self.webView goBack];
}

- (void) tappedNextButton {
    [self.webView goForward];
}
- (void) tappedReloadButton {
    [self clearCacheAndReload];
}

- (void) loadView {
    [super loadView];

    [self configureWebView];

    [self layoutView];

    if (USE_LOCAL) {
        // テストのためにローカルファイルを閲覧
        NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
        NSURL *url = [NSURL fileURLWithPath:path];
        [self.webView loadFileURL:url allowingReadAccessToURL:url];
    }
    else {
        NSURL *url = [NSURL URLWithString:LOAD_URL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }

}

- (void) configureWebView {

    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];

    // インライン再生を許可
    [configuration setAllowsInlineMediaPlayback:YES];
    // すべてのメディアについてユーザインタラクションなしの自動再生を許可
    [configuration setMediaTypesRequiringUserActionForPlayback:WKAudiovisualMediaTypeNone];

    // jsのコンテンツを差し込むことで,idfaやappbundleをjsから取得できるようにする
    self.userContentController = [[WKUserContentController alloc] init];
    [configuration setUserContentController:self.userContentController];

    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;

    // web inspectorでデバックできるようにする
    if (@available(iOS 16.4, *)) {
        [self.webView setInspectable:YES];
    }
}

- (void) layoutView {
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;

    // カスタムの戻るボタンを作成
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backButton setTitle:@"Back" forState:UIControlStateNormal];
    self.backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backButton addTarget:self action:@selector(tappedBackButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];
    [NSLayoutConstraint activateConstraints:@[
         [self.backButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
         [self.backButton.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20],
         [self.backButton.heightAnchor constraintEqualToConstant:50],
         [self.backButton.widthAnchor constraintEqualToConstant:100]
    ]];

    // 進むボタンを作成
    self.nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
    self.nextButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.nextButton addTarget:self action:@selector(tappedNextButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nextButton];
    [NSLayoutConstraint activateConstraints:@[
         [self.nextButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
         [self.nextButton.leftAnchor constraintEqualToAnchor:self.backButton.rightAnchor constant:5],
         [self.nextButton.heightAnchor constraintEqualToConstant:50],
         [self.nextButton.widthAnchor constraintEqualToConstant:100]
    ]];

    // Reloadボタンを作成
    self.reloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.reloadButton setTitle:@"Reload" forState:UIControlStateNormal];
    self.reloadButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.reloadButton addTarget:self action:@selector(tappedReloadButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.reloadButton];
    [NSLayoutConstraint activateConstraints:@[
         [self.reloadButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
         [self.reloadButton.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-20],
         [self.reloadButton.heightAnchor constraintEqualToConstant:50],
         [self.reloadButton.widthAnchor constraintEqualToConstant:100]
    ]];

    [self.view addSubview:self.webView];

    [NSLayoutConstraint activateConstraints:@[
         [self.webView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
         [self.webView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
         [self.webView.bottomAnchor constraintEqualToAnchor:self.nextButton.topAnchor constant:-1],
         [self.webView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor]
    ]];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (@available(iOS 14.0, *)) {
        // iOS14以降ではAppTrackingTransparencyを利用してIDFA取得に関する判定をする
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {

             NSString *str = @"unknown";
             if (status == ATTrackingManagerAuthorizationStatusDenied) {
                 str = @"ATTrackingManagerAuthorizationStatusDenied";
             }
             else if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                 str = @"ATTrackingManagerAuthorizationStatusAuthorized";
             }
             else if (status == ATTrackingManagerAuthorizationStatusRestricted) {
                 str = @"ATTrackingManagerAuthorizationStatusRestricted";
             }
             else if (status == ATTrackingManagerAuthorizationStatusNotDetermined) {
                 str = @"ATTrackingManagerAuthorizationStatusNotDetermined";
             }

             NSLog(@"ATT status:%@", str);
         }];
    }
}

- (void) webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    // 戻る、進むボタンの有効化

    dispatch_async
    (
        dispatch_get_main_queue(),
        ^{
        self.backButton.enabled = [self.webView canGoBack];
        self.backButton.alpha = [self.webView canGoBack] ? 1.0 : 0.4;
        self.nextButton.enabled = [self.webView canGoForward];
        self.nextButton.alpha = [self.webView canGoForward] ? 1.0 : 0.4;
    }
    );

}

- (void)                    webView:(WKWebView *)webView
    decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    // URL遷移時に呼ばれる

    NSURL *url = navigationAction.request.URL;

    NSLog(@"decidePolicyForNavigationAction:%@", url.absoluteString);
    NSString *currentDomain = webView.URL.host;
    NSString *targetDomain = navigationAction.request.URL.host;

    // 外部のブラウザで閲覧するかどうかを決める
    if ([self handleClick:url
            currentDomain:currentDomain
             targetDomain:targetDomain
         navigationAction:navigationAction]) {

        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }

    decisionHandler(WKNavigationActionPolicyAllow);
}



- (WKWebView *)            webView:(WKWebView *)webView
    createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
               forNavigationAction:(WKNavigationAction *)navigationAction
                    windowFeatures:(WKWindowFeatures *)windowFeatures {
    // window.openの時などに呼ばれる

    NSLog(@"createWebViewWithConfiguration");
    NSURL *url = navigationAction.request.URL; // 読み込むURL
    NSString *currentDomain = webView.URL.host; // 現在表示しているドメイン
    NSString *targetDomain = navigationAction.request.URL.host; // 読み込む先のドメイン

    if ([self handleClick:url
            currentDomain:currentDomain
             targetDomain:targetDomain
         navigationAction:navigationAction]) {
        NSLog(@"URL opened in SFSafariViewController.");
    }

    return nil;
}

- (BOOL) handleClick:(NSURL *)url
       currentDomain:(NSString *)currentDomain
        targetDomain:(NSString *)targetDomain
    navigationAction:(WKNavigationAction *)navigationAction {

    // http(s) 以外のプロトコル: 他のアプリへ移動する場合
    if (![url.absoluteString hasPrefix:@"http://"]
        && ![url.absoluteString hasPrefix:@"https://"]
        && [[UIApplication sharedApplication] canOpenURL:url]) {
        NSLog(@"NOT HTTP/HTTPS : %@", url.absoluteString);
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        return YES;
    }

    if (!url || !currentDomain || !targetDomain) {
        return NO;
    }

    // hrefが指定された場合、新しいwindowで開こうとしている場合
    if ((navigationAction.navigationType == WKNavigationTypeLinkActivated
         || !navigationAction.targetFrame)
        // 現在のドメインとは別のドメインのページを開こうとしている場合
        // 外部サイトへの遷移としてSFSafariViewで表示する。
        // サイトに応じて適宜変更が必要
        && ![currentDomain isEqualToString:targetDomain]) {
        // SFSafariView
        SFSafariViewController *safariViewController =
            [[SFSafariViewController alloc] initWithURL:url];
        [self presentViewController:safariViewController animated:YES
                         completion:nil];
        return YES;
    }
    return NO;
}

- (void) clearCacheAndReload {
    // キャッシュを削除する
    NSSet *websiteDataTypes = [NSSet setWithArray:@[
                                   WKWebsiteDataTypeDiskCache,
                                   WKWebsiteDataTypeMemoryCache,
    ]];

    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];

    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes
                                               modifiedSince:dateFrom
                                           completionHandler:^{
         // キャッシュ削除後にリロード
         [self.webView reload];
     }];
}

- (void) webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    // ページの読み込み準備開始
    [self updateUserScript];

}

#pragma mark - HTMLの読み込み前に動作するスクリプトの作成

- (void) updateUserScript {

    WKUserScript *script = [self createUserScript];

    // 登録されているスクリプトを削除
    [self.userContentController removeAllUserScripts];

    // 新規のスクリプトを登録
    [self.userContentController addUserScript:script];
}

- (WKUserScript *) createUserScript {

    // bundleId
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    // IDFA, ATTダイアルの表示は別に行う必要があります
    NSString *idfa = [[ASIdentifierManager sharedManager] advertisingIdentifier].UUIDString;

    if ([idfa isEqualToString:ALL_ZERO_UUID]) {
        idfa = @"";
    }

    // js
    NSString *jsStringTemplate = @"window.adgAdParams = {idfa:'%@', appbundle:'%@'};";
    NSString *jsString = [NSString stringWithFormat:jsStringTemplate, idfa, bundleId];

    WKUserScript *userScript = [[WKUserScript alloc]
                                 initWithSource:jsString
                                  injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                               forMainFrameOnly:YES];
    return userScript;
}
@end
