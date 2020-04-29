//
//  Maze.hpp
//  Maze Generator
//
//  Created by Jason James on 2/5/20.
//  Copyright © 2020 Jason James. All rights reserved.
//

#ifndef Maze_hpp
#define Maze_hpp

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include <string>

#include "Cell.hpp"

using namespace std;

enum maze_algorithm_t
{
    MAZE_ALGORITHM_BINARY_TREE,
    MAZE_ALGORITHM_SIDEWINDER,
    MAZE_ALGORITHM_ALDOUS_BRODER,
    
    MAZE_ALGORITHM_COUNT
};

enum direction_t
{
    DIRECTION_NORTH,
    DIRECTION_EAST,
    DIRECTION_SOUTH,
    DIRECTION_WEST
};

class Maze
{
private:
    unsigned int width;
    unsigned int height;
    Cell *** data;
    
    void use_binary_tree_algorithm();
    void use_sidewinder_algorithm();
    void use_aldous_broder_algorithm();

    bool all_cells_visited();

public:
    Maze(unsigned int width, unsigned int height);
    Maze();
    unsigned int get_width();
    unsigned int get_height();
    string to_string();
    char ** make_map();
    void generate_maze(maze_algorithm_t maze_algorithm);
};

#endif /* Maze_hpp */
