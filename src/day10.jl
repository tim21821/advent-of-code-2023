using LinearAlgebra
using StaticArrays

const NORTH = SVector(0, -1)
const SOUTH = SVector(0, 1)
const EAST = SVector(1, 0)
const WEST = SVector(-1, 0)

const TILE_DIRECTIONS = Dict{Char,Tuple{SVector{2,Int},SVector{2,Int}}}(
    '|' => (NORTH, SOUTH),
    '-' => (EAST, WEST),
    'L' => (NORTH, EAST),
    'J' => (NORTH, WEST),
    '7' => (SOUTH, WEST),
    'F' => (SOUTH, EAST),
)

"""
Return the tile at `position` from `grid`.
"""
function gettile(position::SVector{2,Int}, grid::Vector{Vector{Char}})
    return grid[position[2]][position[1]]
end

"""
Return the position of the tile `c` in the `grid`.
"""
function findtile(c::Char, grid::Vector{Vector{Char}})
    y = findfirst(e -> c in e, grid)
    x = findfirst(e -> e == c, grid[y])
    return SVector(x, y)
end

"""
Replace the `'S'` at `position` inside the `grid` with the appropriate tile.
"""
function replaceS!(grid::Vector{Vector{Char}}, position::SVector{2,Int})
    tilenorth = position[2] > 1 ? grid[position[2]-1][position[1]] : 'X'
    tilesouth = position[2] < length(grid) ? grid[position[2]+1][position[1]] : 'X'
    tileeast =
        position[1] < length(grid[position[2]]) ? grid[position[2]][position[1]+1] : 'X'
    tilewest = position[1] > 1 ? grid[position[2]][position[1]-1] : 'X'

    northaccessible = tilenorth == '|' || tilenorth == '7' || tilenorth == 'F'
    southaccessible = tilesouth == '|' || tilesouth == 'L' || tilesouth == 'J'
    eastaccessible = tileeast == '-' || tileeast == 'J' || tileeast == '7'
    westaccessible = tilewest == '-' || tilewest == 'L' || tilewest == 'F'

    if northaccessible && southaccessible
        grid[position[2]][position[1]] = '|'
    elseif eastaccessible && westaccessible
        grid[position[2]][position[1]] = '-'
    elseif northaccessible && eastaccessible
        grid[position[2]][position[1]] = 'L'
    elseif northaccessible && westaccessible
        grid[position[2]][position[1]] = 'J'
    elseif southaccessible && westaccessible
        grid[position[2]][position[1]] = '7'
    elseif southaccessible && eastaccessible
        grid[position[2]][position[1]] = 'F'
    end
end

"""
Return the area of the polygon described by `coordinates` using the shoelace formula.
"""
function shoelace(coordinates::Vector{SVector{2,Int}})
    sum = 0
    for i in 1:length(coordinates)-1
        matrix = hcat(coordinates[i], coordinates[i+1])
        sum += Int(det(matrix))
    end
    matrix = hcat(coordinates[end], coordinates[1])
    sum += Int(det(matrix))
    return abs(sum) ÷ 2
end

"""
Return the number of innerpoints using Pick's theorem based on the `area` and number of
`boundarypoints`.
"""
function innerpointspicks(area::Int, boundarypoints::Int)
    return area + 1 - (boundarypoints ÷ 2)
end

function part1()
    lines = open("input/day10.txt") do f
        return readlines(f)
    end

    grid = collect.(lines)
    visited = fill(false, length(grid), length(grid[1]))
    steps = 0
    currentposition = findtile('S', grid)
    replaceS!(grid, currentposition)
    while !(visited[currentposition[2], currentposition[1]])
        visited[currentposition[2], currentposition[1]] = true
        directions = TILE_DIRECTIONS[gettile(currentposition, grid)]
        turn1 = currentposition + directions[1]
        if !(visited[turn1[2], turn1[1]])
            currentposition = turn1
        else
            currentposition = currentposition + directions[2]
        end
        steps += 1
    end
    return steps ÷ 2
end

function part2()
    lines = open("input/day10.txt") do f
        return readlines(f)
    end

    grid = collect.(lines)
    coordinates = Vector{SVector{2,Int}}()
    currentposition = findtile('S', grid)
    replaceS!(grid, currentposition)
    while !(currentposition in coordinates)
        push!(coordinates, currentposition)
        directions = TILE_DIRECTIONS[gettile(currentposition, grid)]
        turn1 = currentposition + directions[1]
        if !(turn1 in coordinates)
            currentposition = turn1
        else
            currentposition = currentposition + directions[2]
        end
    end

    area = shoelace(coordinates)
    return innerpointspicks(area, length(coordinates))
end

ans1 = part1()
println(ans1)
ans2 = part2()
println(ans2)
