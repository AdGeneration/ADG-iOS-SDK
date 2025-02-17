//
//  ADGNativeAdView.m
//  NativeAdsObjC
//
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

#import "ADGNativeAdView.h"
#import <ADG/ADGInformationIconView.h>
#import <ADG/ADGMediaView.h>
#import <ADG/ADGNativeAd.h>

@interface ADGNativeAdView ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *mediaViewContainerView;
@property (weak, nonatomic) IBOutlet UILabel *sponsoredLabel;
@property (weak, nonatomic) IBOutlet UILabel *ctaLabel;

@end

@implementation ADGNativeAdView

+ (instancetype) view {
    NSString *className = NSStringFromClass([self class]);

    return [[[NSBundle mainBundle] loadNibNamed:className
                                          owner:nil
                                        options:0] firstObject];
}

- (void) awakeFromNib {
    [super awakeFromNib];
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = UIColor.lightGrayColor.CGColor;

    self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.iconImageView.clipsToBounds = YES;

    self.ctaLabel.backgroundColor = UIColor.whiteColor;
    self.ctaLabel.clipsToBounds = YES;
    self.ctaLabel.textColor = self.ctaLabel.tintColor;
    self.ctaLabel.layer.borderWidth = 1.0f;
    self.ctaLabel.layer.borderColor = self.ctaLabel.tintColor.CGColor;
    self.ctaLabel.layer.cornerRadius = 5.0f;
}

- (void) apply:(ADGNativeAd *)nativeAd viewController:(UIViewController *)viewController {
    if (!nativeAd) {
        return;
    }
    // タイトル
    self.titleLabel.text = nativeAd.title ? nativeAd.title.text : @"";

    // リード文
    self.descriptionLabel.text = nativeAd.desc ? nativeAd.desc.value : @"";

    // アイコン画像
    if (nativeAd.iconImage.url.length > 0) {
        NSURL *iconImageUrl = [NSURL URLWithString:nativeAd.iconImage.url];
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *iconImageData = [NSData dataWithContentsOfURL:iconImageUrl];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.iconImageView.image = [UIImage imageWithData:iconImageData];
            });
        });
    }

    // メイン画像・動画
    for (UIView *v in self.mediaViewContainerView.subviews) {
        [v removeFromSuperview];
    }

    if (nativeAd.canLoadMedia) {
        CGRect mediaViewFrame = CGRectMake(0, 0,
                                           self.mediaViewContainerView.bounds.size.width,
                                           self.mediaViewContainerView.bounds.size.height);
        ADGMediaView *mediaView = [[ADGMediaView alloc] initWithFrame:mediaViewFrame];
        mediaView.nativeAd = nativeAd;
        mediaView.viewController = viewController;
        [self.mediaViewContainerView addSubview:mediaView];
        [mediaView load];
    }

    // インフォメーションアイコン
    ADGInformationIconView *infoIconView = [[ADGInformationIconView alloc] initWithNativeAd:nativeAd];
    if (infoIconView) {
        [self.mediaViewContainerView addSubview:infoIconView];
        [infoIconView updateFrameFromSuperview:UIRectCornerTopRight];
    }

    // 広告主
    self.sponsoredLabel.text = nativeAd.sponsored.value.length > 0 ?
        [NSString stringWithFormat:@"sponsored by %@", nativeAd.sponsored.value] :
        @"sponsored";

    // CTAボタン
    NSString *ctaText = nativeAd.ctatext.value.length > 0 ?
        nativeAd.ctatext.value : @"詳しくはこちら";
    self.ctaLabel.text = ctaText;

    // クリックイベント
    [nativeAd setTapEvent:self handler:nil];
}

@end

