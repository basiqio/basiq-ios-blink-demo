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
    var connectionId: String?
    var url: String!
    
    @IBOutlet weak var ResConnLabel: UILabel!
    private var webView: WKWebView?
    var modelController: ModelController!
    
    override func loadView() {
        webView = WKWebView()
        //If you want to implement the delegate
        webView?.navigationDelegate = self
        view = webView
        loadWebView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
                case "connection":
                    let jsonvalue = urlStr.substring(from: "basiq://connection/".endIndex)
                    if let dataFromString = jsonvalue.data(using: .utf8) {
                        let json = try? JSON(data: dataFromString)
                        let connectionId = json?["data"]["id"]
                        if connectionId != JSON.null {
                            self.connectionId = connectionId?.string
                            modelController.connectionId = self.connectionId ?? ""
                            self.dismiss(animated: true)
                            decisionHandler(.cancel)
                        }
                    }else{
                         decisionHandler(.allow)
                    }
                case "cancellation":
                    self.dismiss(animated: true)
                    decisionHandler(.cancel)
                default:
                    decisionHandler(.allow)
                }
            }
        }else{
            //when user interacts with webview
            decisionHandler(.allow)
        }
    }
}

