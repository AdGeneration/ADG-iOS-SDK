//
//  ADGTableCellProvider.swift
//  ADGNativeSampleForSwift
//
//  Created on 2017/01/19.
//  Copyright © 2017年 Supership. All rights reserved.
//

import Foundation

struct ADGTableCellProvider {
    
    fileprivate(set) var tableView: UITableView?
    
    fileprivate var adgTableCellModels: [ADGTableCellModel] = [
        ADGTableCellModel(locationId: "32924", index: 1),
        ADGTableCellModel(locationId: "32781", index: 5),
        ADGTableCellModel(locationId: "32792", index: 9)        
    ];
    
    var rowCount: Int {
        return adgTableCellModels.count
    }
    
    init(tableView: UITableView) {
        self.tableView = tableView
        adgTableCellModels.forEach{ $0.delegate = self }
    }
    
    /**
     find a element from array by cell index path
     - parameter indexPath: cell index
     - returns: element
     */
    func findByCellIndexPath(_ indexPath: IndexPath) -> ADGTableCellModel? {
        return adgTableCellModels.filter({ $0.adIndex == indexPath.row }).first
    }
    
    func pauseRefresh() {
        adgTableCellModels.forEach{
            $0.adg?.pauseRefresh()
        }
    }
    
}

extension ADGTableCellProvider: ADGTableCellModelDelegate {
    
    func reloadTableViewRows(at: [IndexPath]) {
        self.tableView?.beginUpdates()
        self.tableView?.reloadRows(at: at, with: .none)
        self.tableView?.endUpdates()
    }
}
