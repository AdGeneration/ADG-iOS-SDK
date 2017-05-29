//
//  ADGNativeAdTableViewCell.swift
//  ADGNativeSampleForSwift
//
//  Created on 2016/08/10.
//  Copyright © 2016年 Supership. All rights reserved.
//

import UIKit
import FBAudienceNetwork

class ADGNativeAdTableViewCell: UITableViewCell {
            
    @IBOutlet weak var adView: UIView!
    
    func createContentView(_ adgManagerViewController: ADGManagerViewController, nativeAd: AnyObject, rootViewController: UIViewController) -> ADGNativeAdTableViewCellContent {
        
        let contentView = ADGNativeAdTableViewCellContent.createFromNib() as! ADGNativeAdTableViewCellContent
        if nativeAd is ADGNativeAd {
            contentView.setADGNativeAd(adgManagerViewController, adgNativeAd: nativeAd as! ADGNativeAd)
        } else if nativeAd is FBNativeAd {
            contentView.setFBNativeAd(adgManagerViewController, fbNativeAd: nativeAd as! FBNativeAd, rootViewController: rootViewController)
        }
        
        self.adView.subviews.forEach{
            $0.removeFromSuperview()
        }
        
        self.adView.addSubview(contentView)
        self.adView.addConstraintsToFitSubView(contentView)
        
        return contentView
    }
    
    func applyContentView(_ contentView: ADGNativeAdTableViewCellContent) {
        self.adView.subviews.forEach{
            $0.removeFromSuperview()
        }
        
        self.adView.addSubview(contentView)
        self.adView.addConstraintsToFitSubView(contentView)
    }
    
    func applyBlankContentView() {
        self.adView.subviews.forEach{
            $0.removeFromSuperview()
        }        
    }
}
