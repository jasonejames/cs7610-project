# CS 7610 Project: Penguin Maze

## About


This is my project for a computer graphics course in Spring 2020. I implemented the Aldous-Broder algorithm for generating a maze and created a 3D game to guide a penguin through the maze. A new maze is generated each time the program runs. Additionally, there is a HUD panel that has some options for generating the maze, but these are more for development and not really fit for use while playing the game (for example, the environment is not currently setup to adjust according to the size of the maze). For the game environment, I tried to go with an island theme. The game is written in C / C++ / Objective-C using OpenGL for the graphics and Cocoa for the GUI. The models were created with Blender. The OBJ loader and shader loader were provided in the course with some of the assignment materials.

![An animated scene with a penguin on a beach. In the background, there is an island with a mountain surrounded by vegetation. The ocean and sky can be seen through the distance.](images/screenshot1.png)

![An animated aerial scene of several islands in the ocean. On the center island, a dark maze can be seen, with red gates marking the entrance and exit of the maze. There is also a large island nearby with a mountain surrounded by vegetation, a larger island with a tall volcano with lava flowing on its sides, and a smaller island with vegetation.](images/screenshot2.png)


## Controls
| Action                      | Control |
|-----------------------------|:-------:|
| Move Forward                | ⬆️      |
| Move Backward               | ⬇️      |
| Turn Left                   | ⬅️      |
| Turn Right                  | ➡️      |
| Switch to Bird's Eye View   | 1️⃣      |
| Switch to First Person View | 2️⃣      |
| Switch to Third Person View | 3️⃣      |


## Requirements
* macOS Catalina
* OpenGL
* GLM
