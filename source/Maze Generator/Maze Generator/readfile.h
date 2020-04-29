//
//  readfile.h
//
//  This file was provided with materials for one of the assignments.
//  So, I'm not sure where the code originally came from.
//  However, I have modified the code somewhat.
//

#ifndef readfile_h
#define readfile_h

#include <vector>

#include <glm/glm.hpp>
#include <glm/vec4.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>
#include <glm/gtx/normal.hpp>

int readfile(std::string addrstr,
             GLuint * vertex_count,
             GLfloat ** geometry,
             GLfloat ** face_normals,
             GLfloat ** vertex_normals,
             bool do_scale)
{
    GLfloat xcenter, ycenter, zcenter;
    GLfloat scale;
    std::vector<GLfloat*> vertices;
    std::vector<GLint> faces;

    FILE *file1;
    file1 = fopen(addrstr.c_str(), "r"); //read
    if (file1 == NULL)
    {
        printf("Error reading file.\n");
    }
    float a, b, c, *arrayfloat;
    GLint e, f, g, *arrayint;
    GLfloat min_x = FLT_MAX;    GLfloat min_y = FLT_MAX;    GLfloat min_z = FLT_MAX;
    GLfloat max_x = -10000.0;   GLfloat max_y = -10000.0;   GLfloat max_z = -10000.0;

    char v;
    int count = 0;
    while (!feof(file1))
    {
        v = fgetc(file1);
        if (v == 'v')
        {
            arrayfloat = new GLfloat[3];
            fscanf(file1, "%f%f%f", &a, &b, &c);
            arrayfloat[0] = a;
            arrayfloat[1] = b;
            arrayfloat[2] = c;
            //cout << a << " " << b << " " << c << endl;
            min_x = std::min(a, min_x);
            min_y = std::min(b, min_y);
            min_z = std::min(c, min_z);
            max_x = std::max(a, max_x);
            max_y = std::max(b, max_y);
            max_z = std::max(c, max_z);
            vertices.push_back(arrayfloat);

        }
        else if (v == 'f')
        {
            arrayint = new GLint[3];
            fscanf(file1, "%d%d%d", &e, &f, &g);
            faces.push_back(e);
            faces.push_back(f);
            faces.push_back(g);

        }
    }
    fclose(file1);

    xcenter = (max_x + min_x) / 2;
    ycenter = (max_y + min_y) / 2;
    zcenter = (max_z + min_z) / 2;

    scale = std::max(max_x - min_x, std::max(max_y - min_y, max_z - min_z));

    GLfloat *points;
    points = (GLfloat *)malloc(faces.size() * 3 * sizeof(GLfloat));
    GLfloat *normals;
    normals = (GLfloat *)malloc(faces.size() * 3 * sizeof(GLfloat));
    for (int i = 0; i < faces.size(); ++i) {
        if (do_scale)
        {
            points[i * 3] = ((GLfloat)vertices[faces[i] - 1][0]-xcenter)/scale;
            points[i * 3 + 1] = ((GLfloat)vertices[faces[i] - 1][1]-ycenter)/scale;
            points[i * 3 + 2] = ((GLfloat)vertices[faces[i] - 1][2]-zcenter)/scale;
        }
        else
        {
            points[i * 3] = ((GLfloat)vertices[faces[i] - 1][0]);
            points[i * 3 + 1] = ((GLfloat)vertices[faces[i] - 1][1]);
            points[i * 3 + 2] = ((GLfloat)vertices[faces[i] - 1][2]);
        }

    }
    // printf("count = %d\n", count);
    for (int i = 0; i < faces.size(); i += 3) {
        GLint e = faces[i];
        GLint f = faces[i + 1];
        GLint g = faces[i + 2];
        glm::vec3 v1 = glm::vec3(vertices[e - 1][0], vertices[e - 1][1], vertices[e - 1][2]);
        glm::vec3 v2 = glm::vec3(vertices[f - 1][0], vertices[f - 1][1], vertices[f - 1][2]);
        glm::vec3 v3 = glm::vec3(vertices[g - 1][0], vertices[g - 1][1], vertices[g - 1][2]);
        glm::vec3 n = glm::triangleNormal(v1, v2, v3);
        normals[count] = n.x; count++;
        normals[count] = n.y; count++;
        normals[count] = n.z; count++;
        normals[count] = n.x; count++;
        normals[count] = n.y; count++;
        normals[count] = n.z; count++;
        normals[count] = n.x; count++;
        normals[count] = n.y; count++;
        normals[count] = n.z; count++;
    }

    // Set how many vertices there are.
    *vertex_count = (unsigned int)(faces.size() * 3);

    // Allocate memory for all the vertices.
    *geometry = (GLfloat *)malloc(sizeof(GLfloat) * *vertex_count);

    // Copy over the vertex normals.
    for (int i = 0; i < *vertex_count; i++)
    {
        (*geometry)[i] = points[i];
    }

    // Allocate memory for the face normals.
    *face_normals = (GLfloat *)malloc(sizeof(GLfloat) * *vertex_count);

    // Copy over the vertex normals.
    for (int i = 0; i < *vertex_count; i++)
    {
        (*face_normals)[i] = normals[i];
    }

//    // printf("count = %d\n", count);
//    glGenVertexArrays(1, &vao);
//    glBindVertexArray(vao);
//
//    // GLuint vbo;
//    glGenBuffers(1, &vertices_vbo);
//    glBindBuffer(GL_ARRAY_BUFFER, vertices_vbo);
//    glBufferData(GL_ARRAY_BUFFER, 3 * faces.size() * sizeof(GLfloat), points, GL_STATIC_DRAW);
//    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, NULL);
//    glEnableVertexAttribArray(0);




    // Lets see how many vertices and faces there are.
    // printf("vertices.size(): %lu\n", vertices.size());
    // printf("faces.size(): %lu\n", faces.size());


    // printf("vertices[0]: (%f, %f, %f)\n", vertices[0][0], vertices[0][1], vertices[0][2]);
    // printf("faces[0]: (%d, %d, %d)\n", faces[0], faces[1], faces[2]);

    // Make a vector for its neighbors.
    std::vector<glm::vec3> vertex_normals_vector;

    // Go through each vertex.
    for (int i = 0; i < vertices.size(); i++)
    {
        // Grab this vertex.
        // GLfloat * vertex = vertices[i];

        // Make a vector for its neighbors.
        std::vector<GLint> neighbors;

        // Go through all the faces.
        for (int j = 0; j < faces.size(); j += 3)
        {
           // GLint * face = faces[j];

            // Go through each vertex of the face.
            for (int k = 0; k < 3; k++)
            {
                // Check if this vertex of the face is the ith vertex.
                if ((i + 1) == faces[j + k])
                {
                    // Add this face to the list of neighbors.
                    neighbors.push_back(faces[j + 0]);
                    neighbors.push_back(faces[j + 1]);
                    neighbors.push_back(faces[j + 2]);
                }
            }
        }

        // printf("neighbors.size(): %lu\n", neighbors.size());

        glm::vec3 normal_top(0.0f, 0.0f, 0.0f);

        // Go through the neighboring faces to get the sum.
        for (int j = 0; j < neighbors.size(); j += 3)
        {
            // printf("neighbors[j]: %d\n", neighbors[j]);

            // int face_index = neighbors[j] - 1;

            // Grab the vertices for this face.
            int vertex1 = neighbors[j + 0];
            int vertex2 = neighbors[j + 1];
            int vertex3 = neighbors[j + 2];
            // printf("face: (%d, %d, %d)\n", vertex1, vertex2, vertex3);

            // Calculate the face normal.
            glm::vec3 v1 = glm::vec3(vertices[vertex1 - 1][0], vertices[vertex1 - 1][1], vertices[vertex1 - 1][2]);
            glm::vec3 v2 = glm::vec3(vertices[vertex2 - 1][0], vertices[vertex2 - 1][1], vertices[vertex2 - 1][2]);
            glm::vec3 v3 = glm::vec3(vertices[vertex3 - 1][0], vertices[vertex3 - 1][1], vertices[vertex3 - 1][2]);
            glm::vec3 face_normal = glm::triangleNormal(v1, v2, v3);

            normal_top.x += face_normal.x;
            normal_top.y += face_normal.y;
            normal_top.z += face_normal.z;

            // printf("normal_top: (%f, %f, %f)\n", normal_top.x, normal_top.y, normal_top.z);
        }

        // printf("normal_top: (%f, %f, %f)\n", normal_top.x, normal_top.y, normal_top.z);

        // Do the averaging thing.
        // GLfloat normal_bottom = sqrt(pow(normal_top.x, 2) + pow(normal_top.y, 2) + pow(normal_top.z, 2));

        // printf("normal_bottom: %f\n", normal_bottom);

        // glm::vec3 vector_normal = normal_top / normal_bottom;
        glm::vec3 vertex_normal = glm::normalize(normal_top);

        // printf("vector_normal: (%f, %f, %f)\n", vector_normal.x, vector_normal.y, vector_normal.z);
        // printf("glm::normalize (%f, %f, %f)\n", glm::normalize(normal_top).x, glm::normalize(normal_top).y, glm::normalize(normal_top).z);

        // Add it to the list of vertex normals.
        vertex_normals_vector.push_back(vertex_normal);
    }

    // printf("vertex_normals.size(): %lu\n", vertex_normals.size());

    int face_index = 0;

    // Go through each face.
    for (int i = 0; i < faces.size(); i += 3)
    {
        // Grab this faces three vertices.
        int vertex1 = faces[i + 0];
        int vertex2 = faces[i + 1];
        int vertex3 = faces[i + 2];

        // printf("Face %5d: (%d, %d, %d)\n", i, vertex1, vertex2, vertex3);

        normals[face_index] = vertex_normals_vector[vertex1 - 1].x; face_index++;
        normals[face_index] = vertex_normals_vector[vertex1 - 1].y; face_index++;
        normals[face_index] = vertex_normals_vector[vertex1 - 1].z; face_index++;

        normals[face_index] = vertex_normals_vector[vertex2 - 1].x; face_index++;
        normals[face_index] = vertex_normals_vector[vertex2 - 1].y; face_index++;
        normals[face_index] = vertex_normals_vector[vertex2 - 1].z; face_index++;

        normals[face_index] = vertex_normals_vector[vertex3 - 1].x; face_index++;
        normals[face_index] = vertex_normals_vector[vertex3 - 1].y; face_index++;
        normals[face_index] = vertex_normals_vector[vertex3 - 1].z; face_index++;
        // printf("i = %d\n", i);
    }

    // Allocate memory for the vertex normals.
    *vertex_normals = (GLfloat *)malloc(sizeof(GLfloat) * *vertex_count);

    // Copy over the vertex normals.
    for (int i = 0; i < *vertex_count; i++)
    {
        (*vertex_normals)[i] = normals[i];
    }

    // for (int i = 0; i < faces.size(); i += 3)
    // {
    //     printf("points[%6d]: (%f, %f, %f)\n", i, points[i + 0], points[i + 1], points[i + 2]);
    // }
    // for (int i = 0; i < faces.size(); i += 3)
    // {
    //     printf("normals[%6d]: (%f, %f, %f)\n", i, normals[i + 0], normals[i + 1], normals[i + 2]);
    // }

//    glGenBuffers(1, &face_normals_vbo);
//    glBindBuffer(GL_ARRAY_BUFFER, face_normals_vbo);
//    glBufferData(GL_ARRAY_BUFFER, 3 * faces.size() * sizeof(GLfloat), face_normals, GL_STATIC_DRAW);
//    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, NULL);
//
//    glGenBuffers(1, &vertex_normals_vbo);
//    glBindBuffer(GL_ARRAY_BUFFER, vertex_normals_vbo);
//    glBufferData(GL_ARRAY_BUFFER, 3 * faces.size() * sizeof(GLfloat), vertex_normals, GL_STATIC_DRAW);
//    glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, 0, NULL);
//
//    glEnableVertexAttribArray(0);
//    glEnableVertexAttribArray(1);
//    glEnableVertexAttribArray(2);

    free(points);
    free(normals);

    return (int)faces.size();
}

#endif /* readfile_h */
