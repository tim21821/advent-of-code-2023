struct Directions
    left::String
    right::String
end

"""
Return a `Directions` from `"(left, right)"` input.
"""
function parsedirection(dir::SubString{String})
    left = dir[2:4]
    right = dir[7:9]
    return Directions(left, right)
end

"""
Return a `Dict` of node => directions pairs.
"""
function parsenodes(lines::Vector{String})
    nodes = Dict{String,Directions}()
    for line in lines
        (node, dir) = split(line, " = ")
        nodes[node] = parsedirection(dir)
    end
    return nodes
end

"""
Turn left at `currentnode` based on `nodes`.
"""
function turnleft(nodes::Dict{String,Directions}, currentnode::String)
    return nodes[currentnode].left
end

"""
Turn right at `currentnode` based on `nodes`.
"""
function turnright(nodes::Dict{String,Directions}, currentnode::String)
    return nodes[currentnode].right
end

"""
Return whether `node` is a starting node for ghosts.
"""
function isstartingnode(node::String)
    return last(node) == 'A'
end

"""
Return whether `node` is an end node for ghosts.
"""
function isendnote(node::String)
    return last(node) == 'Z'
end

function part1()
    lines = open("input/day8.txt") do f
        return readlines(f)
    end

    turns = lines[1]
    nodes = parsenodes(lines[3:end])

    currentnode = "AAA"
    steps = 0
    while currentnode != "ZZZ"
        index = (steps % length(turns)) + 1
        if turns[index] == 'L'
            currentnode = turnleft(nodes, currentnode)
        else
            currentnode = turnright(nodes, currentnode)
        end
        steps += 1
    end
    return steps
end

function part2()
    lines = open("input/day8.txt") do f
        return readlines(f)
    end

    turns = lines[1]
    nodes = parsenodes(lines[3:end])

    startingnodes = filter(isstartingnode, collect(keys(nodes)))
    steps = zeros(Int, length(startingnodes))

    for (i, startingnode) in enumerate(startingnodes)
        currentnode = startingnode
        while !isendnote(currentnode)
            index = (steps[i] % length(turns)) + 1
            if turns[index] == 'L'
                currentnode = turnleft(nodes, currentnode)
            else
                currentnode = turnright(nodes, currentnode)
            end
            steps[i] += 1
        end
    end
    return lcm(steps...)
end

ans1 = part1()
println(ans1)
ans2 = part2()
println(ans2)
