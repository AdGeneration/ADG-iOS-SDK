//
//  NativeAdsObjCViewController.m
//  NativeAdsObjC
//
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

#import "NativeAdsObjCViewController.h"
#import "ADGNativeAdView.h"
#import "FBNativeAdCustomView.h"
#import <ADG/ADGManagerViewController.h>
#import <ADG/ADGNativeAd.h>
#import <FBAudienceNetwork/FBNativeAd.h>

@interface NativeAdsObjCViewController () <ADGManagerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *adView;
@property (nonatomic) ADGManagerViewController *adg;

@end

@implementation NativeAdsObjCViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    /*
     locationid:  管理画面から払い出された広告枠ID
     adtype:      枠サイズ kADG_AdType_Free:自由設定
     w:           広告枠横幅
     h:           広告枠高さ
     */
    NSDictionary *adgparam = @{
       @"locationid" : @"48635",
       @"adtype" : @(kADG_AdType_Free),
       @"w" : @300,
       @"h" : @250
    };
    
    // HTMLテンプレートを使用したネイティブ広告を表示のためにはadViewを指定する必要があります
    self.adg = [[ADGManagerViewController alloc] initWithAdParams:adgparam
                                                           adView:self.adView];
    self.adg.delegate = self;
    
    // ネイティブ広告パーツ取得を有効
    self.adg.usePartsResponse = YES;
    
    // インフォメーションアイコンのデフォルト表示
    // デフォルト表示しない場合は必ずADGInformationIconViewの設置を実装してください
    self.adg.informationIconViewDefault = false;
    
    /*
     Audience Networkを配信する場合は、
     最前面にあるUIViewControllerに対して以下のように設定をおこなってください。
     */
    [self addChildViewController:self.adg];
    self.adg.rootViewController = self;
    
    /*
     実機でAudience Networkのテスト広告を表示する場合、
     1. 以下のsetLogLevelメソッドを実行してください
        [FBAdSettings setLogLevel:FBAdLogLevelNotification];
     2. ログに出力されるデバイスハッシュを取得し、addTestDeviceを実行してください
        [FBAdSettings addTestDevice:@"{device_hash}"];
     */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    // インスタンスの破棄
    self.adg.rootViewController = nil;
    self.adg.delegate = nil;
    self.adg = nil;
}


- (IBAction)didTapLoadRequestButton:(id)sender {
    // 広告リクエスト
    [self.adg loadRequest];
}

- (void)ADGManagerViewControllerReceiveAd:(ADGManagerViewController *)adgManagerViewController {
    NSLog(@"Received an ad.");
}

- (void)ADGManagerViewControllerReceiveAd:(ADGManagerViewController *)adgManagerViewController
                        mediationNativeAd:(id)mediationNativeAd {
    NSLog(@"Received an ad.");
    
    UIView *nativeAdView;
    if ([mediationNativeAd isKindOfClass: [ADGNativeAd class]]) {
        ADGNativeAdView *adgNativeAdView = [ADGNativeAdView view];
        [adgNativeAdView apply:(ADGNativeAd *)mediationNativeAd];
        nativeAdView = adgNativeAdView;
    } else if ([mediationNativeAd isKindOfClass: [FBNativeAd class]]) {
        FBNativeAdCustomView *fbNativeAdView = [FBNativeAdCustomView view];
        [fbNativeAdView apply:(FBNativeAd *)mediationNativeAd
               viewController:self];
        nativeAdView = fbNativeAdView;
    }
    
    if (nativeAdView) {
        // ローテーション時に自動的にViewを削除します
        [adgManagerViewController setAutomaticallyRemoveOnReload:nativeAdView];
        
        [self.adView addSubview:nativeAdView];
    }
}

- (void)ADGManagerViewControllerFailedToReceiveAd:(ADGManagerViewController *)adgManagerViewController
                                             code:(kADGErrorCode)code {
    NSLog(@"Failed to receive an ad.");
    // エラー時のリトライは特段の理由がない限り必ず記述するようにしてください。
    switch (code) {
        case kADGErrorCodeNeedConnection:   // ネットワーク不通
        case kADGErrorCodeExceedLimit:      // エラー多発
        case kADGErrorCodeNoAd:             // 広告レスポンスなし
            break;
        default:
            [adgManagerViewController loadRequest];
            break;
    }
}

@end

