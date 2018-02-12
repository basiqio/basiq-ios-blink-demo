//
//  ViewController.swift
//  demo
//
//  Created by Katarina Bantic on 5/02/2018.
//  Copyright © 2018 basiq. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON

class ViewController: UIViewController, WKNavigationDelegate {
    var url: String!
    var webView: WKWebView?
    var modelController: ModelController!
    
    struct Constants{
        static let CONNECTION_EVENT = "connection"
        static let CANCELLATION_EVENT = "cancellation"
    }

    override func loadView() {
        webView = WKWebView()
        webView?.navigationDelegate = self
        view = webView
        loadWebView()
    }
    
    func loadWebView(){
        let nsurl = NSURL (string: self.url);
        let requestObj = NSURLRequest(url: nsurl as! URL);
        self.webView!.load(requestObj as URLRequest);
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .other{
            if let urlStr = navigationAction.request.mainDocumentURL?.absoluteURL.absoluteString.removingPercentEncoding!{
                var event = urlStr.substring(from: "basiq://".endIndex)
                if let lastIndex = event.range(of:"/"){
                    event = event.substring(to:(lastIndex.lowerBound))
                }
                switch event{
                case Constants.CONNECTION_EVENT:
                    let jsonvalue = urlStr.substring(from: "basiq://connection/".endIndex)
                    if let dataFromString = jsonvalue.data(using: .utf8) {
                        let json = try? JSON(data: dataFromString)
                        if let success = json?["success"], success.boolValue{
                            if let connectionId = json?["data"]["id"],connectionId.string != nil {
                                modelController.setConnectionID(connectionId: connectionId.string!)
                                self.dismiss(animated: true)
                                decisionHandler(.cancel)
                            }else{
                                modelController.setError(err: "Cannot parse connectionId from request data!")
                                self.dismiss(animated: true)
                                decisionHandler(.cancel)
                            }
                        }else{
                            //This should be handled on webview
                            print("Message should be disaplyed on web-view")
                            decisionHandler(.allow)
                        }
                    }else{
                        modelController.setError(err: "Cannot parse WebView request data!")
                        self.dismiss(animated: true)
                        decisionHandler(.cancel)
                    }
                case Constants.CANCELLATION_EVENT:
                    self.dismiss(animated: true)
                    decisionHandler(.cancel)
                default:
                    decisionHandler(.allow)
                }
            }else{
                modelController.setError(err: "Cannot parse WebView request URL!")
                self.dismiss(animated: true)
                decisionHandler(.cancel)
            }
        }else{
            //when user interacts with webview
            decisionHandler(.allow)
        }
    }
}

