//
//  ADGFBNativeAdView.m
//  ADGNativeSample
//
//  Copyright © 2016年 supership. All rights reserved.
//

#import "ADGFBNativeAdView.h"

@implementation ADGFBNativeAdView

- (UIView*) createFBNativeAdView:(UIViewController *)viewController adgManagerViewController:(ADGManagerViewController *)adgManagerViewController nativeAd:(FBNativeAd *)nativeAd {

    // アイコン
    NSData *iconImageData = [NSData dataWithContentsOfURL:nativeAd.icon.url];
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(4, 2, 30 ,30)];
    iconImageView.image = [UIImage imageWithData:iconImageData];

    // タイトル
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(38, 2, 258, 30)];
    titleLbl.numberOfLines = 1;
    titleLbl.textColor = [UIColor blackColor];
    [titleLbl setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
    titleLbl.font = [titleLbl.font fontWithSize:16];
    titleLbl.text = nativeAd.title;

    // メインイメージ
    // 動画/静止画兼用のときはFBMediaViewを使用する
    // FBMediaViewはAudienceNetworkのSDKが提供している動画/静止画の出し分けを行うクラスとなります。
    FBMediaView *mainImageView = [[FBMediaView alloc] initWithFrame:CGRectMake(0, 34 , 300 , 157)];
    [mainImageView setClipsToBounds:YES];
    [mainImageView setNativeAd:nativeAd];

    /*
     静止画のみのコード例
     静止画のみのときはnativeAd.coverImage.urlを元にUIImageを生成する
     NSData *coverImageData = [NSData dataWithContentsOfURL:nativeAd.coverImage.url];
     UIImage *coverImage = [UIImage imageWithData:coverImageData];
     UIImageView *mainImageView = [[UIImageView alloc] init];
     mainImageView.frame = CGRectMake(0, 0 , 300 , 156);
     mainImageView.image = coverImage;
     */
    
    // AdChoices（AudienceNetworkの広告オプトアウトへの導線です）
    FBAdChoicesView *adChoices = [[FBAdChoicesView alloc] initWithNativeAd:nativeAd expandable:YES];
    [adChoices setBackgroundShown:NO];
    [mainImageView addSubview:adChoices];
    
    // 本文
    UILabel *descriptionLbl = [[UILabel alloc] initWithFrame:CGRectMake(4, 192, 296, 30)];
    descriptionLbl.numberOfLines = 2;
    descriptionLbl.font = [descriptionLbl.font fontWithSize:11];
    descriptionLbl.text = nativeAd.body;
    descriptionLbl.textColor = [UIColor blackColor];
    
    // 広告マーク
    UILabel *adTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 225, 28, 20)];
    adTextLabel.textColor = [UIColor whiteColor];
    adTextLabel.backgroundColor = [UIColor orangeColor];
    adTextLabel.font = [adTextLabel.font fontWithSize:11];
    [adTextLabel setTextAlignment:NSTextAlignmentCenter];
    adTextLabel.text = @"AD";

    // socialContext
    UILabel *socialLbl = [[UILabel alloc] initWithFrame:CGRectMake(38, 226, 100, 20)];
    socialLbl.numberOfLines = 1;
    socialLbl.font = [socialLbl.font fontWithSize:10];
    socialLbl.textColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
    socialLbl.textColor = [UIColor blackColor];
    socialLbl.text = nativeAd.socialContext;

    // CTA
    UIButton *actionBtn = [[UIButton alloc] initWithFrame:CGRectMake(150 , 223 , 144 , 25)];
    UIColor *ctaMainColor = [UIColor colorWithRed:0.20 green:0.80 blue:0.40 alpha:1.0];
    [actionBtn setTitle:nativeAd.callToAction forState:UIControlStateNormal];
    [actionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [actionBtn.titleLabel setFont: [UIFont boldSystemFontOfSize:10]];
    actionBtn.titleLabel.numberOfLines = 1;
    actionBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    actionBtn.backgroundColor = ctaMainColor;
    actionBtn.layer.borderWidth = 1.0f;
    actionBtn.layer.borderColor = [ctaMainColor CGColor];
    actionBtn.layer.cornerRadius = 5.0f;
    actionBtn.titleEdgeInsets = UIEdgeInsetsMake(1.0f, 1.0f, 1.0f, 1.0f);

    UIView *nativeAdView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 250)];
    [nativeAdView addSubview:iconImageView];
    [nativeAdView addSubview:titleLbl];
    [nativeAdView addSubview:adTextLabel];
    [nativeAdView addSubview:mainImageView];
    [nativeAdView addSubview:descriptionLbl];
    [nativeAdView addSubview:socialLbl];
    [nativeAdView addSubview:actionBtn];
    
    // AdChoices位置指定
    [adChoices updateFrameFromSuperview:UIRectCornerTopRight];
    
    // クリック領域の指定。詳細はリファレンスのregisterViewForInteractionを参照。
    // https://developers.facebook.com/docs/reference/ios/current/class/FBNativeAd/
    NSArray *clickableViews = @[mainImageView, titleLbl , actionBtn , socialLbl];
    [nativeAd registerViewForInteraction:nativeAdView withViewController:viewController withClickableViews:clickableViews];

    return nativeAdView;
}

@end
