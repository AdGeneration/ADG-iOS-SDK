//
//  FBNativeBannerAdCustomView.h
//  NativeAdsObjC
//
//  Copyright © 2018年 Supership Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBAudienceNetwork/FBNativeBannerAd.h>

@interface FBNativeBannerAdCustomView : UIView

+ (instancetype)view;
- (void)apply:(FBNativeBannerAd *)nativeAd viewController:(UIViewController *)viewController;


@end
