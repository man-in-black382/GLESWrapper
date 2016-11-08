#version 300 es

precision highp float;

uniform sampler2D u_texture;
uniform sampler2D u_texture2;

in vec4 v_color;
out vec4 o_fragColor;

void main()
{
    vec4 data = texture(u_texture, vec2(1.0, 1.0));
    vec4 dataa = texture(u_texture2, vec2(1.0, 1.0));
    o_fragColor = v_color;
}
