#include <metal_stdlib>
using namespace metal;

#define CRITICAL_BLUR_RADIUS_VALUE 3

// Returns Gauss destribution for input value

float gauss(float x, float sigma) {
    return 1 / sqrt(2 * M_PI_H * sigma * sigma) * exp(-x * x / (2 * sigma * sigma));
};

// Blur filter is based on Gauss destribution to calculate how intensive close pixels tones will be affect on current on center pixel.

kernel void blur(texture2d<float, access::read> input [[ texture(0) ]],
                 texture2d<float, access::write> output [[ texture(1) ]],
                 constant int& radius [[buffer(0)]],
                 ushort2 position [[thread_position_in_grid]]) {

    //      Define parameters for blur implementation

    float sigma = max(radius*input.get_width()/2, input.get_width());
    int kernel_size = radius * 2 + 1;
    float kernel_weight = 0;
    
    //      If blur radius not heavy enough kernel processes every pixel around pixel in given radius.
    
        if (radius < CRITICAL_BLUR_RADIUS_VALUE) {
    
            //          Count blur kernel weight
    
            for (int j = 0; j < kernel_size; j++) {
                for (int i = 0; i < kernel_size; i++) {
                    int2 centered_position(i - radius, j - radius);
                    kernel_weight += gauss(centered_position.x, sigma) * gauss(centered_position.y, sigma);
                }
            }
    
            float4 blured_color(0, 0, 0, 0);
            for (int j = 0; j < kernel_size; j++) {
                for (int i = 0; i < kernel_size; i++) {
                    int2 centered_position(i - radius, j - radius);
                    ushort2 texture_index(position.x + (i - radius), position.y + (j - radius));
                    float factor = gauss(centered_position.x, sigma) * gauss(centered_position.y, sigma) / kernel_weight;
                    blured_color += factor * input.read(texture_index).rgba;
                }
            }
    
            output.write(float4(blured_color.rgb, 1), position);
            return;
    
        } else { // If blur radius is heavy kernel processes only every fourth pixel in givel radius and only in 8 main directions (top, bottom, left, right, top-right, top-left, bottom-right, bottom-left)
    
            for (int j = 0; j <= kernel_size / 2; j += 4) {
                int2 normalized_position(j - radius, j - radius);
                float step = j > radius ? (j - radius) : (radius - j);
                kernel_weight += gauss(normalized_position.x, sigma) * gauss(normalized_position.y, sigma);
                kernel_weight += gauss(normalized_position.x, sigma) * gauss(normalized_position.y + step, sigma);
                kernel_weight += gauss(normalized_position.x, sigma) * gauss(normalized_position.y + 2*step, sigma);
                kernel_weight += gauss(normalized_position.x + step, sigma) * gauss(normalized_position.y, sigma);
                kernel_weight += gauss(normalized_position.x + step, sigma) * gauss(normalized_position.y + 2*step, sigma);
                kernel_weight += gauss(normalized_position.x + 2*step, sigma) * gauss(normalized_position.y, sigma);
                kernel_weight += gauss(normalized_position.x + 2*step, sigma) * gauss(normalized_position.y + step, sigma);
                kernel_weight += gauss(normalized_position.x + 2*step, sigma) * gauss(normalized_position.y + 2*step, sigma);
            }
            float4 blured_color(0, 0, 0, 0);
    
            for (int j = 0; j <= kernel_size / 2; j += 4) {
                float factor = 0;
                int2 normalized_position(j - radius, j - radius);
                float step = (j > radius) ? (j - radius) : (radius - j);
    
                // Directions
    
                // Top-left
    
                ushort2 texture_index(position.x + (normalized_position.x), position.y + (normalized_position.y));
                factor = gauss(normalized_position.x, sigma) * gauss(normalized_position.y, sigma) / kernel_weight;
                blured_color += factor * input.read(texture_index).rgba;
    
                // Left
    
                ushort2 texture_index1(position.x + (normalized_position.x), position.y + (normalized_position.y + step));
                factor = gauss(normalized_position.x, sigma) * gauss(normalized_position.y + step, sigma) / kernel_weight;
                blured_color += factor * input.read(texture_index1).rgba;
    
                // Bottom-left
    
                ushort2 texture_index2(position.x + (normalized_position.x), position.y + (normalized_position.y + 2*step));
                factor = gauss(normalized_position.x, sigma) * gauss(normalized_position.y + 2*step, sigma) / kernel_weight;
                blured_color += factor * input.read(texture_index2).rgba;
    
                // Top
    
                ushort2 texture_index3(position.x + (normalized_position.x + step), position.y + (normalized_position.y));
                factor = gauss(normalized_position.x + step, sigma) * gauss(normalized_position.y, sigma) / kernel_weight;
                blured_color += factor * input.read(texture_index3).rgba;
    
                // Bottom
    
                ushort2 texture_index4(position.x + (normalized_position.x + step), position.y + (normalized_position.y + 2*step));
                factor = gauss(normalized_position.x + step, sigma) * gauss(normalized_position.y + 2*step, sigma) / kernel_weight;
                blured_color += factor * input.read(texture_index4).rgba;
    
                // Top-right
    
                ushort2 texture_index5(position.x + (normalized_position.x + 2*step), position.y + (normalized_position.y));
                factor = gauss(normalized_position.x + 2*step, sigma) * gauss(normalized_position.y, sigma) / kernel_weight;
                blured_color += factor * input.read(texture_index5).rgba;
    
                // Right
    
                ushort2 texture_index6(position.x + (normalized_position.x + 2*step), position.y + (normalized_position.y + step));
                factor = gauss(normalized_position.x + 2*step, sigma) * gauss(normalized_position.y + step, sigma) / kernel_weight;
                blured_color += factor * input.read(texture_index6).rgba;
    
                // Bottom-right
    
                ushort2 texture_index7(position.x + (normalized_position.x + 2*step), position.y + (normalized_position.y + 2*step));
                factor = gauss(normalized_position.x + 2*step, sigma) * gauss(normalized_position.y + 2*step, sigma) / kernel_weight;
                blured_color += factor * input.read(texture_index7).rgba;
            }
            output.write(float4(blured_color.rgb, 1), position);
            return;
        }
}
