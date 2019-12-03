//
//  CustomViewController.swift
//  Blink Demo
//
//  Created by Mario Vukasinovic on 03/12/2019.
//  Copyright © 2019 Mario Vukasinovic. All rights reserved.
//

import UIKit
import SwiftyJSON
import WebKit


class CustomViewController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var wkWebView: WKWebView!
    
    var url: String!
    var modelController: ModelController!
    
    struct Constants{
        static let CONNECTION_EVENT = "connection"
        static let CANCELLATION_EVENT = "cancellation"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func loadView() {
        wkWebView?.navigationDelegate = self
        view = wkWebView
        loadWebView()
    }
    
    func loadWebView(){
        let nsurl = NSURL (string: self.url);
        let requestObj = NSURLRequest(url: nsurl as! URL);
        self.wkWebView!.load(requestObj as URLRequest);
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
