//
//  FBNativeBannerAdCustomView.m
//  NativeAdsObjC
//
//  Copyright © 2018年 Supership Inc. All rights reserved.
//

#import "FBNativeBannerAdCustomView.h"
#import <FBAudienceNetwork/FBNativeBannerAd.h>

@interface FBNativeBannerAdCustomView()
@property (weak, nonatomic) IBOutlet UIView *iconViewContainer;
@property (weak, nonatomic) IBOutlet UILabel *ctaLabel;
@property (weak, nonatomic) IBOutlet UILabel *socialLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation FBNativeBannerAdCustomView

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
    self.iconViewContainer.clipsToBounds = YES;
}

- (void)apply:(FBNativeBannerAd *)nativeAd viewController:(UIViewController *)viewController {
    if (!nativeAd) {
        return;
    }
    
    // タイトル
    self.titleLabel.text = nativeAd.headline;
    
    // アイコン
    FBAdIconView *iconView = [[FBAdIconView alloc] initWithFrame:CGRectMake(0, 0, self.iconViewContainer.frame.size.width, self.iconViewContainer.frame.size.height)];
    [self.iconViewContainer addSubview:iconView];
    
    // AdChoices（AudienceNetworkの広告オプトアウトへの導線です）
    FBAdChoicesView *adChoices = [[FBAdChoicesView alloc] initWithNativeAd:nativeAd expandable:YES];
    adChoices.backgroundShown = NO;
    [self addSubview:adChoices];
    [adChoices updateFrameFromSuperview:UIRectCornerTopLeft];

    // socialContext
    self.socialLabel.text = nativeAd.socialContext;
    
    // CTA
    self.ctaLabel.text = nativeAd.callToAction;
    
    // クリック領域
    NSArray *clickableViews = @[self.titleLabel, self.socialLabel, self.ctaLabel];
    [nativeAd registerViewForInteraction:self
                                iconView:iconView
                          viewController:viewController
                          clickableViews:clickableViews
     ];
}

@end
