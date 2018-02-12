//
//  WelcomeViewController.swift
//  demo
//
//  Created by Katarina Bantic on 8/02/2018.
//  Copyright © 2018 basiq. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import Alamofire
import SwiftyJSON

class ModelController {
    var connectionId = ""
    var error = ""
    
    func setConnectionID(connectionId : String){
        self.connectionId = connectionId
        self.error = ""
    }
    
    func setError(err : String){
        self.error = err
        self.connectionId = ""
    }
}

class WelcomeViewController : UIViewController {
    var Text = String()
    var userId: String?
    var clientAccessToken: String?
    var modelController: ModelController!
    
    @IBOutlet weak var ConnectButton: UIButton!
    @IBOutlet weak var ConnectionIdLabel: UILabel!
    @IBOutlet weak var ErrorLabel: UILabel!
    
    var LocalServerHost = "http://192.168.2.144"
    var BasiqWebViewEndpoint = "http://192.168.2.144:9080"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAccessToken(completion: createUser)
        self.ConnectionIdLabel.text = Text
        self.ErrorLabel.text = Text
        self.ConnectButton.isEnabled = false
        self.ConnectButton.alpha = 0.5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if modelController.connectionId != "" {
            self.ConnectionIdLabel.text = modelController.connectionId
            self.ConnectButton.isHidden = true
        }else{
            self.ConnectButton.isHidden = false
        }
        
        if modelController.error != ""{
            self.ErrorLabel.text = modelController.error
        }
    }
    
    func getAccessToken(completion: @escaping ()->()){
        let clientData: Parameters = ["client_id": "in12ij3n1onb12"]
        Alamofire.request(self.LocalServerHost + "/access_token", method: .post, parameters: clientData, encoding: JSONEncoding.default, headers: ["Content-Type" :"application/json"]).validate().responseJSON { response in
            switch response.result {
            case .success:
                if response.result.value is NSNull {
                    return
                }
                if let json = response.result.value as? [String:AnyObject] {
                    if let entries = json["result"] as? NSDictionary {
                        self.clientAccessToken = entries["access_token"] as? String
                    }
                }
                //print("Validation Successful")
            case .failure(let error):
                self.ErrorLabel.text = error.localizedDescription
                return
            }
            completion()
        }
    }
    
    func createUser()->(){
        let userData: Parameters = ["email": "katarina@basiq.io"]
        Alamofire.request(self.LocalServerHost + "/user", method: .post, parameters: userData, encoding: JSONEncoding.default, headers: ["Content-Type" :"application/json"]).validate().responseJSON { response in
            switch response.result {
            case .success:
                if response.result.value is NSNull {
                    return
                }
                if let json = response.result.value as? [String:AnyObject] {
                    if let entries = json["result"] as? NSDictionary {
                        self.userId = entries["id"] as? String
                    }
                }
                //print("Validation Successful")
            case .failure(let error):
                self.ErrorLabel.text = error.localizedDescription
                return
            }
            self.enableConnectButton()
        }
    }
    
    func enableConnectButton(){
        self.ConnectButton.isEnabled = true
        self.ConnectButton.alpha = 1.0
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let nextScene =  segue.destination as! ViewController
        nextScene.url = self.BasiqWebViewEndpoint + "?user_id="+self.userId!+"&access_token="+self.clientAccessToken!
        nextScene.modelController = self.modelController
    }
}
