//
//  FBNativeAdCustomView.m
//  NativeAdsObjC
//
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

#import "FBNativeAdCustomView.h"
#import <FBAudienceNetwork/FBNativeAd.h>

@interface FBNativeAdCustomView()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
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
    
    // アイコン
    if (nativeAd.icon) {
        NSData *data = [NSData dataWithContentsOfURL:nativeAd.icon.url];
        self.iconImageView.image = [UIImage imageWithData:data];
    }
    
    // タイトル
    self.titleLabel.text = nativeAd.title;
    
    // FBMediaView
    FBMediaView *mediaView = [[FBMediaView alloc] initWithFrame:CGRectMake(0, 0, self.mediaViewContainer.frame.size.width, self.mediaViewContainer.frame.size.height)];
    mediaView.nativeAd = nativeAd;
    [self.mediaViewContainer addSubview:mediaView];
    
    // FBMediaViewを使用せず静止画のみ使用する場合
//    UIImageView *coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.mediaViewContainer.frame.size.width, self.mediaViewContainer.frame.size.height)];
//    coverImageView.clipsToBounds = YES;
//    NSData *coverImageData = [NSData dataWithContentsOfURL:nativeAd.coverImage.url];
//    UIImage *coverImage = [UIImage imageWithData:coverImageData];
//    coverImageView.image = coverImage;
//    [self.mediaViewContainer addSubview:coverImageView];
    
    // AdChoices（AudienceNetworkの広告オプトアウトへの導線です）
    FBAdChoicesView *adChoices = [[FBAdChoicesView alloc] initWithNativeAd:nativeAd expandable:YES];
    adChoices.backgroundShown = NO;
    [self.mediaViewContainer addSubview:adChoices];
    [adChoices updateFrameFromSuperview:UIRectCornerTopRight];
    
    // 本文
    self.bodyLabel.text = nativeAd.body;
    
    // socialContext
    self.socialLabel.text = nativeAd.socialContext;
    
    // CTA
    self.ctaLabel.text = nativeAd.callToAction;
    
    // クリック領域
    NSArray *clickableViews = @[self.titleLabel, self.mediaViewContainer, self.socialLabel, self.ctaLabel];
    [nativeAd registerViewForInteraction:self
                      withViewController:viewController
                      withClickableViews:clickableViews];
}

@end
