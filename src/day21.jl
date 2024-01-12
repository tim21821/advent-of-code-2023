using Memoization
using ProgressBars
using StaticArrays

"""
Return the coordinates of the `'S'` in `lines`.
"""
function Sposition(lines::Vector{String})
    return SVector((length(lines[1]) + 1) ÷ 2, (length(lines) + 1) ÷ 2)
end

"""
Return whether the `tile` at `position` is accessible, assuming an infinitely repeating
grid.
"""
@memoize function isaccessible(position::SVector{2,Int}, tiles::Vector{String})
    totalsize = SVector(length(tiles[1]), length(tiles))
    p = mod.(position, totalsize)
    if p[1] == 0
        p = SVector(totalsize[1], p[2])
    end
    if p[2] == 0
        p = SVector(p[1], totalsize[2])
    end
    return tiles[p[2]][p[1]] != '#'
end

"""
Return a `Set` of all tiles that are reachable with one step starting at `current`.
"""
@memoize Dict function getreachable(current::Set{SVector{2,Int}}, tiles::Vector{String})
    reachable = Set{SVector{2,Int}}()
    for position in current
        up = position + SVector(0, -1)
        if isaccessible(up, tiles)
            push!(reachable, up)
        end
        down = position + SVector(0, 1)
        if isaccessible(down, tiles)
            push!(reachable, down)
        end
        right = position + SVector(1, 0)
        if isaccessible(right, tiles)
            push!(reachable, right)
        end
        left = position + SVector(-1, 0)
        if isaccessible(left, tiles)
            push!(reachable, left)
        end
    end
    return reachable
end

"""
Return the coefficients of a quadratic polynomial with x values `stepcounts` and y values
`numreachable`.
"""
function getpolynomialcoefficients(stepcounts::SVector{3,Int}, numreachable::MVector{3,Int})
    matrix = @SMatrix [
        stepcounts[1]^2 stepcounts[1] 1
        stepcounts[2]^2 stepcounts[2] 1
        stepcounts[3]^2 stepcounts[3] 1
    ]
    return matrix \ numreachable
end

"""
Return the value of a quadratic polynomial defined by `coefficients` at `x`.
"""
function solvepolynomial(coefficients::MVector{3,Float64}, x::Int)
    return BigInt(trunc(coefficients[1] * x^2 + coefficients[2] * x + coefficients[3]))
end

function part1()
    lines = open("input/day21.txt") do f
        return readlines(f)
    end

    middle = Sposition(lines)
    reachable = Set([middle])
    for _ in 1:64
        reachable = getreachable(reachable, lines)
    end
    return length(reachable)
end

function part2()
    lines = open("input/day21.txt") do f
        return readlines(f)
    end

    middle = Sposition(lines)
    stepcountssample = SVector(65, 196, 327)
    numreachablesample = MVector{3,Int}(0, 0, 0)
    for (i, stepcount) in enumerate(stepcountssample)
        reachable = Set([middle])
        for _ in ProgressBar(1:stepcount)
            reachable = getreachable(reachable, lines)
        end
        numreachablesample[i] = length(reachable)
    end
    coefficients = getpolynomialcoefficients(stepcountssample, numreachablesample)
    return solvepolynomial(coefficients, 26501365)
end

ans1 = part1()
println(ans1)
ans2 = part2()
println(ans2)
