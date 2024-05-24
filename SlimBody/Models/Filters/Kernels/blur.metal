#include <metal_stdlib>
#include <CoreImage/CoreImage.h>
using namespace metal;

#define CRITICAL_BLUR_RADIUS_VALUE 3
#define MASK_BLACK float4(0.15, 0.15, 0.15, 1)

// Returns Gauss destribution for input value

float gauss(float x, float sigma) {
    return 1 / sqrt(2 * M_PI_H * sigma * sigma) * exp(-x * x / (2 * sigma * sigma));
};

extern "C" { namespace coreimage {

    // Blur filter is based on Gauss destribution to calculate how intensive close pixels tones will be affect on current on center pixel.

    float4 blur(sampler sample, float width, float height, int radius) {

        float2 crd = sample.coord();

        //      Define parameters for blur implementation

        float sigma = max(float(radius/2), 1.0);
        int kernel_size = radius * 2 + 1;
        float kernel_weight = 0;

        //      If blur radius not heavy enough kernel processes every pixel around pixel in given radius.

        if (radius < CRITICAL_BLUR_RADIUS_VALUE) {

            //          Count blur kernel weight

            for (int j = 0; j <= kernel_size - 1; j++) {
                for (int i = 0; i <= kernel_size - 1; i++) {
                    int2 normalized_position(i - radius, j - radius);
                    kernel_weight += gauss(normalized_position.x, sigma) * gauss(normalized_position.y, sigma);
                }
            }

            float4 blured_color(0, 0, 0, 0);
            for (int j = 0; j <= kernel_size - 1; j++) {
                for (int i = 0; i <= kernel_size - 1; i++) {
                    int2 normalized_position(i - radius, j - radius);
                    float2 texture_index(crd.x + (i - radius)/width, crd.y + (j - radius)/height);
                    float factor = gauss(normalized_position.x, sigma) * gauss(normalized_position.y, sigma) / kernel_weight;
                    blured_color += factor * sample.sample(texture_index);
                }
            }

            return blured_color;

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

                float2 texture_index(crd.x + (normalized_position.x)/width, crd.y + (normalized_position.y)/height);
                factor = gauss(normalized_position.x, sigma) * gauss(normalized_position.y, sigma) / kernel_weight;
                blured_color += factor * sample.sample(texture_index);

                // Left

                float2 texture_index1(crd.x + (normalized_position.x)/width, crd.y + (normalized_position.y + step)/height);
                factor = gauss(normalized_position.x, sigma) * gauss(normalized_position.y + step, sigma) / kernel_weight;
                blured_color += factor * sample.sample(texture_index1);

                // Bottom-left

                float2 texture_index2(crd.x + (normalized_position.x)/width, crd.y + (normalized_position.y + 2*step)/height);
                factor = gauss(normalized_position.x, sigma) * gauss(normalized_position.y + 2*step, sigma) / kernel_weight;
                blured_color += factor * sample.sample(texture_index2);

                // Top

                float2 texture_index3(crd.x + (normalized_position.x + step)/width, crd.y + (normalized_position.y)/height);
                factor = gauss(normalized_position.x + step, sigma) * gauss(normalized_position.y, sigma) / kernel_weight;
                blured_color += factor * sample.sample(texture_index3);

                // Bottom

                float2 texture_index4(crd.x + (normalized_position.x + step)/width, crd.y + (normalized_position.y + 2*step)/height);
                factor = gauss(normalized_position.x + step, sigma) * gauss(normalized_position.y + 2*step, sigma) / kernel_weight;
                blured_color += factor * sample.sample(texture_index4);

                // Top-right

                float2 texture_index5(crd.x + (normalized_position.x + 2*step)/width, crd.y + (normalized_position.y)/height);
                factor = gauss(normalized_position.x + 2*step, sigma) * gauss(normalized_position.y, sigma) / kernel_weight;
                blured_color += factor * sample.sample(texture_index5);

                // Right

                float2 texture_index6(crd.x + (normalized_position.x + 2*step)/width, crd.y + (normalized_position.y + step)/height);
                factor = gauss(normalized_position.x + 2*step, sigma) * gauss(normalized_position.y + step, sigma) / kernel_weight;
                blured_color += factor * sample.sample(texture_index6);

                // Bottom-right

                float2 texture_index7(crd.x + (normalized_position.x + 2*step)/width, crd.y + (normalized_position.y + 2*step)/height);
                factor = gauss(normalized_position.x + 2*step, sigma) * gauss(normalized_position.y + 2*step, sigma) / kernel_weight;
                blured_color += factor * sample.sample(texture_index7);
            }
            return blured_color;
        }
    }

}}
