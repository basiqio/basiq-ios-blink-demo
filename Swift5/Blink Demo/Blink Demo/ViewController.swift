//
//  ViewController.swift
//  Blink Demo
//
//  Created by Mario Vukasinovic on 02/12/2019.
//  Copyright © 2019 Mario Vukasinovic. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var uiLabelInfo: UILabel!
    @IBOutlet weak var uiButtonConnect: UIButton!
    @IBOutlet weak var uiLabelError: UILabel!
    
    var Text = String()
    var userId: String?
    var clientAccessToken: String?
    var modelController: ModelController!
    var LocalServerHost = "http://192.168.2.144"
    var BasiqWebViewEndpoint = "http://192.168.2.144:9080"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modelController = ModelController()
        getAccessToken(completion: createUser)
        self.uiLabelInfo.text = Text
        self.uiLabelError.text = Text
        self.uiButtonConnect.isEnabled = false
        self.uiButtonConnect.alpha = 0.5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if modelController.connectionId != "" {
            self.uiLabelInfo.text = modelController.connectionId
            self.uiButtonConnect.isHidden = true
        }else{
            self.uiButtonConnect.isHidden = false
        }
        
        if modelController.error != ""{
            self.uiLabelError.text = modelController.error
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let nextScene =  segue.destination as! CustomViewController
        nextScene.url = self.BasiqWebViewEndpoint + "?user_id="+self.userId!+"&access_token="+self.clientAccessToken!
        nextScene.modelController = self.modelController
    }
    
    func getAccessToken(completion: @escaping ()->()){
        let clientData: Parameters = ["client_id": "in12ij3n1onb12"]
        AF.request(self.LocalServerHost + "/access_token", method: .post, parameters: clientData, encoding: JSONEncoding.default, headers: ["Content-Type" :"application/json"]).validate().responseJSON { response in
            switch response.result {
            case .success:
                if response.value is NSNull {
                    return
                }
                if let json = response.value as? [String:AnyObject] {
                    if let entries = json["result"] as? NSDictionary {
                        self.clientAccessToken = entries["access_token"] as? String
                    }
                }
            //print("Validation Successful")
            case .failure(let error):
                self.uiLabelError.text = error.localizedDescription
                return
            }
            completion()
        }
    }
    
    func createUser()->(){
        let userData: Parameters = ["email": "katarina@basiq.io"]
        AF.request(self.LocalServerHost + "/user", method: .post, parameters: userData, encoding: JSONEncoding.default, headers: ["Content-Type" :"application/json"]).validate().responseJSON { response in
            switch response.result {
            case .success:
                if response.value is NSNull {
                    return
                }
                if let json = response.value as? [String:AnyObject] {
                    if let entries = json["result"] as? NSDictionary {
                        self.userId = entries["id"] as? String
                    }
                }
            //print("Validation Successful")
            case .failure(let error):
                self.uiLabelError.text = error.localizedDescription
                return
            }
            self.enableConnectButton()
        }
    }
    
    func enableConnectButton(){
        self.uiButtonConnect.isEnabled = true
        self.uiButtonConnect.alpha = 1.0
    }
    
}

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
