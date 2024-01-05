using StaticArrays

const UP = SVector(0, -1)
const DOWN = SVector(0, 1)
const LEFT = SVector(-1, 0)
const RIGHT = SVector(1, 0)

mutable struct Beam
    position::SVector{2,Int}
    direction::SVector{2,Int}
end

function reflectonmirror1(direction::SVector{2,Int}) # /
    if direction == UP
        return RIGHT
    elseif direction == DOWN
        return LEFT
    elseif direction == LEFT
        return DOWN
    elseif direction == RIGHT
        return UP
    end
end

function reflectonmirror2(direction::SVector{2,Int}) # \
    if direction == UP
        return LEFT
    elseif direction == DOWN
        return RIGHT
    elseif direction == LEFT
        return UP
    elseif direction == RIGHT
        return DOWN
    end
end

function getnumberofenergized(tiles::Vector{String}, beam::Beam)
    beams = [beam]
    energized = zeros(UInt, length(tiles), length(tiles[1]))
    visiteddirections = Dict{SVector{2,Int}, Set{SVector{2,Int}}}()
    while length(beams) > 0
        currentposition = beams[1].position
        if currentposition[1] < 1 || currentposition[1] > length(tiles[1]) || currentposition[2] < 1 || currentposition[2] > length(tiles)
            popfirst!(beams)
        else
            currentbeam = beams[1]
            tile = tiles[currentposition[2]][currentposition[1]]
            energized[currentposition[2], currentposition[1]] = one(UInt)
            if currentposition in keys(visiteddirections)
                push!(visiteddirections[currentposition], currentbeam.direction)
            else
                visiteddirections[currentposition] = Set([currentbeam.direction])
            end

            if tile == '|' && currentbeam.direction[1] != 0
                currentbeam.direction = UP
                push!(beams, Beam(currentposition, DOWN))
            elseif tile == '-' && currentbeam.direction[2] != 0
                currentbeam.direction = LEFT
                push!(beams, Beam(currentposition, RIGHT))
            elseif tile == '/'
                currentbeam.direction = reflectonmirror1(currentbeam.direction)
            elseif tile == '\\'
                currentbeam.direction = reflectonmirror2(currentbeam.direction)
            end

            newposition = currentposition + currentbeam.direction
            if newposition in keys(visiteddirections) && currentbeam.direction in visiteddirections[newposition]
                popfirst!(beams)
            else
                currentbeam.position = newposition
            end
        end
    end
    return sum(energized)
end

function part1()
    lines = open("input/day16.txt") do f
        return readlines(f)
    end

    return getnumberofenergized(lines, Beam(SVector(1, 1), RIGHT))
end

function part2()
    lines = open("input/day16.txt") do f
        return readlines(f)
    end

    maximumenergized = zero(UInt)
    for row in eachindex(lines)
        fromleft = getnumberofenergized(lines, Beam(SVector(1, row), RIGHT))
        fromright = getnumberofenergized(lines, Beam(SVector(length(lines[row]), row), LEFT))
        maximumenergized = max(maximumenergized, fromleft, fromright)
    end

    for col in eachindex(lines[1])
        fromtop = getnumberofenergized(lines, Beam(SVector(col, 1), DOWN))
        frombottom = getnumberofenergized(lines, Beam(SVector(col, length(lines)), UP))
        maximumenergized = max(maximumenergized, fromtop, frombottom)
    end
    return maximumenergized
end

ans1 = part1()
println(ans1)
ans2 = part2()
println(ans2)
