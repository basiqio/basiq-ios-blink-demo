//
//  Final.swift
//  demo
//
//  Created by Katarina Bantic on 8/02/2018.
//  Copyright © 2018 basiq. All rights reserved.
//

import Foundation
import UIKit


class Final : UIViewController {
    
    @IBOutlet weak var Result: UILabel!
    var Text = String()
    
    
    override func viewDidLoad() {
        print("viewdidload")
        Result.text = Text
    }
}
