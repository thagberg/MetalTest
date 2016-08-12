//
//  Texture.swift
//  MetalTest
//
//  Created by Tim on 7/11/16.
//  Copyright © 2016 Tim. All rights reserved.
//

import Foundation
import Metal
import UIKit

class Texture {

    var texDescriptor: MTLTextureDescriptor! = nil
    var tex: MTLTexture! = nil
    var width: Int
    var height: Int
    var depth: Int = 8
    var bytesPerPixel: Int = 4
    
    init(device: MTLDevice, textureName: String) {
        
        let texImage: UIImage = UIImage(named: textureName, inBundle: nil, compatibleWithTraitCollection: nil)!
        let imageRef = texImage.CGImage
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        self.width = CGImageGetWidth(imageRef)
        self.height = CGImageGetHeight(imageRef)
        
        let rowBytes = width * self.bytesPerPixel
        
        let context = CGBitmapContextCreate(nil, self.width, self.height, self.depth, rowBytes, colorSpace, CGImageAlphaInfo.PremultipliedLast.rawValue)
        let bounds = CGRect(x: 0, y: 0, width: self.width, height: self.height)
        CGContextClearRect(context, bounds)
        
        CGContextDrawImage(context, bounds, imageRef)
    
        self.texDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(MTLPixelFormat.RGBA8Unorm, width: self.width, height: self.height, mipmapped: false)
        self.tex = device.newTextureWithDescriptor(self.texDescriptor)
        
        let pixelsData = CGBitmapContextGetData(context)
        let texRegion = MTLRegionMake2D(0, 0, self.width, self.height)
        self.tex.replaceRegion(texRegion, mipmapLevel: 0, withBytes: pixelsData, bytesPerRow: rowBytes)
        
    }
}
