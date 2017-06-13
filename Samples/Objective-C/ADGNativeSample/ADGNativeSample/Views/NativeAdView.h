//
//  NativeAdView.h
//  ADGNativeSample
//
//  Copyright © 2016年 supership. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ADG/ADGNativeAd.h>
#import <ADG/ADGVideoView.h>

@interface NativeAdView : UIView

@property (nonatomic) ADGVideoView *adgVideoView;
- (instancetype)initWithNativeAd:(ADGNativeAd *)nativeAd;

@end
