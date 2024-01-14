using StaticArrays

"""
Represent a brick with a unique `id` and the `positions` of all the cubes.
"""
mutable struct Brick
    id::Int
    positions::Vector{MVector{3,Int}}
end

"""
Return whether the `brick` is standing vertically.
"""
isvertical(brick::Brick) = brick.positions[1][3] != brick.positions[end][3]

"""
Return the z component of the lowest cube of `brick`.
"""
lowest(brick::Brick) = minimum(p -> p[3], brick.positions)

"""
Return a `Brick` with `id` and the `positions` specified in `str`.
"""
function fromstring(str::AbstractString, id::Int)
    (start, ende) = split(str, '~')
    startpos = parse.(Int, split(start, ','))
    endpos = parse.(Int, split(ende, ','))
    positions = Vector{MVector{3,Int}}()
    for x in startpos[1]:endpos[1]
        for y in startpos[2]:endpos[2]
            for z in startpos[3]:endpos[3]
                push!(positions, MVector(x + 1, y + 1, z)) # shift coordinates to be >= 1
            end
        end
    end
    return Brick(id, positions)
end

"""
Return whether the `brick` can fall within the specified `world` if `removedbrick` (or
all bricks in `removedbricks`) was removed.
"""
function canfall(brick::Brick, world::Array{Int,3}, removedbrick::Brick)
    if lowest(brick) == 1
        return false
    end
    if isvertical(brick)
        position = brick.positions[1]
        return world[position[1], position[2], position[3]-1] == 0 ||
               world[position[1], position[2], position[3]-1] == removedbrick.id
    end
    for position in brick.positions
        if world[position[1], position[2], position[3]-1] != 0 &&
           world[position[1], position[2], position[3]-1] != removedbrick.id
            return false
        end
    end
    return true
end

canfall(brick::Brick, world::Array{Int,3}) =
    canfall(brick, world, Brick(0, Vector{MVector{3,Int}}()))

function canfall(brick::Brick, world::Array{Int,3}, removedbricks::Set{Brick})
    if lowest(brick) == 1
        return false
    end
    removedids = [b.id for b in removedbricks]
    push!(removedids, 0)
    if isvertical(brick)
        position = brick.positions[1]
        return any(id -> world[position[1], position[2], position[3]-1] == id, removedids)
    end
    for position in brick.positions
        if all(id -> world[position[1], position[2], position[3]-1] != id, removedids)
            return false
        end
    end
    return true
end

"""
Change `brick` and `world` according to `brick` falling one step in z direction.
"""
function fall!(brick::Brick, world::Array{Int,3})
    for position in brick.positions
        world[position...] = 0
        position[3] -= 1
        world[position...] = brick.id
    end
end

function part1()
    lines = open("input/day22.txt") do f
        return readlines(f)
    end

    xmax = 1
    ymax = 1
    zmax = 1
    bricks = Vector{Brick}(undef, length(lines))
    for (i, line) in enumerate(lines)
        bricks[i] = fromstring(line, i)
        xmax = max(xmax, maximum(p -> p[1], bricks[i].positions))
        ymax = max(ymax, maximum(p -> p[2], bricks[i].positions))
        zmax = max(zmax, maximum(p -> p[3], bricks[i].positions))
    end

    sort!(bricks, by = lowest)

    world = zeros(Int, xmax, ymax, zmax)
    for brick in bricks
        for position in brick.positions
            world[position...] = brick.id
        end
    end

    for brick in bricks
        while canfall(brick, world)
            fall!(brick, world)
        end
    end

    totalsafetodisintegrate = 0
    for bricktodisintegrate in bricks
        safetodisintegrate = true
        for brick in bricks
            if brick == bricktodisintegrate
                continue
            end
            safetodisintegrate =
                safetodisintegrate && !canfall(brick, world, bricktodisintegrate)
        end
        if safetodisintegrate
            totalsafetodisintegrate += 1
        end
    end
    return totalsafetodisintegrate
end

function part2()
    lines = open("input/day22.txt") do f
        return readlines(f)
    end

    xmax = 1
    ymax = 1
    zmax = 1
    bricks = Vector{Brick}(undef, length(lines))
    for (i, line) in enumerate(lines)
        bricks[i] = fromstring(line, i)
        xmax = max(xmax, maximum(p -> p[1], bricks[i].positions))
        ymax = max(ymax, maximum(p -> p[2], bricks[i].positions))
        zmax = max(zmax, maximum(p -> p[3], bricks[i].positions))
    end

    sort!(bricks, by = lowest)

    world = zeros(Int, xmax, ymax, zmax)
    for brick in bricks
        for position in brick.positions
            world[position...] = brick.id
        end
    end

    for brick in bricks
        while canfall(brick, world)
            fall!(brick, world)
        end
    end

    totalfalling = 0
    for bricktodisintegrate in bricks
        removedbricks = Set([bricktodisintegrate])
        fallingsbricks = true
        while fallingsbricks
            fallingsbricks = false
            for brick in bricks
                if brick in removedbricks
                    continue
                elseif canfall(brick, world, removedbricks)
                    push!(removedbricks, brick)
                    fallingsbricks = true
                end
            end
        end
        totalfalling += length(removedbricks) - 1
    end
    return totalfalling
end

ans1 = part1()
println(ans1)
ans2 = part2()
println(ans2)
