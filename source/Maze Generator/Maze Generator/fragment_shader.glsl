#version 410

in vec4 color;

in vec3 phongPosition;
in vec3 phongVertexNormal;

out vec4 fragmentColor;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform mat4 modelViewProjection;

uniform vec4 lightPosition;
uniform vec4 ambientLight;
uniform vec4 diffuseLight;
uniform vec4 specularLight;

uniform vec4 ambientMaterial;
uniform vec4 diffuseMaterial;
uniform vec4 specularMaterial;
uniform float shininessMaterial;

uniform int drawingObject;
uniform int shadingModel;

// So, apparently, it's OK to have named constants in GLSL.
const int SHADING_MODEL_FLAT = 0;
const int SHADING_MODEL_GOURAUD = 1;
const int SHADING_MODEL_PHONG = 2;

const int DRAWING_OBJECT_X_AXIS = 0;
const int DRAWING_OBJECT_Y_AXIS = 1;
const int DRAWING_OBJECT_Z_AXIS = 2;
const int DRAWING_OBJECT_CUBE = 3;
const int DRAWING_OBJECT_PLANE = 4;
const int DRAWING_OBJECT_SKY = 5;
const int DRAWING_OBJECT_BEACH = 6;
const int DRAWING_OBJECT_WATER = 7;
const int DRAWING_OBJECT_BUSH = 8;
const int DRAWING_OBJECT_PALM_GREEN = 9;
const int DRAWING_OBJECT_PALM_BROWN = 10;
const int DRAWING_OBJECT_PENGUIN_BLACK = 11;
const int DRAWING_OBJECT_PENGUIN_WHITE = 12;
const int DRAWING_OBJECT_PENGUIN_ORANGE= 13;
const int DRAWING_OBJECT_GATE = 14;
const int DRAWING_OBJECT_OCEAN_FLOOR = 15;
const int DRAWING_OBJECT_ENEMY_BODY = 16;
const int DRAWING_OBJECT_ENEMY_SPIKES = 17;
const int DRAWING_OBJECT_MOUNTAIN = 18;
const int DRAWING_OBJECT_LAVA = 19;
const int DRAWING_OBJECT_SMOKE = 20;

void main()
{
    fragmentColor = color;

    if (shadingModel == SHADING_MODEL_FLAT)
    {
        fragmentColor = color;
    }
    else if (shadingModel == SHADING_MODEL_GOURAUD)
    {
        fragmentColor = color;
    }
    else if (shadingModel == SHADING_MODEL_PHONG)
    {
        vec3 L = normalize(lightPosition.xyz - phongPosition);
        vec3 E = normalize(-phongPosition);
        vec3 H = normalize(L + E);

        vec3 N = normalize((view * model * vec4(phongVertexNormal, 0.0))).xyz;

        vec4 ambient = ambientLight * ambientMaterial;

        float Kd = max(dot(L, N), 0.0);
        vec4 diffuse = Kd * (diffuseLight * diffuseMaterial);

        float Ks = pow(max(dot(N, H), 0.0), shininessMaterial);
        vec4 specular = Ks * (specularLight * specularMaterial);
        if (dot(L, N) < 0.0)
        {
            specular = vec4(0.0, 0.0, 0.0, 1.0);
        }

        fragmentColor = ambient + diffuse + specular;
        fragmentColor.a = 1.0;
    }
}
