//
//  BannerAdsObjCViewController.m
//  BannerAdsObjC
//
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

#import "BannerAdsObjCViewController.h"
#import <ADG/ADGManagerViewController.h>

@interface BannerAdsObjCViewController () <ADGManagerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *adView;
@property (nonatomic) ADGManagerViewController *adg;

@end

@implementation BannerAdsObjCViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    /*
     locationid:  管理画面から払い出された広告枠ID
     adtype:      枠サイズ
                  kADG_AdType_Sp：320x50, kADG_AdType_Large:320x100,
                  kADG_AdType_Rect:300x250, kADG_AdType_Tablet:728x90,
                  kADG_AdType_Free:自由設定
     originx:     広告枠設置起点のx座標(optional)
     originy:     広告枠設置起点のy座標(optional)
     w:           広告枠横幅(kADG_AdType_Freeのとき有効 optional)
     h:           広告枠高さ(kADG_AdType_Freeのとき有効 optional)
     */
    NSDictionary *adgparam = @{
        @"locationid" : @"48547",
        @"adtype" : @(kADG_AdType_Sp),
//        @"originx" : @0,
//        @"originy" : @0,
//        @"w" : @0,
//        @"h" : @0
    };
    self.adg = [[ADGManagerViewController alloc] initWithAdParams:adgparam
                                                           adView:self.adView];
    self.adg.delegate = self;
    [self.adg loadRequest]; // 広告リクエスト
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 画面復帰時のローテーション再開
    [self.adg resumeRefresh];
}

- (void)dealloc {
    // インスタンスの破棄
    self.adg.delegate = nil;
    self.adg = nil;
}

- (void)ADGManagerViewControllerReceiveAd:(ADGManagerViewController *)adgManagerViewController {
    NSLog(@"Received an ad.");
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

- (void)ADGManagerViewControllerDidTapAd:(ADGManagerViewController *)adgManagerViewController{
    NSLog(@"Did tap an ad.");
}

@end
