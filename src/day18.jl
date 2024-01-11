using LinearAlgebra
using StaticArrays

const DIRECTION_VECS = Dict{String,SVector{2,Int}}(
    "U" => SVector(0, -1),
    "D" => SVector(0, 1),
    "L" => SVector(-1, 0),
    "R" => SVector(1, 0),
)

const DIRECTION_FROM_HEX = Dict{Char,SVector{2,Int}}(
    '0' => SVector(1, 0),
    '1' => SVector(0, 1),
    '2' => SVector(-1, 0),
    '3' => SVector(0, -1),
)

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
Return the sum of all edge lengths of a polygon with the vertices in `coordinates`.
"""
function edgelength(coordinates::Vector{SVector{2,Int}})
    sum = 0
    for i in 1:length(coordinates)-1
        edge = coordinates[i+1] - coordinates[i]
        sum += abs(edge[1]) + abs(edge[2])
    end
    edge = coordinates[end] - coordinates[1]
    sum += abs(edge[1]) + abs(edge[2])
    return sum
end

function part1()
    lines = open("input/day18.txt") do f
        return readlines(f)
    end

    directions = Vector{String}(undef, length(lines))
    steps = Vector{Int}(undef, length(lines))
    for (i, line) in enumerate(lines)
        (direction, step, _rgb) = split(line)
        directions[i] = direction
        steps[i] = parse(Int, step)
    end

    polygonpoints = Vector{SVector{2,Int}}(undef, length(directions) + 1)
    polygonpoints[1] = SVector(1, 1)
    for (i, (direction, step)) in enumerate(zip(directions, steps))
        polygonpoints[i+1] = polygonpoints[i] + step * DIRECTION_VECS[direction]
    end
    unique!(polygonpoints)
    return shoelace(polygonpoints) + edgelength(polygonpoints) ÷ 2 + 1
end

function part2()
    lines = open("input/day18.txt") do f
        return readlines(f)
    end

    directions = Vector{SVector{2,Int}}(undef, length(lines))
    steps = Vector{Int}(undef, length(lines))
    for (i, line) in enumerate(lines)
        (_dir, _step, hex) = split(line)
        stephex = hex[3:7]
        steps[i] = parse(Int, stephex, base = 16)
        directionhex = hex[8]
        directions[i] = DIRECTION_FROM_HEX[directionhex]
    end

    polygonpoints = Vector{SVector{2,Int}}(undef, length(directions) + 1)
    polygonpoints[1] = SVector(1, 1)
    for (i, (direction, step)) in enumerate(zip(directions, steps))
        polygonpoints[i+1] = polygonpoints[i] + step * direction
    end
    unique!(polygonpoints)
    return shoelace(polygonpoints) + edgelength(polygonpoints) ÷ 2 + 1
end

ans1 = part1()
println(ans1)
ans2 = part2()
println(ans2)
