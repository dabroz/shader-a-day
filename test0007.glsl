// https://www.shadertoy.com/view/XdjcWD [tpen]
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License
//
// based on https://i.imgur.com/YL5ljpX.gif
// based on https://www.shadertoy.com/view/Xds3zN

// Xds3zN: The MIT License
// Xds3zN: Copyright © 2013 Inigo Quilez
// Xds3zN: Permission is hereby granted, free of charge, to any person obtaining a copy of
// Xds3zN: this software and associated documentation files (the "Software"), to deal in the
// Xds3zN: Software without restriction, including without limitation the rights to use,
// Xds3zN: copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
// Xds3zN: Software, and to permit persons to whom the Software is furnished to do so,
// Xds3zN: subject to the following conditions: The above copyright notice and this
// Xds3zN: permission notice shall be included in all copies or substantial portions of the
// Xds3zN: Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// Xds3zN: EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// Xds3zN: MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
// Xds3zN: EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
// Xds3zN: OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// Xds3zN: FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// Xds3zN: THE SOFTWARE.
    
#define AA 2

const float PI = 3.14159265359;

const vec3 COLOR_BG1 = vec3(ivec3(0,	82,	190))/255.0;
const vec3 COLOR_BG2 = vec3(ivec3(1,	8,	48))/255.0;
const vec3 CUBEPOS = vec3(1.0,1.0, 0.5);

//------------------------------------------------------------------

float sdPlane( vec3 p )
{
	return p.y;
}

float udRoundBox( vec3 p, vec3 b, float r )
{
    return length(max(abs(p)-b,0.0))-r;
}

//------------------------------------------------------------------

float opS( float d1, float d2 )
{
    return max(-d2,d1);
}

vec2 opU( vec2 d1, vec2 d2 )
{
	return (d1.x<d2.x) ? d1 : d2;
}

vec3 opRep( vec3 p, vec3 c )
{
    return mod(p,c)-0.5*c;
}

vec3 opTwist( vec3 p )
{
    float a = PI*0.25;
    float  c = cos(a);
    float  s = sin(a);
    mat2   m = mat2(c,-s,s,c);
    return vec3(m*p.xz,p.y);
}

// based on http://gsgd.co.uk/sandbox/jquery/easing/jquery.easing.1.3.js
// t: current time, b: begInnIng value, c: change In value, d: duration
float tween1(float t, float b, float c, float d) 
{
    t /= d;
		if (t < (1.0/2.75)) 
        {
			return c*(7.5625*t*t) + b;
		} 
        else if (t < (2.0/2.75)) 
        {
            float t1 = t - 1.5/2.75;
			return c*(7.5625*(t)*t1 + .75) + b;
		} 
        else if (t < (2.5/2.75)) 
        {
            float t1 = t-(2.25/2.75);
			return c*(7.5625*(t)*t1 + .9375) + b;
		} 
        else 
        {
            float t1 = t - 2.625/2.75;
			return c*(7.5625*(t)*t1 + .984375) + b;    
		}
}

float tween2(float t, float b, float c, float d) 
{
    float s=1.70158;
    float p=0.0;
    float a=c;
    if (t==0.0) return b;
    if ((t/=d)==1.0) return b+c;
    if (p==0.0) p=d*.3;
    if (a < abs(c)) { a=c; s=p/4.0; }
    else { s = p/(2.0*PI) * asin (c/a); }
    return a*pow(2.0,-10.0*t) * sin( (t*d-s)*(2.0*PI)/p ) + c + b;
}

float tween3(float t, float b, float c, float d) 
{
    float s = 1.70158;
	return c*((t=t/d-1.0)*t*((s+1.0)*t + s) + 1.0) + b;
}

float simpletween(float t)
{
    return tween3(t, 0.0, 1.0, 1.0);
}

vec3 opTwist2( vec3 p )
{
    p = opTwist(p);
    float a = 10.0*p.y+10.0;
    
    float t = iGlobalTime;
    //t=0.05;
    
    a=simpletween(clamp(mod(t*1.0+p.x*0.2,2.0),0.0,1.0))*PI*0.5;

    float  c = cos(a);
    float  s = sin(a);
    mat2   m = mat2(c,-s,s,c);
    return vec3(p.x,m*p.yz);
}

//------------------------------------------------------------------

vec2 map( in vec3 pos )
{
    vec2 res = vec2(sdPlane(pos), 1.0 );
    res = opU(res, 
      vec2(udRoundBox(opTwist2(pos-CUBEPOS), vec3(0.35), 0.02 ), 41.0 ));

    return res;
}

vec2 castRay( in vec3 ro, in vec3 rd )
{
    float tmin = 0.5;
    float tmax = 20.0;
   
#if 1
    // bounding volume
    float tp1 = (0.0-ro.y)/rd.y; if( tp1>0.0 ) tmax = min( tmax, tp1 );
    float tp2 = (1.6-ro.y)/rd.y; if( tp2>0.0 ) { if( ro.y>1.6 ) tmin = max( tmin, tp2 );
                                                 else           tmax = min( tmax, tp2 ); }
#endif
    
    float t = tmin;
    float m = -1.0;
    for( int i=0; i<64; i++ )
    {
	    float precis = 0.0005*t;
	    vec2 res = map( ro+rd*t );
        if( res.x<precis || t>tmax ) break;
        t += res.x;
	    m = res.y;
    }

    if( t>tmax ) m=-1.0;
    return vec2( t, m );
}

vec3 calcNormal( in vec3 pos )
{
    vec2 e = vec2(1.0,-1.0)*0.5773*0.0005;
    return normalize( e.xyy*map( pos + e.xyy ).x + 
					  e.yyx*map( pos + e.yyx ).x + 
					  e.yxy*map( pos + e.yxy ).x + 
					  e.xxx*map( pos + e.xxx ).x );
}

vec3 render( in vec3 ro, in vec3 rd )
{ 
    vec3 col = vec3(0.7, 0.9, 1.0) +rd.y*0.8;
    vec3 basecol = vec3(1.0);
    for (int k = 0; k < 2; k++)
    {
        vec2 res = castRay(ro,rd);
        float t = res.x;
        float m = res.y;
        if( m>-0.5 )
        {
            vec3 pos = ro + t*rd;
            vec3 nor = calcNormal( pos );
            vec3 ref = reflect( rd, nor );

            // material        
            col = 0.45 + 0.35*sin( vec3(0.05,0.08,0.10)*(m-1.0) );
            if( m<1.5 )
            {
                float f = pos.x*0.25+0.75;
                f = clamp(f, 0.0, 1.0);
                col = mix(COLOR_BG1,COLOR_BG2,f);
                col = pow(col, vec3(2.2));
                basecol = col;
            }

            // lighitng        
           // float occ = 1.0;//calcAO( pos, nor );
           // vec3  lig = normalize( vec3(-0.4, 0.7, -0.6) );
           // float amb = clamp( 0.5+0.5*nor.y, 0.0, 1.0 );
           // float dif = clamp( dot( nor, lig ), 0.0, 1.0 );
           // float bac = clamp( dot( nor, normalize(vec3(-lig.x,0.0,-lig.z))), 0.0, 1.0 )*clamp( 1.0-pos.y,0.0,1.0);
           // float dom = smoothstep( -0.1, 0.1, ref.y );
           // float fre = pow( clamp(1.0+dot(nor,rd),0.0,1.0), 2.0 );
           // float spe = pow(clamp( dot( ref, lig ), 0.0, 1.0 ),16.0);

            if (m<1.5)
            {
            	ro = pos + 0.001*nor;
            	rd = ref;
            }
            else
            {          
                vec3 cuv = reflect(pos-CUBEPOS,nor);
                //cuv = ref;
                col = texture(iChannel0, cuv).xyz;
                col = mix(COLOR_BG1,COLOR_BG2,col);

                if (k==1)
                {
                    col = mix(basecol,col,0.25);
                }
                break;
            }
        }
    }

	return vec3( clamp(col,0.0,1.0) );
}

mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	vec3 cw = normalize(ta-ro);
	vec3 cp = vec3(sin(cr), cos(cr),0.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv = normalize( cross(cu,cw) );
    return mat3( cu, cv, cw );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec3 tot = vec3(0.0);
#if AA>1
    for( int m=0; m<AA; m++ )
    for( int n=0; n<AA; n++ )
    {
        // pixel coordinates
        vec2 o = vec2(float(m),float(n)) / float(AA) - 0.5;
        vec2 p = (-iResolution.xy + 2.0*(fragCoord+o))/iResolution.y;
#else    
        vec2 p = (-iResolution.xy + 2.0*fragCoord)/iResolution.y;
#endif

		// camera	
        vec3 ro = vec3( -0.5+3.5, 2.0, 0.5);
        vec3 ta = vec3( -0.5, -0.4, 0.5 );
        // camera-to-world transformation
        mat3 ca = setCamera( ro, ta, 0.0 );
        // ray direction
        vec3 rd = ca * normalize( vec3(p.xy,2.0) );

        // render	
        vec3 col = render( ro, rd );

		// gamma
        col = pow( col, vec3(0.4545) );

        tot += col;
#if AA>1
    }
    tot /= float(AA*AA);
#endif

  //  tot = vec3(simpletween(fragCoord.x/iResolution.x));
    fragColor = vec4( tot, 1.0 );
}
