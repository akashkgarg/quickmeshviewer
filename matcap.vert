
VARYING vec3 normal_eye;

void MAIN()
{
    mat4 xform = transpose(inverse(MODEL_MATRIX * VIEW_MATRIX));
    normal_eye = vec3(xform * vec4(NORMAL, 0.0));
    POSITION = MODELVIEWPROJECTION_MATRIX * vec4(VERTEX, 1.0);
}
