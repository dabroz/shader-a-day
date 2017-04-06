// https://www.shadertoy.com/view/XdSyDR
// based on http://i.imgur.com/qX1qqW0.gif

const float RADIUS = 0.6;
const float WIDTH = 0.03;
const float PI = 3.14159265359;
const float WIGGLE_REPEAT = 8.0;
const float WIGGLE_STRENGTH = 0.12;
const float WIGGLE_OFFSET = 1.0;

vec3 shape(float d, vec3 radii)
{
    vec3 dv = vec3(d);
    vec3 t1 = vec3(greaterThan(dv, radii - vec3(WIDTH * 0.5)));
    vec3 t2 = vec3(lessThan(dv, radii + vec3(WIDTH * 0.5)));
    return t1 * t2;
}

vec3 pattern(vec2 p)
{
    float d = length(p);
    float a = atan(p.y, p.x);
    
    vec3 offsets = vec3(0.0, 1.0, 2.0) * WIGGLE_OFFSET;
    vec3 angles = offsets + vec3(a * WIGGLE_REPEAT);
    float factor = sin(a + iGlobalTime * 2.0) * 0.5 + 0.5;
    vec3 mods = sin(angles) * factor * WIGGLE_STRENGTH + vec3(1.0);
    vec3 radii = mods * vec3(RADIUS);
    
    return shape(d, radii);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv *= 2.0;
    uv -= vec2(1.0);
    uv.x *= iResolution.x / iResolution.y;
    
    fragColor = vec4(pattern(uv), 1.0);
}
