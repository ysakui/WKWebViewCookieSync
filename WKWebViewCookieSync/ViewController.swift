//
//  ViewController.swift
//  WKWebViewCookieSync
//
//  Created by SakuiYoshimitsu on 2017/09/03.
//  Copyright © 2017年 ysakui. All rights reserved.
//

import UIKit
import WebKit

final class ViewController: UIViewController {
    private var webView: WKWebView?
    
    func setUpWKWebView() {
        let configuration = WKWebViewConfiguration()
        
        // 共有しているprocessPoolを使う
        configuration.processPool = WKCookieStorage.shared.sharedProcessPool
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(webView)
        
        NSLayoutConstraint.activate(
            [
                webView.topAnchor.constraint(equalTo: view.topAnchor),
                webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ]
        )
        
        self.webView = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpWKWebView()
        
        if let url = URL(string: "https://google.co.jp") {
            let request = URLRequest(url: url)
            webView?.load(request)
        }
        
        WKCookieStorage.shared.setCookie(name: "test", value: "hogehoge") { 
            print("setCookie success")
            
            WKCookieStorage.shared.getCookiesString { (cookiesString) in
                print("cookiesString -> \(cookiesString ?? "")")
            }
        }
        
    }
}

