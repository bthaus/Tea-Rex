shader_type spatial;

uniform float rotation_speed : hint_range(0.0, 10.0); // Control the speed of rotation

void vertex() {
    // Time since the shader started
    float time = TIME * rotation_speed;

    // Create a Y-axis rotation matrix
    mat4 rotation_matrix = mat4(
        vec4(cos(time), 0.0, sin(time), 0.0),
        vec4(0.0, 1.0, 0.0, 0.0),
        vec4(-sin(time), 0.0, cos(time), 0.0),
        vec4(0.0, 0.0, 0.0, 1.0)
    );

    // Apply rotation to the vertex position

    // Transform the vertex by the world matrix
    MODELVIEW_MATRIX *= rotation_matrix;
}
