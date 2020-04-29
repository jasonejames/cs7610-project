//
//  Cell.hpp
//  Maze Generator
//
//  Created by Jason James on 2/5/20.
//  Copyright © 2020 Jason James. All rights reserved.
//

#ifndef Cell_hpp
#define Cell_hpp

#include <stdio.h>

#include <string>

using namespace std;

enum wall_t
{
    WALL_CLOSED = 0,
    WALL_OPEN = 1
};

class Cell
{

private:
    bool visited;
    wall_t north_wall;
    wall_t east_wall;
    wall_t west_wall;
    wall_t south_wall;

public:
    Cell();
    Cell(wall_t north_wall, wall_t east_wall, wall_t west_wall, wall_t south_wall);

    string to_string();

    bool get_visited();
    void set_visited(bool visited);

    wall_t get_north_wall();
    void set_north_wall(wall_t north_wall);

    wall_t get_south_wall();
    void set_south_wall(wall_t south_wall);

    wall_t get_east_wall();
    void set_east_wall(wall_t east_wall);

    wall_t get_west_wall();
    void set_west_wall(wall_t west_wall);
};

#endif /* Cell_hpp */
