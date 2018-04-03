//
//  BlankWebView.swift
//  WKWebViewCookieSync
//
//  Created by SakuiYoshimitsu on 2018/04/03.
//  Copyright © 2018年 ysakui. All rights reserved.
//

import UIKit
import WebKit

class BlankWebView: WKWebView {

    private var completionHandler: (() -> Void)?
    
    func loadBlank(completion: @escaping (() -> Void)) {
        self.navigationDelegate = self
        self.completionHandler = completion
        
        if let url = URL(string: "about:blank") {
            let request = URLRequest(url: url)
            load(request)
        }
    }
}

extension BlankWebView: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.completionHandler?()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.completionHandler?()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.completionHandler?()
    }
}
