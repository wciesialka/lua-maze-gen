require('MazeGenerator')

function classify(v)
    s = ""
    if v & MAZE_WEST == MAZE_WEST then
        s = s .. "|"
    else
        s = s .. " "
    end

    if v & MAZE_NORTH == MAZE_NORTH then
        if v & MAZE_SOUTH == MAZE_SOUTH then
            s = s .. "\u{2050}"
        else
            s = s .. "\u{23ba}"
        end
    elseif v & MAZE_SOUTH == MAZE_SOUTH then
        s = s .. "\u{23af}"
    else
        s = s .. " "
    end

    if v & MAZE_EAST == MAZE_EAST then
        s = s .. "|"
    else
        s = s .. " "
    end

    return s
end

size = arg[1]
if size == nil then size = 5 end

maze = GenerateMaze(size)

for i,v in pairs(maze) do
    io.write(classify(v))
    if i % size == 0 then print() end
end