//
//  Package.swift
//  demo
//
//  Created by Katarina Bantic on 5/02/2018.
//  Copyright © 2018 basiq. All rights reserved.
//

//import Foundation
import PackageDescription
let package = Package(
    name: "Greeter",
    dependencies: [
    .Package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", majorVersion: 3, minor: 1),
    .Package(url: "https://github.com/Alamofire/Alamofire.git", majorVersion: 4)
    ]
)
