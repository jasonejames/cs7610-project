//
//  Cell.cpp
//  Maze Generator
//
//  Created by Jason James on 2/5/20.
//  Copyright © 2020 Jason James. All rights reserved.
//

#include "Cell.hpp"


Cell::Cell(wall_t north_wall, wall_t east_wall, wall_t west_wall, wall_t south_wall)
{
    this->north_wall = north_wall;
    this->east_wall = east_wall;
    this->west_wall = west_wall;
    this->south_wall = south_wall;
}

Cell::Cell()
{
    // TODO: Use designated constructor.
    this->north_wall = WALL_CLOSED;
    this->east_wall = WALL_CLOSED;
    this->west_wall = WALL_CLOSED;
    this->south_wall = WALL_CLOSED;
}

string Cell::to_string()
{
    string result = "";
    
    if (this->north_wall == WALL_CLOSED)
    {
        result += "-";
    }
    else
    {
        result += " ";
    }

    result += "\n";

    return result;
}

bool Cell::get_visited()
{
    return this->visited;
}

void Cell::set_visited(bool visited)
{
    this->visited = visited;
}

void Cell::set_north_wall(wall_t north_wall)
{
    this->north_wall = north_wall;
}

wall_t Cell::get_north_wall()
{
    return this->north_wall;
}

void Cell::set_south_wall(wall_t south_wall)
{
    this->south_wall = south_wall;
}

wall_t Cell::get_south_wall()
{
    return this->south_wall;
}

void Cell::set_east_wall(wall_t east_wall)
{
    this->east_wall = east_wall;
}

wall_t Cell::get_east_wall()
{
    return this->east_wall;
}

void Cell::set_west_wall(wall_t west_wall)
{
    this->west_wall = west_wall;
}

wall_t Cell::get_west_wall()
{
    return this->west_wall;
}
