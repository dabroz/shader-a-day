// https://www.shadertoy.com/view/MsBcDz
// based on http://imgur.com/gallery/R5Kty3B

const float NUMBER_OF_CIRCLES = 12.0;
const float PI = 3.14159265359;
const float MOTION_BLUR = 5.0;
const float MAX_T = 4.0;

float circle(vec2 p, vec2 center, float exRadius, float inRadius)
{
    float d = distance(p, center);
    float aaf = fwidth(d);
    
    return smoothstep(inRadius - aaf, inRadius, d)
        -smoothstep(exRadius - aaf, exRadius, d);
}

float circleEx(vec2 p, vec2 center, float exRadius, float inRadius, float t, float speed, float minBorder)
{
    float regCircle = circle(p, center, exRadius, max(exRadius-minBorder,inRadius));

    vec2 diff = p - center;
    float angle = atan(diff.y, diff.x);
    
    float ret = 0.0;

    float recExRadius = (exRadius-inRadius)*0.5;
    float recInRadius = min(recExRadius-minBorder, recExRadius * inRadius / exRadius);
    float xradius = inRadius + recExRadius;
    
    for (float i = 0.0; i < NUMBER_OF_CIRCLES; i++)
    {
        float a = -t*speed + i / NUMBER_OF_CIRCLES * PI * 2.0;
       
        vec2 cpos = center + vec2(cos(a), sin(a)) * xradius;
        
        float c = circle(p, cpos, recExRadius, recInRadius);
        ret = max(ret, c);
    }
    
    return mix(ret,regCircle,pow(smoothstep(3.0,4.0,speed),2.0));
}

float circleExMB(vec2 p, vec2 center, float exRadius, float inRadius, float t, float speed, float minBorder)
{
   	float ret = 0.0;
    for (float i = -MOTION_BLUR; i <= MOTION_BLUR; i += 1.0)
    {
        float t2 = t + (i / MOTION_BLUR) * speed * 0.1 * 0.05;
        ret += circleEx(p, center, exRadius, inRadius, t2, speed, minBorder);
    }
    return ret / (MOTION_BLUR * 2.0 + 1.0);
}

float pattern(vec2 p, float t)
{    
    float factor = smoothstep(0.0, 1.0, (1.0 - (t / MAX_T)));
    float radius = 5.0 * factor;
    float width = 2.0/3.0 * factor;
    float minBorder = 0.05;
    radius = max(radius, width);
    radius = max(radius,1.0/3.0);
    width = max(width, minBorder);
    float tx = t;
    float speed = t;
	float d = circleExMB(p, vec2(0.0, 1.0/3.0 - radius), radius, radius - width, tx, speed, minBorder);
    return d;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = 2.0 * fragCoord.xy / iResolution.xy - vec2(1.0);
    uv.x *= iResolution.x / iResolution.y;
    
    float time = mod(iGlobalTime * 0.5, MAX_T);
    
    float d = pattern(uv, time);
    
    fragColor = vec4(vec3(1.0 - d), 1.0);
}
