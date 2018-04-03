//
//  WKCookieStorage.swift
//  WKWebViewCookieSync
//
//  Created by SakuiYoshimitsu on 2017/09/06.
//  Copyright © 2017年 ysakui. All rights reserved.
//

import UIKit
import WebKit

final class WKCookieStorage: NSObject {
    @objc static let shared = WKCookieStorage()
    
    @objc fileprivate(set) var sharedProcessPool: WKProcessPool = WKProcessPool()
    fileprivate var webView: WKWebView?
    
    private let htmlTemplate = "<DOCTYPE html><html><body></body></html>"
    private let dummyBaseURL = URL(string: "https://dummy.google.co.jp")
    fileprivate let getCookiesStringHandler = "getCookiesStringHandler"
    fileprivate let setCookieHandler = "setCookieHandler"
    
    fileprivate var getCookiesCompletion: ((_ cookiesString: String?) -> Void)?
    fileprivate var setCookieCompletion: (() -> Void)?
    
    @objc func getCookiesString(completion: @escaping (_ cookiesString: String?) -> Void) {
        self.getCookiesCompletion = completion
        
        let javaScriptString = "webkit.messageHandlers.\(self.getCookiesStringHandler).postMessage(document.cookie)"
        
        loadHTMLString(javaScriptString: javaScriptString, messageHandler: self.getCookiesStringHandler)
    }
    
    @objc func setCookie(name: String, value: String, completion: @escaping () -> Void) {
        self.setCookieCompletion = completion
        
        let javaScriptString = "webkit.messageHandlers.\(self.setCookieHandler).postMessage(document.cookie='\(name)=\(value)')"
        
        loadHTMLString(javaScriptString: javaScriptString, messageHandler: self.setCookieHandler)
    }
    
    private func loadHTMLString(javaScriptString: String, messageHandler: String) {
        let userScript = WKUserScript(
            source: javaScriptString,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        
        let controller = WKUserContentController()
        controller.addUserScript(userScript)
        controller.add(self, name: messageHandler)
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = controller
        configuration.processPool = self.sharedProcessPool
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        
        webView.loadHTMLString(htmlTemplate, baseURL: dummyBaseURL)
        
        self.webView = webView
    }
}

extension WKCookieStorage: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.webView?.stopLoading()
        self.webView = nil
        
        switch message.name {
        case self.getCookiesStringHandler:
            if let cookiesString = message.body as? String {
                self.getCookiesCompletion?(cookiesString)
            } else {
                self.getCookiesCompletion?(nil)
            }
            
        case self.setCookieHandler:
            self.setCookieCompletion?()
            
        default:
            break
        }
    }
}
