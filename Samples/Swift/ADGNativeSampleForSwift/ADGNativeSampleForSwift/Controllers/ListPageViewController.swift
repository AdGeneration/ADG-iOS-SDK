//
//  ListPageViewController.swift
//  ADGNativeSampleForSwift
//
//  Created on 2016/08/10.
//  Copyright © 2016年 Supership. All rights reserved.
//

import UIKit

class ListPageViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate let contentsData: [Int] = [Int](0...17)
    
    fileprivate var adgTableCellProvider: ADGTableCellProvider?
    
    fileprivate let rowHight:CGFloat = 138;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // set row height
        tableView.estimatedRowHeight = self.rowHight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // register cell
        tableView.register(UINib(nibName: "BlankTableViewCell", bundle: nil), forCellReuseIdentifier: "BlankTableViewCell")
        tableView.register(UINib(nibName: "ADGNativeAdTableViewCell", bundle: nil), forCellReuseIdentifier: "ADGNativeAdTableViewCell")
        
        adgTableCellProvider = ADGTableCellProvider(tableView: tableView)        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        adgTableCellProvider?.pauseRefresh()
    }
    
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension ListPageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentsData.count + (adgTableCellProvider != nil ? adgTableCellProvider!.rowCount : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var resultCell: UITableViewCell?
        
        if let cellInfo = adgTableCellProvider?.findByCellIndexPath(indexPath) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ADGNativeAdTableViewCell", for: indexPath) as! ADGNativeAdTableViewCell
            
            cellInfo.applyForRowAtIndexPath(self, cell: cell, indexPath: indexPath)
            resultCell = cell
        }
        
        if resultCell == nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BlankTableViewCell") as! BlankTableViewCell
            if let lbl = cell.label {
                lbl.text = String(indexPath.row)
                resultCell = cell
            }
        }
        
        return resultCell!
    }
    
}

extension ListPageViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let cellInfo = adgTableCellProvider?.findByCellIndexPath(indexPath), cellInfo.isError {
            print("ad error row: \(indexPath.row)")
            return 0
        }
        
        return self.rowHight
    }
}


