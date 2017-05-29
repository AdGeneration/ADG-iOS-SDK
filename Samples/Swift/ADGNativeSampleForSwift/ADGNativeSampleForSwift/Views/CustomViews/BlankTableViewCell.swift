//
//  BlankTableViewCell.swift
//  ADGNativeSampleForSwift
//
//  Created by yuki.kuroda on 2016/08/10.
//  Copyright © 2016年 Supership. All rights reserved.
//

import UIKit

class BlankTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
