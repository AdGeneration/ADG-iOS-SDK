//
//  FBNativeAdCustomView.h
//  NativeAdsObjC
//
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBAudienceNetwork/FBNativeAd.h>

@interface FBNativeAdCustomView : UIView

+ (instancetype)view;
- (void)apply:(FBNativeAd *)nativeAd viewController:(UIViewController *)viewController;

@end
