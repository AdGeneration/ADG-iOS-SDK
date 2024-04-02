//
//  BannerAdsObjCViewController.m
//  BannerAdsObjC
//
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

#import "BannerAdsObjCViewController.h"
#import <ADG/ADGManagerViewController.h>
#import <ADG/ADGSettings.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <AdSupport/AdSupport.h>
#import <AppTrackingTransparency/ATTrackingManager.h>

@interface BannerAdsObjCViewController () <ADGManagerViewControllerDelegate>

#define LOCATION_ID @"48547"

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *attButon;
@property (weak, nonatomic) IBOutlet UILabel *attStatusLabel;
@property (weak, nonatomic) IBOutlet UIView *adView;
@property (nonatomic) ADGManagerViewController *adg;

@end

@implementation BannerAdsObjCViewController

- (void)loadAd {
    /*
     locationID:  管理画面から払い出された広告枠ID
     adType:      枠サイズ
                  kADG_AdType_Sp：320x50, kADG_AdType_Large:320x100,
                  kADG_AdType_Rect:300x250, kADG_AdType_Tablet:728x90,
                  kADG_AdType_Free:自由設定
     rootViewController: 広告を配置するViewController
     */
    self.adg = [[ADGManagerViewController alloc] initWithLocationID:LOCATION_ID
                                                             adType:kADG_AdType_Sp
                                                 rootViewController:self];
    // test mode 設定
    //[self.adg setEnableTestMode:YES]
    // geolocation 設定
    //[ADGSettings setGeolocationEnabled:YES]
    // in app browser 設定
    //[ADGSettings setEnableInAppBrowser:NO];
    // child directed であると指定
    //[ADGSettings setChildDirectedEnabled:YES];
    // child directed でないと指定
    //[ADGSettings setChildDirectedEnabled:NO];
    // hyper id 設定
    //[ADGSettings setHyperIdEnabled:NO];
    [self.adg addAdContainerView:self.adView]; // 広告Viewを配置するViewを指定
    self.adg.delegate = self;
    [self.adg loadRequest]; // 広告リクエスト
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadAd];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    self.titleLabel.text = @"Objective-C - 広告枠id: " LOCATION_ID;
    [self reloadATTViews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 画面復帰時のローテーション再開
    [self.adg resumeRefresh];
}

- (NSString *)getInfoText {
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *provider = [networkInfo subscriberCellularProvider];
    return [NSString stringWithFormat:
            @"ADG SDK: v%@\n"
            "isHyperIdEnabled: %@\n"
            "isGeolocationEnabled: %@\n"
            "enableInAppBrowser: %@\n"
            "device name: %@\n"
            "system name: %@\n"
            "system version: %@\n"
            "OS model: %@\n"
            "carrier name: %@\n"
            "ISO Country code: %@\n"
            "PreferredLanguage: %@\n"
            "code: %@\n"
            "BundleID: %@\n"
            "ChildDirected: %@\n"
            "IDFA: %@\n"
            "IDFV: %@"
            , ADG_SDK_VERSION
            , ADGSettings.isHyperIdEnabled ? @"YES" : @"NO"
            , ADGSettings.isGeolocationEnabled ? @"YES" : @"NO"
            , ADGSettings.enableInAppBrowser ? @"YES" : @"NO"
            , UIDevice.currentDevice.name
            , UIDevice.currentDevice.systemName
            , UIDevice.currentDevice.systemVersion
            , UIDevice.currentDevice.model
            , provider.carrierName
            , provider.isoCountryCode
            , NSLocale.preferredLanguages.firstObject
            , NSLocale.currentLocale.localeIdentifier
            , NSBundle.mainBundle.bundleIdentifier
            , ADGSettings.isChildDirectedEnabled ? @"YES" : @"NO"
            , ASIdentifierManager.sharedManager.advertisingIdentifier.UUIDString
            , UIDevice.currentDevice.identifierForVendor.UUIDString
    ];
}

- (void)reloadATTViews {
    self.attStatusLabel.text = @"エラー";
    if (@available(iOS 14, *)) {
        self.attButon.enabled = YES;
        switch (ATTrackingManager.trackingAuthorizationStatus) {
            case ATTrackingManagerAuthorizationStatusAuthorized:
                self.attStatusLabel.text = @"Authorized";
                break;
            case ATTrackingManagerAuthorizationStatusRestricted:
                self.attStatusLabel.text = @"Restricted";
                break;
            case ATTrackingManagerAuthorizationStatusDenied:
                self.attStatusLabel.text = @"Denied";
                break;
            case ATTrackingManagerAuthorizationStatusNotDetermined:
                self.attStatusLabel.text = @"NotDetermined";
                break;
        }
    } else {
        self.attButon.enabled = NO;
        self.attStatusLabel.text = @"OS非対応";
    }
}

- (IBAction)tappedInfo {
    UIAlertController *infoDialog = [UIAlertController alertControllerWithTitle:@"Info" message:[self getInfoText] preferredStyle:UIAlertControllerStyleAlert];
     [infoDialog addAction:[UIAlertAction actionWithTitle:@"閉じる" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:infoDialog animated:YES completion:nil];
}


- (IBAction)tappedATT {
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf reloadATTViews];
            });
        }];
    }
}


- (IBAction)tappedAdReload {
    [self reloadATTViews];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf loadAd];
    });
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
