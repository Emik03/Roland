#if defined(VERTEX) || __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
    #define MY_HIGHP_OR_MEDIUMP highp
#else
    #define MY_HIGHP_OR_MEDIUMP mediump
#endif

extern MY_HIGHP_OR_MEDIUMP vec2 frozen;
extern MY_HIGHP_OR_MEDIUMP number dissolve;
extern MY_HIGHP_OR_MEDIUMP number time;
extern MY_HIGHP_OR_MEDIUMP vec4 texture_details;
extern MY_HIGHP_OR_MEDIUMP vec2 image_details;
extern bool shadow;
extern MY_HIGHP_OR_MEDIUMP vec4 burn_colour_1;
extern MY_HIGHP_OR_MEDIUMP vec4 burn_colour_2;

vec4 dissolve_mask(vec4 tex, vec2 texture_coords, vec2 uv)
{
    if (dissolve < 0.001) {
        return vec4(shadow ? vec3(0.,0.,0.) : tex.xyz, shadow ? tex.a*0.3: tex.a);
    }

    float adjusted_dissolve = (dissolve*dissolve*(3.-2.*dissolve))*1.02 - 0.01;

    float t = time * 10.0 + 2003.;
    vec2 floored_uv = (floor((uv*texture_details.ba)))/max(texture_details.b, texture_details.a);
    vec2 uv_scaled_centered = (floored_uv - 0.5) * 2.3 * max(texture_details.b, texture_details.a);
    
    vec2 field_part1 = uv_scaled_centered + 50.*vec2(sin(-t / 143.6340), cos(-t / 99.4324));
    vec2 field_part2 = uv_scaled_centered + 50.*vec2(cos( t / 53.1532),  cos( t / 61.4532));
    vec2 field_part3 = uv_scaled_centered + 50.*vec2(sin(-t / 87.53218), sin(-t / 49.0000));

    float field = (1.+ (
        cos(length(field_part1) / 19.483) + sin(length(field_part2) / 33.155) * cos(field_part2.y / 15.73) +
        cos(length(field_part3) / 27.193) * sin(field_part3.x / 21.92) ))/2.;
    vec2 borders = vec2(0.2, 0.8);

    float res = (.5 + .5* cos( (adjusted_dissolve) / 82.612 + ( field + -.5 ) *3.14))
    - (floored_uv.x > borders.y ? (floored_uv.x - borders.y)*(5. + 5.*dissolve) : 0.)*(dissolve)
    - (floored_uv.y > borders.y ? (floored_uv.y - borders.y)*(5. + 5.*dissolve) : 0.)*(dissolve)
    - (floored_uv.x < borders.x ? (borders.x - floored_uv.x)*(5. + 5.*dissolve) : 0.)*(dissolve)
    - (floored_uv.y < borders.x ? (borders.x - floored_uv.y)*(5. + 5.*dissolve) : 0.)*(dissolve);

    if (tex.a > 0.01 && burn_colour_1.a > 0.01 && !shadow && res < adjusted_dissolve + 0.8*(0.5-abs(adjusted_dissolve-0.5)) && res > adjusted_dissolve) {
        if (!shadow && res < adjusted_dissolve + 0.5*(0.5-abs(adjusted_dissolve-0.5)) && res > adjusted_dissolve) {
            tex.rgba = burn_colour_1.rgba;
        } else if (burn_colour_2.a > 0.01) {
            tex.rgba = burn_colour_2.rgba;
        }
    }

    return vec4(shadow ? vec3(0.,6.,0.) : tex.xyz, res > adjusted_dissolve ? (shadow ? tex.a*0.3: tex.a) : .0);
}

#define DEPTH 21
#define PHI ((1. + sqrt(5.)) / 2.)
#define PI 3.141592653589
#define S(M, O) (0.5 + 0.5 * sin(O + M * pos.x)) / 6.
#define C(M, O) (0.5 + 0.5 * cos(O + M * pos.y)) / 6.

vec2 rotate(vec2 v, float a)
{
	float s = sin(a);
	float c = cos(a);
	mat2 m = mat2(c, -s, s, c);
	return m * v;
}

float cr(vec2 a, vec2 b)
{
    return a.x * b.y - b.x * a.y;
}

float cr(vec2 a, vec2 b, vec2 c)
{
    return cr(b - a, c - b);
}

vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 tex = Texel(texture, texture_coords);
    vec2 uv = (((texture_coords)*(image_details)) - texture_details.xy*texture_details.ba)/texture_details.ba;

    if (uv.x > uv.x * 2.) {
        uv = frozen;
    }

    // Slightly adapted from 'snowflake lattice' by pali6.
    // https://www.shadertoy.com/view/7sG3zd
    // https://www.shadertoy.com/user/pali6
    float iTime = 0.0;
    vec2 pos = (((texture_coords)*(image_details)) - texture_details.xx*texture_details.ba)/texture_details.ba;

    float scale = 72. + 18. * sin(iTime / 10.) + 20. * sin(4. + iTime / 15.) + 30. * sin(iTime / 6.);
    vec2 camPos = vec2(0.5, 0.5);
    float SF = 1. / pow(scale, 0.3);
    camPos += vec2(0.02 * sin(iTime / 15.), -0.07 * cos(iTime / 19.)) * SF;
    camPos += vec2(-0.1 * sin(3. + iTime / 37.), -0.1 * cos(4. + iTime / 27.)) * SF;
    camPos += vec2(0.07 * sin(9. + iTime / 47.), -0.08 * cos(20. + iTime / 31.)) * SF;
    camPos += vec2(0.04 * sin(19. + iTime / 7.), 0.06 * cos(25. + iTime / 5.)) * SF;
    pos -= vec2(0.5, 0.5);
    pos = rotate(pos, iTime / 30. + PI * cos(iTime / 37.) + 2. * PI * sin(iTime / 87. + 10.));
    pos /= scale;
    pos += camPos;
    vec2 ota = vec2(-1., 0.);
    vec2 otb = vec2(2., 0.);
    vec2 ta = ota;
    vec2 tb = otb;
    vec2 tc;
    bool gn = true;
    float fl = -1.;
    float f = 0.;
    float nDark = 0.;
    
    for (int i = 0; i < DEPTH; i++)
    {
        vec2 next;

        if (gn)
            tc = ta + rotate(tb - ta, fl * PI / 5.) / PHI;
        else
            tc = ta + rotate(tb - ta, fl * 2. * PI / 5.) * PHI;
            
        if(!(gn && min(length(pos - ta), length(pos - tb)) > length(ta - tb) / 3. || !gn && length(pos - tb) <= length(tc - tb) * PHI / 3.5))
        {
            nDark += 1.;
        }

        if (gn)
        {
            next = tb + (ta - tb) / PHI;

            if (abs(cr(next, tc, pos)) * float(i + 1) < 0.000001)
                f = 1.;

            if (cr(next, tc, pos) * cr(next, tc, tb) > 0.)
            {
                gn = false;
                ta = next;
                tb = tc;
                fl *= -1.;
                i--;
            }
            else
            {
                gn = true;
                tb = ta;
                ta = tc;
            }
        }
        else
        {
            next = tc + (tb - tc) / PHI;

            if (abs(cr(ta, next, pos)) * float(i + 1) < 0.000001)
                f = 1.;

            if (cr(ta, next, pos) * cr(ta, next, tb) > 0.)
            {
                gn = false;
                ta = tb;
                tb = next;
            }
            else
            {
                gn = true;
                tb = ta;
                ta = tc;
            }
        }
    }

    colour = (nDark / float(DEPTH)) * vec4(
        0.1 + S(30., 10.) + C(10., 11.) + S(50., 16.) + S(99., 15.) + S(1., 42.) + C(1.5, 73.),
        0.1 + C(20., 10.) + S(70., 12.) + C(23., 18.) + C(67., 119.) + S(1.2, 49.) + C(0.9, 79.),
        0.15 + S(70., 10.5) + C(31., 17.) + S(55., 135.) + C(123., 15.) + S(0.7, 13.) + C(0.11, 31.),
        1.
    ) * 1.5;

    return dissolve_mask(tex*colour, texture_coords, uv);
}

extern MY_HIGHP_OR_MEDIUMP vec2 mouse_screen_pos;
extern MY_HIGHP_OR_MEDIUMP float hovering;
extern MY_HIGHP_OR_MEDIUMP float screen_scale;

#ifdef VERTEX
vec4 position( mat4 transform_projection, vec4 vertex_position )
{
    if (hovering <= 0.){
        return transform_projection * vertex_position;
    }
    float mid_dist = length(vertex_position.xy - 0.5*love_ScreenSize.xy)/length(love_ScreenSize.xy);
    vec2 mouse_offset = (vertex_position.xy - mouse_screen_pos.xy)/screen_scale;
    float scale = 0.2*(-0.03 - 0.3*max(0., 0.3-mid_dist))
                *hovering*(length(mouse_offset)*length(mouse_offset))/(2. -mid_dist);

    return transform_projection * vertex_position + vec4(0.,0.,0.,scale);
}
#endif