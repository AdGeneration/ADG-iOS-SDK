//
//  ADGTableCellModel.swift
//  ADGNativeSampleForSwift
//
//  Created on 2016/10/18.
//  Copyright © 2016年 Supership. All rights reserved.
//

import UIKit
import FBAudienceNetwork

class ADGTableCellModel {
    
    /// locationId
    fileprivate(set) var locationId: String = ""
    
    /// adIndex
    fileprivate(set) var adIndex: Int = -1
    
    /// IndexPath of a cell
    fileprivate(set) var cellIndexPath: IndexPath?
    
    /// RootViewController
    fileprivate(set) var rootViewController: UIViewController?
    
    /// ADGNativeAdTableViewCell
    fileprivate(set) var nativeAdCell: ADGNativeAdTableViewCell?
    
    /// ADGNativeAdTableViewCellContent
    fileprivate(set) var nativeAdCellContent: ADGNativeAdTableViewCellContent?
    
    /// ADGManagerViewController
    fileprivate(set) var adg: ADGManagerViewController?
    
    /// ADGNativeAd
    fileprivate(set) var adgNativeAd: ADGNativeAd?
    
    /// FBNativeAd
    fileprivate(set) var fbNativeAd: FBNativeAd?
    
    /// ErrorCell
    fileprivate(set) var isError: Bool = false
    
    /// Delegate
    var delegate: ADGTableCellModelDelegate?
    
    /**
     init with locationId and adIndex
     - parameter locationId: locationId
     - parameter index: ad index
     */
    init(locationId: String, index: Int) {
        self.locationId = locationId
        self.adIndex = index
    }
    
    /**
     apply for row
     - parameter rootViewController: parent ViewController
     - parameter cell: native ad cell
     - parameter indexpath: cell IndexPath
     */
    func applyForRowAtIndexPath(_ rootViewController: UIViewController, cell: ADGNativeAdTableViewCell, indexPath: IndexPath) {
                
        if self.adg == nil {
            self.createADG(rootViewController, cell: cell, cellIndexPath: indexPath)
        } else if let contentView = self.nativeAdCellContent {
            cell.applyContentView(contentView)
        } else {
            cell.applyBlankContentView()
        }
    }
    
    /**
     create ADGManagerViewController
     - parameter rootViewController: parent ViewController
     - parameter cell: native ad cell
     - parameter cellIndexPath: cell IndexPath
     */
    fileprivate func createADG(_ rootViewController: UIViewController, cell: ADGNativeAdTableViewCell, cellIndexPath: IndexPath) {
        print("init ADG at \(cellIndexPath.row)")
        
        let adgParam = [
            "locationid": String(locationId),
            "adtype": String(ADGAdType.free.rawValue),
            "originx": "0",
            "originy": "0",
            "w": "320",
            "h": "100"
        ]
        
        if let adgManagerViewController = ADGManagerViewController(adParams: adgParam, adView: cell.adView) {
            adgManagerViewController.delegate = self
            adgManagerViewController.usePartsResponse = true
            adgManagerViewController.setFillerRetry(false)
            adgManagerViewController.rootViewController = rootViewController
            adgManagerViewController.loadRequest()
            adg = adgManagerViewController
        }
        
        self.rootViewController = rootViewController
        self.cellIndexPath = cellIndexPath
        self.nativeAdCell = cell
    }
}

extension ADGTableCellModel: ADGManagerViewControllerDelegate {
    /**
     バナー広告の取得に成功した場合に呼び出されます
     */
    func adgManagerViewControllerReceiveAd(_ adgManagerViewController: ADGManagerViewController!) {
        print("バナー広告をロードしました \(adgManagerViewController.locationid ?? "")")
    }
    
    /**
     ネイティブ広告の取得に成功した場合に呼び出されます
     - parameter adgManagerViewController: ADGManagerViewController
     - parameter mediationNativeAd: ネイティブ広告のインスタンス
     */
    func adgManagerViewControllerReceiveAd(_ adgManagerViewController: ADGManagerViewController!, mediationNativeAd: Any!) {
        print("ネイティブ広告をロードしました \(adgManagerViewController.locationid ?? "")")
        
        guard let adg = self.adg, let rootViewController = self.rootViewController else {
            print("Unexpected property state")
            return
        }
        self.adgNativeAd = mediationNativeAd as? ADGNativeAd
        self.fbNativeAd = mediationNativeAd as? FBNativeAd
        self.nativeAdCellContent = self.nativeAdCell?.createContentView(adg, nativeAd: mediationNativeAd as AnyObject, rootViewController: rootViewController)
    }
    
    /**
     広告の取得に失敗した場合に呼び出されます
     - parameter adgManagerViewController: ADGManagerViewController
     - parameter code: エラーコード
     */
    func adgManagerViewControllerFailed(toReceiveAd adgManagerViewController: ADGManagerViewController!, code: kADGErrorCode) {
        switch code {
        case .adgErrorCodeNeedConnection:
            print("エラーが発生しました ネットワーク接続不通 \(adgManagerViewController.locationid ?? "")")
        case .adgErrorCodeNoAd:
            print("エラーが発生しました レスポンス無し \(adgManagerViewController.locationid ?? "")")
        case .adgErrorCodeReceivedFiller:
            print("エラーが発生しました 白板検知 \(adgManagerViewController.locationid ?? "")")
        case .adgErrorCodeCommunicationError:
            print("エラーが発生しました サーバ間通信エラー \(adgManagerViewController.locationid ?? "")")
        case .adgErrorCodeExceedLimit:
            print("エラーが発生しました エラー多発 \(adgManagerViewController.locationid ?? "")")
        default:
            print("エラーが発生しました 不明なエラー \(adgManagerViewController.locationid ?? "")")
        }
        
        // 以下のエラーコード以外はリトライしてください
        switch code {
        case .adgErrorCodeNeedConnection, .adgErrorCodeExceedLimit, .adgErrorCodeNoAd:
            
            self.isError = true
            if let indexPath = self.cellIndexPath {
                self.delegate?.reloadTableViewRows(at: [indexPath])
            }
            
            break
        default:
            adgManagerViewController.loadRequest()
        }
    }
}

protocol ADGTableCellModelDelegate {
    func reloadTableViewRows(at: [IndexPath])
}
