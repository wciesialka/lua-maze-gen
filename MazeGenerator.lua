require('Stack')

MAZE_VISITED = 1
MAZE_NORTH = 1 << 1
MAZE_EAST = 1 << 2
MAZE_WEST = 1 << 3
MAZE_SOUTH = 1 << 4

function mazechar(v)
    s = ""
    if bit32.band(v,MAZE_WEST) == MAZE_WEST then
        s = s .. "|"
    else
        s = s .. " "
    end

    if bit32.band(v,MAZE_NORTH) == MAZE_NORTH then
        if bit32.band(v,MAZE_SOUTH) == MAZE_SOUTH then
            s = s .. "\u{2050}"
        else
            s = s .. "\u{23ba}"
        end
    elseif bit32.band(v,MAZE_SOUTH) == MAZE_SOUTH then
        s = s .. "\u{23af}"
    else
        s = s .. " "
    end

    if bit32.band(v,MAZE_EAST) == MAZE_EAST then
        s = s .. "|"
    else
        s = s .. " "
    end

    return s
end

function GenerateMaze(n,debug)
    n = tonumber(n)
    if debug == nil then debug = false end

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
        grid[x] = bit32.bor(MAZE_NORTH, MAZE_EAST, MAZE_SOUTH, MAZE_WEST)
    end
    local current_cell = 1
    grid[current_cell] = bit32.bor(grid[current_cell], MAZE_VISITED)
    stk:Push(current_cell)

    local done = false

    while not done do
        if debug then 
            for i,v in pairs(grid) do
                if i == current_cell then
                    io.write('|\u{2588}|')
                else
                    io.write(mazechar(v))
                end
                if i % size == 0 then print() end
            end
            io.stdin:read'*l' 
        end
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
                local new_i, new_loc

                if to_visit == 0 then
                    new_loc = {x=loc.x,y=loc.y - 1}
                elseif to_visit == 1 then
                    new_loc = {x=loc.x+1,y=loc.y}
                elseif to_visit == 2 then
                    new_loc = {x=loc.x,y=loc.y+1}
                elseif to_visit == 3 then
                    new_loc = {x=loc.x-1,y=loc.y}
                end

                if (new_loc.x >= 0) and (new_loc.x < n) and (new_loc.y >= 0) and (new_loc.y < n) then
                    new_i = i(new_loc.x,new_loc.y)
                    if bit32.band(grid[new_i],MAZE_VISITED) == MAZE_VISITED then
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
                grid[current_cell] = bit32.band(grid[current_cell], bit32.bnot(MAZE_EAST))
                grid[new_cell] = bit32.band(grid[new_cell],bit32.bnot(MAZE_WEST))
            elseif cloc.x < loc.x then
                -- new cell is further left
                grid[current_cell] = bit32.band(grid[current_cell], bit32.bnot(MAZE_WEST))
                grid[new_cell] = bit32.band(grid[new_cell],bit32.bnot(MAZE_EAST))
            elseif cloc.y < loc.y then
                -- new cell is further north
                grid[current_cell] = bit32.band(grid[current_cell], bit32.bnot(MAZE_NORTH))
                grid[new_cell] = bit32.band(grid[new_cell],bit32.bnot(MAZE_SOUTH))
            else
                -- new cell is further south
                grid[current_cell] = bit32.band(grid[current_cell], bit32.bnot(MAZE_SOUTH))
                grid[new_cell] = bit32.band(grid[new_cell],bit32.bnot(MAZE_NORTH))
            end
            grid[new_cell] = bit32.bor(grid[new_cell],MAZE_VISITED)
            stk:Push(new_cell)
        end
    end

    -- pick entrance and exit

    local entrance = math.random( 0, n-1 )
    local exit = math.random( 0, n-1 )

    local entrance_i = i(entrance,n-1)
    local exit_i = i(exit,0)

    grid[entrance_i] = bit32.band(grid[entrance_i],bit32.bnot(MAZE_SOUTH))
    grid[exit_i] = bit32.band(grid[exit_i], bit32.bnot(MAZE_NORTH))

    return grid
end