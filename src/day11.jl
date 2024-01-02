"""
Represent a `Galaxy` (`'#'`) with its coordinates.
"""
struct Galaxy
    x::Int
    y::Int
end

"""
Return the distance between `g1` and `g2` by only going left, right, up and down.
If `emptyrows` and `emptycols` are provided, each of their values represent 1 000 000
rows instead of the empty one.
"""
distance(g1::Galaxy, g2::Galaxy) = abs(g1.x - g2.x) + abs(g1.y - g2.y)

function distance(g1::Galaxy, g2::Galaxy, emptyrows::Set{Int}, emptycols::Set{Int})
    dist = abs(g1.x - g2.x) + abs(g1.y - g2.y)
    xrange = g1.x > g2.x ? (g2.x:g1.x) : (g1.x:g2.x)
    yrange = g1.y > g2.y ? (g2.y:g1.y) : (g1.y:g2.y)
    for x in xrange
        if x in emptycols
            dist += 1_000_000 - 1
        end
    end
    for y in yrange
        if y in emptyrows
            dist += 1_000_000 - 1
        end
    end
    return dist
end

"""
Expand the `universe` by doubling each empty row and column.
"""
function expanduniverse(universe::Vector{Vector{Char}})
    newuniverse = expandhorizontally(universe)
    newuniverse = expandvertically(newuniverse)
    return newuniverse
end

"""
Expand the `universe` horizontally by doubling each empty column.
"""
function expandhorizontally(universe::Vector{Vector{Char}})
    newuniverse = Vector{Vector{Char}}()
    for i in eachindex(universe[1])
        col = [universe[j][i] for j in eachindex(universe)]
        push!(newuniverse, col)
        if all(e -> e == '.', col)
            push!(newuniverse, col)
        end
    end
    transposed = [[x[i] for x in newuniverse] for i in eachindex(universe[1])]
    return transposed
end

"""
Expand the `universe` vertically by doubling each empty row.
"""
function expandvertically(universe::Vector{Vector{Char}})
    newuniverse = Vector{Vector{Char}}()
    for row in universe
        push!(newuniverse, row)
        if all(e -> e == '.', row)
            push!(newuniverse, row)
        end
    end
    return newuniverse
end

"""
Return all the `Galaxy`s in the `universe`.
"""
function findgalaxies(universe::Vector{Vector{Char}})
    galaxies = Vector{Galaxy}()
    for (y, row) in enumerate(universe)
        for (x, c) in enumerate(row)
            if c == '#'
                push!(galaxies, Galaxy(x, y))
            end
        end
    end
    return galaxies
end

function part1()
    lines = open("input/day11.txt") do f
        return readlines(f)
    end

    universe = collect.(lines)
    universe = expanduniverse(universe)
    galaxies = findgalaxies(universe)
    distancesum = 0
    for (i, galaxy1) in enumerate(galaxies)
        for galaxy2 in galaxies[i:end]
            distancesum += distance(galaxy1, galaxy2)
        end
    end
    return distancesum
end

function part2()
    lines = open("input/day11.txt") do f
        return readlines(f)
    end

    universe = collect.(lines)
    emptyrows = Set{Int}()
    emptycols = Set{Int}()
    for (i, row) in enumerate(universe)
        if all(e -> e == '.', row)
            push!(emptyrows, i)
        end
    end
    for i in eachindex(universe[1])
        col = [universe[j][i] for j in eachindex(universe)]
        if all(e -> e == '.', col)
            push!(emptycols, i)
        end
    end

    galaxies = findgalaxies(universe)
    distancesum = 0
    for (i, galaxy1) in enumerate(galaxies)
        for galaxy2 in galaxies[i:end]
            distancesum += distance(galaxy1, galaxy2, emptyrows, emptycols)
        end
    end
    return distancesum
end

ans1 = part1()
println(ans1)
ans2 = part2()
println(ans2)
