//
//  InterstitialAdsObjCViewController.m
//  InterstitialAdsObjC
//
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

#import "InterstitialAdsObjCViewController.h"
#import <ADG/ADGInterstitial.h>

@interface InterstitialAdsObjCViewController () <ADGInterstitialDelegate>

@property (nonatomic) ADGInterstitial *interstitial;

@end

@implementation InterstitialAdsObjCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.interstitial = [[ADGInterstitial alloc] init];
    [self.interstitial setLocationId:@"48549"]; // 管理画面から払い出された広告枠ID
    self.interstitial.delegate = self;
    self.interstitial.rootViewController = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapPreloadButton:(id)sender {
    // 広告リクエスト
    [self.interstitial preload];
}

- (IBAction)didTapShowButton:(id)sender {
    // 広告表示
    [self.interstitial show];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // 広告非表示
    [self.interstitial dismiss];
}

- (void)dealloc {
    self.interstitial.delegate = nil;
    self.interstitial = nil;
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

- (void)ADGManagerViewControllerDidTapAd:(ADGManagerViewController *)adgManagerViewController {
    NSLog(@"Did tap an ad.");
}

- (void)ADGInterstitialClose {
    NSLog(@"Closed interstitial ads.");
}

@end
