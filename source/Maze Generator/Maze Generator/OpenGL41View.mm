//
//  OpenGL41View.m
//  Maze Generator
//
//  Created by Jason James on 4/16/20.
//  Copyright © 2020 Jason James. All rights reserved.
//

#import "OpenGL41View.h"

#include <OpenGL/gl3.h>
// TODO: Implement own vextor and matrix types.
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

#include "Maze.hpp"
// TODO: Implement own shader source loader.
#include "InitShader.h"
// TODO: Implement own OBJ loader.
#include "readfile.h"

@implementation OpenGL41View


#define MOVEMENT_STEP_SIZE 0.5
#define MOVEMENT_ROTATE_SIZE 30.0

// So, apparently, there's like no named constants for the key codes?
#define KEY_0 29
#define KEY_1 18
#define KEY_2 19
#define KEY_3 20
#define KEY_4 21
#define KEY_5 22
#define KEY_6 23
#define KEY_7 24
#define KEY_8 25
#define KEY_9 25
#define KEY_UP 126
#define KEY_DOWN 125
#define KEY_LEFT 123
#define KEY_RIGHT 124

typedef enum
{
    SHADING_MODEL_FLAT = 0,
    SHADING_MODEL_GOURAUD = 1,
    SHADING_MODEL_PHONG = 2,

    SHADING_MODEL_COUNT
} shading_model_t;

typedef enum
{
    DRAWING_OBJECT_X_AXIS = 0,
    DRAWING_OBJECT_Y_AXIS = 1,
    DRAWING_OBJECT_Z_AXIS = 2,

    DRAWING_OBJECT_CUBE = 3,
    DRAWING_OBJECT_PLANE = 4,

    DRAWING_OBJECT_SKY = 5,
    DRAWING_OBJECT_BEACH = 6,
    DRAWING_OBJECT_WATER = 7,

    DRAWING_OBJECT_BUSH = 8,
    DRAWING_OBJECT_PALM_GREEN = 9,
    DRAWING_OBJECT_PALM_BROWN = 10,
    DRAWING_OBJECT_PENGUIN_BLACK = 11,
    DRAWING_OBJECT_PENGUIN_WHITE = 12,
    DRAWING_OBJECT_PENGUIN_ORANGE= 13,
    DRAWING_OBJECT_GATE = 14,
    DRAWING_OBJECT_OCEAN_FLOOR = 15,

    DRAWING_OBJECT_ENEMY_BODY = 16,
    DRAWING_OBJECT_ENEMY_SPIKES = 17,

    DRAWING_OBJECT_MOUNTAIN = 18,
    DRAWING_OBJECT_LAVA = 19,
    DRAWING_OBJECT_SMOKE = 20,

    DRAWING_OBJECT_COUNT
} drawing_object_t;

typedef enum
{
    CAMERA_TYPE_DEVELOPMENT = 0,
    CAMERA_TYPE_START_SCREEN = 1,
    CAMERA_TYPE_FIRST_PERSON = 2,
    CAMERA_TYPE_BIRDS_EYE = 3,
    CAMERA_TYPE_THIRD_PERSON = 4,

    CAMERA_TYPE_COUNT
} camera_type_t;

typedef struct
{
    glm::vec4 position;
    glm::vec4 ambient;
    glm::vec4 diffuse;
    glm::vec4 specular;
} light_t;

typedef struct
{
    glm::vec4 ambient;
    glm::vec4 diffuse;
    glm::vec4 specular;
    GLfloat shininess;
} material_t;

typedef struct
{
    glm::vec3 position;
    glm::vec3 front;
    glm::vec3 up;
    glm::vec3 right;
    glm::vec3 worldUp;
    glm::vec3 target;

    GLfloat yaw;
    GLfloat pitch;
    GLfloat roll;

    glm::mat4 view;
} camera_t;

shading_model_t shadingModel = SHADING_MODEL_FLAT;
//shading_model_t shadingModel = SHADING_MODEL_GOURAUD;
//shading_model_t shadingModel = SHADING_MODEL_PHONG;
GLuint shadingModelVariable;

camera_t developmentCamera;
camera_t startScreenCamera;
camera_t birdsEyeCamera;
camera_t firstPersonCamera;
camera_t thirdPersonCamera;

double spinCameraAngle = 0.0;

//camera_type_t currentCameraType = CAMERA_TYPE_BIRDS_EYE;
camera_type_t currentCameraType = CAMERA_TYPE_START_SCREEN;

// TODO: Implement own vextor and matrix types.
glm::vec3 eye(0.0, 0.0, 50.0);
glm::vec3 at(0.0, 0.0, 0.0);
glm::vec3 up(0.0, 1.0, 0.0);
glm::mat4 view = glm::lookAt(eye, at, up);

GLfloat zoom = 1.0;
GLfloat horizontalRotation = 0.0;
GLfloat verticalRotation = 0.0;

//GLfloat zoom = 1.0;
//GLfloat horizontalRotation = 0.0;
//GLfloat verticalRotation = 0.0;

GLuint shaderProgram;

GLuint modelVariable;
GLuint viewVariable;
GLuint projectionVariable;

Maze * maze;
char ** mazeMap;
int mapHeight = 0;
int mapWidth = 0;

light_t light;

GLuint lightPositionVariable;
GLuint lightAmbientVariable;
GLuint lightDiffuseVariable;
GLuint lightSpecularVariable;
GLuint materialAmbientVariable;
GLuint materialDiffuseVariable;
GLuint materialSpecularVariable;
GLuint materialShininessVariable;

GLuint triangleVAO;
GLuint triangleVBO;
GLuint xAxisVAO;
GLuint xAxisVBO;
GLuint yAxisVAO;
GLuint yAxisVBO;
GLuint zAxisVAO;
GLuint zAxisVBO;
GLuint cubeVAO;
GLuint cubePointVBO;
GLuint cubeFaceNormalVBO;
GLuint cubeVertexNormalVBO;
GLuint planeVAO;
GLuint planePointVBO;
GLuint planeFaceNormalVBO;
GLuint planeVertexNormalVBO;

GLuint skyVAO;
GLuint skyPointVBO;
GLuint skyColorVBO;

GLuint beachVAO;
GLuint beachPointVBO;
GLuint beachFaceNormalVBO;
GLuint beachVertexNormalVBO;

GLuint waterVAO;
GLuint waterPointVBO;
GLuint waterColorVBO;

GLuint oceanFloorVAO;
GLuint oceanFloorPointVBO;
GLuint oceanFloorColorVBO;

GLuint bushVAO;
GLuint bushPointVBO;
GLuint bushFaceNormalVBO;
GLuint bushVertexNormalVBO;

GLuint palmGreenVAO;
GLuint palmGreenPointVBO;
GLuint palmGreenFaceNormalVBO;
GLuint palmGreenVertexNormalVBO;

GLuint palmBrownVAO;
GLuint palmBrownPointVBO;
GLuint palmBrownFaceNormalVBO;
GLuint palmBrownVertexNormalVBO;

GLuint penguinBlackBodyVAO;
GLuint penguinBlackBodyPointVBO;
GLuint penguinBlackBodyFaceNormalVBO;
GLuint penguinBlackBodyVertexNormalVBO;

GLuint penguinWhiteBodyVAO;
GLuint penguinWhiteBodyPointVBO;
GLuint penguinWhiteBodyFaceNormalVBO;
GLuint penguinWhiteBodyVertexNormalVBO;

GLuint penguinOrangeBodyVAO;
GLuint penguinOrangeBodyPointVBO;
GLuint penguinOrangeBodyFaceNormalVBO;
GLuint penguinOrangeBodyVertexNormalVBO;

GLuint gateVAO;
GLuint gatePointVBO;
GLuint gateFaceNormalVBO;
GLuint gateVertexNormalVBO;

GLuint enemyBodyVAO;
GLuint enemyBodyPointVBO;
GLuint enemyBodyFaceNormalVBO;
GLuint enemyBodyVertexNormalVBO;

GLuint enemySpikesVAO;
GLuint enemySpikesPointVBO;
GLuint enemySpikesFaceNormalVBO;
GLuint enemySpikesVertexNormalVBO;

GLuint mountainVAO;
GLuint mountainPointVBO;
GLuint mountainFaceNormalVBO;
GLuint mountainVertexNormalVBO;

GLuint lavaVAO;
GLuint lavaPointVBO;
GLuint lavaFaceNormalVBO;
GLuint lavaVertexNormalVBO;

GLuint smokeVAO;
GLuint smokePointVBO;
GLuint smokeFaceNormalVBO;
GLuint smokeVertexNormalVBO;

GLuint cubePointCount = 0;
GLfloat * cubePoints = NULL;
GLfloat * cubeFaceNormals = NULL;
GLfloat * cubeVertexNormals = NULL;

GLuint planePointCount = 0;
GLfloat * planePoints = NULL;
GLfloat * planeFaceNormals = NULL;
GLfloat * planeVertexNormals = NULL;

GLuint beachPointCount = 0;
GLfloat * beachPoints = NULL;
GLfloat * beachFaceNormals = NULL;
GLfloat * beachVertexNormals = NULL;

GLuint bushPointCount = 0;
GLfloat * bushPoints = NULL;
GLfloat * bushFaceNormals = NULL;
GLfloat * bushVertexNormals = NULL;

GLuint palmGreenPointCount = 0;
GLfloat * palmGreenPoints = NULL;
GLfloat * palmGreenFaceNormals = NULL;
GLfloat * palmGreenVertexNormals = NULL;

GLuint palmBrownPointCount = 0;
GLfloat * palmBrownPoints = NULL;
GLfloat * palmBrownFaceNormals = NULL;
GLfloat * palmBrownVertexNormals = NULL;

GLuint penguinBlackBodyPointCount = 0;
GLfloat * penguinBlackBodyPoints = NULL;
GLfloat * penguinBlackBodyFaceNormals = NULL;
GLfloat * penguinBlackBodyVertexNormals = NULL;

GLuint penguinWhiteBodyPointCount = 0;
GLfloat * penguinWhiteBodyPoints = NULL;
GLfloat * penguinWhiteBodyFaceNormals = NULL;
GLfloat * penguinWhiteBodyVertexNormals = NULL;

GLuint penguinOrangeBodyPointCount = 0;
GLfloat * penguinOrangeBodyPoints = NULL;
GLfloat * penguinOrangeBodyFaceNormals = NULL;
GLfloat * penguinOrangeBodyVertexNormals = NULL;

GLuint gatePointCount = 0;
GLfloat * gatePoints = NULL;
GLfloat * gateFaceNormals = NULL;
GLfloat * gateVertexNormals = NULL;

GLuint enemyBodyPointCount = 0;
GLfloat * enemyBodyPoints = NULL;
GLfloat * enemyBodyFaceNormals = NULL;
GLfloat * enemyBodyVertexNormals = NULL;

GLuint enemySpikesPointCount = 0;
GLfloat * enemySpikesPoints = NULL;
GLfloat * enemySpikesFaceNormals = NULL;
GLfloat * enemySpikesVertexNormals = NULL;

GLuint mountainPointCount = 0;
GLfloat * mountainPoints = NULL;
GLfloat * mountainFaceNormals = NULL;
GLfloat * mountainVertexNormals = NULL;

GLuint lavaPointCount = 0;
GLfloat * lavaPoints = NULL;
GLfloat * lavaFaceNormals = NULL;
GLfloat * lavaVertexNormals = NULL;

GLuint smokePointCount = 0;
GLfloat * smokePoints = NULL;
GLfloat * smokeFaceNormals = NULL;
GLfloat * smokeVertexNormals = NULL;

glm::vec3 triangleTranslation(0.0, 0.0, 0.0);
GLfloat triangleRotation = 0.0;

glm::vec3 penguinTranslation(0.0, 0.0, 0.0);
GLfloat penguinRotation = 0.0;

unsigned long int startTime = 0;
unsigned long int timeLimit = 60;

typedef struct
{
    glm::vec3 location;
    GLfloat radius;
} goal_t;

goal_t goal;

typedef enum
{
    // Game not actually going.
    GAME_STATE_DEVELOPMENT,

    // The game has not yet begun.
    GAME_STATE_STARTING,

    // The game is currently in progress.
    GAME_STATE_IN_PROGRESS,

    // The game has ended.
    GAME_STATE_FINISHED

} game_state_t;

//game_state_t gameState = GAME_STATE_DEVELOPMENT;
game_state_t gameState = GAME_STATE_STARTING;

typedef struct
{
    glm::vec3 location;
    GLfloat radius;
    GLfloat speed;
} enemy_t;

glm::vec3 enemyStartLocation(0.0, 0.0, 55.0);

vector<enemy_t> enemies;

typedef struct
{
    glm::vec3 location;
    GLfloat rotation;
    glm::vec3 scale;
} plant_t;

vector<plant_t> trees;
vector<plant_t> bushes;

void resetGame()
{
    triangleTranslation = glm::vec3(0.0, 1.0, 53.0);
    penguinTranslation = glm::vec3(2.0, 1.0, 53.0);
    penguinRotation = 0.0;

    // Setup the light.
    light.position = glm::vec4(500.0, 500.0, -200.0, 0.0f);
    light.ambient = glm::vec4(1.0f, 1.0f, 1.0f, 1.0f);
    light.diffuse = glm::vec4(1.0f, 1.0f, 1.0f, 1.0f);
    light.specular = glm::vec4(1.0f, 1.0f, 1.0f, 1.0f);

    // Setup the development camera.
    developmentCamera.position = glm::vec3(0.0, 50.0, 53.0);
    developmentCamera.front = glm::vec3(0.0, -1.0, 0.0);
    developmentCamera.up = glm::vec3(0.0, 0.0, -1.0);
    developmentCamera.worldUp = glm::vec3(0.0, 0.0, -1.0);
    developmentCamera.view = glm::lookAt(developmentCamera.position,
                                         developmentCamera.position + developmentCamera.front,
                                         developmentCamera.up);

    // Yaw needs to start at -90.0 degrees.
    developmentCamera.yaw = -90.0;
    developmentCamera.pitch = 0.0;
    developmentCamera.roll = 0.0;

    // Setup the start screen camera.
    spinCameraAngle = 0.0;
    startScreenCamera.position.x = sin(glm::radians(spinCameraAngle)) * 100.0;
    startScreenCamera.position.y = 200.0;
    startScreenCamera.position.z = cos(glm::radians(spinCameraAngle)) * 100.0;

    startScreenCamera.view = glm::lookAt(startScreenCamera.position, glm::vec3(0.0, 0.0, 0.0), up);

    // Yaw needs to start at -90.0 degrees.
    startScreenCamera.yaw = -90.0;
    startScreenCamera.pitch = 0.0;
    startScreenCamera.roll = 0.0;

    // Setup the first person camera.
    firstPersonCamera.position = glm::vec3(2.0, 4.0, 53.0);
    firstPersonCamera.front = glm::vec3(0.0, 0.0, -1.0);
    firstPersonCamera.up = glm::vec3(0.0, 1.0, 0.0);
    firstPersonCamera.worldUp = glm::vec3(0.0, 1.0, 0.0);
    firstPersonCamera.view = glm::lookAt(firstPersonCamera.position,
                                         firstPersonCamera.position + firstPersonCamera.front,
                                         firstPersonCamera.up);

    // Yaw needs to start at -90.0 degrees.
    firstPersonCamera.yaw = -90.0;
    firstPersonCamera.pitch = 0.0;
    firstPersonCamera.roll = 0.0;

    // Setup the third person camera.
    glm::vec3 direction = glm::vec3(0.0, 0.0, 0.0);
    direction.x = sin(glm::radians(180.0 + penguinRotation));
    direction.y = glm::radians(-30.0);
    direction.z = cos(glm::radians(180.0 + penguinRotation));
    thirdPersonCamera.position = penguinTranslation - 4.0f * glm::normalize(direction);
    thirdPersonCamera.position.y = 10.0;
    thirdPersonCamera.front = glm::normalize(direction);
    thirdPersonCamera.up = glm::vec3(0.0, 1.0, 0.0);
    thirdPersonCamera.worldUp = glm::vec3(0.0, 1.0, 0.0);
    thirdPersonCamera.view = glm::lookAt(thirdPersonCamera.position,
                                         thirdPersonCamera.position + thirdPersonCamera.front,
                                         thirdPersonCamera.up);

//    thirdPersonCamera.front = glm::normalize(direction);

    // Yaw needs to start at -90.0 degrees.
    thirdPersonCamera.yaw = -90.0;
    thirdPersonCamera.pitch = 0.0;
    thirdPersonCamera.roll = 0.0;

    // Setup the bird's eye camera.
    birdsEyeCamera.position = glm::vec3(0.0, 50.0, 53.0);
    birdsEyeCamera.front = glm::vec3(0.0, -1.0, 0.0);
    birdsEyeCamera.up = glm::vec3(0.0, 0.0, -1.0);
    birdsEyeCamera.worldUp = glm::vec3(0.0, 0.0, -1.0);
    birdsEyeCamera.view = glm::lookAt(birdsEyeCamera.position,
                                      birdsEyeCamera.position + birdsEyeCamera.front,
                                      birdsEyeCamera.up);

    // Yaw needs to start at -90.0 degrees.
    birdsEyeCamera.yaw = -90.0;
    birdsEyeCamera.pitch = 0.0;
    birdsEyeCamera.roll = 0.0;

    // Clear the enemies.
    enemies.clear();
}

BOOL isTouchingEnemy(enemy_t enemy, glm::vec3 playerLocation)
{
    // Calculate the distance between the enemy's location and the player's location.
    double distance = sqrt(pow(enemy.location.x - playerLocation.x, 2.0) + pow(enemy.location.z - playerLocation.z, 2.0));

//    printf("distance: %f\n", distance);

    // Check if that distance is less than the enemy radius.
    if (distance <= enemy.radius)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

BOOL isAtGoal(glm::vec3 playerLocation)
{
    // Calculate the distance between the player's location and the goal location.
    double distance = sqrt(pow(playerLocation.x - goal.location.x, 2.0) + pow(playerLocation.z - goal.location.z, 2.0));

//    printf("distance: %f\n", distance);

    // Check if that distance is less than the goal radius.
    if (distance <= goal.radius)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)awakeFromNib
{
    [self acceptsFirstResponder];

    // Setup the goal location.
    goal.location = glm::vec3(0.0, 0.0, -50.0);
    goal.radius = 5.0;

    // Start the spin camera timer.
    spinCameraTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                       target:self
                                                     selector:@selector(spinCameraTick:)
                                                     userInfo:nil
                                                      repeats:YES];

    // Add some vegetation to the main island.
    plant_t bigTreeRight;
    bigTreeRight.location = glm::vec3(42.0, 0.0, 48.0);
    bigTreeRight.rotation = glm::radians((double)rand() / (double)INT_MAX * 360);
    bigTreeRight.scale = glm::vec3(3.0);

    trees.push_back(bigTreeRight);

    plant_t smallerTreeRight1;
    smallerTreeRight1.location = glm::vec3(40.0, 0.0, 46.0);
    smallerTreeRight1.rotation = glm::radians((double)rand() / (double)INT_MAX * 360);
    smallerTreeRight1.scale = glm::vec3(1.5);

    trees.push_back(smallerTreeRight1);

    plant_t smallerTreeRight2;
    smallerTreeRight2.location = glm::vec3(44.0, 0.0, 50.0);
    smallerTreeRight2.rotation = glm::radians((double)rand() / (double)INT_MAX * 360);
    smallerTreeRight2.scale = glm::vec3(1.5);

    trees.push_back(smallerTreeRight2);

    plant_t bigTreeLeft;
    bigTreeLeft.location = glm::vec3(-42.0, 0.0, 48.0);
    bigTreeLeft.rotation = glm::radians((double)rand() / (double)INT_MAX * 360);
    bigTreeLeft.scale = glm::vec3(3.0);

    trees.push_back(bigTreeLeft);

    plant_t smallerTreeLeft1;
    smallerTreeLeft1.location = glm::vec3(-40.0, 0.0, 46.0);
    smallerTreeLeft1.rotation = glm::radians((double)rand() / (double)INT_MAX * 360);
    smallerTreeLeft1.scale = glm::vec3(1.5);

    trees.push_back(smallerTreeLeft1);

    plant_t smallerTreeLeft2;
    smallerTreeLeft2.location = glm::vec3(-44.0, 0.0, 50.0);
    smallerTreeLeft2.rotation = glm::radians((double)rand() / (double)INT_MAX * 360);
    smallerTreeLeft2.scale = glm::vec3(1.5);

    trees.push_back(smallerTreeLeft2);

//    for (int i = 0; i < 20; i++)
//    {
//        plant_t newTree;
//        double treeAngle = (rand() % 45) + 45.0;
//        newTree.location.x = 60.0 * cos(treeAngle);
//        newTree.location.z = 60.0 * sin(treeAngle);
//        newTree.rotation = (double)rand() / (double)INT_MAX * 360;
//        double randomTreeScale = ((double)rand() / (double)INT_MAX) * 3.0 + 1.0;
//        newTree.scale = glm::vec3(randomTreeScale, randomTreeScale, randomTreeScale);
//
//        trees.push_back(newTree);
//
//        plant_t newBush;
//        double bushAngle = (rand() % 45) + 45.0;
//        newBush.location.x = 60.0 * cos(bushAngle);
//        newBush.location.z = 60.0 * sin(bushAngle);
//        newBush.rotation = (double)rand() / (double)INT_MAX * 360;
//        double randomBushScale = ((double)rand() / (double)INT_MAX) * 3.0 + 1.0;
//        newBush.scale = glm::vec3(randomBushScale, randomBushScale, randomBushScale);
//
//        bushes.push_back(newBush);
//    }

    // Create some vegetation for the volcano.
    for (int i = 0; i < 100; i++)
    {
        plant_t newTree;
        double treeAngle = ((double)rand() / (double)INT_MAX) * 360.0;
        newTree.location.x = 200.0 + 200.0 * cos(treeAngle);
        newTree.location.z = -400.0 + 200.0 * sin(treeAngle);
        newTree.rotation = (double)rand() / (double)INT_MAX * 360;
        double randomTreeScale = ((double)rand() / (double)INT_MAX) * 5.0 + 1.0;
        newTree.scale = glm::vec3(randomTreeScale, randomTreeScale, randomTreeScale);

        trees.push_back(newTree);

        plant_t newBush;
        double bushAngle = ((double)rand() / (double)INT_MAX) * 360.0;
        newBush.location.x = 200.0 + 200.0 * cos(bushAngle);
        newBush.location.z = -400.0 + 200.0 * sin(bushAngle);
        newBush.rotation = (double)rand() / (double)INT_MAX * 360;
        double randomBushScale = ((double)rand() / (double)INT_MAX) * 5.0 + 1.0;
        newBush.scale = glm::vec3(randomBushScale, randomBushScale, randomBushScale);

        bushes.push_back(newBush);
    }

    // Create some vegetation for the big island.
    for (int i = 0; i < 50; i++)
    {
        plant_t newTree;
        double treeAngle = ((double)rand() / (double)INT_MAX) * 360.0;
        newTree.location.x = -200.0 + 95.0 * cos(treeAngle);
        newTree.location.z = 200.0 + 95.0 * sin(treeAngle);
        newTree.rotation = (double)rand() / (double)INT_MAX * 360;
        double randomTreeScale = ((double)rand() / (double)INT_MAX) * 3.0 + 1.0;
        newTree.scale = glm::vec3(randomTreeScale, randomTreeScale, randomTreeScale);

        trees.push_back(newTree);

        plant_t newBush;
        double bushAngle = ((double)rand() / (double)INT_MAX) * 360.0;
        newBush.location.x = -200.0 + 95.0 * cos(bushAngle);
        newBush.location.z = 200.0 + 95.0 * sin(bushAngle);
        newBush.rotation = (double)rand() / (double)INT_MAX * 360;
        double randomBushScale = ((double)rand() / (double)INT_MAX) * 3.0 + 1.0;
        newBush.scale = glm::vec3(randomBushScale, randomBushScale, randomBushScale);

        bushes.push_back(newBush);
    }

    // Create some vegetation for the second smallest island.
    for (int i = 0; i < 10; i++)
    {
        plant_t newTree;
        newTree.location.x = 150.0 - (rand() % 50) + 25.0;
        newTree.location.z = 100.0 - (rand() % 50) + 25.0;
        newTree.rotation = (double)rand() / (double)INT_MAX * 360;
        double randomTreeScale = ((double)rand() / (double)INT_MAX) * 3.0 + 1.0;
        newTree.scale = glm::vec3(randomTreeScale, randomTreeScale, randomTreeScale);

        trees.push_back(newTree);

        plant_t newBush;
        newBush.location.x = 150.0 - (rand() % 50) + 25.0;
        newBush.location.z = 100.0 - (rand() % 50) + 25.0;
        newBush.rotation = (double)rand() / (double)INT_MAX * 360;
        double randomBushScale = ((double)rand() / (double)INT_MAX) * 3.0 + 1.0;
        newBush.scale = glm::vec3(randomBushScale, randomBushScale, randomBushScale);

        bushes.push_back(newBush);
    }

    // Create some more bushes second smallest island.
    for (int i = 0; i < 50; i++)
    {
        plant_t newBush;
        newBush.location.x = 150.0 - (rand() % 50) + 25.0;
        newBush.location.z = 100.0 - (rand() % 50) + 25.0;
        newBush.rotation = (double)rand() / (double)INT_MAX * 360;
        double randomBushScale = ((double)rand() / (double)INT_MAX) * 3.0 + 1.0;
        newBush.scale = glm::vec3(randomBushScale, randomBushScale, randomBushScale);

        bushes.push_back(newBush);
    }

    // Create some vegetation for the smallest island.
    for (int i = 0; i < 1; i++)
    {
        plant_t newTree;
        newTree.location.x = 250.0;
        newTree.location.z = 200.0;
        newTree.rotation = (double)rand() / (double)INT_MAX * 360.0;
        double randomTreeScale = ((double)rand() / (double)INT_MAX) * 3.0 + 1.0;
        newTree.scale = glm::vec3(randomTreeScale, randomTreeScale, randomTreeScale);

        trees.push_back(newTree);
    }

    NSFontManager * fontManager = [NSFontManager sharedFontManager];

    NSFont * timerFont = [fontManager fontWithFamily:@"Courier New"
                                              traits:NSBoldFontMask
                                              weight:0
                                                size:48];

    [timeLabel setTextColor:[NSColor greenColor]];
    [timeLabel setFont:timerFont];
    [timeLabel setStringValue:@""];

    NSFont * messageFont = [fontManager fontWithFamily:@"Courier New"
                                                traits:NSBoldFontMask
                                                weight:0
                                                  size:64];

    [messageLabel setTextColor:[NSColor greenColor]];
    [messageLabel setFont:messageFont];
    [messageLabel setStringValue:@"Penguin Maze\n\nPress any key to start!"];

    if (gameState == GAME_STATE_DEVELOPMENT)
    {
        [timeLabel setStringValue:@""];
        [messageLabel setStringValue:@""];
    }

    [algorithmPopUpButton selectItemWithTitle:@"Aldous-Broder"];
    [heightTextField setStringValue:[heightStepper stringValue]];
    [widthTextField setStringValue:[widthStepper stringValue]];

    if (currentCameraType == CAMERA_TYPE_BIRDS_EYE)
    {
        [viewPopUpButton selectItemWithTitle:@"Bird's Eye"];
    }
    else if (currentCameraType == CAMERA_TYPE_FIRST_PERSON)
    {
        [viewPopUpButton selectItemWithTitle:@"First Person"];
    }
    else if (currentCameraType == CAMERA_TYPE_THIRD_PERSON)
    {
        [viewPopUpButton selectItemWithTitle:@"Third Person"];
    }
    else if (currentCameraType == CAMERA_TYPE_DEVELOPMENT)
    {
        [viewPopUpButton selectItemWithTitle:@"Development"];
    }
    else if (currentCameraType == CAMERA_TYPE_START_SCREEN)
    {
        [viewPopUpButton selectItemWithTitle:@"Start Screen"];
    }

    triangleTranslation = glm::vec3(0.0, 1.0, 53.0);
    penguinTranslation = glm::vec3(2.0, 1.0, 53.0);

    // Setup the light.
    light.position = glm::vec4(-500.0, 500.0, 0, 0.0f);
    light.ambient = glm::vec4(1.0f, 1.0f, 1.0f, 1.0f);
    light.diffuse = glm::vec4(1.0f, 1.0f, 1.0f, 1.0f);
    light.specular = glm::vec4(1.0f, 1.0f, 1.0f, 1.0f);

    // Setup the camera.
    developmentCamera.position = glm::vec3(0.0, 0.0, 30);
    developmentCamera.front = glm::vec3(0.0, 0.0, -1.0);
    developmentCamera.up = glm::vec3(0.0, 1.0, 0.0);
    developmentCamera.worldUp = glm::vec3(0.0, 1.0, 0.0);
    developmentCamera.view = glm::lookAt(developmentCamera.position,
                                         developmentCamera.position + developmentCamera.front,
                                         developmentCamera.up);

    // Yaw needs to start at -90.0 degrees.
    developmentCamera.yaw = -90.0;
    developmentCamera.pitch = 0.0;
    developmentCamera.roll = 0.0;

    // Setup the first person camera.
    firstPersonCamera.position = glm::vec3(2.0, 4.0, 53.0);
    firstPersonCamera.front = glm::vec3(0.0, 0.0, -1.0);
    firstPersonCamera.up = glm::vec3(0.0, 1.0, 0.0);
    firstPersonCamera.worldUp = glm::vec3(0.0, 1.0, 0.0);
    firstPersonCamera.view = glm::lookAt(firstPersonCamera.position,
                                         firstPersonCamera.position + firstPersonCamera.front,
                                         firstPersonCamera.up);

    // Yaw needs to start at -90.0 degrees.
    firstPersonCamera.yaw = -90.0;
    firstPersonCamera.pitch = 0.0;
    firstPersonCamera.roll = 0.0;

    // Setup the third person camera.
    glm::vec3 direction(0.0, 0.0, 0.0);
    direction.x = sin(glm::radians(180.0 + penguinRotation));
    direction.y = glm::radians(-30.0);
    direction.z = cos(glm::radians(180.0 + penguinRotation));
    thirdPersonCamera.position = penguinTranslation - 4.0f * glm::normalize(direction);
    thirdPersonCamera.position.y = 10.0;
    thirdPersonCamera.front = glm::normalize(direction);
    thirdPersonCamera.up = glm::vec3(0.0, 1.0, 0.0);
    thirdPersonCamera.worldUp = glm::vec3(0.0, 1.0, 0.0);
    thirdPersonCamera.view = glm::lookAt(thirdPersonCamera.position,
                                         thirdPersonCamera.position + thirdPersonCamera.front,
                                         thirdPersonCamera.up);

//    thirdPersonCamera.front = glm::normalize(direction);

    // Yaw needs to start at -90.0 degrees.
    thirdPersonCamera.yaw = -90.0;
    thirdPersonCamera.pitch = 0.0;
    thirdPersonCamera.roll = 0.0;

    // Setup the bird's eye camera.
    birdsEyeCamera.position = glm::vec3(0.0, 50.0, 53.0);
    birdsEyeCamera.front = glm::vec3(0.0, -1.0, 0.0);
    birdsEyeCamera.up = glm::vec3(0.0, 0.0, -1.0);
    birdsEyeCamera.worldUp = glm::vec3(0.0, 0.0, -1.0);
    birdsEyeCamera.view = glm::lookAt(birdsEyeCamera.position,
                                      birdsEyeCamera.position + birdsEyeCamera.front,
                                      birdsEyeCamera.up);

    // Yaw needs to start at -90.0 degrees.
    birdsEyeCamera.yaw = -90.0;
    birdsEyeCamera.pitch = 0.0;
    birdsEyeCamera.roll = 0.0;


    // Setup triangle.
    GLfloat trianglePoints[] =
    {
         0.0,  0.0, -0.8, 1.0,
        -0.4,  0.0,  0.4, 1.0,
         0.4,  0.0,  0.4, 1.0
    };

    glGenVertexArrays(1, &triangleVAO);
    glBindVertexArray(triangleVAO);

    glGenBuffers(1, &triangleVBO);
    glBindBuffer(GL_ARRAY_BUFFER, triangleVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * sizeof(trianglePoints), trianglePoints, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(0);

    // Setup x-axis.
    GLfloat xAxis[] =
    {
        -1000.0, 0.0, 0.0, 1.0,
        0.0, 0.0, 0.0, 1.0,
        1000.0, 0.0, 0.0, 1.0,
    };

    glGenVertexArrays(1, &xAxisVAO);
    glBindVertexArray(xAxisVAO);

    glGenBuffers(1, &xAxisVBO);
    glBindBuffer(GL_ARRAY_BUFFER, xAxisVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * 12, xAxis, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(0);

    // Setup y-axis.
    GLfloat yAxis[] =
    {
        0.0, -1000.0, 0.0, 1.0,
        0.0, 0.0, 0.0, 1.0,
        0.0, 1000.0, 0.0, 1.0,
    };

    glGenVertexArrays(1, &yAxisVAO);
    glBindVertexArray(yAxisVAO);

    glGenBuffers(1, &yAxisVBO);
    glBindBuffer(GL_ARRAY_BUFFER, yAxisVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * 12, yAxis, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(0);

    // Setup z-axis.
    GLfloat zAxis[] =
    {
        0.0, 0.0, -1000.0, 1.0,
        0.0, 0.0, 0.0, 1.0,
        0.0, 0.0, 1000.0, 1.0,
    };

    glGenVertexArrays(1, &zAxisVAO);
    glBindVertexArray(zAxisVAO);

    glGenBuffers(1, &zAxisVBO);
    glBindBuffer(GL_ARRAY_BUFFER, zAxisVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * 12, zAxis, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(0);

    // Setup cube.
    NSString * cubeMeshPath = [[NSBundle mainBundle] pathForResource:@"cube" ofType:@"obj"];
    std::string cubeMeshPathString = [cubeMeshPath UTF8String];
    readfile(cubeMeshPathString,
             &cubePointCount,
             &cubePoints,
             &cubeFaceNormals,
             &cubeVertexNormals,
             true);

    glGenVertexArrays(1, &cubeVAO);
    glBindVertexArray(cubeVAO);

    glGenBuffers(1, &cubePointVBO);
    glBindBuffer(GL_ARRAY_BUFFER, cubePointVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * cubePointCount, cubePoints, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, NULL);

    glGenBuffers(1, &cubeFaceNormalVBO);
    glBindBuffer(GL_ARRAY_BUFFER, cubeFaceNormalVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * cubePointCount, cubeFaceNormals, GL_STATIC_DRAW);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, NULL);

    glGenBuffers(1, &cubeVertexNormalVBO);
    glBindBuffer(GL_ARRAY_BUFFER, cubeVertexNormalVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * cubePointCount, cubeVertexNormals, GL_STATIC_DRAW);
    glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, 0, NULL);

    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(1);
    glEnableVertexAttribArray(2);

//    for (int i = 0; i < cubePointCount; i++)
//    {
//        printf("%f\n", cubePoints[i]);
//    }

    // Setup plane.
    NSString * planeMeshPath = [[NSBundle mainBundle] pathForResource:@"plane" ofType:@"obj"];
    std::string planeMeshPathString = [planeMeshPath UTF8String];
    readfile(planeMeshPathString,
             &planePointCount,
             &planePoints,
             &planeFaceNormals,
             &planeVertexNormals,
             false);

    glGenVertexArrays(1, &planeVAO);
    glBindVertexArray(planeVAO);

    glGenBuffers(1, &planePointVBO);
    glBindBuffer(GL_ARRAY_BUFFER, planePointVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * planePointCount, planePoints, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(0);

    glGenBuffers(1, &planeFaceNormalVBO);
    glBindBuffer(GL_ARRAY_BUFFER, planeFaceNormalVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * planePointCount, planeFaceNormals, GL_STATIC_DRAW);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(1);

    glGenBuffers(1, &planeVertexNormalVBO);
    glBindBuffer(GL_ARRAY_BUFFER, planeVertexNormalVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * planePointCount, planeVertexNormals, GL_STATIC_DRAW);
    glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(2);

    // Setup a sky box.
    GLfloat skyPoints[] =
    {
        // Specify the -z-axis sky.
        -1000.0,  1000.0, -1000.0, 1.0,
         1000.0,  1000.0, -1000.0, 1.0,
        -1000.0,    -1.0, -1000.0, 1.0,

        -1000.0,    -1.0, -1000.0, 1.0,
         1000.0,  1000.0, -1000.0, 1.0,
         1000.0,    -1.0, -1000.0, 1.0,

        // Specify the z-axis sky.
        -1000.0,  1000.0,  1000.0, 1.0,
         1000.0,  1000.0,  1000.0, 1.0,
        -1000.0,    -1.0,  1000.0, 1.0,

        -1000.0,    -1.0,  1000.0, 1.0,
         1000.0,  1000.0,  1000.0, 1.0,
         1000.0,    -1.0,  1000.0, 1.0,

        // Specify the -x-axis sky.
        -1000.0,  1000.0,  1000.0, 1.0,
        -1000.0,  1000.0, -1000.0, 1.0,
        -1000.0,    -1.0,  1000.0, 1.0,

        -1000.0,    -1.0,  1000.0, 1.0,
        -1000.0,  1000.0, -1000.0, 1.0,
        -1000.0,    -1.0, -1000.0, 1.0,

        // Specify the x-axis sky.
         1000.0,  1000.0, -1000.0, 1.0,
         1000.0,  1000.0,  1000.0, 1.0,
         1000.0,    -1.0, -1000.0, 1.0,

         1000.0,    -1.0, -1000.0, 1.0,
         1000.0,  1000.0,  1000.0, 1.0,
         1000.0,    -1.0,  1000.0, 1.0,

        // Specify the top of the sky.
        -1000.0,  1000.0, -1000.0, 1.0,
         1000.0,  1000.0, -1000.0, 1.0,
        -1000.0,  1000.0,  1000.0, 1.0,

        -1000.0,  1000.0,  1000.0, 1.0,
         1000.0,  1000.0, -1000.0, 1.0,
         1000.0,  1000.0,  1000.0, 1.0
    };

    // This is probably horrible and kinda surprised it works..
#define DARKER_SKY_COLOR   0.0, 0.4, 0.8, 1.0,
#define LIGHTER_SKY_COLOR  0.7, 0.95, 1.0, 1.0,

    GLfloat skyColors[] =
    {
        // Specify the -z-axis sky colors.
        DARKER_SKY_COLOR
        DARKER_SKY_COLOR
        LIGHTER_SKY_COLOR

        LIGHTER_SKY_COLOR
        DARKER_SKY_COLOR
        LIGHTER_SKY_COLOR

        // Specify the z-axis sky colors.
        DARKER_SKY_COLOR
        DARKER_SKY_COLOR
        LIGHTER_SKY_COLOR

        LIGHTER_SKY_COLOR
        DARKER_SKY_COLOR
        LIGHTER_SKY_COLOR

        // Specify the -x-axis sky.
        DARKER_SKY_COLOR
        DARKER_SKY_COLOR
        LIGHTER_SKY_COLOR

        LIGHTER_SKY_COLOR
        DARKER_SKY_COLOR
        LIGHTER_SKY_COLOR

        // Specify the x-axis sky.
        DARKER_SKY_COLOR
        DARKER_SKY_COLOR
        LIGHTER_SKY_COLOR

        LIGHTER_SKY_COLOR
        DARKER_SKY_COLOR
        LIGHTER_SKY_COLOR

        // Specify the top of the sky.
        DARKER_SKY_COLOR
        DARKER_SKY_COLOR
        DARKER_SKY_COLOR

        DARKER_SKY_COLOR
        DARKER_SKY_COLOR
        DARKER_SKY_COLOR
    };

    glGenVertexArrays(1, &skyVAO);
    glBindVertexArray(skyVAO);

    glGenBuffers(1, &skyPointVBO);
    glBindBuffer(GL_ARRAY_BUFFER, skyPointVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * sizeof(skyPoints), skyPoints, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(0);

    glGenBuffers(1, &skyColorVBO);
    glBindBuffer(GL_ARRAY_BUFFER, skyColorVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * sizeof(skyColors), skyColors, GL_STATIC_DRAW);
    glVertexAttribPointer(3, 4, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(3);


    // Setup beach.
    NSString * beachMeshPath = [[NSBundle mainBundle] pathForResource:@"islands" ofType:@"obj"];
    std::string beachMeshPathString = [beachMeshPath UTF8String];
    readfile(beachMeshPathString,
             &beachPointCount,
             &beachPoints,
             &beachFaceNormals,
             &beachVertexNormals,
             false);

    glGenVertexArrays(1, &beachVAO);
    glBindVertexArray(beachVAO);

    glGenBuffers(1, &beachPointVBO);
    glBindBuffer(GL_ARRAY_BUFFER, beachPointVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * beachPointCount, beachPoints, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(0);

    glGenBuffers(1, &beachFaceNormalVBO);
    glBindBuffer(GL_ARRAY_BUFFER, beachFaceNormalVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * beachPointCount, beachFaceNormals, GL_STATIC_DRAW);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(1);

    glGenBuffers(1, &beachVertexNormalVBO);
    glBindBuffer(GL_ARRAY_BUFFER, beachVertexNormalVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * beachPointCount, beachVertexNormals, GL_STATIC_DRAW);
    glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(2);


    // Setup water.
    GLfloat waterPoints[] =
    {
        -1000.0,  0.0,  -1000.0, 1.0,
         1000.0,  0.0,  -1000.0, 1.0,
        -1000.0,  0.0,   1000.0, 1.0,

        -1000.0,  0.0,   1000.0, 1.0,
         1000.0,  0.0,  -1000.0, 1.0,
         1000.0,  0.0,   1000.0, 1.0
    };

    GLfloat waterColors[] =
    {
        0.0, 0.8, 1.0, 0.75,
        0.0, 0.8, 1.0, 0.75,
        0.0, 0.8, 1.0, 0.75,

        0.0, 0.8, 1.0, 0.75,
        0.0, 0.8, 1.0, 0.75,
        0.0, 0.8, 1.0, 0.75,
    };

    glGenVertexArrays(1, &waterVAO);
    glBindVertexArray(waterVAO);

    glGenBuffers(1, &waterPointVBO);
    glBindBuffer(GL_ARRAY_BUFFER, waterPointVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * sizeof(waterPoints), waterPoints, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(0);

    glGenBuffers(1, &waterColorVBO);
    glBindBuffer(GL_ARRAY_BUFFER, waterColorVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * sizeof(waterColors), waterColors, GL_STATIC_DRAW);
    glVertexAttribPointer(3, 4, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(3);


    // Setup ocean floor.
    GLfloat oceanFloorPoints[] =
    {
        // Specify the -z-axis sky.
        -1000.0,    0.0, -1000.0, 1.0,
         1000.0,    0.0, -1000.0, 1.0,
        -1000.0, -100.0, -1000.0, 1.0,

        -1000.0, -100.0, -1000.0, 1.0,
         1000.0,    0.0, -1000.0, 1.0,
         1000.0, -100.0, -1000.0, 1.0,

        // Specify the z-axis sky.
        -1000.0,    0.0,  1000.0, 1.0,
         1000.0,    0.0,  1000.0, 1.0,
        -1000.0, -100.0,  1000.0, 1.0,

        -1000.0, -100.0,  1000.0, 1.0,
         1000.0,    0.0,  1000.0, 1.0,
         1000.0, -100.0,  1000.0, 1.0,

        // Specify the -x-axis sky.
        -1000.0,    0.0,  1000.0, 1.0,
        -1000.0,    0.0, -1000.0, 1.0,
        -1000.0, -100.0,  1000.0, 1.0,

        -1000.0, -100.0,  1000.0, 1.0,
        -1000.0,    0.0, -1000.0, 1.0,
        -1000.0, -100.0, -1000.0, 1.0,

        // Specify the x-axis sky.
         1000.0,    0.0, -1000.0, 1.0,
         1000.0,    0.0,  1000.0, 1.0,
         1000.0, -100.0, -1000.0, 1.0,

         1000.0, -100.0, -1000.0, 1.0,
         1000.0,    0.0,  1000.0, 1.0,
         1000.0, -100.0,  1000.0, 1.0,

        // Specify the bottom of the ocean floor.
        -1000.0,  -100.0,  -1000.0, 1.0,
         1000.0,  -100.0,  -1000.0, 1.0,
        -1000.0,  -100.0,   1000.0, 1.0,

        -1000.0,  -100.0,   1000.0, 1.0,
         1000.0,  -100.0,  -1000.0, 1.0,
         1000.0,  -100.0,   1000.0, 1.0
    };

    GLfloat oceanFloorColors[] =
    {
        0.7, 0.7, 0.7, 1.0,
        0.7, 0.7, 0.7, 1.0,
        0.7, 0.7, 0.7, 1.0,

        0.7, 0.7, 0.7, 1.0,
        0.7, 0.7, 0.7, 1.0,
        0.7, 0.7, 0.7, 1.0,

        0.7, 0.7, 0.7, 1.0,
        0.7, 0.7, 0.7, 1.0,
        0.7, 0.7, 0.7, 1.0,

        0.7, 0.7, 0.7, 1.0,
        0.7, 0.7, 0.7, 1.0,
        0.7, 0.7, 0.7, 1.0,

        0.7, 0.7, 0.7, 1.0,
        0.7, 0.7, 0.7, 1.0,
        0.7, 0.7, 0.7, 1.0,

        0.7, 0.7, 0.7, 1.0,
        0.7, 0.7, 0.7, 1.0,
        0.7, 0.7, 0.7, 1.0,

        0.7, 0.7, 0.7, 1.0,
        0.7, 0.7, 0.7, 1.0,
        0.7, 0.7, 0.7, 1.0,

        0.7, 0.7, 0.7, 1.0,
        0.7, 0.7, 0.7, 1.0,
        0.7, 0.7, 0.7, 1.0,

        // Specify the bottom of the ocean floor.
        0.7, 0.7, 0.7, 1.0,
        0.7, 0.7, 0.7, 1.0,
        0.7, 0.7, 0.7, 1.0,

        0.7, 0.7, 0.7, 1.0,
        0.7, 0.7, 0.7, 1.0,
        0.7, 0.7, 0.7, 1.0,
    };


    glGenVertexArrays(1, &oceanFloorVAO);
    glBindVertexArray(oceanFloorVAO);

    glGenBuffers(1, &oceanFloorPointVBO);
    glBindBuffer(GL_ARRAY_BUFFER, oceanFloorPointVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * sizeof(oceanFloorPoints), oceanFloorPoints, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(0);

    glGenBuffers(1, &oceanFloorColorVBO);
    glBindBuffer(GL_ARRAY_BUFFER, oceanFloorColorVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * sizeof(oceanFloorColors), oceanFloorColors, GL_STATIC_DRAW);
    glVertexAttribPointer(3, 4, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(3);

    // Setup bush.
    NSString * bushMeshPath = [[NSBundle mainBundle] pathForResource:@"bush" ofType:@"obj"];
    std::string bushMeshPathString = [bushMeshPath UTF8String];
    readfile(bushMeshPathString,
             &bushPointCount,
             &bushPoints,
             &bushFaceNormals,
             &bushVertexNormals,
             false);

    glGenVertexArrays(1, &bushVAO);
    glBindVertexArray(bushVAO);

    glGenBuffers(1, &bushPointVBO);
    glBindBuffer(GL_ARRAY_BUFFER, bushPointVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * bushPointCount, bushPoints, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(0);

    glGenBuffers(1, &bushFaceNormalVBO);
    glBindBuffer(GL_ARRAY_BUFFER, bushFaceNormalVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * bushPointCount, bushFaceNormals, GL_STATIC_DRAW);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(1);

    glGenBuffers(1, &bushVertexNormalVBO);
    glBindBuffer(GL_ARRAY_BUFFER, bushVertexNormalVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * bushPointCount, bushVertexNormals, GL_STATIC_DRAW);
    glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(2);

    // Setup palm (green components).
    NSString * palmGreenMeshPath = [[NSBundle mainBundle] pathForResource:@"palmGreen" ofType:@"obj"];
    std::string palmGreenMeshPathString = [palmGreenMeshPath UTF8String];
    readfile(palmGreenMeshPathString,
             &palmGreenPointCount,
             &palmGreenPoints,
             &palmGreenFaceNormals,
             &palmGreenVertexNormals,
             false);

    glGenVertexArrays(1, &palmGreenVAO);
    glBindVertexArray(palmGreenVAO);

    glGenBuffers(1, &palmGreenPointVBO);
    glBindBuffer(GL_ARRAY_BUFFER, palmGreenPointVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * palmGreenPointCount, palmGreenPoints, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(0);

    glGenBuffers(1, &palmGreenFaceNormalVBO);
    glBindBuffer(GL_ARRAY_BUFFER, palmGreenFaceNormalVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * palmGreenPointCount, palmGreenFaceNormals, GL_STATIC_DRAW);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(1);

    glGenBuffers(1, &palmGreenVertexNormalVBO);
    glBindBuffer(GL_ARRAY_BUFFER, palmGreenVertexNormalVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * palmGreenPointCount, palmGreenVertexNormals, GL_STATIC_DRAW);
    glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(2);

    // Setup palm (brown components).
    NSString * palmBrownMeshPath = [[NSBundle mainBundle] pathForResource:@"palmBrown" ofType:@"obj"];
    std::string palmBrownMeshPathString = [palmBrownMeshPath UTF8String];
    readfile(palmBrownMeshPathString,
             &palmBrownPointCount,
             &palmBrownPoints,
             &palmBrownFaceNormals,
             &palmBrownVertexNormals,
             false);

    glGenVertexArrays(1, &palmBrownVAO);
    glBindVertexArray(palmBrownVAO);

    glGenBuffers(1, &palmBrownPointVBO);
    glBindBuffer(GL_ARRAY_BUFFER, palmBrownPointVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * palmBrownPointCount, palmBrownPoints, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(0);

    glGenBuffers(1, &palmBrownFaceNormalVBO);
    glBindBuffer(GL_ARRAY_BUFFER, palmBrownFaceNormalVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * palmBrownPointCount, palmBrownFaceNormals, GL_STATIC_DRAW);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(1);

    glGenBuffers(1, &palmBrownVertexNormalVBO);
    glBindBuffer(GL_ARRAY_BUFFER, palmBrownVertexNormalVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * palmBrownPointCount, palmBrownVertexNormals, GL_STATIC_DRAW);
    glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(2);

    // Setup penguin (black components).
    NSString * penguinBlackBodyMeshPath = [[NSBundle mainBundle] pathForResource:@"penguinBlack" ofType:@"obj"];
    std::string penguinBlackBodyMeshPathString = [penguinBlackBodyMeshPath UTF8String];
    readfile(penguinBlackBodyMeshPathString,
             &penguinBlackBodyPointCount,
             &penguinBlackBodyPoints,
             &penguinBlackBodyFaceNormals,
             &penguinBlackBodyVertexNormals,
             false);

    glGenVertexArrays(1, &penguinBlackBodyVAO);
    glBindVertexArray(penguinBlackBodyVAO);

    glGenBuffers(1, &penguinBlackBodyPointVBO);
    glBindBuffer(GL_ARRAY_BUFFER, penguinBlackBodyPointVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * penguinBlackBodyPointCount, penguinBlackBodyPoints, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(0);

    glGenBuffers(1, &penguinBlackBodyFaceNormalVBO);
    glBindBuffer(GL_ARRAY_BUFFER, penguinBlackBodyFaceNormalVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * penguinBlackBodyPointCount, penguinBlackBodyFaceNormals, GL_STATIC_DRAW);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(1);

    glGenBuffers(1, &penguinBlackBodyVertexNormalVBO);
    glBindBuffer(GL_ARRAY_BUFFER, penguinBlackBodyVertexNormalVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * penguinBlackBodyPointCount, penguinBlackBodyVertexNormals, GL_STATIC_DRAW);
    glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(2);

    // Setup penguin (white components).
    NSString * penguinWhiteBodyMeshPath = [[NSBundle mainBundle] pathForResource:@"penguinWhite" ofType:@"obj"];
    std::string penguinWhiteBodyMeshPathString = [penguinWhiteBodyMeshPath UTF8String];
    readfile(penguinWhiteBodyMeshPathString,
             &penguinWhiteBodyPointCount,
             &penguinWhiteBodyPoints,
             &penguinWhiteBodyFaceNormals,
             &penguinWhiteBodyVertexNormals,
             false);

    glGenVertexArrays(1, &penguinWhiteBodyVAO);
    glBindVertexArray(penguinWhiteBodyVAO);

    glGenBuffers(1, &penguinWhiteBodyPointVBO);
    glBindBuffer(GL_ARRAY_BUFFER, penguinWhiteBodyPointVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * penguinWhiteBodyPointCount, penguinWhiteBodyPoints, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(0);

    glGenBuffers(1, &penguinWhiteBodyFaceNormalVBO);
    glBindBuffer(GL_ARRAY_BUFFER, penguinWhiteBodyFaceNormalVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * penguinWhiteBodyPointCount, penguinWhiteBodyFaceNormals, GL_STATIC_DRAW);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(1);

    glGenBuffers(1, &penguinWhiteBodyVertexNormalVBO);
    glBindBuffer(GL_ARRAY_BUFFER, penguinWhiteBodyVertexNormalVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * penguinWhiteBodyPointCount, penguinWhiteBodyVertexNormals, GL_STATIC_DRAW);
    glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(2);

    // Setup penguin (ornage components).
    NSString * penguinOrangeBodyMeshPath = [[NSBundle mainBundle] pathForResource:@"penguinOrange" ofType:@"obj"];
    std::string penguinOrangeBodyMeshPathString = [penguinOrangeBodyMeshPath UTF8String];
    readfile(penguinOrangeBodyMeshPathString,
             &penguinOrangeBodyPointCount,
             &penguinOrangeBodyPoints,
             &penguinOrangeBodyFaceNormals,
             &penguinOrangeBodyVertexNormals,
             false);

    glGenVertexArrays(1, &penguinOrangeBodyVAO);
    glBindVertexArray(penguinOrangeBodyVAO);

    glGenBuffers(1, &penguinOrangeBodyPointVBO);
    glBindBuffer(GL_ARRAY_BUFFER, penguinOrangeBodyPointVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * penguinOrangeBodyPointCount, penguinOrangeBodyPoints, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(0);

    glGenBuffers(1, &penguinOrangeBodyFaceNormalVBO);
    glBindBuffer(GL_ARRAY_BUFFER, penguinOrangeBodyFaceNormalVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * penguinOrangeBodyPointCount, penguinOrangeBodyFaceNormals, GL_STATIC_DRAW);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(1);

    glGenBuffers(1, &penguinOrangeBodyVertexNormalVBO);
    glBindBuffer(GL_ARRAY_BUFFER, penguinOrangeBodyVertexNormalVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * penguinOrangeBodyPointCount, penguinOrangeBodyVertexNormals, GL_STATIC_DRAW);
    glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(2);


    // Setup gate.
    NSString * gateMeshPath = [[NSBundle mainBundle] pathForResource:@"gate" ofType:@"obj"];
    std::string gateMeshPathString = [gateMeshPath UTF8String];
    readfile(gateMeshPathString,
             &gatePointCount,
             &gatePoints,
             &gateFaceNormals,
             &gateVertexNormals,
             false);

    glGenVertexArrays(1, &gateVAO);
    glBindVertexArray(gateVAO);

    glGenBuffers(1, &gatePointVBO);
    glBindBuffer(GL_ARRAY_BUFFER, gatePointVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * gatePointCount, gatePoints, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(0);

    glGenBuffers(1, &gateFaceNormalVBO);
    glBindBuffer(GL_ARRAY_BUFFER, gateFaceNormalVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * gatePointCount, gateFaceNormals, GL_STATIC_DRAW);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(1);

    glGenBuffers(1, &gateVertexNormalVBO);
    glBindBuffer(GL_ARRAY_BUFFER, gateVertexNormalVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * gatePointCount, gateVertexNormals, GL_STATIC_DRAW);
    glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(2);

    // Setup enemy (body components).
    NSString * enemyBodyMeshPath = [[NSBundle mainBundle] pathForResource:@"enemyBody" ofType:@"obj"];
    std::string enemyBodyMeshPathString = [enemyBodyMeshPath UTF8String];
    readfile(enemyBodyMeshPathString,
             &enemyBodyPointCount,
             &enemyBodyPoints,
             &enemyBodyFaceNormals,
             &enemyBodyVertexNormals,
             false);

    glGenVertexArrays(1, &enemyBodyVAO);
    glBindVertexArray(enemyBodyVAO);

    glGenBuffers(1, &enemyBodyPointVBO);
    glBindBuffer(GL_ARRAY_BUFFER, enemyBodyPointVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * enemyBodyPointCount, enemyBodyPoints, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(0);

    glGenBuffers(1, &enemyBodyFaceNormalVBO);
    glBindBuffer(GL_ARRAY_BUFFER, enemyBodyFaceNormalVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * enemyBodyPointCount, enemyBodyFaceNormals, GL_STATIC_DRAW);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(1);

    glGenBuffers(1, &enemyBodyVertexNormalVBO);
    glBindBuffer(GL_ARRAY_BUFFER, enemyBodyVertexNormalVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * enemyBodyPointCount, enemyBodyVertexNormals, GL_STATIC_DRAW);
    glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(2);

    // Setup enemy (spikes components).
    NSString * enemySpikesMeshPath = [[NSBundle mainBundle] pathForResource:@"enemySpikes" ofType:@"obj"];
    std::string enemySpikesMeshPathString = [enemySpikesMeshPath UTF8String];
    readfile(enemySpikesMeshPathString,
             &enemySpikesPointCount,
             &enemySpikesPoints,
             &enemySpikesFaceNormals,
             &enemySpikesVertexNormals,
             false);

    glGenVertexArrays(1, &enemySpikesVAO);
    glBindVertexArray(enemySpikesVAO);

    glGenBuffers(1, &enemySpikesPointVBO);
    glBindBuffer(GL_ARRAY_BUFFER, enemySpikesPointVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * enemySpikesPointCount, enemySpikesPoints, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(0);

    glGenBuffers(1, &enemySpikesFaceNormalVBO);
    glBindBuffer(GL_ARRAY_BUFFER, enemySpikesFaceNormalVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * enemySpikesPointCount, enemySpikesFaceNormals, GL_STATIC_DRAW);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(1);

    glGenBuffers(1, &enemySpikesVertexNormalVBO);
    glBindBuffer(GL_ARRAY_BUFFER, enemySpikesVertexNormalVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * enemySpikesPointCount, enemySpikesVertexNormals, GL_STATIC_DRAW);
    glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(2);

    // Setup mountain.
    NSString * mountainMeshPath = [[NSBundle mainBundle] pathForResource:@"mountain" ofType:@"obj"];
    std::string mountainMeshPathString = [mountainMeshPath UTF8String];
    readfile(mountainMeshPathString,
             &mountainPointCount,
             &mountainPoints,
             &mountainFaceNormals,
             &mountainVertexNormals,
             false);

    glGenVertexArrays(1, &mountainVAO);
    glBindVertexArray(mountainVAO);

    glGenBuffers(1, &mountainPointVBO);
    glBindBuffer(GL_ARRAY_BUFFER, mountainPointVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * mountainPointCount, mountainPoints, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(0);

    glGenBuffers(1, &mountainFaceNormalVBO);
    glBindBuffer(GL_ARRAY_BUFFER, mountainFaceNormalVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * mountainPointCount, mountainFaceNormals, GL_STATIC_DRAW);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(1);

    glGenBuffers(1, &mountainVertexNormalVBO);
    glBindBuffer(GL_ARRAY_BUFFER, mountainVertexNormalVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * mountainPointCount, mountainVertexNormals, GL_STATIC_DRAW);
    glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(2);

    // Setup lava.
    NSString * lavaMeshPath = [[NSBundle mainBundle] pathForResource:@"lava" ofType:@"obj"];
    std::string lavaMeshPathString = [lavaMeshPath UTF8String];
    readfile(lavaMeshPathString,
             &lavaPointCount,
             &lavaPoints,
             &lavaFaceNormals,
             &lavaVertexNormals,
             false);

    glGenVertexArrays(1, &lavaVAO);
    glBindVertexArray(lavaVAO);

    glGenBuffers(1, &lavaPointVBO);
    glBindBuffer(GL_ARRAY_BUFFER, lavaPointVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * lavaPointCount, lavaPoints, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(0);

    glGenBuffers(1, &lavaFaceNormalVBO);
    glBindBuffer(GL_ARRAY_BUFFER, lavaFaceNormalVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * lavaPointCount, lavaFaceNormals, GL_STATIC_DRAW);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(1);

    glGenBuffers(1, &lavaVertexNormalVBO);
    glBindBuffer(GL_ARRAY_BUFFER, lavaVertexNormalVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * lavaPointCount, lavaVertexNormals, GL_STATIC_DRAW);
    glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(2);

    // Setup smoke.
    NSString * smokeMeshPath = [[NSBundle mainBundle] pathForResource:@"smoke" ofType:@"obj"];
    std::string smokeMeshPathString = [smokeMeshPath UTF8String];
    readfile(smokeMeshPathString,
             &smokePointCount,
             &smokePoints,
             &smokeFaceNormals,
             &smokeVertexNormals,
             false);

    glGenVertexArrays(1, &smokeVAO);
    glBindVertexArray(smokeVAO);

    glGenBuffers(1, &smokePointVBO);
    glBindBuffer(GL_ARRAY_BUFFER, smokePointVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * smokePointCount, smokePoints, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(0);

    glGenBuffers(1, &smokeFaceNormalVBO);
    glBindBuffer(GL_ARRAY_BUFFER, smokeFaceNormalVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * smokePointCount, smokeFaceNormals, GL_STATIC_DRAW);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(1);

    glGenBuffers(1, &smokeVertexNormalVBO);
    glBindBuffer(GL_ARRAY_BUFFER, smokeVertexNormalVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * smokePointCount, smokeVertexNormals, GL_STATIC_DRAW);
    glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(2);

    NSString * algorithm = [algorithmPopUpButton titleOfSelectedItem];
    int height = [heightTextField intValue];
    int width = [widthTextField intValue];

    maze = new Maze(width, height);
    if ([algorithm isEqualToString:@"Binary Tree"])
    {
        maze->generate_maze(MAZE_ALGORITHM_BINARY_TREE);
    }
    else if ([algorithm isEqualToString:@"Aldous-Broder"])
    {
        maze->generate_maze(MAZE_ALGORITHM_ALDOUS_BRODER);
    }

    // Grab the maze map.
    mazeMap = maze->make_map();
    mapHeight = height * 2 + 1;
    mapWidth = width * 2 + 1;

    // TODO: Is it possible both wall segments cleared could be blocked?
    // Create an exit.
    mazeMap[0][mapWidth / 2] = ' ';
    mazeMap[0][mapWidth / 2 + 1] = ' ';
    mazeMap[1][mapWidth / 2] = ' ';
    mazeMap[1][mapWidth / 2 + 1] = ' ';
    mazeMap[2][mapWidth / 2] = ' ';
    mazeMap[2][mapWidth / 2 + 1] = ' ';
    mazeMap[3][mapWidth / 2] = ' ';
    mazeMap[3][mapWidth / 2 + 1] = ' ';

    // Create an entrance.
    mazeMap[mapHeight - 1][mapWidth / 2] = ' ';
    mazeMap[mapHeight - 1][mapWidth / 2 + 1] = ' ';
    mazeMap[mapHeight - 2][mapWidth / 2] = ' ';
    mazeMap[mapHeight - 2][mapWidth / 2 + 1] = ' ';
    mazeMap[mapHeight - 3][mapWidth / 2] = ' ';
    mazeMap[mapHeight - 3][mapWidth / 2 + 1] = ' ';
    mazeMap[mapHeight - 4][mapWidth / 2] = ' ';
    mazeMap[mapHeight - 4][mapWidth / 2 + 1] = ' ';
}

- (void)tick:(id)sender
{
//    NSLog(@"tick:");

    if (gameState == GAME_STATE_DEVELOPMENT)
    {
        printf("Triangle Location: (%f, %f)\n", triangleTranslation.x, triangleTranslation.z);
//        printf("Penguin Location: (%f, %f)\n", penguinTranslation.x, penguinTranslation.z);
    }

    unsigned long int currentTime = time(NULL);

    unsigned long timeElapsed = currentTime - startTime;

    [timeLabel setStringValue:[@"Time: " stringByAppendingFormat:@"%lu", timeElapsed]];

    // Check for end of game.
    if (timeElapsed > timeLimit)
    {
        [messageLabel setTextColor:[NSColor redColor]];
        [messageLabel setStringValue:@"You Lose!\n\nPress any key to play again!"];

        // Stop the timer.
        [timer invalidate];
        [enemyTimer invalidate];

        gameState = GAME_STATE_FINISHED;
    }

//    printf("penguinTranslation: (%f, %f)\n", penguinTranslation.x, penguinTranslation.z);

    if (isAtGoal(penguinTranslation))
    {
        [messageLabel setStringValue:@"You Win!\n\nPress any key to play again!"];

        // Stop the timer.
        [timer invalidate];
        [enemyTimer invalidate];

        gameState = GAME_STATE_FINISHED;
    }

    BOOL touchedEnemy = NO;

    // Check if there are any enemies yet.
    if (!enemies.empty())
    {
        // Update enemy locations.
        for (int i = 0; i < enemies.size(); i++)
        {
            double distance = sqrt(pow(enemies[i].location.x - penguinTranslation.x, 2.0) + pow(enemies[i].location.z - penguinTranslation.z, 2.0));

            glm::vec3 direction = penguinTranslation - enemies[i].location;

            enemies[i].location.x += direction.x / distance * enemies[i].speed * 0.1;
            enemies[i].location.z += direction.z / distance * enemies[i].speed * 0.1;

            if (isTouchingEnemy(enemies[i], penguinTranslation))
            {
                touchedEnemy = YES;
                break;
            }
        }

        if (touchedEnemy)
        {
            [messageLabel setTextColor:[NSColor redColor]];
            [messageLabel setStringValue:@"You Lose!\n\nPress any key to play again!"];

            // Stop the timer.
            [timer invalidate];
            [enemyTimer invalidate];

            gameState = GAME_STATE_FINISHED;
        }

        [self drawRect:[self convertRectToBase:[self bounds]]];
    }
}

- (void)enemyTick:(id)sender
{
//    NSLog(@"enemyTick:");

    unsigned long int currentTime = time(NULL);

    unsigned long timeElapsed = currentTime - startTime;

    // Check that not just starting and not at end and if time is multiple of tne
    if (timeElapsed > 0 && timeElapsed < 60 && timeElapsed % 10 == 0)
    {
        // Create a new enemy.
        enemy_t newEnemy;
        newEnemy.location = enemyStartLocation;
        newEnemy.radius = 1.0;
        newEnemy.speed = 2.0;

        // Add enemy to the list.
        enemies.push_back(newEnemy);

        [self drawRect:[self convertRectToBase:[self bounds]]];
    }
}

- (void)spinCameraTick:(id)sender
{
//    NSLog(@"spinCameraTick:");

//    printf("time: %d\n", clock_gettime_nsec_np(CLOCK_UPTIME_RAW));
//
//    printf("time: %f\n", CFAbsoluteTimeGetCurrent());

//    printf("spinCameraAngle: %f\n", spinCameraAngle);

    startScreenCamera.position.x = sin(glm::radians(spinCameraAngle)) * 100.0;
    startScreenCamera.position.y = 200.0;
    startScreenCamera.position.z = cos(glm::radians(spinCameraAngle)) * 100.0;

    startScreenCamera.view = glm::lookAt(startScreenCamera.position, glm::vec3(0.0, 0.0, 0.0), up);

    if (spinCameraAngle >= 360.0)
    {
        spinCameraAngle = 0.0;
    }

    spinCameraAngle += 1.0;

    [self drawRect:[self convertRectToBase:[self bounds]]];
}

- (IBAction)updateAlgorithm:(id)sender
{

}

- (IBAction)updateHeight:(id)sender
{
    [heightTextField setStringValue:[heightStepper stringValue]];
}

- (IBAction)updateWidth:(id)sender
{
    [widthTextField setStringValue:[widthStepper stringValue]];
}

- (IBAction)updateView:(id)sender
{
    NSString * viewName = [viewPopUpButton titleOfSelectedItem];

    if ([viewName isEqualToString:@"Development"])
    {
        currentCameraType = CAMERA_TYPE_DEVELOPMENT;
    }
    else if ([viewName isEqualToString:@"Bird's Eye"])
    {
        currentCameraType = CAMERA_TYPE_BIRDS_EYE;
    }
    else if ([viewName isEqualToString:@"First Person"])
    {
        currentCameraType = CAMERA_TYPE_FIRST_PERSON;
    }
    else if ([viewName isEqualToString:@"Third Person"])
    {
        currentCameraType = CAMERA_TYPE_THIRD_PERSON;
    }

    [self drawRect:[self convertRectToBase:[self bounds]]];
}

- (IBAction)updateAxes:(id)sender
{
    // Tell it to redraw.
    [self drawRect:[self convertRectToBase:[self bounds]]];
}

- (IBAction)generate:(id)sender
{
    if (mazeMap != NULL)
    {
        int height = maze->get_height();

        for (int i = 0; i < height; i++)
        {
            free(mazeMap[i]);
        }

        free(mazeMap);
    }

    if (maze != NULL)
    {
        delete maze;
    }

    NSString * algorithm = [algorithmPopUpButton titleOfSelectedItem];
    int height = [heightTextField intValue];
    int width = [widthTextField intValue];

    maze = new Maze(width, height);
    if ([algorithm isEqualToString:@"Binary Tree"])
    {
        maze->generate_maze(MAZE_ALGORITHM_BINARY_TREE);
    }
    else if ([algorithm isEqualToString:@"Aldous-Broder"])
    {
        maze->generate_maze(MAZE_ALGORITHM_ALDOUS_BRODER);
    }

    mazeMap = maze->make_map();
    mapHeight = height * 2 + 1;
    mapWidth = width * 2 + 1;

    // TODO: Is it possible both wall segments cleared could be blocked?
    // Create an exit.
    mazeMap[0][mapWidth / 2] = ' ';
    mazeMap[0][mapWidth / 2 + 1] = ' ';
    mazeMap[1][mapWidth / 2] = ' ';
    mazeMap[1][mapWidth / 2 + 1] = ' ';
    mazeMap[2][mapWidth / 2] = ' ';
    mazeMap[2][mapWidth / 2 + 1] = ' ';
    mazeMap[3][mapWidth / 2] = ' ';
    mazeMap[3][mapWidth / 2 + 1] = ' ';

    // Create an entrance.
    mazeMap[mapHeight - 1][mapWidth / 2] = ' ';
    mazeMap[mapHeight - 1][mapWidth / 2 + 1] = ' ';
    mazeMap[mapHeight - 2][mapWidth / 2] = ' ';
    mazeMap[mapHeight - 2][mapWidth / 2 + 1] = ' ';
    mazeMap[mapHeight - 3][mapWidth / 2] = ' ';
    mazeMap[mapHeight - 3][mapWidth / 2 + 1] = ' ';
    mazeMap[mapHeight - 4][mapWidth / 2] = ' ';
    mazeMap[mapHeight - 4][mapWidth / 2 + 1] = ' ';

//    for (int i = 0; i < height * 2 + 1; i++)
//    {
//        for (int j = 0; j < width * 2 + 1; j++)
//        {
//            printf("%c", mazeMap[i][j]);
//            if (j != width * 2 + 1 - 1)
//            {
//                printf(" ");
//            }
//        }
//        printf("\n");
//    }

    [self drawRect:[self convertRectToBase:[self bounds]]];
}

// Had to add this to get it to respond to key events.
- (BOOL)acceptsFirstResponder
{
//    NSLog(@"acceptsFirstResponder");

    return YES;
}

- (void)keyDown:(NSEvent *)event
{
    // Grab the key.
    short int key = [event keyCode];

//    printf("keyCode: %d\n", key);

    //    printf("key: %d\n", key);
    if (gameState == GAME_STATE_DEVELOPMENT)
    {
        printf("Location: (%f, %f, %f)\n", triangleTranslation.x, triangleTranslation.y, triangleTranslation.z);

        double stepSize = 1.0;

        if (key == KEY_1)
        {
            currentCameraType = CAMERA_TYPE_BIRDS_EYE;
            [viewPopUpButton selectItemWithTitle:@"Bird's Eye"];
        }
        else if (key == KEY_2)
        {
            currentCameraType = CAMERA_TYPE_FIRST_PERSON;
            [viewPopUpButton selectItemWithTitle:@"First Person"];
        }
        else if (key == KEY_3)
        {
            currentCameraType = CAMERA_TYPE_THIRD_PERSON;
            [viewPopUpButton selectItemWithTitle:@"Third Person"];
        }
        else if (key == KEY_9)
        {
            currentCameraType = CAMERA_TYPE_START_SCREEN;
            [viewPopUpButton selectItemWithTitle:@"Start Screen"];
        }
        else if (key == KEY_0)
        {
            currentCameraType = CAMERA_TYPE_DEVELOPMENT;
            [viewPopUpButton selectItemWithTitle:@"Development"];
        }

        if (key == KEY_UP)
        {
            // Update the triangle location.
            triangleTranslation.x -= sin(glm::radians(triangleRotation)) * stepSize;
            triangleTranslation.z -= cos(glm::radians(triangleRotation)) * stepSize;

            // Update the camera location.
            birdsEyeCamera.position.x -= sin(glm::radians(triangleRotation)) * stepSize;
            birdsEyeCamera.position.z -= cos(glm::radians(triangleRotation)) * stepSize;

            birdsEyeCamera.target.x -= sin(glm::radians(triangleRotation)) * stepSize;
            birdsEyeCamera.target.z -= cos(glm::radians(triangleRotation)) * stepSize;

            firstPersonCamera.position.x -= sin(glm::radians(triangleRotation)) * stepSize;
            firstPersonCamera.position.z -= cos(glm::radians(triangleRotation)) * stepSize;

            thirdPersonCamera.position.x -= sin(glm::radians(triangleRotation)) * stepSize;
            thirdPersonCamera.position.z -= cos(glm::radians(triangleRotation)) * stepSize;
        }
        else if (key == KEY_DOWN)
        {
            // Update the triangle location.
            triangleTranslation.x += sin(glm::radians(triangleRotation));
            triangleTranslation.z += cos(glm::radians(triangleRotation));

            // Update the camera location.
            birdsEyeCamera.position.x += sin(glm::radians(triangleRotation));
            birdsEyeCamera.position.z += cos(glm::radians(triangleRotation));

            birdsEyeCamera.target.x += sin(glm::radians(triangleRotation));
            birdsEyeCamera.target.z += cos(glm::radians(triangleRotation));

            firstPersonCamera.position.x += sin(glm::radians(triangleRotation));
            firstPersonCamera.position.z += cos(glm::radians(triangleRotation));

            thirdPersonCamera.position.x += sin(glm::radians(triangleRotation));
            thirdPersonCamera.position.z += cos(glm::radians(triangleRotation));
        }
        else if (key == KEY_LEFT)
        {
            triangleRotation += MOVEMENT_ROTATE_SIZE;

            glm::vec3 direction(0.0, 0.0, 0.0);
            direction.x = sin(glm::radians(180.0 + triangleRotation));
            direction.y = 0.0;
            direction.z = cos(glm::radians(180.0 + triangleRotation));

            firstPersonCamera.front = glm::normalize(direction);
            firstPersonCamera.right = glm::normalize(glm::cross(firstPersonCamera.front, firstPersonCamera.worldUp));
            firstPersonCamera.up = glm::normalize(glm::cross(firstPersonCamera.right, firstPersonCamera.front));

            direction.y = glm::radians(-30.0);
            thirdPersonCamera.position = triangleTranslation - 4.0f * glm::normalize(direction);
            thirdPersonCamera.position.y = 10.0;
            thirdPersonCamera.front = glm::normalize(direction);
        }
        else if (key == KEY_RIGHT)
        {
            triangleRotation -= MOVEMENT_ROTATE_SIZE;

            glm::vec3 direction(0.0, 0.0, 0.0);
            direction.x = sin(glm::radians(180.0 + triangleRotation));
            direction.y = 0.0;
            direction.z = cos(glm::radians(180.0 + triangleRotation));

            firstPersonCamera.front = glm::normalize(direction);
            firstPersonCamera.right = glm::normalize(glm::cross(firstPersonCamera.front, firstPersonCamera.worldUp));
            firstPersonCamera.up = glm::normalize(glm::cross(firstPersonCamera.right, firstPersonCamera.front));

            direction.y = glm::radians(-30.0);
            thirdPersonCamera.position = triangleRotation - 4.0f * glm::normalize(direction);
            thirdPersonCamera.position.y = 10.0;
            thirdPersonCamera.front = glm::normalize(direction);
        }

        birdsEyeCamera.view = glm::lookAt(birdsEyeCamera.position,
                                          birdsEyeCamera.position + birdsEyeCamera.front,
                                          birdsEyeCamera.up);

        firstPersonCamera.view = glm::lookAt(firstPersonCamera.position,
                                             firstPersonCamera.position + firstPersonCamera.front,
                                             firstPersonCamera.up);

        thirdPersonCamera.view = glm::lookAt(thirdPersonCamera.position,
                                             thirdPersonCamera.position + thirdPersonCamera.front,
                                             thirdPersonCamera.up);
    }
    else if (gameState == GAME_STATE_STARTING)
    {
        // Set the start time.
        startTime = time(NULL);

        // Start the timer.
        timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                 target:self
                                               selector:@selector(tick:)
                                               userInfo:nil
                                                repeats:YES];

        // Start the enemy timer.
        enemyTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(enemyTick:)
                                                    userInfo:nil
                                                     repeats:YES];

        [messageLabel setStringValue:@""];

        currentCameraType = CAMERA_TYPE_BIRDS_EYE;

        [spinCameraTimer invalidate];

        // Transition to in progress game state.
        gameState = GAME_STATE_IN_PROGRESS;
    }
    else if (gameState == GAME_STATE_IN_PROGRESS)
    {
        if (key == KEY_1)
        {
            currentCameraType = CAMERA_TYPE_BIRDS_EYE;
            [viewPopUpButton selectItemWithTitle:@"Bird's Eye"];
        }
        else if (key == KEY_2)
        {
            currentCameraType = CAMERA_TYPE_FIRST_PERSON;
            [viewPopUpButton selectItemWithTitle:@"First Person"];
        }
        else if (key == KEY_3)
        {
            currentCameraType = CAMERA_TYPE_THIRD_PERSON;
            [viewPopUpButton selectItemWithTitle:@"Third Person"];
        }

        if (key == KEY_UP)
        {
            // TODO: Refactor with collision detection.
            glm::vec3 newPosition = penguinTranslation;
            newPosition.x -= sin(glm::radians(penguinRotation));
            newPosition.z -= cos(glm::radians(penguinRotation));
    //        printf("Penguin Translation: (%f, %f)\n", penguinTranslation.x, penguinTranslation.z);
            int block_j = (int)(((newPosition.x) / 4.0) + 11.5 + 0.5);
            int block_i = (int)(((newPosition.z) / 4.0) + 11.5 + 0.5);
    //        printf("corresponds to block: (%d, %d)\n", block_i, block_j);
    //        if (block_i >= 0 && block_j >= 0 && block_i < mapHeight  && block_j < mapWidth)
    //        {
    //            printf("mazeMap[%d][%d] = %c\n", block_i, block_j, mazeMap[block_i][block_j]);
    //        }
            if (block_i >= 0 && block_j >= 0 && block_i < mapHeight  && block_j < mapWidth)
            {
                if (mazeMap[block_i][block_j] == '#')
                {
                    printf("Collision!\n");

                    // TODO: Play a sound?
                }
                else
                {
                    // Update the triangle location.
                    triangleTranslation.x -= sin(glm::radians(triangleRotation));
                    triangleTranslation.z -= cos(glm::radians(triangleRotation));

                    // Update the penguin location.
                    penguinTranslation.x -= sin(glm::radians(penguinRotation));
                    penguinTranslation.z -= cos(glm::radians(penguinRotation));

                    // Update the camera location.
                    birdsEyeCamera.position.x -= sin(glm::radians(penguinRotation));
                    birdsEyeCamera.position.z -= cos(glm::radians(penguinRotation));

                    birdsEyeCamera.target.x -= sin(glm::radians(penguinRotation));
                    birdsEyeCamera.target.z -= cos(glm::radians(penguinRotation));

                    firstPersonCamera.position.x -= sin(glm::radians(penguinRotation));
                    firstPersonCamera.position.z -= cos(glm::radians(penguinRotation));

                    thirdPersonCamera.position.x -= sin(glm::radians(penguinRotation));
                    thirdPersonCamera.position.z -= cos(glm::radians(penguinRotation));
                }
            }
            else
            {
                // Update the triangle location.
                triangleTranslation.x -= sin(glm::radians(triangleRotation));
                triangleTranslation.z -= cos(glm::radians(triangleRotation));

                // Update the penguin location.
                penguinTranslation.x -= sin(glm::radians(penguinRotation));
                penguinTranslation.z -= cos(glm::radians(penguinRotation));

                // Update the camera location.
                birdsEyeCamera.position.x -= sin(glm::radians(penguinRotation));
                birdsEyeCamera.position.z -= cos(glm::radians(penguinRotation));

                birdsEyeCamera.target.x -= sin(glm::radians(penguinRotation));
                birdsEyeCamera.target.z -= cos(glm::radians(penguinRotation));

                firstPersonCamera.position.x -= sin(glm::radians(penguinRotation));
                firstPersonCamera.position.z -= cos(glm::radians(penguinRotation));

                thirdPersonCamera.position.x -= sin(glm::radians(penguinRotation));
                thirdPersonCamera.position.z -= cos(glm::radians(penguinRotation));
            }
        }
        else if (key == KEY_DOWN)
        {
            glm::vec3 newPosition = penguinTranslation;
            newPosition.x += sin(glm::radians(penguinRotation));
            newPosition.z += cos(glm::radians(penguinRotation));
    //        printf("Penguin Translation: (%f, %f)\n", penguinTranslation.x, penguinTranslation.z);
            int block_j = (int)(((newPosition.x) / 4.0) + 11.5 + 0.5);
            int block_i = (int)(((newPosition.z) / 4.0) + 11.5 + 0.5);
    //        printf("corresponds to block: (%d, %d)\n", block_i, block_j);
    //        if (block_i >= 0 && block_j >= 0 && block_i < mapHeight  && block_j < mapWidth)
    //        {
    //            printf("mazeMap[%d][%d] = %c\n", block_i, block_j, mazeMap[block_i][block_j]);
    //        }
            if (block_i >= 0 && block_j >= 0 && block_i < mapHeight  && block_j < mapWidth)
            {
                if (mazeMap[block_i][block_j] == '#')
                {
                    printf("Collision!\n");

                    // TODO: Play a sound?
                }
                else
                {
                    // Update the triangle location.
                    triangleTranslation.x += sin(glm::radians(triangleRotation));
                    triangleTranslation.z += cos(glm::radians(triangleRotation));

                    // Update the peguin location.
                    penguinTranslation.x += sin(glm::radians(penguinRotation));
                    penguinTranslation.z += cos(glm::radians(penguinRotation));

                    // Update the camera location.
                    birdsEyeCamera.position.x += sin(glm::radians(penguinRotation));
                    birdsEyeCamera.position.z += cos(glm::radians(penguinRotation));

                    birdsEyeCamera.target.x += sin(glm::radians(penguinRotation));
                    birdsEyeCamera.target.z += cos(glm::radians(penguinRotation));

                    firstPersonCamera.position.x += sin(glm::radians(penguinRotation));
                    firstPersonCamera.position.z += cos(glm::radians(penguinRotation));

                    thirdPersonCamera.position.x += sin(glm::radians(penguinRotation));
                    thirdPersonCamera.position.z += cos(glm::radians(penguinRotation));
                }
            }
            else
            {
                // Update the triangle location.
                triangleTranslation.x += sin(glm::radians(triangleRotation));
                triangleTranslation.z += cos(glm::radians(triangleRotation));

                // Update the peguin location.
                penguinTranslation.x += sin(glm::radians(penguinRotation));
                penguinTranslation.z += cos(glm::radians(penguinRotation));

                // Update the camera location.
                birdsEyeCamera.position.x += sin(glm::radians(penguinRotation));
                birdsEyeCamera.position.z += cos(glm::radians(penguinRotation));

                birdsEyeCamera.target.x += sin(glm::radians(penguinRotation));
                birdsEyeCamera.target.z += cos(glm::radians(penguinRotation));

                firstPersonCamera.position.x += sin(glm::radians(penguinRotation));
                firstPersonCamera.position.z += cos(glm::radians(penguinRotation));

                thirdPersonCamera.position.x += sin(glm::radians(penguinRotation));
                thirdPersonCamera.position.z += cos(glm::radians(penguinRotation));
            }
        }
        else if (key == KEY_LEFT)
        {
            triangleRotation += MOVEMENT_ROTATE_SIZE;
            penguinRotation += MOVEMENT_ROTATE_SIZE;

            glm::vec3 direction(0.0, 0.0, 0.0);
            direction.x = sin(glm::radians(180.0 + penguinRotation));
            direction.y = 0.0;
            direction.z = cos(glm::radians(180.0 + penguinRotation));

            firstPersonCamera.front = glm::normalize(direction);
            firstPersonCamera.right = glm::normalize(glm::cross(firstPersonCamera.front, firstPersonCamera.worldUp));
            firstPersonCamera.up = glm::normalize(glm::cross(firstPersonCamera.right, firstPersonCamera.front));

            direction.y = glm::radians(-30.0);
            thirdPersonCamera.position = penguinTranslation - 4.0f * glm::normalize(direction);
            thirdPersonCamera.position.y = 10.0;
            thirdPersonCamera.front = glm::normalize(direction);
        }
        else if (key == KEY_RIGHT)
        {
            triangleRotation -= MOVEMENT_ROTATE_SIZE;
            penguinRotation -= MOVEMENT_ROTATE_SIZE;

            glm::vec3 direction(0.0, 0.0, 0.0);
            direction.x = sin(glm::radians(180.0 + penguinRotation));
            direction.y = 0.0;
            direction.z = cos(glm::radians(180.0 + penguinRotation));

            firstPersonCamera.front = glm::normalize(direction);
            firstPersonCamera.right = glm::normalize(glm::cross(firstPersonCamera.front, firstPersonCamera.worldUp));
            firstPersonCamera.up = glm::normalize(glm::cross(firstPersonCamera.right, firstPersonCamera.front));

            direction.y = glm::radians(-30.0);
            thirdPersonCamera.position = penguinTranslation - 4.0f * glm::normalize(direction);
            thirdPersonCamera.position.y = 10.0;
            thirdPersonCamera.front = glm::normalize(direction);
        }

        birdsEyeCamera.view = glm::lookAt(birdsEyeCamera.position,
                                          birdsEyeCamera.position + birdsEyeCamera.front,
                                          birdsEyeCamera.up);

        firstPersonCamera.view = glm::lookAt(firstPersonCamera.position,
                                             firstPersonCamera.position + firstPersonCamera.front,
                                             firstPersonCamera.up);

        thirdPersonCamera.view = glm::lookAt(thirdPersonCamera.position,
                                             thirdPersonCamera.position + thirdPersonCamera.front,
                                             thirdPersonCamera.up);

    //    printf("Penguin Translation: (%f, %f)\n", penguinTranslation.x, penguinTranslation.z);
    //    int block_j = (int)((penguinTranslation.x) / 4.0 + 11.5);
    //    int block_i = (int)((penguinTranslation.z) / 4.0 + 11.5);
    //    printf("corresponds to block: (%d, %d)\n", block_i, block_j);
    //    if (block_i >= 0 && block_j >= 0 && block_i < mapHeight  && block_j < mapWidth)
    //    {
    //        printf("mazeMap[%d][%d] = %c\n", block_i, block_j, mazeMap[block_i][block_j]);
    //    }
    }
    else if (gameState == GAME_STATE_FINISHED)
    {
        // Reset the game.
        resetGame();

        NSFontManager * fontManager = [NSFontManager sharedFontManager];

        NSFont * timerFont = [fontManager fontWithFamily:@"Courier New"
                                                  traits:NSBoldFontMask
                                                  weight:0
                                                    size:48];

        [timeLabel setTextColor:[NSColor greenColor]];
        [timeLabel setFont:timerFont];
        [timeLabel setStringValue:@""];

        NSFont * messageFont = [fontManager fontWithFamily:@"Courier New"
                                                    traits:NSBoldFontMask
                                                    weight:0
                                                      size:64];

        [messageLabel setTextColor:[NSColor greenColor]];
        [messageLabel setFont:messageFont];
        [messageLabel setStringValue:@"Penguin Maze\n\nPress any key to start!"];

        currentCameraType = CAMERA_TYPE_START_SCREEN;

        spinCameraTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                           target:self
                                                         selector:@selector(spinCameraTick:)
                                                         userInfo:nil
                                                          repeats:YES];

        gameState = GAME_STATE_STARTING;
    }

    [self drawRect:[self convertRectToBase:[self bounds]]];
}

- (void)scrollWheel:(NSEvent *)event
{
    // Should only be able to zoom in and zoom out during development.
    if (gameState == GAME_STATE_DEVELOPMENT)
    {
        zoom += ([event deltaY] * 0.005);

        [self drawRect:[self convertRectToBase:[self bounds]]];
    }
}


GLfloat oldMouseX = 0.0;
GLfloat oldMouseY = 0.0;

- (void)mouseDown:(NSEvent *)event
{
    // Should only be able to rotate world if in development.
    if (gameState == GAME_STATE_DEVELOPMENT)
    {
        NSPoint position = [NSEvent mouseLocation];

        oldMouseX = position.x;
        oldMouseY = position.y;
   }
}

- (void)mouseDragged:(NSEvent *)event
{
    // Should only be able to rotate world if in development.
    if (gameState == GAME_STATE_DEVELOPMENT)
    {
        NSPoint position = [NSEvent mouseLocation];

        horizontalRotation += (0.01) * (position.x - oldMouseX);
        verticalRotation += (0.01) * (position.y - oldMouseY);

        [self drawRect:[self convertRectToBase:[self bounds]]];
    }
}

- (void)prepare
{
    NSLog(@"prepare");

    NSOpenGLPixelFormatAttribute attributes[] =
    {
        NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
        NSOpenGLPFAAccelerated,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAColorSize, 24,
        NSOpenGLPFAAlphaSize, 8,
        NSOpenGLPFADepthSize, 24,
        0
    };

    NSOpenGLPixelFormat * pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];

    [self setPixelFormat:pixelFormat];

    NSOpenGLContext * context = [self openGLContext];

    [context makeCurrentContext];

    const GLubyte * vendor = glGetString(GL_VENDOR);
    const GLubyte * renderer = glGetString(GL_RENDERER);
    const GLubyte * version = glGetString(GL_VERSION);
    const GLubyte * shadingLanguageVersion = glGetString(GL_SHADING_LANGUAGE_VERSION);

    printf("Vendor: %s\n", vendor);
    printf("Renderer: %s\n", renderer);
    printf("Version: %s\n", version);
    printf("Shading Language Version: %s\n", shadingLanguageVersion);

    NSString * vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"vertex_shader" ofType:@"glsl"];
    NSString * fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"fragment_shader" ofType:@"glsl"];

    // TODO: Implement own shader source loader.
    shaderProgram = InitShader([vertexShaderPath UTF8String], [fragmentShaderPath UTF8String]);

    glClearColor(0.2, 0.2, 0.2, 1.0);

    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);

//    glEnable(GL_CULL_FACE);
//    glCullFace(GL_BACK);
//    glFrontFace(GL_CCW);

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];

    if (self)
    {
        [self prepare];
    }

    return self;
}

//- (void)reshape
//{
//    [super reshape];
//
//    NSLog(@"reshape");
//}

- (void)drawRect:(NSRect)dirtyRect
{
//    [super drawRect:dirtyRect];

//    [timeLabel setStringValue:[NSString stringWithFormat:@"%.f",  CFAbsoluteTimeGetCurrent()]];

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glUseProgram(shaderProgram);

    shadingModelVariable = glGetUniformLocation(shaderProgram, "shadingModel");

    glUniform1i(shadingModelVariable, shadingModel);

    GLuint drawingObjectVariable = glGetUniformLocation(shaderProgram, "drawingObject");

    modelVariable = glGetUniformLocation(shaderProgram, "model");
    viewVariable = glGetUniformLocation(shaderProgram, "view");
    projectionVariable = glGetUniformLocation(shaderProgram, "projection");

    lightPositionVariable = glGetUniformLocation(shaderProgram, "lightPosition");
    lightAmbientVariable = glGetUniformLocation(shaderProgram, "ambientLight");
    lightDiffuseVariable = glGetUniformLocation(shaderProgram, "diffuseLight");
    lightSpecularVariable = glGetUniformLocation(shaderProgram, "specularLight");

    materialAmbientVariable = glGetUniformLocation(shaderProgram, "ambientMaterial");
    materialDiffuseVariable = glGetUniformLocation(shaderProgram, "diffuseMaterial");
    materialSpecularVariable = glGetUniformLocation(shaderProgram, "specularMaterial");
    materialShininessVariable = glGetUniformLocation(shaderProgram, "shininessMaterial");

    glUniform4fv(lightPositionVariable, 1, glm::value_ptr(light.position));
    glUniform4fv(lightAmbientVariable, 1, glm::value_ptr(light.ambient));
    glUniform4fv(lightDiffuseVariable, 1, glm::value_ptr(light.diffuse));
    glUniform4fv(lightSpecularVariable, 1, glm::value_ptr(light.specular));

    glUniform1i(drawingObjectVariable, 0);

    glm::mat4 model = glm::mat4(1.0);

    model = glm::scale(model, glm::vec3(zoom));
    model = glm::rotate(model, horizontalRotation, glm::vec3(0.0, 1.0, 0.0));
    model = glm::rotate(model, verticalRotation, glm::vec3(1.0, 0.0, 0.0));

    GLfloat fieldOfView = 90.0;
//    GLfloat aspectRatio = 1.0;
    GLfloat aspectRatio = 1280.0 / 720.0;
    GLfloat nearClippingPlane = 0.1;
    GLfloat farClippingPlane = 10000.0;

    glm::mat4 projection = glm::perspective(glm::radians(fieldOfView), aspectRatio, nearClippingPlane, farClippingPlane);

    if (currentCameraType == CAMERA_TYPE_DEVELOPMENT)
    {
        glUniformMatrix4fv(viewVariable, 1, GL_FALSE, glm::value_ptr(developmentCamera.view));
    }
    else if (currentCameraType == CAMERA_TYPE_START_SCREEN)
    {
        glUniformMatrix4fv(viewVariable, 1, GL_FALSE, glm::value_ptr(startScreenCamera.view));
    }
    else if (currentCameraType == CAMERA_TYPE_BIRDS_EYE)
    {
        glUniformMatrix4fv(viewVariable, 1, GL_FALSE, glm::value_ptr(birdsEyeCamera.view));
    }
    else if (currentCameraType == CAMERA_TYPE_FIRST_PERSON)
    {
        glUniformMatrix4fv(viewVariable, 1, GL_FALSE, glm::value_ptr(firstPersonCamera.view));
    }
    else if (currentCameraType == CAMERA_TYPE_THIRD_PERSON)
    {
        glUniformMatrix4fv(viewVariable, 1, GL_FALSE, glm::value_ptr(thirdPersonCamera.view));
    }
    else
    {
        glUniformMatrix4fv(viewVariable, 1, GL_FALSE, glm::value_ptr(developmentCamera.view));
    }

    glUniformMatrix4fv(projectionVariable, 1, GL_FALSE, glm::value_ptr(projection));

    glUniformMatrix4fv(modelVariable, 1, GL_FALSE, glm::value_ptr(model));

    // Draw triangle.
    if (gameState == GAME_STATE_DEVELOPMENT)
    {
        glUniform1i(drawingObjectVariable, DRAWING_OBJECT_Z_AXIS);
        model = glm::mat4(1.0);
        model = glm::translate(model, triangleTranslation);
        model = glm::rotate(model, glm::radians(triangleRotation), glm::vec3(0.0, 1.0, 0.0));
        glBindVertexArray(triangleVAO);
        glUniformMatrix4fv(modelVariable, 1, GL_FALSE, glm::value_ptr(model));
        glDrawArrays(GL_TRIANGLES, 0, 3);
    }

    model = glm::mat4(1.0);
    glUniformMatrix4fv(modelVariable, 1, GL_FALSE, glm::value_ptr(model));

    if ([axesSwitch state] == NSControlStateValueOn)
    {
        // Draw x-axis.
        glUniform1i(drawingObjectVariable, DRAWING_OBJECT_X_AXIS);
        glBindVertexArray(xAxisVAO);
        glDrawArrays(GL_LINE_STRIP, 0, 12);

        // Draw y-axis.
        glUniform1i(drawingObjectVariable, DRAWING_OBJECT_Y_AXIS);
        glBindVertexArray(yAxisVAO);
        glDrawArrays(GL_LINE_STRIP, 0, 12);

        // Draw z-axis.
        glUniform1i(drawingObjectVariable, DRAWING_OBJECT_Z_AXIS);
        glBindVertexArray(zAxisVAO);
        glDrawArrays(GL_LINE_STRIP, 0, 12);
    }

    // Let's try to draw a maze.
    glUniform1i(drawingObjectVariable, DRAWING_OBJECT_CUBE);
    glUniform1i(shadingModelVariable, SHADING_MODEL_FLAT);

//    printf("Face Normals:\n");
//    for (int i = 0; i < cubePointCount / 3; i += 3)
//    {
//        printf("(%f, %f, %f)\n", cubeFaceNormals[i], cubeFaceNormals[i + 1], cubeFaceNormals[i + 2]);
//    }
//    printf("Vertex Normals:\n");
//    for (int i = 0; i < cubePointCount / 3; i += 3)
//    {
//        printf("(%f, %f, %f)\n", cubeVertexNormals[i], cubeVertexNormals[i + 1], cubeVertexNormals[i + 2]);
//    }

    int height = maze->get_height();
    int width = maze->get_width();

//    mazeMap = maze->make_map();
    int mapHeight = height * 2 + 1;
    int mapWidth = width * 2 + 1;

    GLfloat yTranslate = (GLfloat)(mapHeight) / 2.0;
    GLfloat xTranslate = (GLfloat)(mapWidth) / 2.0;

    material_t wallMaterial;
    // Use obsidion values.
    wallMaterial.ambient = glm::vec4(0.05375, 0.05, 0.06625, 1.0);
    wallMaterial.diffuse = glm::vec4(0.18275, 0.17, 0.22525, 1.0);
    wallMaterial.specular = glm::vec4(0.332741, 0.328634, 0.346435, 1.0);
    wallMaterial.shininess = 0.3 * 128;
    glUniform4fv(materialAmbientVariable, 1, glm::value_ptr(wallMaterial.ambient));
    glUniform4fv(materialDiffuseVariable, 1, glm::value_ptr(wallMaterial.diffuse));
    glUniform4fv(materialSpecularVariable, 1, glm::value_ptr(wallMaterial.specular));
    glUniform1f(materialShininessVariable, wallMaterial.shininess);

    int mazeStretch = 4.0;

//    printf("xTranslate and xTranslate: %f and %f\n", xTranslate, xTranslate);

    for (int i = 0; i < mapHeight; i++)
    {
        for (int j = 0; j < mapWidth; j++)
        {
            if (mazeMap[i][j] == '#')
            {
                model = glm::mat4(1.0);
                model = glm::rotate(model, horizontalRotation, glm::vec3(0.0, 1.0, 0.0));
                model = glm::rotate(model, verticalRotation, glm::vec3(1.0, 0.0, 0.0));
//                model = glm::translate(model, glm::vec3(j - xTranslate, i - yTranslate, 0.0 + 0.5));
                model = glm::translate(model, glm::vec3((j - xTranslate) * mazeStretch, 2.0, (i - yTranslate) * mazeStretch));
                model = glm::scale(model, glm::vec3(mazeStretch, 6.0, mazeStretch));
                model = glm::scale(model, glm::vec3(zoom));

                glUniformMatrix4fv(modelVariable, 1, GL_FALSE, glm::value_ptr(model));

                glBindVertexArray(cubeVAO);
                glDrawArrays(GL_TRIANGLES, 0, cubePointCount);

//                printf("(%d, %d) at (%f, %f)\n", i, j,
//                       (j - xTranslate) * mazeStretch,
//                       (i - yTranslate) * mazeStretch);
            }
        }
    }

    // Draw a plane.
    glUniform1i(drawingObjectVariable, DRAWING_OBJECT_PLANE);
    model = glm::mat4(1.0);
    model = glm::scale(model, glm::vec3(100.0, 100.0, 100.0));
    model = glm::scale(model, glm::vec3(zoom));
    model = glm::rotate(model, horizontalRotation, glm::vec3(0.0, 1.0, 0.0));
    model = glm::rotate(model, verticalRotation, glm::vec3(1.0, 0.0, 0.0));
    glUniformMatrix4fv(modelVariable, 1, GL_FALSE, glm::value_ptr(model));
    glBindVertexArray(planeVAO);
//    glDrawArrays(GL_TRIANGLES, 0, planePointCount);


    // Draw sky.
    glUniform1i(drawingObjectVariable, DRAWING_OBJECT_SKY);
    glUniform1i(shadingModelVariable, SHADING_MODEL_FLAT);
    model = glm::mat4(1.0);
    glUniformMatrix4fv(modelVariable, 1, GL_FALSE, glm::value_ptr(model));
    glBindVertexArray(skyVAO);
    glDrawArrays(GL_TRIANGLES, 0, 30);


    // Draw beach / islands.
    glUniform1i(drawingObjectVariable, DRAWING_OBJECT_BEACH);
    glUniform1i(shadingModelVariable, SHADING_MODEL_PHONG);
    material_t beachMaterial;
    beachMaterial.ambient = glm::vec4(0.97, 0.97, 0.74, 1.0);
    beachMaterial.diffuse = glm::vec4(0.3, 0.3, 0.3, 1.0);
    beachMaterial.specular = glm::vec4(0.1, 0.1, 0.1, 1.0);
    beachMaterial.shininess = 10.0;
    glUniform4fv(materialAmbientVariable, 1, glm::value_ptr(beachMaterial.ambient));
    glUniform4fv(materialDiffuseVariable, 1, glm::value_ptr(beachMaterial.diffuse));
    glUniform4fv(materialSpecularVariable, 1, glm::value_ptr(beachMaterial.specular));
    glUniform1f(materialShininessVariable, beachMaterial.shininess);
    model = glm::mat4(1.0);
    model = glm::translate(model, glm::vec3(0.0, -8.0, 0.0));
    model = glm::rotate(model, horizontalRotation, glm::vec3(0.0, 1.0, 0.0));
    model = glm::rotate(model, verticalRotation, glm::vec3(1.0, 0.0, 0.0));
    model = glm::scale(model, glm::vec3(0.5 * mazeStretch / 2, 1.0, 0.5 * mazeStretch / 2));
    model = glm::scale(model, glm::vec3(zoom));
    glUniformMatrix4fv(modelVariable, 1, GL_FALSE, glm::value_ptr(model));
    glBindVertexArray(beachVAO);
    glDrawArrays(GL_TRIANGLES, 0, beachPointCount);


    // Draw ocean floor.
    glUniform1i(drawingObjectVariable, DRAWING_OBJECT_OCEAN_FLOOR);
    glUniform1i(shadingModelVariable, SHADING_MODEL_FLAT);
    model = glm::mat4(1.0);
//    model = glm::translate(model, glm::vec3(0.0, -1.0, 0.0));
//    model = glm::rotate(model, horizontalRotation, glm::vec3(0.0, 1.0, 0.0));
//    model = glm::rotate(model, verticalRotation, glm::vec3(1.0, 0.0, 0.0));
//    model = glm::scale(model, glm::vec3(zoom));
    glUniformMatrix4fv(modelVariable, 1, GL_FALSE, glm::value_ptr(model));
    glBindVertexArray(oceanFloorVAO);
    glDrawArrays(GL_TRIANGLES, 0, 30);


    // Draw water.
    glUniform1i(drawingObjectVariable, DRAWING_OBJECT_WATER);
    glUniform1i(shadingModelVariable, SHADING_MODEL_FLAT);
    model = glm::mat4(1.0);
    model = glm::translate(model, glm::vec3(0.0, -1.0, 0.0));
    model = glm::rotate(model, horizontalRotation, glm::vec3(0.0, 1.0, 0.0));
    model = glm::rotate(model, verticalRotation, glm::vec3(1.0, 0.0, 0.0));
    model = glm::scale(model, glm::vec3(zoom));
    glUniformMatrix4fv(modelVariable, 1, GL_FALSE, glm::value_ptr(model));
    glBindVertexArray(waterVAO);
    glDrawArrays(GL_TRIANGLES, 0, 6);


    // Draw bush.
    glUniform1i(drawingObjectVariable, DRAWING_OBJECT_BUSH);
    glUniform1i(shadingModelVariable, SHADING_MODEL_PHONG);
    material_t bushMaterial;
    bushMaterial.ambient = glm::vec4(0.0, 0.5, 0.0, 1.0);
    bushMaterial.diffuse = glm::vec4(0.4, 0.5, 0.4, 1.0);
    bushMaterial.specular = glm::vec4(0.04, 0.07, 0.04, 1.0);
    bushMaterial.shininess = 10.0;
    glUniform4fv(materialAmbientVariable, 1, glm::value_ptr(bushMaterial.ambient));
    glUniform4fv(materialDiffuseVariable, 1, glm::value_ptr(bushMaterial.diffuse));
    glUniform4fv(materialSpecularVariable, 1, glm::value_ptr(bushMaterial.specular));
    glUniform1f(materialShininessVariable, bushMaterial.shininess);
    model = glm::mat4(1.0);
    model = glm::translate(model, glm::vec3(-20.0 * mazeStretch / 2, 0.0, 24.0 * mazeStretch / 2));
    model = glm::rotate(model, horizontalRotation, glm::vec3(0.0, 1.0, 0.0));
    model = glm::rotate(model, verticalRotation, glm::vec3(1.0, 0.0, 0.0));
    model = glm::scale(model, glm::vec3(zoom));
    glUniformMatrix4fv(modelVariable, 1, GL_FALSE, glm::value_ptr(model));
    glBindVertexArray(bushVAO);
    glDrawArrays(GL_TRIANGLES, 0, bushPointCount);


    // Draw palm (green components).
    glUniform1i(drawingObjectVariable, DRAWING_OBJECT_PALM_GREEN);
    glUniform1i(shadingModelVariable, SHADING_MODEL_PHONG);
    material_t palmGreenMaterial;
    palmGreenMaterial.ambient = glm::vec4(0.0, 0.5, 0.0, 1.0);
    palmGreenMaterial.diffuse = glm::vec4(0.4, 0.5, 0.4, 1.0);
    palmGreenMaterial.specular = glm::vec4(0.04, 0.07, 0.04, 1.0);
    palmGreenMaterial.shininess = 10.0;
    glUniform4fv(materialAmbientVariable, 1, glm::value_ptr(palmGreenMaterial.ambient));
    glUniform4fv(materialDiffuseVariable, 1, glm::value_ptr(palmGreenMaterial.diffuse));
    glUniform4fv(materialSpecularVariable, 1, glm::value_ptr(palmGreenMaterial.specular));
    glUniform1f(materialShininessVariable, palmGreenMaterial.shininess);
    model = glm::mat4(1.0);
    model = glm::translate(model, glm::vec3(23.0 * mazeStretch / 2, 0.0, 23.0 * mazeStretch / 2));
    model = glm::rotate(model, horizontalRotation, glm::vec3(0.0, 1.0, 0.0));
    model = glm::rotate(model, verticalRotation, glm::vec3(1.0, 0.0, 0.0));
    model = glm::scale(model, glm::vec3(zoom));
    glUniformMatrix4fv(modelVariable, 1, GL_FALSE, glm::value_ptr(model));
    glBindVertexArray(palmGreenVAO);
    glDrawArrays(GL_TRIANGLES, 0, palmGreenPointCount);


    // Draw palm (brown components).
    glUniform1i(drawingObjectVariable, DRAWING_OBJECT_PALM_BROWN);
    glUniform1i(shadingModelVariable, SHADING_MODEL_PHONG);
    material_t palmBrownMaterial;
    palmBrownMaterial.ambient = glm::vec4(0.5, 0.25, 0.0, 1.0);
    palmBrownMaterial.diffuse = glm::vec4(0.5, 0.4, 0.4, 1.0);
    palmBrownMaterial.specular = glm::vec4(0.07, 0.04, 0.04, 1.0);
    palmBrownMaterial.shininess = 10.0;
    glUniform4fv(materialAmbientVariable, 1, glm::value_ptr(palmBrownMaterial.ambient));
    glUniform4fv(materialDiffuseVariable, 1, glm::value_ptr(palmBrownMaterial.diffuse));
    glUniform4fv(materialSpecularVariable, 1, glm::value_ptr(palmBrownMaterial.specular));
    glUniform1f(materialShininessVariable, palmBrownMaterial.shininess);
    model = glm::mat4(1.0);
    model = glm::translate(model, glm::vec3(23.0 * mazeStretch / 2, 0.0, 23.0 * mazeStretch / 2));
    model = glm::rotate(model, horizontalRotation, glm::vec3(0.0, 1.0, 0.0));
    model = glm::rotate(model, verticalRotation, glm::vec3(1.0, 0.0, 0.0));
    model = glm::scale(model, glm::vec3(zoom));
    glUniformMatrix4fv(modelVariable, 1, GL_FALSE, glm::value_ptr(model));
    glBindVertexArray(palmBrownVAO);
    glDrawArrays(GL_TRIANGLES, 0, palmBrownPointCount);


    // Draw penguin (black components).
    glUniform1i(drawingObjectVariable, DRAWING_OBJECT_PENGUIN_BLACK);
    glUniform1i(shadingModelVariable, SHADING_MODEL_PHONG);
    material_t penguinBlackBodyMaterial;
    penguinBlackBodyMaterial.ambient = glm::vec4(0.1, 0.1, 0.1, 1.0);
    penguinBlackBodyMaterial.diffuse = glm::vec4(0.2, 0.2, 0.2, 1.0);
    penguinBlackBodyMaterial.specular = glm::vec4(0.5, 0.5, 0.5, 1.0);
    penguinBlackBodyMaterial.shininess = 10.0;
    glUniform4fv(materialAmbientVariable, 1, glm::value_ptr(penguinBlackBodyMaterial.ambient));
    glUniform4fv(materialDiffuseVariable, 1, glm::value_ptr(penguinBlackBodyMaterial.diffuse));
    glUniform4fv(materialSpecularVariable, 1, glm::value_ptr(penguinBlackBodyMaterial.specular));
    glUniform1f(materialShininessVariable, penguinBlackBodyMaterial.shininess);
    model = glm::mat4(1.0);
    model = glm::translate(model, penguinTranslation);
    model = glm::rotate(model, (GLfloat)glm::radians(90.0), glm::vec3(0.0, 1.0, 0.0));
    model = glm::rotate(model, glm::radians(penguinRotation), glm::vec3(0.0, 1.0, 0.0));
    model = glm::rotate(model, horizontalRotation, glm::vec3(0.0, 1.0, 0.0));
    model = glm::rotate(model, verticalRotation, glm::vec3(1.0, 0.0, 0.0));
    model = glm::scale(model, glm::vec3(0.5, 0.5, 0.5));
    model = glm::scale(model, glm::vec3(zoom));
    glUniformMatrix4fv(modelVariable, 1, GL_FALSE, glm::value_ptr(model));
    glBindVertexArray(penguinBlackBodyVAO);
    glDrawArrays(GL_TRIANGLES, 0, penguinBlackBodyPointCount);


    // Draw penguin (white components).
    glUniform1i(drawingObjectVariable, DRAWING_OBJECT_PENGUIN_WHITE);
    glUniform1i(shadingModelVariable, SHADING_MODEL_PHONG);
    material_t penguinWhiteBodyMaterial;
    penguinWhiteBodyMaterial.ambient = glm::vec4(0.9, 0.9, 0.9, 1.0);
    penguinWhiteBodyMaterial.diffuse = glm::vec4(0.8, 0.8, 0.8, 1.0);
    penguinWhiteBodyMaterial.specular = glm::vec4(0.5, 0.5, 0.5, 1.0);
    penguinWhiteBodyMaterial.shininess = 10.0;
    glUniform4fv(materialAmbientVariable, 1, glm::value_ptr(penguinWhiteBodyMaterial.ambient));
    glUniform4fv(materialDiffuseVariable, 1, glm::value_ptr(penguinWhiteBodyMaterial.diffuse));
    glUniform4fv(materialSpecularVariable, 1, glm::value_ptr(penguinWhiteBodyMaterial.specular));
    glUniform1f(materialShininessVariable, penguinWhiteBodyMaterial.shininess);
    model = glm::mat4(1.0);
    model = glm::translate(model, penguinTranslation);
    model = glm::rotate(model, (GLfloat)glm::radians(90.0), glm::vec3(0.0, 1.0, 0.0));
    model = glm::rotate(model, glm::radians(penguinRotation), glm::vec3(0.0, 1.0, 0.0));
    model = glm::rotate(model, horizontalRotation, glm::vec3(0.0, 1.0, 0.0));
    model = glm::rotate(model, verticalRotation, glm::vec3(1.0, 0.0, 0.0));
    model = glm::scale(model, glm::vec3(0.5, 0.5, 0.5));
    model = glm::scale(model, glm::vec3(zoom));
    glUniformMatrix4fv(modelVariable, 1, GL_FALSE, glm::value_ptr(model));
    glBindVertexArray(penguinWhiteBodyVAO);
    glDrawArrays(GL_TRIANGLES, 0, penguinWhiteBodyPointCount);


    // Draw penguin (orange components).
    glUniform1i(drawingObjectVariable, DRAWING_OBJECT_PENGUIN_ORANGE);
    glUniform1i(shadingModelVariable, SHADING_MODEL_PHONG);
    material_t penguinOrangeBodyMaterial;
    penguinOrangeBodyMaterial.ambient = glm::vec4(0.5, 0.25, 0.0, 1.0);
    penguinOrangeBodyMaterial.diffuse = glm::vec4(1.0, 0.5, 0.0, 1.0);
    penguinOrangeBodyMaterial.specular = glm::vec4(0.5, 0.5, 0.5, 1.0);
    penguinOrangeBodyMaterial.shininess = 10.0;
    glUniform4fv(materialAmbientVariable, 1, glm::value_ptr(penguinOrangeBodyMaterial.ambient));
    glUniform4fv(materialDiffuseVariable, 1, glm::value_ptr(penguinOrangeBodyMaterial.diffuse));
    glUniform4fv(materialSpecularVariable, 1, glm::value_ptr(penguinOrangeBodyMaterial.specular));
    glUniform1f(materialShininessVariable, penguinOrangeBodyMaterial.shininess);
    model = glm::mat4(1.0);
    model = glm::translate(model, penguinTranslation);
    model = glm::rotate(model, (GLfloat)glm::radians(90.0), glm::vec3(0.0, 1.0, 0.0));
    model = glm::rotate(model, glm::radians(penguinRotation), glm::vec3(0.0, 1.0, 0.0));
    model = glm::rotate(model, horizontalRotation, glm::vec3(0.0, 1.0, 0.0));
    model = glm::rotate(model, verticalRotation, glm::vec3(1.0, 0.0, 0.0));
    model = glm::scale(model, glm::vec3(0.5, 0.5, 0.5));
    model = glm::scale(model, glm::vec3(zoom));
    glUniformMatrix4fv(modelVariable, 1, GL_FALSE, glm::value_ptr(model));
    glBindVertexArray(penguinOrangeBodyVAO);
    glDrawArrays(GL_TRIANGLES, 0, penguinOrangeBodyPointCount);


    // Draw entrance gate.
    glUniform1i(drawingObjectVariable, DRAWING_OBJECT_GATE);
    glUniform1i(shadingModelVariable, SHADING_MODEL_PHONG);
    material_t gateMaterial;
    gateMaterial.ambient = glm::vec4(0.5, 0.0, 0.0, 1.0);
    gateMaterial.diffuse = glm::vec4(0.5, 0.0, 0.0, 1.0);
    gateMaterial.specular = glm::vec4(0.7, 0.7, 0.6, 1.0);
    gateMaterial.shininess = 0.25 * 128;
    glUniform4fv(materialAmbientVariable, 1, glm::value_ptr(gateMaterial.ambient));
    glUniform4fv(materialDiffuseVariable, 1, glm::value_ptr(gateMaterial.diffuse));
    glUniform4fv(materialSpecularVariable, 1, glm::value_ptr(gateMaterial.specular));
    glUniform1f(materialShininessVariable, gateMaterial.shininess);
    model = glm::mat4(1.0);
    model = glm::translate(model, glm::vec3(0.0, 0.0, 23.0 * mazeStretch / 2));
    model = glm::rotate(model, horizontalRotation, glm::vec3(0.0, 1.0, 0.0));
    model = glm::rotate(model, verticalRotation, glm::vec3(1.0, 0.0, 0.0));
    model = glm::scale(model, glm::vec3(0.5, 0.5, 0.5));
    model = glm::scale(model, glm::vec3(zoom));
    glUniformMatrix4fv(modelVariable, 1, GL_FALSE, glm::value_ptr(model));
    glBindVertexArray(gateVAO);
    glDrawArrays(GL_TRIANGLES, 0, gatePointCount);

    // Draw exit gate
    model = glm::mat4(1.0);
    model = glm::translate(model, glm::vec3(0.0, 0.0, -25.0 * mazeStretch / 2));
    model = glm::rotate(model, horizontalRotation, glm::vec3(0.0, 1.0, 0.0));
    model = glm::rotate(model, verticalRotation, glm::vec3(1.0, 0.0, 0.0));
    model = glm::scale(model, glm::vec3(0.5, 0.5, 0.5));
    model = glm::scale(model, glm::vec3(zoom));
    glUniformMatrix4fv(modelVariable, 1, GL_FALSE, glm::value_ptr(model));
    glBindVertexArray(gateVAO);
    glDrawArrays(GL_TRIANGLES, 0, gatePointCount);

    // Draw enemies.
    material_t enemyBodyMaterial;
    enemyBodyMaterial.ambient = glm::vec4(0.3, 0.0, 0.3, 1.0);
    enemyBodyMaterial.diffuse = glm::vec4(0.3, 0.0, 0.3, 1.0);
    enemyBodyMaterial.specular = glm::vec4(0.7, 0.7, 0.7, 1.0);
    enemyBodyMaterial.shininess = 0.78125 * 128;

    // Let's try silver material settings.
    material_t enemySpikesMaterial;
    enemySpikesMaterial.ambient = glm::vec4(0.19225, 0.19225, 0.19225, 1.0);
    enemySpikesMaterial.diffuse = glm::vec4(0.50754, 0.50754, 0.50754, 1.0);
    enemySpikesMaterial.specular = glm::vec4(0.508273, 0.508273, 0.508273, 1.0);
    enemySpikesMaterial.shininess = 0.4 * 128;

    if (!enemies.empty())
    {
        for (int i = 0; i < enemies.size(); i++)
        {
            model = glm::mat4(1.0);
            model = glm::translate(model, enemies[i].location);
            model = glm::scale(model, glm::vec3(1.0, 1.0, 1.0));
            glUniformMatrix4fv(modelVariable, 1, GL_FALSE, glm::value_ptr(model));

            // Draw enemy body.
            glUniform1i(drawingObjectVariable, DRAWING_OBJECT_ENEMY_BODY);
            glUniform1i(shadingModelVariable, SHADING_MODEL_PHONG);
            glUniform4fv(materialAmbientVariable, 1, glm::value_ptr(enemyBodyMaterial.ambient));
            glUniform4fv(materialDiffuseVariable, 1, glm::value_ptr(enemyBodyMaterial.diffuse));
            glUniform4fv(materialSpecularVariable, 1, glm::value_ptr(enemyBodyMaterial.specular));
            glUniform1f(materialShininessVariable, enemyBodyMaterial.shininess);
            glUniformMatrix4fv(modelVariable, 1, GL_FALSE, glm::value_ptr(model));
            
            glBindVertexArray(enemyBodyVAO);
            glDrawArrays(GL_TRIANGLES, 0, enemyBodyPointCount);

            // Draw enemy spikes.
            glUniform1i(drawingObjectVariable, DRAWING_OBJECT_ENEMY_SPIKES);
            glUniform1i(shadingModelVariable, SHADING_MODEL_PHONG);
            glUniform4fv(materialAmbientVariable, 1, glm::value_ptr(enemySpikesMaterial.ambient));
            glUniform4fv(materialDiffuseVariable, 1, glm::value_ptr(enemySpikesMaterial.diffuse));
            glUniform4fv(materialSpecularVariable, 1, glm::value_ptr(enemySpikesMaterial.specular));
            glUniform1f(materialShininessVariable, enemySpikesMaterial.shininess);
            glUniformMatrix4fv(modelVariable, 1, GL_FALSE, glm::value_ptr(model));

            glBindVertexArray(enemySpikesVAO);
            glDrawArrays(GL_TRIANGLES, 0, enemySpikesPointCount);
        }
    }

    // Draw mountain.
    glUniform1i(drawingObjectVariable, DRAWING_OBJECT_MOUNTAIN);
    glUniform1i(shadingModelVariable, SHADING_MODEL_PHONG);
    material_t mountainMaterial;
    mountainMaterial.ambient = glm::vec4(0.1, 0.1, 0.1, 1.0);
    mountainMaterial.diffuse = glm::vec4(0.6, 0.6, 0.6, 1.0);
    mountainMaterial.specular = glm::vec4(0.1, 0.1, 0.1, 1.0);
    mountainMaterial.shininess = 25.0;
    glUniform4fv(materialAmbientVariable, 1, glm::value_ptr(mountainMaterial.ambient));
    glUniform4fv(materialDiffuseVariable, 1, glm::value_ptr(mountainMaterial.diffuse));
    glUniform4fv(materialSpecularVariable, 1, glm::value_ptr(mountainMaterial.specular));
    glUniform1f(materialShininessVariable, mountainMaterial.shininess);
    model = glm::mat4(1.0);
    model = glm::translate(model, glm::vec3(0.0, -35.0, 0.0));
    model = glm::rotate(model, horizontalRotation, glm::vec3(0.0, 1.0, 0.0));
    model = glm::rotate(model, verticalRotation, glm::vec3(1.0, 0.0, 0.0));
    model = glm::scale(model, glm::vec3(0.5 * mazeStretch / 2, 1.0, 0.5 * mazeStretch / 2));
    model = glm::scale(model, glm::vec3(zoom));
    glUniformMatrix4fv(modelVariable, 1, GL_FALSE, glm::value_ptr(model));
    glBindVertexArray(mountainVAO);
    glDrawArrays(GL_TRIANGLES, 0, mountainPointCount);

    // Draw lava.
    glUniform1i(drawingObjectVariable, DRAWING_OBJECT_LAVA);
    glUniform1i(shadingModelVariable, SHADING_MODEL_PHONG);
    material_t lavalMaterial;
    lavalMaterial.ambient = glm::vec4(0.2, 0.1, 0.0, 1.0);
    lavalMaterial.diffuse = glm::vec4(0.8, 0.4, 0.0, 1.0);
    lavalMaterial.specular = glm::vec4(0.7, 0.04, 0.04, 1.0);
    lavalMaterial.shininess = 0.078125 * 128;
    glUniform4fv(materialAmbientVariable, 1, glm::value_ptr(lavalMaterial.ambient));
    glUniform4fv(materialDiffuseVariable, 1, glm::value_ptr(lavalMaterial.diffuse));
    glUniform4fv(materialSpecularVariable, 1, glm::value_ptr(lavalMaterial.specular));
    glUniform1f(materialShininessVariable, lavalMaterial.shininess);
    model = glm::mat4(1.0);
    model = glm::translate(model, glm::vec3(0.0, -35.0, 0.0));
    model = glm::rotate(model, horizontalRotation, glm::vec3(0.0, 1.0, 0.0));
    model = glm::rotate(model, verticalRotation, glm::vec3(1.0, 0.0, 0.0));
    model = glm::scale(model, glm::vec3(0.5 * mazeStretch / 2, 1.0, 0.5 * mazeStretch / 2));
    model = glm::scale(model, glm::vec3(zoom));
    glUniformMatrix4fv(modelVariable, 1, GL_FALSE, glm::value_ptr(model));
    glBindVertexArray(lavaVAO);
    glDrawArrays(GL_TRIANGLES, 0, lavaPointCount);

    // Draw smoke.
    glUniform1i(drawingObjectVariable, DRAWING_OBJECT_SMOKE);
    glUniform1i(shadingModelVariable, SHADING_MODEL_PHONG);
    material_t smokeMaterial;
    smokeMaterial.ambient = glm::vec4(0.4, 0.4, 0.4, 1.0);
    smokeMaterial.diffuse = glm::vec4(0.7, 0.7, 0.7, 1.0);
    smokeMaterial.specular = glm::vec4(0.1, 0.1, 0.1, 1.0);
    smokeMaterial.shininess = 25.0;
    glUniform4fv(materialAmbientVariable, 1, glm::value_ptr(smokeMaterial.ambient));
    glUniform4fv(materialDiffuseVariable, 1, glm::value_ptr(smokeMaterial.diffuse));
    glUniform4fv(materialSpecularVariable, 1, glm::value_ptr(smokeMaterial.specular));
    glUniform1f(materialShininessVariable, smokeMaterial.shininess);
    model = glm::mat4(1.0);
    model = glm::translate(model, glm::vec3(0.0, -35.0, 0.0));
    model = glm::rotate(model, horizontalRotation, glm::vec3(0.0, 1.0, 0.0));
    model = glm::rotate(model, verticalRotation, glm::vec3(1.0, 0.0, 0.0));
    model = glm::scale(model, glm::vec3(0.5 * mazeStretch / 2, 1.0, 0.5 * mazeStretch / 2));
    model = glm::scale(model, glm::vec3(zoom));
    glUniformMatrix4fv(modelVariable, 1, GL_FALSE, glm::value_ptr(model));
    glBindVertexArray(smokeVAO);
    glDrawArrays(GL_TRIANGLES, 0, smokePointCount);

    // Draw trees.
    if (!trees.empty())
    {
        for (int i = 0; i < trees.size(); i++)
        {
            // Draw palm (green components).
            glUniform1i(drawingObjectVariable, DRAWING_OBJECT_PALM_GREEN);
            glUniform1i(shadingModelVariable, SHADING_MODEL_PHONG);
            glUniform4fv(materialAmbientVariable, 1, glm::value_ptr(palmGreenMaterial.ambient));
            glUniform4fv(materialDiffuseVariable, 1, glm::value_ptr(palmGreenMaterial.diffuse));
            glUniform4fv(materialSpecularVariable, 1, glm::value_ptr(palmGreenMaterial.specular));
            glUniform1f(materialShininessVariable, palmGreenMaterial.shininess);
            model = glm::mat4(1.0);
            model = glm::translate(model, trees[i].location);
            model = glm::rotate(model, trees[i].rotation, glm::vec3(0.0, 1.0, 0.0));
            model = glm::rotate(model, horizontalRotation, glm::vec3(0.0, 1.0, 0.0));
            model = glm::rotate(model, verticalRotation, glm::vec3(1.0, 0.0, 0.0));
            model = glm::scale(model, trees[i].scale);
            model = glm::scale(model, glm::vec3(zoom));
            glUniformMatrix4fv(modelVariable, 1, GL_FALSE, glm::value_ptr(model));
            glBindVertexArray(palmGreenVAO);
            glDrawArrays(GL_TRIANGLES, 0, palmGreenPointCount);

            // Draw palm (brown components).
            glUniform1i(drawingObjectVariable, DRAWING_OBJECT_PALM_BROWN);
            glUniform1i(shadingModelVariable, SHADING_MODEL_PHONG);
            glUniform4fv(materialAmbientVariable, 1, glm::value_ptr(palmBrownMaterial.ambient));
            glUniform4fv(materialDiffuseVariable, 1, glm::value_ptr(palmBrownMaterial.diffuse));
            glUniform4fv(materialSpecularVariable, 1, glm::value_ptr(palmBrownMaterial.specular));
            glUniform1f(materialShininessVariable, palmBrownMaterial.shininess);
            model = glm::mat4(1.0);
            model = glm::translate(model, trees[i].location);
            model = glm::rotate(model, trees[i].rotation, glm::vec3(0.0, 1.0, 0.0));
            model = glm::rotate(model, horizontalRotation, glm::vec3(0.0, 1.0, 0.0));
            model = glm::rotate(model, verticalRotation, glm::vec3(1.0, 0.0, 0.0));
            model = glm::scale(model, trees[i].scale);
            model = glm::scale(model, glm::vec3(zoom));
            glUniformMatrix4fv(modelVariable, 1, GL_FALSE, glm::value_ptr(model));
            glBindVertexArray(palmBrownVAO);
            glDrawArrays(GL_TRIANGLES, 0, palmBrownPointCount);
        }
    }

    // Draw bushes.
    if (!bushes.empty())
    {
        for (int i = 0; i < bushes.size(); i++)
        {
            glUniform1i(drawingObjectVariable, DRAWING_OBJECT_BUSH);
            glUniform1i(shadingModelVariable, SHADING_MODEL_PHONG);
            glUniform4fv(materialAmbientVariable, 1, glm::value_ptr(bushMaterial.ambient));
            glUniform4fv(materialDiffuseVariable, 1, glm::value_ptr(bushMaterial.diffuse));
            glUniform4fv(materialSpecularVariable, 1, glm::value_ptr(bushMaterial.specular));
            glUniform1f(materialShininessVariable, bushMaterial.shininess);
            model = glm::mat4(1.0);
            model = glm::translate(model, bushes[i].location);
            model = glm::rotate(model, bushes[i].rotation, glm::vec3(0.0, 1.0, 0.0));
            model = glm::rotate(model, horizontalRotation, glm::vec3(0.0, 1.0, 0.0));
            model = glm::rotate(model, verticalRotation, glm::vec3(1.0, 0.0, 0.0));
            model = glm::scale(model, bushes[i].scale);
            model = glm::scale(model, glm::vec3(zoom));
            glUniformMatrix4fv(modelVariable, 1, GL_FALSE, glm::value_ptr(model));
            glBindVertexArray(bushVAO);
            glDrawArrays(GL_TRIANGLES, 0, bushPointCount);
        }
    }

    [[self openGLContext] flushBuffer];
}

@end
