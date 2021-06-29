VARYING vec3 normal_eye;

void MAIN()
{
    vec2 uv = normalize(normal_eye).xy * 0.5 + 0.5;
    FRAGCOLOR = texture(tex, uv);
}
