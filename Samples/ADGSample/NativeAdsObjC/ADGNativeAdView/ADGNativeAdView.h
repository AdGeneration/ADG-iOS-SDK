//
//  ADGNativeAdView.h
//  NativeAdsObjC
//
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ADG/ADGNativeAd.h>

@interface ADGNativeAdView : UIView

+ (instancetype)view;
- (void)apply:(ADGNativeAd *)nativeAd;

@end
