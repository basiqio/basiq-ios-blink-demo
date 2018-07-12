# Basiq Blink iOS integration

## Prerequisites

Installed Xcode version > 8.2
Installed Swift 3

## Installation
Package manager is CocoaPods

```sudo gem install cocoapods```

```pod install```

## Running

To open application in Xcode type from command-line

```open demo.xcworkspace```


## Server requirements

To run the example, your API must expose two endpoints, ```/access_token``` and ```/user```. These
endpoints must return the access_token that was retrieved from Basiq's API with the CLIENT_CREDENTIALS
scope, and a user_id that will be used to create the connection.

You can find an example server implementation [here](https://github.com/basiqio/basiq-blink-server-example)


## Example WebViewClient

You can find the source code from the example [here](https://github.com/basiqio/basiq-ios-blink-demo/blob/master/demo/ViewController.swift).

As you can see in the following code snippet:

```swift
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
```

We detect if the url starts with the "basiq" protocol, and in that case parse it. The
payload is a JSON string, and it comes after the event name. Example:

```
basiq://connection/{"id":"klqwd-qwdoijjoqd102wq-djkqw"}
```

In the example, *connection* is the event name, and the payload contains the connection id
in the JSON. We can extract connectionId from such response, and continue to use it.

