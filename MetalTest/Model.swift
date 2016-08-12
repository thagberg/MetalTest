//
//  Model.swift
//  MetalTest
//
//  Created by Tim on 7/12/16.
//  Copyright © 2016 Tim. All rights reserved.
//

import Foundation
import Metal
import MetalKit
import ModelIO

class Model {
    var modelName: String
    var asset: MDLAsset
    
    init(device: MTLDevice, modelName: String) {
        
        self.modelName = modelName
        
        var url: NSURL = NSBundle.mainBundle().resourceURL!
        url = url.URLByAppendingPathComponent(modelName)
        self.asset = MDLAsset.init(URL: url)
    }
}