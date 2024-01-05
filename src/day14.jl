"""
Return the load on the north support beams.
"""
function getload(rocks::Vector{Vector{Char}})
    load = 0
    for (i, row) in enumerate(rocks)
        for rock in row
            if rock == 'O'
                load += length(rocks) - i + 1
            end
        end
    end
    return load
end

"""
Tilt the platform north and let the `rocks` roll into place.
"""
function tiltnorth!(rocks::Vector{Vector{Char}})
    for (i, row) in enumerate(rocks)
        for (j, rock) in enumerate(row)
            if rock == 'O'
                k = 1
                while i - k >= 1 && rocks[i-k][j] == '.'
                    rocks[i-k][j] = 'O'
                    rocks[i-k+1][j] = '.'
                    k += 1
                end
            end
        end
    end
end

"""
Tilt the platform south and let the `rocks` roll into place.
"""
function tiltsouth!(rocks::Vector{Vector{Char}})
    for i in length(rocks):-1:1
        row = rocks[i]
        for (j, rock) in enumerate(row)
            if rock == 'O'
                k = 1
                while i + k <= length(rocks) && rocks[i+k][j] == '.'
                    rocks[i+k][j] = 'O'
                    rocks[i+k-1][j] = '.'
                    k += 1
                end
            end
        end
    end
end

"""
Tilt the platform west and let the `rocks` roll into place.
"""
function tiltwest!(rocks::Vector{Vector{Char}})
    for row in rocks
        for (j, rock) in enumerate(row)
            if rock == 'O'
                k = 1
                while j - k >= 1 && row[j-k] == '.'
                    row[j-k] = 'O'
                    row[j-k+1] = '.'
                    k += 1
                end
            end
        end
    end
end

"""
Tilt the platform east and let the `rocks` roll into place.
"""
function tilteast!(rocks::Vector{Vector{Char}})
    for row in rocks
        for j in length(row):-1:1
            rock = row[j]
            if rock == 'O'
                k = 1
                while j + k <= length(row) && row[j+k] == '.'
                    row[j+k] = 'O'
                    row[j+k-1] = '.'
                    k += 1
                end
            end
        end
    end
end

"""
Do an entire cycle of tilts (north, west, south, east).
"""
function docycle!(rocks::Vector{Vector{Char}})
    tiltnorth!(rocks)
    tiltwest!(rocks)
    tiltsouth!(rocks)
    return tilteast!(rocks)
end

"""
Return a string of the concatenated characters of `rocks`.
"""
function string(rocks::Vector{Vector{Char}})
    return join([join(row) for row in rocks])
end

function part1()
    lines = open("input/day14.txt") do f
        return readlines(f)
    end

    rocks = collect.(lines)
    tiltnorth!(rocks)
    return getload(rocks)
end

function part2()
    lines = open("input/day14.txt") do f
        return readlines(f)
    end

    rocks = collect.(lines)
    memory = Dict{String,Int}()
    foundloop = false
    i = 1
    while i <= 1_000_000_000
        docycle!(rocks)
        str = string(rocks)
        if !foundloop
            if !(str in keys(memory))
                memory[str] = i
            else
                cyclestart = memory[str]
                cyclelength = i - cyclestart
                repeats = (1_000_000_000 - i) ÷ cyclelength
                i += cyclelength * repeats
                foundloop = true
            end
        end
        i += 1
    end
    return getload(rocks)
end

ans1 = part1()
println(ans1)
ans2 = part2()
println(ans2)
