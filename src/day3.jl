"""
Return whether there is an adjacent symbol to the specified number
"""
function hasneighboringsymbol(lines::Vector{String}, row::Int, col::Int, numberlength::Int)
    for i in max(row - 1, 1):min(length(lines), row + 1)
        for j in max(col - 1, 1):min(length(lines[i]), col + numberlength)
            if !(isdigit(lines[i][j]) || lines[i][j] == '.')
                return true
            end
        end
    end
    return false
end

"""
Return the length of the number starting at index `numberstart`
"""
function getnumberlength(line::String, numberstart::Int)
    numberlength = 1
    while numberstart + numberlength <= length(line) &&
        isdigit(line[numberstart+numberlength])
        numberlength += 1
    end
    return numberlength
end

"""
Return whether `c` equals `*`.
"""
function isgear(c::Char)
    return c == '*'
end

"""
Return a `Vector` of all numbers adjacent to `lines[row][col]`.
"""
function getneighboringnumbers(lines::Vector{String}, row::Int, col::Int)
    numbers = Vector{Int}(undef, 0)

    if col > 1 && isdigit(lines[row][col-1])
        i = 1
        while col - i > 1 && isdigit(lines[row][col-i-1])
            i += 1
        end
        push!(numbers, parse(Int, lines[row][col-i:col-1]))
    end
    if col < length(lines[row]) && isdigit(lines[row][col+1])
        i = 1
        while col + i < length(lines[row]) && isdigit(lines[row][col+i+1])
            i += 1
        end
        push!(numbers, parse(Int, lines[row][col+1:col+i]))
    end

    if row > 1 && isdigit(lines[row-1][col])
        i1 = 0
        i2 = 0
        while col - i1 > 1 && isdigit(lines[row-1][col-i1-1])
            i1 += 1
        end
        while col + i2 < length(lines[row-1]) && isdigit(lines[row-1][col+i2+1])
            i2 += 1
        end
        push!(numbers, parse(Int, lines[row-1][col-i1:col+i2]))
    elseif row > 1
        if col > 1 && isdigit(lines[row-1][col-1])
            i = 1
            while col - i > 1 && isdigit(lines[row-1][col-i-1])
                i += 1
            end
            push!(numbers, parse(Int, lines[row-1][col-i:col-1]))
        end

        if col < length(lines[row-1]) && isdigit(lines[row-1][col+1])
            i = 1
            while col + i < length(lines[row-1]) && isdigit(lines[row-1][col+i+1])
                i += 1
            end
            push!(numbers, parse(Int, lines[row-1][col+1:col+i]))
        end
    end

    if row < length(lines) && isdigit(lines[row+1][col])
        i1 = 0
        i2 = 0
        while col - i1 > 1 && isdigit(lines[row+1][col-i1-1])
            i1 += 1
        end
        while col + i2 < length(lines[row+1]) && isdigit(lines[row+1][col+i2+1])
            i2 += 1
        end
        push!(numbers, parse(Int, lines[row+1][col-i1:col+i2]))
    elseif row < length(lines)
        if col > 1 && isdigit(lines[row+1][col-1])
            i = 1
            while col - i > 1 && isdigit(lines[row+1][col-i-1])
                i += 1
            end
            push!(numbers, parse(Int, lines[row+1][col-i:col-1]))
        end
        if col < length(lines[row]) && isdigit(lines[row+1][col+1])
            i = 1
            while col + i < length(lines[row+1]) && isdigit(lines[row+1][col+i+1])
                i += 1
            end
            push!(numbers, parse(Int, lines[row+1][col+1:col+i]))
        end
    end

    return numbers
end

function part1()
    lines = open("input/day3.txt") do f
        return readlines(f)
    end

    partnumbersum = 0

    for (i, line) in enumerate(lines)
        j = 1
        while j <= length(line)
            if isdigit(line[j])
                numberlength = getnumberlength(line, j)
                ispartnumber = hasneighboringsymbol(lines, i, j, numberlength)
                if ispartnumber
                    partnumbersum += parse(Int, line[j:j+numberlength-1])
                end
                j += numberlength
            end
            j += 1
        end
    end
    return partnumbersum
end

function part2()
    lines = open("input/day3.txt") do f
        return readlines(f)
    end

    gearratiosum = 0

    for (i, line) in enumerate(lines)
        for (j, c) in enumerate(line)
            if isgear(c)
                neighboringnumbers = getneighboringnumbers(lines, i, j)
                if length(neighboringnumbers) == 2
                    gearratiosum += neighboringnumbers[1] * neighboringnumbers[2]
                end
            end
        end
    end

    return gearratiosum
end

ans1 = part1()
println(ans1)
ans2 = part2()
println(ans2)
