using LinearAlgebra

"""
Return an adjacency matrix from vertex => Set{vertex} pairs. Rows and columns are according
to numbers specified in `vertexnums`.
"""
function constructadjacencymatrix(
    vertices::Dict{String,Set{String}},
    vertexnums::Dict{String,Int},
)
    A = zeros(Int, length(vertices), length(vertices))
    for v1 in keys(vertices)
        i = vertexnums[v1]
        for v2 in vertices[v1]
            j = vertexnums[v2]
            A[i, j] = 1
            A[j, i] = 1
        end
    end
    return A
end

"""
Perform a spectral bisection on the Laplacian matrix and return the sizes of the two
distinct graphs.
"""
function spectralbisection(Laplacian::Symmetric{Int,Matrix{Int}})
    v = eigvecs(Laplacian)[:, 2]
    firstpartition = 0
    secondpartition = 0
    for i in v
        if i < 0
            firstpartition += 1
        else
            secondpartition += 1
        end
    end
    return firstpartition, secondpartition
end

function part1()
    lines = open("input/day25.txt") do f
        return readlines(f)
    end

    vertices = Dict{String,Set{String}}()
    for line in lines
        wire, connections_str = split(line, ": ")
        connections = split(connections_str)
        if wire in keys(vertices)
            union!(vertices[wire], connections)
        else
            vertices[wire] = Set(connections)
        end
        for connection in connections
            if connection in keys(vertices)
                push!(vertices[connection], wire)
            else
                vertices[connection] = Set([wire])
            end
        end
    end

    vertexnums = Dict(s => i for (i, s) in enumerate(keys(vertices)))
    D = Diagonal([length(vertices[v]) for v in keys(vertices)])
    A = constructadjacencymatrix(vertices, vertexnums)
    L = Symmetric(D - A)
    firstpartition, secondpartition = spectralbisection(L)
    return firstpartition * secondpartition
end

ans1 = part1()
println(ans1)
