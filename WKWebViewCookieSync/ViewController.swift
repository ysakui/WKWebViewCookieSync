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
    
    @objc func setUpWKWebView() {
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
    
    private let urlRequest = URLRequest(url: URL(string: "https://yahoo.co.jp/")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpWKWebView()
        
        webView?.load(urlRequest)
        
        updateCookiesForiOS10()
    }
    
    private var dummyWebView: BlankWebView?
    
    @IBAction func updateButtonDidTapped(_ sender: Any) {
//        updateCookiesForiOS10()
        
        webView?.load(urlRequest)
        
        if self.dummyWebView == nil {
            let configuration = WKWebViewConfiguration()
            configuration.processPool = WKCookieStorage.shared.sharedProcessPool
            self.dummyWebView = BlankWebView(frame: .zero, configuration: configuration)
        }
        
        self.dummyWebView?.loadBlank { [weak self] in
            print("🐷 finish loading")
            
            if #available(iOS 11.0, *),
                let cookieStore = self?.dummyWebView?.configuration.websiteDataStore.httpCookieStore {
                
                let value = "\(arc4random_uniform(10000))"
                let cookie = HTTPCookie(properties: [
                    HTTPCookiePropertyKey.domain: "example.com",
                    HTTPCookiePropertyKey.path: "/",
                    HTTPCookiePropertyKey.name: "test",
                    HTTPCookiePropertyKey.value: value,
                    HTTPCookiePropertyKey.expires: Date()
                    ])!
                cookieStore.setCookie(cookie, completionHandler: {
                    print("🐶 setCookie success -> \(value)")
                })
                
                cookieStore.getAllCookies({ (cookies) in
                    var value: String?
                    for cookie in cookies {
                        if cookie.name == "test" {
                            value = cookie.value
                        }
                    }
                    
                    print("🐶 success get cookie -> \(value ?? "")")
                })
            }
        }
    }
    
    private func updateCookiesForiOS10() {
        let randomValue = "\(arc4random_uniform(10000))"
        WKCookieStorage.shared.setCookie(name: "test", value: randomValue) {
            print("setCookie success")
            
//            WKCookieStorage.shared.getCookiesString { (cookiesString) in
//                print("cookiesString -> \(cookiesString ?? "")")
//            }
        }
    }
}

