// https://www.shadertoy.com/view/MdjyRw

const float TOTAL_RADIUS = 177.0;
const float CIRCLE_RADIUS = 13.5;
const float MARGIN = 50.0;
const float NUMBER_OF_CIRCLES = 24.0 / 2.0;

const float INTERNAL_RADIUS = (CIRCLE_RADIUS)/(TOTAL_RADIUS+MARGIN);
const float EXTERNAL_RADIUS = (TOTAL_RADIUS-CIRCLE_RADIUS)/(TOTAL_RADIUS+MARGIN);
const float PI = 3.14159265359;

// http://www.chilliant.com/rgb2hsv.html
vec3 hueToRGB(float H)
{
    float R = abs(H * 6.0 - 3.0) - 1.0;
    float G = 2.0 - abs(H * 6.0 - 2.0);
    float B = 2.0 - abs(H * 6.0 - 4.0);
    return clamp(vec3(R,G,B), vec3(0.0), vec3(1.0));
}

float pointCircle(vec2 p, vec2 center, float radius)
{
    float d = distance(p, center);
    float aaf = fwidth(d);
	return 1.0 - smoothstep(radius - aaf, radius, d);
}

float pointCircleStroke(vec2 p, vec2 center, float radius)
{
    float d = distance(p, center);
    float aaf = fwidth(d);
    
    return smoothstep(radius-aaf, radius, d) - smoothstep(radius, radius+aaf, d);
}

vec4 alphaBlend(vec4 src, vec4 dst)
{
    vec3 col = mix(dst.xyz, src.xyz, src.w);
    return vec4(col, 1.0);
}

vec4 circlePattern(vec2 p)
{
    vec4 ret = vec4(vec3(0.0), 1.0);
    for (float i = 0.0; i < NUMBER_OF_CIRCLES; i++)
    {
        float angle0 = i * PI * 2.0 / NUMBER_OF_CIRCLES;
        float angle1 = (i + 1.5) * PI * 2.0 / NUMBER_OF_CIRCLES;
        
        float radius = INTERNAL_RADIUS;
                
        vec2 circlePos0 = vec2(cos(angle0), sin(angle0)) * EXTERNAL_RADIUS;        
        vec2 circlePos1 = vec2(cos(angle1), sin(angle1)) * EXTERNAL_RADIUS;
        vec2 middlePos = (circlePos0 + circlePos1) / 2.0;
        vec2 diff = middlePos - circlePos0;
        float middleRadius = length(diff);
        
        float middleAngle = atan(diff.y,diff.x);
        
        float ratio = smoothstep(0.0,1.0,mod(iGlobalTime*0.5+i*0.25,3.0));
        middleAngle -= ratio * PI;
            
        vec2 realPos0 = middlePos + vec2(cos(middleAngle), sin(middleAngle)) * middleRadius;
        vec2 realPos1 = middlePos + vec2(cos(PI + middleAngle), sin(PI + middleAngle)) * middleRadius;
        
        vec3 color0 = hueToRGB(mod(0.25 + 1.0/24.0 - (i+1.5) / NUMBER_OF_CIRCLES, 1.0));
        vec3 color1 = hueToRGB(mod(0.25 + 1.0/24.0 - (i-0.0) / NUMBER_OF_CIRCLES, 1.0));
        
        float bandRatio = 1.0 - abs(2.0 * ratio - 1.0);
        
        vec3 realColor0 = mix(color0, color1, ratio);
        vec3 realColor1 = mix(color1, color0, ratio);
               
        float st = pointCircleStroke(p, middlePos, middleRadius);
		ret = alphaBlend(vec4(color0, st * bandRatio), ret);
        
        float c0 = pointCircle(p, realPos0, radius);
        ret = alphaBlend(vec4(realColor0, c0), ret);
        
        float c1 = pointCircle(p, realPos1, radius);
        ret = alphaBlend(vec4(realColor1, c1), ret);
    }
    return ret;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = 2.0 * fragCoord.xy / iResolution.xy - vec2(1.0);
    uv.x *= iResolution.x / iResolution.y;
    
	fragColor = circlePattern(uv);
}
