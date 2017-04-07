// https://www.shadertoy.com/view/MsBcDz
// based on http://imgur.com/gallery/R5Kty3B

const float NUMBER_OF_CIRCLES = 12.0;
const float PI = 3.14159265359;
const float MOTION_BLUR = 5.0;

float circle(vec2 p, vec2 center, float exRadius, float inRadius)
{
    float d = distance(p, center);
    float aaf = fwidth(d);
    
    return smoothstep(inRadius - aaf, inRadius, d)
        -smoothstep(exRadius - aaf, exRadius, d);
}

float circleEx(vec2 p, vec2 center, float exRadius, float inRadius, float t)
{
    vec2 diff = p - center;
    float angle = atan(diff.y, diff.x);
    
    float ret = 0.0;

    float recExRadius = (exRadius-inRadius)*0.5;
    float recInRadius = 0.0;//recExRadius * inRadius / exRadius;
    float xradius = inRadius + recExRadius;
    
    for (float i = 0.0; i < NUMBER_OF_CIRCLES; i++)
    {
        float a = -t + i / NUMBER_OF_CIRCLES * PI * 2.0;
       
        vec2 cpos = center + vec2(cos(a), sin(a)) * xradius;
        
        float c = circle(p, cpos, recExRadius, recInRadius);
        ret = max(ret, c);
    }
    return ret;
}

float pattern(vec2 p, float t)
{
	float d = circleEx(p, vec2(1.0, 0.25), 0.5, 0.375, t);
    return d;
}

float patternMB(vec2 p, float t)
{
   	float ret = 0.0;
    for (float i = -MOTION_BLUR; i <= MOTION_BLUR; i += 1.0)
    {
        ret += pattern(p, t + (i / MOTION_BLUR) * 0.05);
    }
    return ret / (MOTION_BLUR * 2.0 + 1.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = 2.0 * fragCoord.xy / iResolution.xy - vec2(1.0);
    uv.x *= iResolution.x / iResolution.y;
    
    float t = iGlobalTime;
#if 1
    float d = patternMB(uv, t);
#else
    float d = circle(uv, vec2(1.0, 0.25), 0.5, 0.375);
#endif
    fragColor = vec4(vec3(1.0 - d), 1.0);
}
