//
//  NativeAdsObjCViewController.m
//  NativeAdsObjC
//
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

#import "NativeAdsObjCViewController.h"
#import "ADGNativeAdView.h"
#import <ADG/ADGManagerViewController.h>
#import <ADG/ADGNativeAd.h>

@interface NativeAdsObjCViewController () <ADGManagerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *adView;
@property (nonatomic) ADGManagerViewController *adg;

@end

@implementation NativeAdsObjCViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    /*
     locationID:  管理画面から払い出された広告枠ID
     adType:      枠サイズ kADG_AdType_Free:自由設定
     rootViewController: 広告を配置するViewController
     */
    self.adg = [[ADGManagerViewController alloc] initWithLocationID:@"48635"
                                                             adType:kADG_AdType_Free
                                                 rootViewController:self];
    
    // HTMLテンプレートを使用したネイティブ広告を表示するためには以下のように配置するViewを指定します
    self.adg.adSize = CGSizeMake(300, 250);
    [self.adg addAdContainerView:self.adView];
    
    self.adg.delegate = self;
    
    // ネイティブ広告パーツ取得を有効
    self.adg.usePartsResponse = YES;
    
    // インフォメーションアイコンのデフォルト表示
    // デフォルト表示しない場合は必ずADGInformationIconViewの設置を実装してください
    self.adg.informationIconViewDefault = NO;
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
        [adgNativeAdView apply:(ADGNativeAd *)mediationNativeAd viewController:self];
        nativeAdView = adgNativeAdView;
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

