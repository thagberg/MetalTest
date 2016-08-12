//
//  Shaders.metal
//  MetalTest
//
//  Created by Tim on 7/9/16.
//  Copyright © 2016 Tim. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Uniforms {
    float4x4 modelMatrix;
    float4x4 viewProj;
};

struct VertexIn {
    packed_float3 position;
    packed_float4 color;
    packed_float2 texCoord;
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
    float2 texCoord;
};

vertex VertexOut basic_vertex(
    const device VertexIn* vertex_array [[ buffer(0) ]],
    const device Uniforms& uniforms     [[ buffer(1) ]],
    unsigned int vid [[ vertex_id ]]) {
    
    float4x4 mv_Matrix = uniforms.modelMatrix;
    float4x4 viewProj = uniforms.viewProj;
    
    VertexIn in = vertex_array[vid];
    
    VertexOut out;
    out.position = viewProj * mv_Matrix * float4(in.position, 1);
    out.color = in.color;
    out.texCoord = in.texCoord;
    
    return out;
}

fragment float4 basic_fragment(VertexOut lerp [[stage_in]],
                              texture2d<float> tex2D [[texture(0)]],
                              sampler sampler2D [[sampler(0)]]) {
    //return half4(lerp.color[0], lerp.color[1], lerp.color[2], lerp.color[3]);
    return tex2D.sample(sampler2D, lerp.texCoord);
}

