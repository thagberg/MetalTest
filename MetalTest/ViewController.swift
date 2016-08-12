//
//  ViewController.swift
//  MetalTest
//
//  Created by Tim on 7/9/16.
//  Copyright © 2016 Tim. All rights reserved.
//

import UIKit
import Metal
import QuartzCore
import GLKit

class ViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        device = MTLCreateSystemDefaultDevice()
        
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .BGRA8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
        
        projectionMat = GLKMatrix4MakePerspective(1.48, Float(self.view.bounds.size.width / self.view.bounds.size.height), 0.01, 100.0)
        
        //objectToDraw = Triangle(device: device)
        //objectToDraw = Cube(device: device)
        var cube: Cube = Cube(device: device)
        cube.transform = GLKMatrix4Translate(cube.transform, 2.5, 0, -10.0)
        objectsToDraw.append(cube)
        var cube2: Cube = Cube(device: device)
        cube2.transform = GLKMatrix4Translate(cube2.transform, 0.0, 0.0, -10.0)
        objectsToDraw.append(cube2)
        var tri: Triangle = Triangle(device: device)
        tri.transform = GLKMatrix4Translate(tri.transform, -2.0, 0.0, -5.0)
        objectsToDraw.append(tri)
        
        var testAsset = Model(device: device, modelName: "monkey.obj")
//        var testModel = testAsset.asset[0]
//        var testChildren = testModel!.children.objects
//        var testChild = testChildren[0]
        
        let defaultLibrary = device.newDefaultLibrary()
        let fragmentProgram = defaultLibrary!.newFunctionWithName("basic_fragment")
        let vertexProgram = defaultLibrary!.newFunctionWithName("basic_vertex")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
        
        do {
            try self.pipelineState = device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor)
        } catch let pipelineError as NSError {
            print("Failed to create pipeline state, error \(pipelineError)")
        }
        
        commandQueue = device.newCommandQueue()
        
        timer = CADisplayLink(target: self, selector: #selector(ViewController.gameLoop))
        
        //timer = CADisplayLink(target: self, selector: Selector("gameloop"))
        timer.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func render() {
        let drawable = metalLayer.nextDrawable()!
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .Clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        renderPassDescriptor.colorAttachments[0].storeAction = .Store
        
        let commandBuffer = commandQueue.commandBuffer()
        
        let renderEncoderOpt = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
        for (index, obj) in objectsToDraw.enumerate() {
            obj.render(commandBuffer, renderEncoderOpt, pipelineState, projectionMat!)
        }
        renderEncoderOpt.endEncoding()
        
        //objectToDraw.render(commandBuffer, renderEncoderOpt, pipelineState, projectionMat!)
        //objectToDraw.render(commandQueue, pipelineState: pipelineState, drawable: drawable, projectionMatrix: projectionMat!, clearColor: nil)
        
        commandBuffer.presentDrawable(drawable)
        commandBuffer.commit()
    }
    
    func gameLoop() {
        autoreleasepool {
            self.render()
        }
    }

    var device: MTLDevice! = nil
    var metalLayer: CAMetalLayer! = nil
    
    //var objectsToDraw: [Node]
    var objectsToDraw: [Node] = []
    
    var pipelineState: MTLRenderPipelineState! = nil
    
    var commandQueue: MTLCommandQueue! = nil
    
    var timer: CADisplayLink! = nil
    
    var projectionMat: GLKMatrix4!

    
}

