require('MazeGenerator')

size = arg[1]
if size == nil then size = 5 end

maze = GenerateMaze(size,false)

for i,v in pairs(maze) do
    io.write(classify(v))
    if i % size == 0 then print() end
end