// https://www.shadertoy.com/view/ldjcWh
// based on http://i.imgur.com/Yh35xhH.gif

const vec3 COLOR_FG = vec3(ivec3(77, 255, 74)) / 255.0;
const vec3 COLOR_BG = vec3(0.0);

const float NUMBER_OF_CIRCLES = 9.0;
const float SPEED_RATIO = 0.2;

const float BAR_WIDTH = 1.0 / 3.0;
const float BAR_MARGIN = (1.0 - BAR_WIDTH) * 0.5;
const float MARGIN = 30.0 / 270.0;

const float PI = 3.14159265359;

float aastep(float threshold, float value)
{
    float aaf = fwidth(value) * 0.5;
    return smoothstep(threshold-aaf, threshold+aaf, value);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = 2.0 * fragCoord.xy / iResolution.xy - vec2(1.0);
    uv.x *= iResolution.x / iResolution.y;
    
    float a = 1.0-mod(0.25+0.5+atan(uv.y, uv.x)*0.5/PI,1.0);
    float d = length(uv);
    
    float c = 0.0;
    
    if (d > MARGIN && d < (1.0 - MARGIN))
    {
        float dd = (d - MARGIN) / (1.0 - MARGIN * 2.0);
        float qq = floor(dd * NUMBER_OF_CIRCLES) / NUMBER_OF_CIRCLES;
        float qq0 = floor(dd * NUMBER_OF_CIRCLES) / (NUMBER_OF_CIRCLES-1.0);        
        float rr = fract(dd * NUMBER_OF_CIRCLES);
        if (rr > BAR_MARGIN && rr < (1.0-BAR_MARGIN))
        {
            float rrr = 1.0-abs(2.0*(rr - BAR_MARGIN)/BAR_WIDTH-1.0);
            float speed = (11.0 - qq0*10.0) * SPEED_RATIO;
            float aa = mod(a - iGlobalTime * speed - iGlobalTime * 0.05, 1.0); 
            if (aa > 0.5)
            {
        		c = aastep(1.0-aa,rrr*0.5);
            }
        }
    }
    
	fragColor = vec4(mix(COLOR_BG, COLOR_FG, c), 1.0);
}

// version history
// 1.0 - original version [tpen]
// 1.1 - timing fix [void room]
