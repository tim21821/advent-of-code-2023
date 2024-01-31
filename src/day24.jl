using LinearAlgebra

"""
Represent a hailstone by its initial `position` and velocity.
"""
struct Hailstone
    position::Vector{Int}
    velocity::Vector{Int}
end

"""
Construct a `Hailstone` from a String.
"""
function fromstring(str::AbstractString)
    (p, v) = split(str, " @ ")
    pos = parse.(Int, split(p, ", "))
    velo = parse.(Int, split(v, ", "))
    return Hailstone(pos, velo)
end

"""
Return the times (one for each `Hailstone`) when the `Hailstone`s have identical x and y
coordinates.
"""
function intersectiontimes2d(stone1::Hailstone, stone2::Hailstone)
    velmatrix = hcat(stone1.velocity[1:2], stone2.velocity[1:2])
    if rank(velmatrix) < 2
        return -1, -1
    end
    posdiff = stone2.position[1:2] .- stone1.position[1:2]
    (t1, t2) = velmatrix \ posdiff
    return t1, -t2
end

"""
Return a vector [px, py, pz, vx, vy, vz] with the initial position and velocity of a stone
hitting all hailstones at some point.
"""
function rockthrow(stone1::Hailstone, stone2::Hailstone, stone3::Hailstone)
    r1 =
        [
            stone2.velocity[2] - stone1.velocity[2],
            -(stone2.velocity[1] - stone1.velocity[1]),
            0,
            -(stone2.position[2] - stone1.position[2]),
            stone2.position[1] - stone1.position[1],
            0,
        ]'
    r2 =
        [
            0,
            stone2.velocity[3] - stone1.velocity[3],
            -(stone2.velocity[2] - stone1.velocity[2]),
            0,
            -(stone2.position[3] - stone1.position[3]),
            stone2.position[2] - stone1.position[2],
        ]'
    r3 =
        [
            -(stone2.velocity[3] - stone1.velocity[3]),
            0,
            stone2.velocity[1] - stone1.velocity[1],
            stone2.position[3] - stone1.position[3],
            0,
            -(stone2.position[1] - stone1.position[1]),
        ]'
    r4 =
        [
            stone3.velocity[2] - stone2.velocity[2],
            -(stone3.velocity[1] - stone2.velocity[1]),
            0,
            -(stone3.position[2] - stone2.position[2]),
            stone3.position[1] - stone2.position[1],
            0,
        ]'
    r5 =
        [
            0,
            stone3.velocity[3] - stone2.velocity[3],
            -(stone3.velocity[2] - stone2.velocity[2]),
            0,
            -(stone3.position[3] - stone2.position[3]),
            stone3.position[2] - stone2.position[2],
        ]'
    r6 =
        [
            -(stone3.velocity[3] - stone2.velocity[3]),
            0,
            stone3.velocity[1] - stone2.velocity[1],
            stone3.position[3] - stone2.position[3],
            0,
            -(stone3.position[1] - stone2.position[1]),
        ]'
    m = vcat(r1, r2, r3, r4, r5, r6)
    res = [
        -stone1.position[1] * stone1.velocity[2] +
        stone1.position[2] * stone1.velocity[1] +
        stone2.position[1] * stone2.velocity[2] -
        stone2.position[2] * stone2.velocity[1],
        -stone1.position[2] * stone1.velocity[3] +
        stone1.position[3] * stone1.velocity[2] +
        stone2.position[2] * stone2.velocity[3] -
        stone2.position[3] * stone2.velocity[2],
        -stone1.position[3] * stone1.velocity[1] +
        stone1.position[1] * stone1.velocity[3] +
        stone2.position[3] * stone2.velocity[1] -
        stone2.position[1] * stone2.velocity[3],
        -stone2.position[1] * stone2.velocity[2] +
        stone2.position[2] * stone2.velocity[1] +
        stone3.position[1] * stone3.velocity[2] -
        stone3.position[2] * stone3.velocity[1],
        -stone2.position[2] * stone2.velocity[3] +
        stone2.position[3] * stone2.velocity[2] +
        stone3.position[2] * stone3.velocity[3] -
        stone3.position[3] * stone3.velocity[2],
        -stone2.position[3] * stone2.velocity[1] +
        stone2.position[1] * stone2.velocity[3] +
        stone3.position[3] * stone3.velocity[1] -
        stone3.position[1] * stone3.velocity[3],
    ]
    return m \ res
end

function part1()
    lines = open("input/day24.txt") do f
        return readlines(f)
    end

    hailstones = fromstring.(lines)

    inarea = 0
    for (i, stone1) in enumerate(hailstones)
        for stone2 in hailstones[i+1:end]
            (t1, t2) = intersectiontimes2d(stone1, stone2)
            if t1 >= 0 && t2 >= 0
                x = stone1.position[1] + t1 * stone1.velocity[1]
                y = stone1.position[2] + t1 * stone1.velocity[2]
                if 200000000000000 <= x <= 400000000000000 &&
                   200000000000000 <= y <= 400000000000000
                    inarea += 1
                end
            end
        end
    end
    return inarea
end

function part2()
    lines = open("input/day24.txt") do f
        return readlines(f)
    end

    hailstones = fromstring.(lines)
    rockdata = rockthrow(hailstones[1], hailstones[2], hailstones[3])
    return trunc(Int, round(sum(rockdata[1:3])))
end

ans1 = part1()
println(ans1)
ans2 = part2()
println(ans2)
