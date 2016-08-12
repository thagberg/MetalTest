//
//  Vertex.swift
//  MetalTest
//
//  Created by Tim on 7/9/16.
//  Copyright © 2016 Tim. All rights reserved.
//

struct Vertex {
  
    var x, y, z: Float
    var r, g, b, a: Float
    var s, t: Float
    
    func floatBuffer() -> [Float] {
        return [x,y,z,r,g,b,a,s,t]
    }
};
