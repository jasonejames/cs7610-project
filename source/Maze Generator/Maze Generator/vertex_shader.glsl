#version 410

layout(location = 0) in vec4 vertexPosition;
layout(location = 1) in vec3 faceNormal;
layout(location = 2) in vec3 vertexNormal;
layout(location = 3) in vec4 colorData;

out vec4 color;
out vec3 phongVertexNormal;
out vec3 phongPosition;

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

// List possible types of items to draw.
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
//    gl_Position = modelViewProjection * vertexPosition;
    gl_Position = projection * view * model * vertexPosition;

    // TODO: Refactor some of this.

    // Check if shading model is flat shading.
    if (shadingModel == SHADING_MODEL_FLAT)
    {
        // Handle x-axis.
        if (drawingObject == DRAWING_OBJECT_X_AXIS)
        {
            color = vec4(1.0, 0.0, 0.0, 1.0);
        }
        // Handle y-axis.
        else if (drawingObject == DRAWING_OBJECT_Y_AXIS)
        {
            color = vec4(0.2, 0.8, 0.5, 1.0);
        }
        // Handle z-axis.
        else if (drawingObject == DRAWING_OBJECT_Z_AXIS)
        {
            color = vec4(0.0, 0.8, 1.0, 1.0);
        }
        // Handle maze.
        else if (drawingObject == DRAWING_OBJECT_CUBE)
        {
            vec3 position3 = (view * model * vertexPosition).xyz;

            vec3 L = normalize(lightPosition.xyz - position3);
            vec3 E = normalize(-position3);
            vec3 H = normalize(L + E);

            vec3 N = normalize((view * model * vec4(faceNormal, 0.0))).xyz;

            vec4 ambient = ambientLight * ambientMaterial;

            float Kd = max(dot(L, N), 0.0);
            vec4 diffuse = Kd * (diffuseLight * diffuseMaterial);

            float Ks = pow(max(dot(N, H), 0.0), shininessMaterial);
            vec4 specular = Ks * (specularLight * specularMaterial);
            if (dot(L, N) < 0.0)
            {
                specular = vec4(0.0, 0.0, 0.0, 1.0);
            }

            color = ambient + diffuse + specular;
            color.a = 1.0;
        }
        // Handle plane.
        else if (drawingObject == DRAWING_OBJECT_PLANE)
        {
            vec3 position3 = (view * model * vertexPosition).xyz;

            vec3 L = normalize(lightPosition.xyz - position3);
            vec3 E = normalize(-position3);
            vec3 H = normalize(L + E);

            vec3 N = normalize((view * model * vec4(faceNormal, 0.0))).xyz;

            vec4 ambient = ambientLight * ambientMaterial;

            float Kd = max(dot(L, N), 0.0);
            vec4 diffuse = Kd * (diffuseLight * diffuseMaterial);

            float Ks = pow(max(dot(N, H), 0.0), shininessMaterial);
            vec4 specular = Ks * (specularLight * specularMaterial);
            if (dot(L, N) < 0.0)
            {
                specular = vec4(0.0, 0.0, 0.0, 1.0);
            }

            color = ambient + diffuse + specular;
            color.a = 1.0;
    //        color = vec4(0.97, 0.97, 0.74, 1.0);
        }
        else if (drawingObject == DRAWING_OBJECT_SKY)
        {
            color = colorData;
//            color = vec4(0.97, 0.97, 0.74, 1.0);
        }
        else if (drawingObject == DRAWING_OBJECT_BEACH)
        {
//            color = vec4(0.97, 0.97, 0.74, 1.0);
            vec3 position3 = (view * model * vertexPosition).xyz;

            vec3 L = normalize(lightPosition.xyz - position3);
            vec3 E = normalize(-position3);
            vec3 H = normalize(L + E);

            vec3 N = normalize((view * model * vec4(faceNormal, 0.0))).xyz;

            vec4 ambient = ambientLight * ambientMaterial;

            float Kd = max(dot(L, N), 0.0);
            vec4 diffuse = Kd * (diffuseLight * diffuseMaterial);

            float Ks = pow(max(dot(N, H), 0.0), shininessMaterial);
            vec4 specular = Ks * (specularLight * specularMaterial);
            if (dot(L, N) < 0.0)
            {
                specular = vec4(0.0, 0.0, 0.0, 1.0);
            }

            color = ambient + diffuse + specular;
            color.a = 1.0;
        }
        else if (drawingObject == DRAWING_OBJECT_WATER)
        {
            color = colorData;
        }
        else if (drawingObject == DRAWING_OBJECT_BUSH)
        {
            vec3 position3 = (view * model * vertexPosition).xyz;

            vec3 L = normalize(lightPosition.xyz - position3);
            vec3 E = normalize(-position3);
            vec3 H = normalize(L + E);

            vec3 N = normalize((view * model * vec4(faceNormal, 0.0))).xyz;

            vec4 ambient = ambientLight * ambientMaterial;

            float Kd = max(dot(L, N), 0.0);
            vec4 diffuse = Kd * (diffuseLight * diffuseMaterial);

            float Ks = pow(max(dot(N, H), 0.0), shininessMaterial);
            vec4 specular = Ks * (specularLight * specularMaterial);
            if (dot(L, N) < 0.0)
            {
                specular = vec4(0.0, 0.0, 0.0, 1.0);
            }

            color = ambient + diffuse + specular;
            color.a = 1.0;
        }
        else if (drawingObject == DRAWING_OBJECT_OCEAN_FLOOR)
        {
            color = colorData;
        }
        else
        {
            color = vec4(1.0, 1.0, 1.0, 1.0);
        }
    }
    // Check if the shading model is Gouraud shading.
    else if (shadingModel == SHADING_MODEL_GOURAUD)
    {
        // Handle x-axis.
        if (drawingObject == 0)
        {
            color = vec4(1.0, 0.0, 0.0, 1.0);
        }
        // Handle y-axis.
        else if (drawingObject == 1)
        {
            color = vec4(0.2, 0.8, 0.5, 1.0);
        }
        // Handle z-axis.
        else if (drawingObject == 2)
        {
            color = vec4(0.0, 0.8, 1.0, 1.0);
        }
        // Handle maze.
        else if (drawingObject == 3)
        {
            vec3 position3 = (view * model * vertexPosition).xyz;

            vec3 L = normalize(lightPosition.xyz - position3);
            vec3 E = normalize(-position3);
            vec3 H = normalize(L + E);

            vec3 N = normalize((view * model * vec4(vertexNormal, 0.0))).xyz;

            vec4 ambient = ambientLight * ambientMaterial;

            float Kd = max(dot(L, N), 0.0);
            vec4 diffuse = Kd * (diffuseLight * diffuseMaterial);

            float Ks = pow(max(dot(N, H), 0.0), shininessMaterial);
            vec4 specular = Ks * (specularLight * specularMaterial);
            if (dot(L, N) < 0.0)
            {
                specular = vec4(0.0, 0.0, 0.0, 1.0);
            }

            color = ambient + diffuse + specular;
            color.a = 1.0;
        }
        // Handle plane.
        else if (drawingObject == 4)
        {
            vec3 position3 = (view * model * vertexPosition).xyz;

            vec3 L = normalize(lightPosition.xyz - position3);
            vec3 E = normalize(-position3);
            vec3 H = normalize(L + E);

            vec3 N = normalize((view * model * vec4(vertexNormal, 0.0))).xyz;

            vec4 ambient = ambientLight * ambientMaterial;

            float Kd = max(dot(L, N), 0.0);
            vec4 diffuse = Kd * (diffuseLight * diffuseMaterial);

            float Ks = pow(max(dot(N, H), 0.0), shininessMaterial);
            vec4 specular = Ks * (specularLight * specularMaterial);
            if (dot(L, N) < 0.0)
            {
                specular = vec4(0.0, 0.0, 0.0, 1.0);
            }

            color = ambient + diffuse + specular;
            color.a = 1.0;
    //        color = vec4(0.97, 0.97, 0.74, 1.0);
        }
        else if (drawingObject == 6)
        {
//            color = vec4(0.97, 0.97, 0.74, 1.0);
            vec3 position3 = (view * model * vertexPosition).xyz;

            vec3 L = normalize(lightPosition.xyz - position3);
            vec3 E = normalize(-position3);
            vec3 H = normalize(L + E);

            vec3 N = normalize((view * model * vec4(vertexNormal, 0.0))).xyz;

            vec4 ambient = ambientLight * ambientMaterial;

            float Kd = max(dot(L, N), 0.0);
            vec4 diffuse = Kd * (diffuseLight * diffuseMaterial);

            float Ks = pow(max(dot(N, H), 0.0), shininessMaterial);
            vec4 specular = Ks * (specularLight * specularMaterial);
            if (dot(L, N) < 0.0)
            {
                specular = vec4(0.0, 0.0, 0.0, 1.0);
            }

            color = ambient + diffuse + specular;
            color.a = 1.0;
        }
        else if (drawingObject == DRAWING_OBJECT_BUSH)
        {
            vec3 position3 = (view * model * vertexPosition).xyz;

            vec3 L = normalize(lightPosition.xyz - position3);
            vec3 E = normalize(-position3);
            vec3 H = normalize(L + E);

            vec3 N = normalize((view * model * vec4(vertexNormal, 0.0))).xyz;

            vec4 ambient = ambientLight * ambientMaterial;

            float Kd = max(dot(L, N), 0.0);
            vec4 diffuse = Kd * (diffuseLight * diffuseMaterial);

            float Ks = pow(max(dot(N, H), 0.0), shininessMaterial);
            vec4 specular = Ks * (specularLight * specularMaterial);
            if (dot(L, N) < 0.0)
            {
                specular = vec4(0.0, 0.0, 0.0, 1.0);
            }

            color = ambient + diffuse + specular;
            color.a = 1.0;
        }
        else if (drawingObject == DRAWING_OBJECT_PALM_GREEN)
        {
            vec3 position3 = (view * model * vertexPosition).xyz;

            vec3 L = normalize(lightPosition.xyz - position3);
            vec3 E = normalize(-position3);
            vec3 H = normalize(L + E);

            vec3 N = normalize((view * model * vec4(vertexNormal, 0.0))).xyz;

            vec4 ambient = ambientLight * ambientMaterial;

            float Kd = max(dot(L, N), 0.0);
            vec4 diffuse = Kd * (diffuseLight * diffuseMaterial);

            float Ks = pow(max(dot(N, H), 0.0), shininessMaterial);
            vec4 specular = Ks * (specularLight * specularMaterial);
            if (dot(L, N) < 0.0)
            {
                specular = vec4(0.0, 0.0, 0.0, 1.0);
            }

            color = ambient + diffuse + specular;
            color.a = 1.0;
        }
        else if (drawingObject == DRAWING_OBJECT_PALM_BROWN)
        {
            vec3 position3 = (view * model * vertexPosition).xyz;

            vec3 L = normalize(lightPosition.xyz - position3);
            vec3 E = normalize(-position3);
            vec3 H = normalize(L + E);

            vec3 N = normalize((view * model * vec4(vertexNormal, 0.0))).xyz;

            vec4 ambient = ambientLight * ambientMaterial;

            float Kd = max(dot(L, N), 0.0);
            vec4 diffuse = Kd * (diffuseLight * diffuseMaterial);

            float Ks = pow(max(dot(N, H), 0.0), shininessMaterial);
            vec4 specular = Ks * (specularLight * specularMaterial);
            if (dot(L, N) < 0.0)
            {
                specular = vec4(0.0, 0.0, 0.0, 1.0);
            }

            color = ambient + diffuse + specular;
            color.a = 1.0;
        }
        else if (drawingObject == DRAWING_OBJECT_PENGUIN_BLACK)
        {
            vec3 position3 = (view * model * vertexPosition).xyz;

            vec3 L = normalize(lightPosition.xyz - position3);
            vec3 E = normalize(-position3);
            vec3 H = normalize(L + E);

            vec3 N = normalize((view * model * vec4(vertexNormal, 0.0))).xyz;

            vec4 ambient = ambientLight * ambientMaterial;

            float Kd = max(dot(L, N), 0.0);
            vec4 diffuse = Kd * (diffuseLight * diffuseMaterial);

            float Ks = pow(max(dot(N, H), 0.0), shininessMaterial);
            vec4 specular = Ks * (specularLight * specularMaterial);
            if (dot(L, N) < 0.0)
            {
                specular = vec4(0.0, 0.0, 0.0, 1.0);
            }

            color = ambient + diffuse + specular;
            color.a = 1.0;
        }
        else if (drawingObject == DRAWING_OBJECT_PENGUIN_WHITE)
        {
            vec3 position3 = (view * model * vertexPosition).xyz;

            vec3 L = normalize(lightPosition.xyz - position3);
            vec3 E = normalize(-position3);
            vec3 H = normalize(L + E);

            vec3 N = normalize((view * model * vec4(vertexNormal, 0.0))).xyz;

            vec4 ambient = ambientLight * ambientMaterial;

            float Kd = max(dot(L, N), 0.0);
            vec4 diffuse = Kd * (diffuseLight * diffuseMaterial);

            float Ks = pow(max(dot(N, H), 0.0), shininessMaterial);
            vec4 specular = Ks * (specularLight * specularMaterial);
            if (dot(L, N) < 0.0)
            {
                specular = vec4(0.0, 0.0, 0.0, 1.0);
            }

            color = ambient + diffuse + specular;
            color.a = 1.0;
        }
        else if (drawingObject == DRAWING_OBJECT_PENGUIN_ORANGE)
        {
            vec3 position3 = (view * model * vertexPosition).xyz;

            vec3 L = normalize(lightPosition.xyz - position3);
            vec3 E = normalize(-position3);
            vec3 H = normalize(L + E);

            vec3 N = normalize((view * model * vec4(vertexNormal, 0.0))).xyz;

            vec4 ambient = ambientLight * ambientMaterial;

            float Kd = max(dot(L, N), 0.0);
            vec4 diffuse = Kd * (diffuseLight * diffuseMaterial);

            float Ks = pow(max(dot(N, H), 0.0), shininessMaterial);
            vec4 specular = Ks * (specularLight * specularMaterial);
            if (dot(L, N) < 0.0)
            {
                specular = vec4(0.0, 0.0, 0.0, 1.0);
            }

            color = ambient + diffuse + specular;
            color.a = 1.0;
        }
        else if (drawingObject == DRAWING_OBJECT_GATE)
        {
            vec3 position3 = (view * model * vertexPosition).xyz;

            vec3 L = normalize(lightPosition.xyz - position3);
            vec3 E = normalize(-position3);
            vec3 H = normalize(L + E);

            vec3 N = normalize((view * model * vec4(vertexNormal, 0.0))).xyz;

            vec4 ambient = ambientLight * ambientMaterial;

            float Kd = max(dot(L, N), 0.0);
            vec4 diffuse = Kd * (diffuseLight * diffuseMaterial);

            float Ks = pow(max(dot(N, H), 0.0), shininessMaterial);
            vec4 specular = Ks * (specularLight * specularMaterial);
            if (dot(L, N) < 0.0)
            {
                specular = vec4(0.0, 0.0, 0.0, 1.0);
            }

            color = ambient + diffuse + specular;
            color.a = 1.0;
        }
        else if (drawingObject == DRAWING_OBJECT_ENEMY_BODY)
        {
            vec3 position3 = (view * model * vertexPosition).xyz;

            vec3 L = normalize(lightPosition.xyz - position3);
            vec3 E = normalize(-position3);
            vec3 H = normalize(L + E);

            vec3 N = normalize((view * model * vec4(vertexNormal, 0.0))).xyz;

            vec4 ambient = ambientLight * ambientMaterial;

            float Kd = max(dot(L, N), 0.0);
            vec4 diffuse = Kd * (diffuseLight * diffuseMaterial);

            float Ks = pow(max(dot(N, H), 0.0), shininessMaterial);
            vec4 specular = Ks * (specularLight * specularMaterial);
            if (dot(L, N) < 0.0)
            {
                specular = vec4(0.0, 0.0, 0.0, 1.0);
            }

            color = ambient + diffuse + specular;
            color.a = 1.0;
        }
        else if (drawingObject == DRAWING_OBJECT_ENEMY_SPIKES)
        {
            vec3 position3 = (view * model * vertexPosition).xyz;

            vec3 L = normalize(lightPosition.xyz - position3);
            vec3 E = normalize(-position3);
            vec3 H = normalize(L + E);

            vec3 N = normalize((view * model * vec4(vertexNormal, 0.0))).xyz;

            vec4 ambient = ambientLight * ambientMaterial;

            float Kd = max(dot(L, N), 0.0);
            vec4 diffuse = Kd * (diffuseLight * diffuseMaterial);

            float Ks = pow(max(dot(N, H), 0.0), shininessMaterial);
            vec4 specular = Ks * (specularLight * specularMaterial);
            if (dot(L, N) < 0.0)
            {
                specular = vec4(0.0, 0.0, 0.0, 1.0);
            }

            color = ambient + diffuse + specular;
            color.a = 1.0;
        }
        else if (drawingObject == DRAWING_OBJECT_MOUNTAIN)
        {
            vec3 position3 = (view * model * vertexPosition).xyz;

            vec3 L = normalize(lightPosition.xyz - position3);
            vec3 E = normalize(-position3);
            vec3 H = normalize(L + E);

            vec3 N = normalize((view * model * vec4(vertexNormal, 0.0))).xyz;

            vec4 ambient = ambientLight * ambientMaterial;

            float Kd = max(dot(L, N), 0.0);
            vec4 diffuse = Kd * (diffuseLight * diffuseMaterial);

            float Ks = pow(max(dot(N, H), 0.0), shininessMaterial);
            vec4 specular = Ks * (specularLight * specularMaterial);
            if (dot(L, N) < 0.0)
            {
                specular = vec4(0.0, 0.0, 0.0, 1.0);
            }

            color = ambient + diffuse + specular;
            color.a = 1.0;
        }
        else if (drawingObject == DRAWING_OBJECT_LAVA)
        {
            vec3 position3 = (view * model * vertexPosition).xyz;

            vec3 L = normalize(lightPosition.xyz - position3);
            vec3 E = normalize(-position3);
            vec3 H = normalize(L + E);

            vec3 N = normalize((view * model * vec4(vertexNormal, 0.0))).xyz;

            vec4 ambient = ambientLight * ambientMaterial;

            float Kd = max(dot(L, N), 0.0);
            vec4 diffuse = Kd * (diffuseLight * diffuseMaterial);

            float Ks = pow(max(dot(N, H), 0.0), shininessMaterial);
            vec4 specular = Ks * (specularLight * specularMaterial);
            if (dot(L, N) < 0.0)
            {
                specular = vec4(0.0, 0.0, 0.0, 1.0);
            }

            color = ambient + diffuse + specular;
            color.a = 1.0;
        }
        else if (drawingObject == DRAWING_OBJECT_SMOKE)
        {
            vec3 position3 = (view * model * vertexPosition).xyz;

            vec3 L = normalize(lightPosition.xyz - position3);
            vec3 E = normalize(-position3);
            vec3 H = normalize(L + E);

            vec3 N = normalize((view * model * vec4(vertexNormal, 0.0))).xyz;

            vec4 ambient = ambientLight * ambientMaterial;

            float Kd = max(dot(L, N), 0.0);
            vec4 diffuse = Kd * (diffuseLight * diffuseMaterial);

            float Ks = pow(max(dot(N, H), 0.0), shininessMaterial);
            vec4 specular = Ks * (specularLight * specularMaterial);
            if (dot(L, N) < 0.0)
            {
                specular = vec4(0.0, 0.0, 0.0, 1.0);
            }

            color = ambient + diffuse + specular;
            color.a = 1.0;
        }
        else
        {
            color = vec4(1.0, 1.0, 1.0, 1.0);
        }
    }
    // Check if the shading model is Phong shading.
    else if (shadingModel == SHADING_MODEL_PHONG)
    {
        phongVertexNormal = vertexNormal;

        phongPosition = (view * model * vertexPosition).xyz;
    }
}
