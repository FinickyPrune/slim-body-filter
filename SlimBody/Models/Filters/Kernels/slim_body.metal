#include <metal_stdlib>
#include <CoreImage/CoreImage.h>
using namespace metal;


extern "C" { namespace coreimage {

    //    For slim body effect we use function f(x) = exp(x^2) and also addind to it shifts and multipliers.
    //    In this case x-axis is [0; roi_width/2] line segment, where zero is center of region of our filter.

    float offset_for_point(float2 coords,
                           int intensivity,
                           float2 center,
                           float roi_width,
                           float roi_height) {

        //    on [0; edge*roi_width/2] segment funtion don't affect on our picture.
        //    on [edge; roi_width/2] segment we use f(x) with center in exp_center (in the middle of segment). And also shift function down to implicitly provide zero values in border values of segment: f(edge*roi_width/2) = 0 f(roi_width/2) = 0

        float edge = 0.12;
        float exp_center = 0.6;
        float x = edge * roi_width/2;

        //      All constants like edge, -80, 1.005, 0.3, 0.013 is selected iteratively lauching filter, so in future it could be changed to affect on filter behavior.

        float y = exp(-80 * pow(x - (exp_center * roi_width/2), 2));

        float delta_x = abs(center.x - coords.x);
        float st_1 = step(edge * roi_width/2, delta_x);
        float st_2 = step(roi_width/2, delta_x);

        float x_offset = (exp(-80 * pow(delta_x - (exp_center * roi_width/2), 2)) - y) * st_1 * (1 - st_2);

        float delta_y = abs(center.y - coords.y);
        float st_y = step(roi_height/2, delta_y);

        x = roi_height/2;
        y = -pow(x, 1.005) * 0.3;

        //      for y-axis behavior was chosen f(y) = -(y)^2 shifted up to implicitly provide zero values in border values of segment: f(roi_height/2) = 0

        float y_offset =  (-pow(delta_y, 1.005) * 0.3 - y) * (1 - st_y);

        float offset = 0.013 * float(intensivity) * x_offset * y_offset;

        return offset;
    }

    bool pixel_in_selected_area(float2 coord,
                                float roi_width,
                                float roi_height) {

        return  (coord.x > 0) &&
        (coord.x < roi_width) &&
        (coord.y > 0) &&
        (coord.y < roi_height);
    }

    float4 slim_body(sampler source,
                     float roi_width,
                     float roi_height,
                     float width,
                     float height,
                     int intensivity,
                     float a, float b, float c, float d, float tx, float ty,
                     float _a, float _b, float _c, float _d, float _tx, float _ty
                     ) {

        // Build transform matrixes.

        float3x3 transform = float3x3(float3(a, c, tx), float3(b, d, ty), float3(0, 0, 1));
        float3x3 inverted_transform = float3x3(float3(_a, _c, _tx), float3(_b, _d, _ty), float3(0, 0, 1));

        // Calculate absolute coordinates of pixel from normalized coordinates.

        float2 point = source.coord();
        point = float2(point.x * width, height - point.y * height);

        // Move pixel to initial point using inverted transform.

        float3 transformed_point = float3(point.x, point.y, 1) * inverted_transform;

        // Calculate offset for pixel (coordinated are normalized back) depending on his horizontal and vertical position in selected area.

        float offset = offset_for_point(float2(transformed_point.x/width, transformed_point.y/height),
                                        intensivity,
                                        float2(0.5 * roi_width/width, 0.5 * roi_height/height),
                                        roi_width/width,
                                        roi_height/height);

        // Move pixel with offset.

        float2 s = float2(0, 0);
        float st = step(roi_width * 0.5, transformed_point.x);
        s = float2(transformed_point.x + st * offset * width - (1 - st) * offset * width, transformed_point.y);

        // Move pixel back to his location using his transform.

        float3 rotated_s = float3(s.x, s.y, 1) * transform;
        return sample(source, float2(rotated_s.x/width, 1 - rotated_s.y/height));
    }

}}
