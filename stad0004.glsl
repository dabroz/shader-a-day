// https://www.shadertoy.com/view/MsBcDz
// based on http://imgur.com/gallery/R5Kty3B

const float NUMBER_OF_CIRCLES = 12.0;
const float PI = 3.14159265359;
const float MOTION_BLUR = 5.0;
const float MAX_T = 2.0 * PI;

float circle(vec2 p, vec2 center, float exRadius, float inRadius)
{
    float d = distance(p, center);
    float aaf = fwidth(d);
    
    return smoothstep(inRadius - aaf, inRadius, d)
        -smoothstep(exRadius - aaf, exRadius, d);
}

float circleEx(vec2 p, vec2 center, float exRadius, float inRadius, float t, float minBorder)
{
    vec2 diff = p - center;
    float angle = atan(diff.y, diff.x);
    
    float ret = 0.0;

    float recExRadius = (exRadius-inRadius)*0.5;
    float recInRadius = min(recExRadius-minBorder, recExRadius * inRadius / exRadius);
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

float circleExMB(vec2 p, vec2 center, float exRadius, float inRadius, float t, float minBorder)
{
   	float ret = 0.0;
    for (float i = -MOTION_BLUR; i <= MOTION_BLUR; i += 1.0)
    {
        float t2 = t + (i / MOTION_BLUR) * 0.05;
        ret += circleEx(p, center, exRadius, inRadius, t2, minBorder);
    }
    return ret / (MOTION_BLUR * 2.0 + 1.0);
}

float pattern(vec2 p, float t)
{    
    float factor = (1.0 - (t / MAX_T));
    float radius = 5.0 * factor;
    float width = 2.0/3.0 * factor;
    float minBorder = 0.1;
    radius = max(radius, width);
    float tx = pow(t, 2.0);
	float d = circleExMB(p, vec2(0.0, 1.0/3.0 - radius), radius, radius - width, tx, minBorder);
    return d;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = 2.0 * fragCoord.xy / iResolution.xy - vec2(1.0);
    uv.x *= iResolution.x / iResolution.y;
    
    float time = mod(iGlobalTime * 0.5, MAX_T);
    //time = 0.0;
    
    float t = iGlobalTime;
//#if 1
    float d = pattern(uv, time); //MB
//#else
//    float d = circle(uv, vec2(1.0, 0.25), 0.5, 0.375);
//#endif
    fragColor = vec4(vec3(1.0 - d), 1.0);
}
