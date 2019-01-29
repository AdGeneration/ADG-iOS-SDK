//
//  FBNativeAdCustomView.m
//  NativeAdsObjC
//
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

#import "FBNativeAdCustomView.h"
#import <FBAudienceNetwork/FBNativeAd.h>

@interface FBNativeAdCustomView()

@property (weak, nonatomic) IBOutlet FBAdIconView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *mediaViewContainer;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;
@property (weak, nonatomic) IBOutlet UILabel *adLabel;
@property (weak, nonatomic) IBOutlet UILabel *socialLabel;
@property (weak, nonatomic) IBOutlet UILabel *ctaLabel;

@end

@implementation FBNativeAdCustomView

+ (instancetype)view {
    NSString *className = NSStringFromClass([self class]);
    return [[[NSBundle mainBundle] loadNibNamed:className
                                          owner:nil
                                        options:0] firstObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = UIColor.lightGrayColor.CGColor;
    
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.iconImageView.clipsToBounds = YES;
    
    self.mediaViewContainer.clipsToBounds = YES;
    
    self.ctaLabel.layer.cornerRadius = 5.0f;
}

- (void)apply:(FBNativeAd *)nativeAd viewController:(UIViewController *)viewController {
    if (!nativeAd) {
        return;
    }
    
    // タイトル
    self.titleLabel.text = nativeAd.headline;
    
    // FBMediaView
    FBMediaView *mediaView = [[FBMediaView alloc] initWithFrame:CGRectMake(0, 0, self.mediaViewContainer.frame.size.width, self.mediaViewContainer.frame.size.height)];
    [self.mediaViewContainer addSubview:mediaView];

    // AdChoices（AudienceNetworkの広告オプトアウトへの導線です）
    FBAdChoicesView *adChoices = [[FBAdChoicesView alloc] initWithNativeAd:nativeAd expandable:YES];
    adChoices.backgroundShown = NO;
    [self.mediaViewContainer addSubview:adChoices];
    [adChoices updateFrameFromSuperview:UIRectCornerTopRight];
    
    // 本文
    self.bodyLabel.text = nativeAd.bodyText;
    
    // socialContext
    self.socialLabel.text = nativeAd.socialContext;
    
    // CTA
    self.ctaLabel.text = nativeAd.callToAction;
    
    
    
    // クリック領域
    NSArray *clickableViews = @[self.titleLabel, self.mediaViewContainer, self.socialLabel, self.ctaLabel];
    [nativeAd registerViewForInteraction:self
                               mediaView:mediaView
                                iconView:self.iconImageView
                          viewController:viewController
                          clickableViews:clickableViews];
}

@end
