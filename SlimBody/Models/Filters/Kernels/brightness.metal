#include <metal_stdlib>
#include <CoreImage/CoreImage.h>
using namespace metal;

extern "C" { namespace coreimage {
    
    float4 brightness(sampler sample, float width, float height, float factor) {
        
        float2 crd = sample.coord();
        
        return float4(
                      sample.sample(crd)[0] * factor,
                      sample.sample(crd)[1] * factor,
                      sample.sample(crd)[2] * factor,
                      sample.sample(crd)[3]
                      );
    }
}
    
}
