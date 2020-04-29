//
//  Maze.cpp
//  Maze Generator
//
//  Created by Jason James on 2/5/20.
//  Copyright © 2020 Jason James. All rights reserved.
//

#include "Maze.hpp"

Maze::Maze(unsigned int width, unsigned int height)
{
    // Validate the width.
    if (width > 0)
    {
        // Set the width.
        this->width = width;
    }
    else
    {
        printf("Error: Invalid width.\n");
    }

    // Validate the height.
    if (height > 0)
    {
        // Set the height.
        this->height = height;
    }
    else
    {
        printf("Error: Invalid height.\n");
    }

    // Allocate memory for the array of pointers.
    this->data = (Cell ***)malloc(sizeof(Cell **) * this->height);
    
    // Go through each row of the maze.
    for (int i = 0; i < this->height; i++)
    {
        // Allocate memory that row.
        this->data[i] = (Cell **)malloc(sizeof(Cell *) * this->width);
    }

    // Go through each cell in the maze.
    for (int i = 0; i < this->height; i++)
    {
        for (int j = 0; j < this->width; j++)
        {
            // Create a cell and put it in the maze.
            this->data[i][j] = new Cell(WALL_CLOSED, WALL_CLOSED, WALL_CLOSED, WALL_CLOSED);
        }
    }
}

Maze::Maze()
{
    // TODO: Use designated constructor?
    this->width = 10;
    this->height = 10;
}

unsigned int Maze::get_width()
{
    return this->width;
}

unsigned int Maze::get_height()
{
    return this->height;
}

// Generate a string representation of the maze.
string Maze::to_string()
{
    string result = "";

    result += "Width: " + std::to_string(this->get_width()) + "\n";
    result += "Height: " + std::to_string(this->get_height()) + "\n";

    result += "Data:\n";

    for (int i = 0; i < this->height; i++)
    {
        for (int j = 0; j < this->width; j++)
        {
            result += "(";

            if (this->data[i][j]->get_north_wall() == WALL_CLOSED)
            {
                result += "1";
            }
            else
            {
                result += "0";
            }

            result += ", ";
            
            if (this->data[i][j]->get_east_wall() == WALL_CLOSED)
            {
                result += "1";
            }
            else
            {
                result += "0";
            }

            result += ", ";
            
            if (this->data[i][j]->get_west_wall() == WALL_CLOSED)
            {
                result += "1";
            }
            else
            {
                result += "0";
            }

            result += ", ";
            
            if (this->data[i][j]->get_south_wall() == WALL_CLOSED)
            {
                result += "1";
            }
            else
            {
                result += "0";
            }

            if (j == this->width - 1)
            {
                result += ")";
            }
            else
            {
                result += ") ";
            }
        }

        result += "\n";
    }

    // Make a visual representation in text.
    result += "\n";

//    // Add the top.
//    result += "+";
//    for (int i = 0; i < this->width; i++)
//    {
//        result += "-+";
//    }
//    result += "+\n";
//
//    for (int i = 0; i < this->height; i++)
//    {
//        result += "|";
//        for (int j = 0; j < this->width; j++)
//        {
//            if (this->data[i][j]->get_east_wall() == WALL_CLOSED)
//            {
//                result += " |";
//            }
//            else
//            {
//                result += "  ";
//            }
//        }
//        result += "|";
//
//        result += "\n";
//
//        result += "+";
//        for (int j = 0; j < this->width; j++)
//        {
//            if (this->data[i][j]->get_south_wall() == WALL_CLOSED)
//            {
//                result += "-+";
//            }
//            else
//            {
//                result += " +";
//            }
//        }
//        result += "+\n";
//    }

    for (int i = 0; i < this->height; i++)
    {
        for (int j = 0; j < this->width; j++)
        {
            if (this->data[i][j]->get_north_wall() == WALL_CLOSED)
            {
                result += "+---+";
            }
            else
            {
                result += "+   +";
            }

            if (j != this->width - 1)
            {
                result += " ";
            }
        }

        result += "\n";

        for (int j = 0; j < this->width; j++)
        {
            if (this->data[i][j]->get_west_wall() == WALL_CLOSED)
            {
                result += "|";
            }
            else
            {
                result += " ";
            }

            result += "   ";

            if (this->data[i][j]->get_east_wall() == WALL_CLOSED)
            {
                result += "|";
            }
            else
            {
                result += " ";
            }

            if (j != this->width - 1)
            {
                result += " ";
            }
        }

        result += "\n";

        for (int j = 0; j < this->width; j++)
        {
            if (this->data[i][j]->get_south_wall() == WALL_CLOSED)
            {
                result += "+---+";
            }
            else
            {
                result += "+   +";
            }

            if (j != this->width - 1)
            {
                result += " ";
            }
        }

        result += "\n";
    }

    return result;
}

char ** Maze::make_map()
{
//    printf("this->get_height(): %d\n", this->get_height());
//    printf("this->get_width(): %d\n", this->get_width());

    int map_height = (this->get_height() * 2) + 1;
    int map_width = (this->get_width() * 2) + 1;

//    printf("map_height: %d\n", map_height);
//    printf("map_width: %d\n", map_width);
//
//    printf("\n");

//    char map[map_height][map_width];

    char ** map = (char **)malloc(sizeof(char *) * map_height);

    for (int i = 0; i < map_height; i++)
    {
        map[i] = (char *)malloc(sizeof(char) * map_width);
    }

    // Fill the map.
    for (int i = 0; i < map_height; i++)
    {
        for (int j = 0; j < map_width; j++)
        {
            map[i][j] = ' ';
        }
    }

    // Put the border of the map.
    for (int i = 0; i < map_height; i++)
    {
        for (int j = 0; j < map_width; j++)
        {
            if (i == 0)
            {
                map[i][j] = '#';
            }

            if (j == 0)
            {
                map[i][j] = '#';
            }

            if (i == map_height - 1)
            {
                map[i][j] = '#';
            }

            if (j == map_width - 1)
            {
                map[i][j] = '#';
            }
        }
    }

    // Fill the corners.
    for (int i = 2; i < map_height; i += 2)
    {
        for (int j = 2; j < map_width; j += 2)
        {
            map[i][j] = '#';
        }
    }

    int map_i = 1;
    int map_j = 2;

    for (int i = 0; i < this->get_height(); i++)
    {
        for (int j = 0; j < this->get_width(); j++)
        {
            if (this->data[i][j]->get_east_wall() == WALL_CLOSED && j != this->get_width() - 1)
            {
                map[map_i][map_j] = '#';
//                map[map_i + 1][map_j] = '#';

//                printf("(i, j): (%d, %d)\n", i, j);
//                printf("(map_i, map_j): (%d, %d)\n", map_i, map_j);
            }

            if (this->data[i][j]->get_south_wall() == WALL_CLOSED && i != this->get_height() - 1)
            {
                map[map_i + 1][map_j - 1] = '#';
//                map[map_i + 1][map_j] = '#';

//                printf("(i, j): (%d, %d)\n", i, j);
//                printf("(map_i + 1, map_j - 1): (%d, %d)\n", map_i + 1, map_j - 1);
            }

            map_j += 2;
        }

        map_i += 2;
        map_j = 2;
    }

    // Print the map.
//    for (int i = 0; i < map_height; i++)
//    {
//        for (int j = 0; j < map_width; j++)
//        {
//            printf("%c ", map[i][j]);
//        }
//        printf("\n");
//    }

    return map;
}

// Populate the Maze object with a maze using the specified algorithm.
void Maze::generate_maze(maze_algorithm_t maze_algorithm)
{
    if (maze_algorithm == MAZE_ALGORITHM_BINARY_TREE)
    {
        this->use_binary_tree_algorithm();
    }
    else if (maze_algorithm == MAZE_ALGORITHM_SIDEWINDER)
    {
        this->use_sidewinder_algorithm();
    }
    else if (maze_algorithm == MAZE_ALGORITHM_ALDOUS_BRODER)
    {
        this->use_aldous_broder_algorithm();
    }
    else
    {
        printf("Error: Invalid maze algorithm.\n");
    }
}

void Maze::use_binary_tree_algorithm()
{
    // Seed the random number generator with the time.
    srand((unsigned int)time(NULL));

    // Go through all the cells, starting at the southwest (lower left) corner.
    for (int i = this->height - 1; i >= 0; i--)
    {
        for (int j = 0; j < this->width; j++)
        {
            // Check if we're at the top right corner of the grid.
            if (i == 0 && j == this->width - 1)
            {
                // Don't really do anything in this case.
            }
            // Check if we're at the top of the grid.
            else if (i == 0)
            {
                // Clear the east wall (right).
                this->data[i][j]->set_east_wall(WALL_OPEN);

                // Check that not at right side yet.
                if (j < this->width - 1)
                {
                    // Go ahead and open the west wall of the cell to the right.
                    this->data[i][j + 1]->set_west_wall(WALL_OPEN);
                }
            }
            // Check if we're at the right side of the grid.
            else if (j == this->width - 1)
            {
                // Clear the north wall (top).
                this->data[i][j]->set_north_wall(WALL_OPEN);

                // Check that not at top yet.
                if (i > 0)
                {
                    // Go ahead and open the south wall of the cell above.
                    this->data[i - 1][j]->set_south_wall(WALL_OPEN);
                }
            }
            else
            {
                // Choose a random number to decide between south and east wall.
                unsigned int choice = rand() % 2;

                // Check if the choice is the north wall.
                if (choice == 0)
                {
                    // Open the south wall.
                    this->data[i][j]->set_north_wall(WALL_OPEN);

                    // Check that not at top yet.
                    if (i > 0)
                    {
                        // Go ahead and open the south wall of the cell above.
                        this->data[i - 1][j]->set_south_wall(WALL_OPEN);
                    }
                }
                // Otherwise the choice must be the east wall.
                else
                {
                    // Open the east wall.
                    this->data[i][j]->set_east_wall(WALL_OPEN);

                    // Check that not at right side yet.
                    if (j < this->width - 1)
                    {
                        // Go ahead and open the west wall of the cell to the right.
                        this->data[i][j + 1]->set_west_wall(WALL_OPEN);
                    }
                }
            }
        }
    }
}

void Maze::use_sidewinder_algorithm()
{

}

void Maze::use_aldous_broder_algorithm()
{
    // Seed the random number generator.
    srand((unsigned int)time(NULL));

    // Choose a random row index.
    unsigned int i = rand() % this->height;

    // Choose a random column index.
    unsigned int j = rand() % this->width;

    // Keep track of the previous location.
    unsigned int previous_i = i;
    unsigned int previous_j = j;

    direction_t direction = DIRECTION_NORTH;

    // Repeat while not all cells have been visited.
    while (!this->all_cells_visited())
    {
        // Check whether this cell is visited.
        if (!this->data[i][j]->get_visited())
        {
            // Set this cell to visited.
            this->data[i][j]->set_visited(true);

            if (i != previous_i || j != previous_j)
            {
                switch (direction)
                {
                    case DIRECTION_NORTH:
                        this->data[previous_i][previous_j]->set_north_wall(WALL_OPEN);
                        this->data[i][j]->set_south_wall(WALL_OPEN);
                        break;
                    case DIRECTION_SOUTH:
                        this->data[previous_i][previous_j]->set_south_wall(WALL_OPEN);
                        this->data[i][j]->set_north_wall(WALL_OPEN);
                        break;
                    case DIRECTION_WEST:
                        this->data[previous_i][previous_j]->set_west_wall(WALL_OPEN);
                        this->data[i][j]->set_east_wall(WALL_OPEN);
                        break;
                    case DIRECTION_EAST:
                        this->data[previous_i][previous_j]->set_east_wall(WALL_OPEN);
                        this->data[i][j]->set_west_wall(WALL_OPEN);
                        break;
                }
            }
        }

        // Check for northwest corner.
        if (i == 0 && j == 0)
        {
            // Choose between south and east.
            unsigned int choice = rand() % 2;

            if (choice == 0)
            {
                direction = DIRECTION_SOUTH;
            }
            else
            {
                direction = DIRECTION_EAST;
            }
        }
        // Check for northeast corner.
        else if (i == 0 && j == this->width - 1)
        {
            // Choose between south and west.
            unsigned int choice = rand() % 2;

            if (choice == 0)
            {
                direction = DIRECTION_SOUTH;
            }
            else
            {
                direction = DIRECTION_WEST;
            }
        }
        // Check for southwest corner.
        else if (i == this->height - 1 && j == 0)
        {
            // Choose between north and east.
            unsigned int choice = rand() % 2;

            if (choice == 0)
            {
                direction = DIRECTION_NORTH;
            }
            else
            {
                direction = DIRECTION_EAST;
            }
        }
        // Check for southeast corner.
        else if (i == this->height - 1 && j == this->width - 1)
        {
            // Choose between north and west.
            unsigned int choice = rand() % 2;

            if (choice == 0)
            {
                direction = DIRECTION_NORTH;
            }
            else
            {
                direction = DIRECTION_WEST;
            }
        }
        // Check for being at the top.
        else if (i == 0)
        {
            // Choose between south, east, and west.
            unsigned int choice = rand() % 3;

            if (choice == 0)
            {
                direction = DIRECTION_SOUTH;
            }
            else if (choice == 1)
            {
                direction = DIRECTION_EAST;
            }
            else
            {
                direction = DIRECTION_WEST;
            }
        }
        // Check for being at the bottom.
        else if (i == this->height - 1)
        {
            // Choose between north, east, and west.
            unsigned int choice = rand() % 3;

            if (choice == 0)
            {
                direction = DIRECTION_NORTH;
            }
            else if (choice == 1)
            {
                direction = DIRECTION_EAST;
            }
            else
            {
                direction = DIRECTION_WEST;
            }
        }
        // Check for being at the right edge.
        else if (j == this->width - 1)
        {
            // Choose between north, south, and east.
            unsigned int choice = rand() % 3;

            if (choice == 0)
            {
                direction = DIRECTION_NORTH;
            }
            else if (choice == 1)
            {
                direction = DIRECTION_SOUTH;
            }
            else
            {
                direction = DIRECTION_WEST;
            }
        }
        // Check for being at the left edge.
        else if (j == 0)
        {
            // Choose between north, south, and west.
            unsigned int choice = rand() % 3;

            if (choice == 0)
            {
                direction = DIRECTION_NORTH;
            }
            else if (choice == 1)
            {
                direction = DIRECTION_SOUTH;
            }
            else
            {
                direction = DIRECTION_EAST;
            }
        }
        // Otherwise, assume interior.
        else
        {
            unsigned int choice = rand() % 4;

            if (choice == 0)
            {
                direction = DIRECTION_NORTH;
            }
            else if (choice == 1)
            {
                direction = DIRECTION_SOUTH;
            }
            else if (choice == 2)
            {
                direction = DIRECTION_EAST;
            }
            else
            {
                direction = DIRECTION_WEST;
            }
        }

        // Store the current indices.
        previous_i = i;
        previous_j = j;

        if (direction == DIRECTION_NORTH)
        {
            i = i - 1;
        }
        else if (direction == DIRECTION_SOUTH)
        {
            i = i + 1;
        }
        else if (direction == DIRECTION_WEST)
        {
            j = j - 1;
        }
        else if (direction == DIRECTION_EAST)
        {
            j = j + 1;
        }
        else
        {
            printf("Error: Invalid direction.\n");
        }
    }
}

bool Maze::all_cells_visited()
{
    // Assume all cells have been visited.
    bool result = true;

    // Go through each cell.
    for (int i = 0; i < this->height; i++)
    {
        for (int j = 0; j < this->width; j++)
        {
            // Check if this cell is unvisited.
            if (!this->data[i][j]->get_visited())
            {
                // Set the result to false.
                result = false;

                // Exit the inner loop.
                break;
            }
        }

        // Exit the outer loop.
        if (!result)
        {
            break;
        }
    }

    // Return the result.
    return result;
}
