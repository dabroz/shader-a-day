// https://www.shadertoy.com/view/ld2yWR
// based on http://i.imgur.com/0fDavWZ.mp4 [Clayton Shonkwiler]

const vec3 COLOR_BKG = vec3(ivec3( 69,  81, 105)) / 255.0;
const vec3 COLOR_0   = vec3(ivec3(186, 113, 182)) / 255.0;
const vec3 COLOR_1   = vec3(ivec3( 54, 194, 245)) / 255.0;

const float PATTERN_SIZE = 0.2;
const float PATTERN_WIDTH = 0.005;
const float LINE_AA = 0.001;
const float CIRCLE_SIZE = 0.08;
    
float aastep(float threshold, float value)
{
    float aaf = fwidth(value) * 0.5;
    return smoothstep(threshold-aaf, threshold+aaf, value);
}

vec2 aastep(float threshold, vec2 value)
{
    return vec2(aastep(threshold, value.x), aastep(threshold, value.y));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = 2.0 * fragCoord.xy / iResolution.xy - vec2(1.0);
    uv.x *= iResolution.x / iResolution.y;
    
    vec2 pos = mod(uv,PATTERN_SIZE);
    vec2 rpos = vec2(PATTERN_SIZE)-pos;
    vec2 d = aastep(PATTERN_WIDTH,pos)*aastep(PATTERN_WIDTH,rpos);
    
    float c = d.x * d.y;
    
    vec2 upos = (fract(pos/PATTERN_SIZE + 0.5) - 0.5);
    
    c *= aastep(CIRCLE_SIZE, length(upos));
     
    vec3 cc = mix(COLOR_0, COLOR_BKG, c);
    
	fragColor = vec4(cc, 1.0);
}
