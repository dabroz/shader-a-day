// https://www.shadertoy.com/view/ldjcWh
// based on http://i.imgur.com/Yh35xhH.gif

const vec3 COLOR_FG = vec3(ivec3(77, 255, 74)) / 255.0;
const vec3 COLOR_BG = vec3(0.0);

const float NUMBER_OF_CIRCLES = 9.0;
const float SPEED_RATIO = 0.5; //8.0;

const float BAR_WIDTH = 1.0 / 2.0;
const float BAR_MARGIN = (1.0 - BAR_WIDTH) * 0.5;
const float MARGIN = 30.0 / 270.0;

const float PI = 3.14159265359;

//const float SPACER_WIDTH = (1.0 - BAR_WIDTH * NUMBER_OF_CIRCLES - MARGIN * 2.0)
//    / (NUMBER_OF_CIRCLES - 1.0);

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
        float rr = fract(dd * NUMBER_OF_CIRCLES);
        if (rr > BAR_MARGIN && rr < (1.0-BAR_MARGIN))
        {
            float rrr = 1.0-abs(2.0*(rr - BAR_MARGIN)/BAR_WIDTH-1.0);
            float speed = (1.0-qq) * SPEED_RATIO;
            float aa = mod(a - iGlobalTime * speed, 1.0);
        	c = rrr*aa;
        }
    }
    
	fragColor = vec4(mix(COLOR_BG, COLOR_FG, c), 1.0);
}
