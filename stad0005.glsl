// https://www.shadertoy.com/view/ld2yWR
// based on http://i.imgur.com/0fDavWZ.mp4 [Clayton Shonkwiler]

// hard lines are not preserved (yet)

const vec3 COLOR_BKG = vec3(ivec3( 69,  81, 105)) / 255.0;
const vec3 COLOR_0   = vec3(ivec3(186, 113, 182)) / 255.0;
const vec3 COLOR_1   = vec3(ivec3( 54, 194, 245)) / 255.0;

const float PATTERN_SIZE = 0.2;
const float PATTERN_WIDTH = 0.005;
const float LINE_AA = 0.001;
const float CIRCLE_SIZE = 0.09;
    
const float PI = 3.14159265359;

const float MAX_T = 4.0;

float aastep(float threshold, float value)
{
    float aaf = fwidth(value) * 0.5;
    return smoothstep(threshold-aaf, threshold+aaf, value);
}

vec2 aastep(float threshold, vec2 value)
{
    vec2 aaf = fwidth(value) * 0.5;
    return smoothstep(threshold-aaf, threshold+aaf, value);
}

float warpFactor(vec2 p, float t)
{
    float dist = length(p);
    //dist = max(abs(p.x), abs(p.y));
    //float quant = round(dist * 10.0 - 0.5) / 10.0;
    
    float factor = (t*3.0-1.0) - dist*0.5;
    factor = smoothstep(0.0, 1.0, factor);
    
    return factor;
}

vec2 warp(vec2 p, float factor) 
{       
    float a = -factor * 0.5 * PI;
    mat2 matrix = mat2(cos(a), sin(a), -sin(a), cos(a));
    vec2 r = matrix * p;
	return r;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = 2.0 * fragCoord.xy / iResolution.xy - vec2(1.0);
    uv.x *= iResolution.x / iResolution.y;
    
    float t = mod(iGlobalTime, MAX_T) / MAX_T;
    
    vec2 baseuv = uv;
    float factor = warpFactor(uv, t);
    uv = warp(uv, factor);
    
    vec2 pos = mod(uv,PATTERN_SIZE);
    vec2 rpos = vec2(PATTERN_SIZE)-pos;
    vec2 d = aastep(PATTERN_WIDTH,pos)*aastep(PATTERN_WIDTH,rpos);
    
    float c = d.x * d.y;
    
    vec2 upos = (fract(pos/PATTERN_SIZE + 0.5) - 0.5);
    
    c *= aastep(CIRCLE_SIZE, length(upos));
     
    float ratio = length(baseuv);
    vec3 color = mix(COLOR_1, COLOR_0, abs(factor*2.0-1.0));
   	vec3 bkg = COLOR_BKG;
        // baseuv.x>1.6 ? vec3(step(t,baseuv.y*0.5+0.5)) : COLOR_BKG;
    vec3 cc = mix(color, bkg, c);
    
	fragColor = vec4(cc, 1.0);
}
