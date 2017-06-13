//
//  Log.swift
//  ADGSampleForSwift
//
//  Created on 2016/07/04.
//  Copyright © 2016年 Supership. All rights reserved.
//

import Foundation

class Log {
    class func format(_ log: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        return dateFormatter.string(from: Date()) + " " + log + "\n"
    }
}
