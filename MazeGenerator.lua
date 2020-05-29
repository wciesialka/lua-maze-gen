require('Stack')

MAZE_VISITED = 1
MAZE_NORTH = 1 << 1
MAZE_EAST = 1 << 2
MAZE_WEST = 1 << 3
MAZE_SOUTH = 1 << 4

function GenerateMaze(n)
    n = tonumber(n)
    math.randomseed(os.time())

    local stk = Stack()

    -- get place in table from x and y
    function i(x,y)
        return ((y*n) + x) + 1
    end

    -- get x and y from place in table
    function xy(v)
        local v2 = v - 1
        return {x= (v2%n), y= math.floor( v2/n )}
    end

    local grid = {}
    for x = 1, n*n do
        grid[x] = MAZE_NORTH | MAZE_EAST | MAZE_SOUTH | MAZE_WEST
    end
    local current_cell = 1
    grid[current_cell] = grid[current_cell] | MAZE_VISITED
    stk:Push(current_cell)

    local done = false

    while not done do
        current_cell = stk:Pop()
        local loc = xy(current_cell)
        local gen_rand = true
        local stuck = false
        local next_cell

        local choices = {0,1,2,3}

        while gen_rand do

            gen_rand = false

            if #choices == 0 then
                -- no more choices, all nearby MAZE_VISITED
                stuck = true
            else
                local rand = math.random( 1, #choices )
                local to_visit = choices[rand]
                local new_i

                if to_visit == 0 then
                    new_i = i(loc.x + 1,loc.y)
                elseif to_visit == 1 then
                    new_i = i(loc.x - 1,loc.y)
                elseif to_visit == 2 then
                    new_i = i(loc.x,loc.y + 1)
                elseif to_visit == 3 then
                    new_i = i(loc.x,loc.y - 1)
                end

                new_loc = xy(new_i)

                if (new_loc.x >= 0) and (new_loc.x < n) and (new_loc.y >= 0) and (new_loc.y < n) then
                    if grid[new_i] & MAZE_VISITED == MAZE_VISITED then
                        gen_rand = true
                    else
                        new_cell = new_i
                    end
                else
                    gen_rand = true
                end

                if gen_rand then
                    table.remove( choices, rand )
                end
            end
        end -- end while gen_rand

        if stuck then
            if stk:Is_Empty() then
                done = true
            end
        else
            stk:Push(current_cell)
            
            local cloc = xy(new_cell)

            if cloc.x > loc.x then
                -- new cell is further right
                grid[current_cell] = grid[current_cell] & (~MAZE_EAST)
                grid[new_cell] = grid[new_cell] & (~MAZE_WEST)
            elseif cloc.x < loc.x then
                -- new cell is further left
                grid[current_cell] = grid[current_cell] & (~MAZE_WEST)
                grid[new_cell] = grid[new_cell] & (~MAZE_EAST)
            elseif cloc.y < loc.y then
                -- new cell is further north
                grid[current_cell] = grid[current_cell] & (~MAZE_NORTH)
                grid[new_cell] = grid[new_cell] & (~MAZE_SOUTH)
            else
                -- new cell is further south
                grid[current_cell] = grid[current_cell] & (~MAZE_SOUTH)
                grid[new_cell] = grid[new_cell] & (~MAZE_NORTH)   
            end
            grid[new_cell] = grid[new_cell] | MAZE_VISITED
            stk:Push(new_cell)
        end
    end

    -- pick entrance and exit

    local entrance = math.random( 0, n-1 )
    local exit = math.random( 0, n-1 )

    local entrance_i = i(entrance,n-1)
    local exit_i = i(exit,0)

    grid[entrance_i] = grid[entrance_i] & (~MAZE_SOUTH)
    grid[exit_i] = grid[exit_i] & (~MAZE_NORTH)

    return grid
end