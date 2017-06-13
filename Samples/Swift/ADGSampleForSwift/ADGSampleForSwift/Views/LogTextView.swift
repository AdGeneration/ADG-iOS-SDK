//
//  LogTextView.swift
//  ADGSampleForSwift
//
//  Created on 2016/07/14.
//  Copyright © 2016年 Supership. All rights reserved.
//

import UIKit

class LogTextView: UITextView {
    
    func appendLog(_ text: String) {
        self.text.append(Log.format(text))
    }
}
