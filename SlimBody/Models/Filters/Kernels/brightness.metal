#include <metal_stdlib>
using namespace metal;

kernel void brightness(texture2d<float, access::read> input [[ texture(0) ]],
                       texture2d<float, access::write> output [[ texture(1) ]],
                       constant float& factor [[buffer(0)]],
                       ushort2 position [[thread_position_in_grid]]) {
    float4 inputColor = input.read(position);
    
    inputColor *= factor;
    
    output.write(inputColor, position);
}
