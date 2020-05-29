require('Stack')

MAZE_VISITED = 1
MAZE_NORTH = 1 << 1
MAZE_EAST = 1 << 2
MAZE_WEST = 1 << 3
MAZE_SOUTH = 1 << 4

function GenerateMaze(n)

    math.randomseed(os.time())

    local stk = Stack()

    function i(x,y)
        return ((y*n) + x) + 1
    end

    function xy(v)
        v = v - 1
        return {x= (v%n), y= math.floor( v/n )}
    end

    local grid = {}
    for x = 1, n*n do
        grid[x] = MAZE_NORTH | MAZE_EAST | MAZE_WEST | MAZE_SOUTH
    end
    local current_cell = 1
    grid[current_cell] = grid[current_cell] | MAZE_VISITED
    stk:Push(current_cell)

    while not stk:Is_Empty() do
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

                if new_i >= 1 and new_i <= #grid then
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

        if not stuck then
            stk:Push(current_cell)
            local wall = 0
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
                -- new cell is further MAZE_NORTH
                grid[current_cell] = grid[current_cell] & (~MAZE_NORTH)
                grid[new_cell] = grid[new_cell] & (~MAZE_SOUTH)
            else
                -- new cell is further MAZE_SOUTH
                grid[current_cell] = grid[current_cell] & (~MAZE_SOUTH)
                grid[new_cell] = grid[new_cell] & (~MAZE_NORTH)   
            end
            grid[new_cell] = grid[new_cell] | MAZE_VISITED
            stk:Push(new_cell)
        end
    end

    return grid
end