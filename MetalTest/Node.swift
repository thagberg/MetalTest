//
//  Node.swift
//  MetalTest
//
//  Created by Tim on 7/9/16.
//  Copyright © 2016 Tim. All rights reserved.
//

import Foundation
import Metal
import QuartzCore
import GLKit

public class Node {
    
    let name: String
    var vertexCount: Int
    var vertexBuffer: MTLBuffer
    var device: MTLDevice
    var uniformBuffer: MTLBuffer?
    var texture: Texture
    var samplerState: MTLSamplerState
    
    public var transform: GLKMatrix4
    
    init(name: String, vertices: Array<Vertex>, device: MTLDevice, textureName: String) {
        
        var vertexData = Array<Float>()
        for vertex in vertices {
            vertexData += vertex.floatBuffer()
        }
        
        let dataSize = vertexData.count * sizeofValue(vertexData[0])
        self.vertexBuffer = device.newBufferWithBytes(vertexData, length: dataSize, options: [])
        
        self.name = name
        self.device = device
        self.vertexCount = vertices.count
        
        self.transform = GLKMatrix4Make(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)
        
        self.texture = Texture(device: device, textureName: textureName)
        let samplerDescriptor: MTLSamplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter                 = MTLSamplerMinMagFilter.Nearest
        samplerDescriptor.magFilter                 = MTLSamplerMinMagFilter.Nearest
        samplerDescriptor.mipFilter                 = MTLSamplerMipFilter.Nearest
        samplerDescriptor.maxAnisotropy             = 1
        samplerDescriptor.sAddressMode              = MTLSamplerAddressMode.ClampToEdge
        samplerDescriptor.tAddressMode              = MTLSamplerAddressMode.ClampToEdge
        samplerDescriptor.rAddressMode              = MTLSamplerAddressMode.ClampToEdge
        samplerDescriptor.normalizedCoordinates     = true
        samplerDescriptor.lodMinClamp               = 0
        samplerDescriptor.lodMaxClamp               = FLT_MAX
        self.samplerState = device.newSamplerStateWithDescriptor(samplerDescriptor)
    }
    
    func render(_ commandBuffer: MTLCommandBuffer, _ commandEncoder: MTLRenderCommandEncoder, _ pipelineState: MTLRenderPipelineState, _ projectionMatrix: GLKMatrix4) {
        
        commandEncoder.setRenderPipelineState(pipelineState)
        commandEncoder.setCullMode(MTLCullMode.Front)
        commandEncoder.setVertexBuffer(self.vertexBuffer, offset: 0, atIndex: 0)
        commandEncoder.setFragmentTexture(self.texture.tex, atIndex: 0)
        commandEncoder.setFragmentSamplerState(self.samplerState, atIndex: 0)
        let nodeModelMatrix = self.transform
        let transArray = [Float](arrayLiteral: nodeModelMatrix[0], nodeModelMatrix[1], nodeModelMatrix[2], nodeModelMatrix[3], nodeModelMatrix[4], nodeModelMatrix[5], nodeModelMatrix[6], nodeModelMatrix[7],
                                 nodeModelMatrix[8], nodeModelMatrix[9], nodeModelMatrix[10], nodeModelMatrix[11], nodeModelMatrix[12], nodeModelMatrix[13], nodeModelMatrix[14], nodeModelMatrix[15])
        let projectionArray = [Float](arrayLiteral: projectionMatrix[0], projectionMatrix[1], projectionMatrix[2], projectionMatrix[3], projectionMatrix[4], projectionMatrix[5], projectionMatrix[6],
                                      projectionMatrix[7], projectionMatrix[8], projectionMatrix[9], projectionMatrix[10], projectionMatrix[11], projectionMatrix[12], projectionMatrix[13],
                                      projectionMatrix[14], projectionMatrix[15])
        uniformBuffer = device.newBufferWithLength(sizeof(Float) * 16 * 2, options: [])
        memcpy((uniformBuffer?.contents())!, transArray, sizeof(Float) * 16)
        memcpy((uniformBuffer?.contents())! + sizeof(Float) * 16, projectionArray, sizeof(Float) * 16)
        commandEncoder.setVertexBuffer(self.uniformBuffer, offset: 0, atIndex: 1)
        
        commandEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: 1)
        
    }
    
}
