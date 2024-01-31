using DataStructures

"""
Represent a path with the current position and a `Set` of the already visited positions.
"""
struct Path
    currentposition::CartesianIndex{2}
    visited::Set{CartesianIndex{2}}
end

"""
Represent a path by just intersections. Stores the current intersection position, a `Set`
of already visited intersections and the total length of the path.
"""
struct IntersectionPath
    currentposition::CartesianIndex{2}
    visited::Set{CartesianIndex{2}}
    length::Int
end

"""
Return the possible positions to reach starting from `position` using slippery slopes.
"""
function generatenextpositions1(position::CartesianIndex{2}, grid::Matrix{Char})
    currenttile = grid[position]
    if currenttile == '^'
        return [position + CartesianIndex(-1, 0)]
    elseif currenttile == '>'
        return [position + CartesianIndex(0, 1)]
    elseif currenttile == 'v'
        return [position + CartesianIndex(1, 0)]
    elseif currenttile == '<'
        return [position + CartesianIndex(0, -1)]
    else
        nextpositions = Vector{CartesianIndex{2}}()
        up = position + CartesianIndex(-1, 0)
        if checkbounds(Bool, grid, up) && grid[up] != '#'
            push!(nextpositions, up)
        end

        right = position + CartesianIndex(0, 1)
        if checkbounds(Bool, grid, right) && grid[right] != '#'
            push!(nextpositions, right)
        end

        down = position + CartesianIndex(1, 0)
        if checkbounds(Bool, grid, down) && grid[down] != '#'
            push!(nextpositions, down)
        end

        left = position + CartesianIndex(0, -1)
        if checkbounds(Bool, grid, left) && grid[left] != '#'
            push!(nextpositions, left)
        end

        return nextpositions
    end
end

"""
Return the possible positions to reach starting from `position` not using slippery slopes.
"""
function generatenextpositions2(position::CartesianIndex{2}, grid::Matrix{Char})
    nextpositions = Vector{CartesianIndex{2}}()

    up = position + CartesianIndex(-1, 0)
    if checkbounds(Bool, grid, up) && grid[up] != '#'
        push!(nextpositions, up)
    end

    right = position + CartesianIndex(0, 1)
    if checkbounds(Bool, grid, right) && grid[right] != '#'
        push!(nextpositions, right)
    end

    down = position + CartesianIndex(1, 0)
    if checkbounds(Bool, grid, down) && grid[down] != '#'
        push!(nextpositions, down)
    end

    left = position + CartesianIndex(0, -1)
    if checkbounds(Bool, grid, left) && grid[left] != '#'
        push!(nextpositions, left)
    end

    return nextpositions
end

"""
Return the distance between the current position and the next intersection.
"""
function intersection_distance(
    current::CartesianIndex{2},
    distance::Int,
    seen::Set{CartesianIndex{2}},
    intersections::Vector{CartesianIndex{2}},
    neighbors::Dict{CartesianIndex{2},Vector{CartesianIndex{2}}},
)
    if current in intersections
        return current, distance
    end

    next = [p for p in neighbors[current] if !(p in seen)][1]
    return intersection_distance(
        next,
        distance + 1,
        union(seen, Set([current])),
        intersections,
        neighbors,
    )
end

function part1()
    lines = open("input/day23.txt") do f
        return readlines(f)
    end

    grid = stack(collect.(lines); dims = 1)
    start = CartesianIndex(1, 2)
    ende = CartesianIndex(length(lines), length(lines[end]) - 1)

    longestpathlength = 0
    paths = Stack{Path}()
    push!(paths, Path(start, Set{CartesianIndex{2}}()))

    while !isempty(paths)
        currentpath = pop!(paths)
        visited = union(currentpath.visited, Set([currentpath.currentposition]))
        if currentpath.currentposition == ende
            longestpathlength = max(longestpathlength, length(visited))
        else
            nextmoves = generatenextpositions1(currentpath.currentposition, grid)
            for move in nextmoves
                if !(move in visited)
                    push!(paths, Path(move, visited))
                end
            end
        end
        println(length(paths))
    end
    return longestpathlength - 1  # one step fewer than tiles visited
end

function part2()
    lines = open("input/day23.txt") do f
        return readlines(f)
    end

    grid = stack(collect.(lines); dims = 1)
    start = CartesianIndex(1, 2)
    ende = CartesianIndex(length(lines), length(lines[end]) - 1)

    neighbors = Dict{CartesianIndex{2},Vector{CartesianIndex{2}}}()
    intersections = [start, ende]
    for (y, row) in enumerate(eachrow(grid))
        for (x, tile) in enumerate(row)
            if tile != '#'
                next = generatenextpositions2(CartesianIndex(y, x), grid)
                neighbors[CartesianIndex(y, x)] = next
                if length(next) > 2
                    push!(intersections, CartesianIndex(y, x))
                end
            end
        end
    end

    graph = Dict{CartesianIndex{2},Vector{Tuple{CartesianIndex{2},Int}}}()
    for intersection in intersections
        graph[intersection] = Vector{Tuple{CartesianIndex{2},Int}}()
        for neighbor in neighbors[intersection]
            push!(
                graph[intersection],
                intersection_distance(
                    neighbor,
                    1,
                    Set([intersection]),
                    intersections,
                    neighbors,
                ),
            )
        end
    end

    longestpathlength = 0
    paths = Stack{IntersectionPath}()
    push!(paths, IntersectionPath(start, Set{CartesianIndex{2}}(), 0))

    while !isempty(paths)
        currentpath = pop!(paths)
        visited = union(currentpath.visited, Set([currentpath.currentposition]))
        if currentpath.currentposition == ende
            longestpathlength = max(longestpathlength, currentpath.length)
        else
            nextintersections = graph[currentpath.currentposition]
            for (intersection, distance) in nextintersections
                if !(intersection in visited)
                    push!(
                        paths,
                        IntersectionPath(
                            intersection,
                            visited,
                            currentpath.length + distance,
                        ),
                    )
                end
            end
        end
        println("Stack: $(length(paths)), Max: $longestpathlength")
    end
    return longestpathlength
end

ans1 = part1()
println(ans1)
ans2 = part2()
println(ans2)
