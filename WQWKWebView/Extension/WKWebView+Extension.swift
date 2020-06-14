//
//  WKWebView+Extension.swift
//  WQWKWebView
//
//  Created by chenweiqiang on 2020/6/6.
//  Copyright © 2020 chenweiqiang. All rights reserved.
//

import UIKit
import WebKit

extension WKWebView{
    func load(_ string: String){
        if let url = URL(string: string){
            load(URLRequest(url: url))
        }
    }
}
