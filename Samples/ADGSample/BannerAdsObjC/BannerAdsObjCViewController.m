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
     locationID:  管理画面から払い出された広告枠ID
     adType:      枠サイズ
                  kADG_AdType_Sp：320x50, kADG_AdType_Large:320x100,
                  kADG_AdType_Rect:300x250, kADG_AdType_Tablet:728x90,
                  kADG_AdType_Free:自由設定
     rootViewController: 広告を配置するViewController
     */
    self.adg = [[ADGManagerViewController alloc] initWithLocationID:@"48547"
                                                             adType:kADG_AdType_Sp
                                                 rootViewController:self];
    [self.adg addAdContainerView:self.adView]; // 広告Viewを配置するViewを指定
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
