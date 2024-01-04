using Memoization

"""
Return the number of possible arrangements based on the `pattern` and the `counts` of
broken springs.
"""
@memoize Dict function getnumberofarrangements(pattern::String, counts::Vector{Int})
    if sum(counts) + length(counts) - 1 > length(pattern) # not enough springs left for pattern
        return 0
    end

    if length(counts) == 0 # no more damaged springs
        if '#' in pattern
            return 0
        else
            return 1
        end
    end

    if pattern[1] == '.' # no information from leading dot
        return getnumberofarrangements(pattern[2:end], counts)
    end

    totalarrangements = 0
    if pattern[1] == '?'
        totalarrangements += getnumberofarrangements(pattern[2:end], counts) # consider . case
    end

    # make group if possible
    if all(c -> c != '.', pattern[1:counts[1]]) &&
       (length(pattern) > counts[1] ? pattern[counts[1]+1] != '#' : true)
        totalarrangements +=
            getnumberofarrangements(pattern[counts[1]+2:end], counts[2:end])
    end
    return totalarrangements
end

function part1()
    lines = open("input/day12.txt") do f
        return readlines(f)
    end

    patterns = Vector{String}(undef, length(lines))
    counts = Vector{Vector{Int}}(undef, length(lines))
    for (i, line) in enumerate(lines)
        (pattern, count) = split(line)
        patterns[i] = pattern
        counts[i] = parse.(Int, split(count, ','))
    end

    arrangementssum = 0
    for (pattern, count) in zip(patterns, counts)
        arrangementssum += getnumberofarrangements(pattern, count)
    end
    return arrangementssum
end

function part2()
    lines = open("input/day12.txt") do f
        return readlines(f)
    end

    patterns = Vector{String}(undef, length(lines))
    counts = Vector{Vector{Int}}(undef, length(lines))
    for (i, line) in enumerate(lines)
        (pattern, count) = split(line)
        unfoldedpattern = join([pattern for _ in 1:5], '?')
        patterns[i] = unfoldedpattern
        unfoldedcount = join([count for _ in 1:5], ',')
        counts[i] = parse.(Int, split(unfoldedcount, ','))
    end

    arrangementssum = 0
    for (pattern, count) in zip(patterns, counts)
        arrangementssum += getnumberofarrangements(pattern, count)
    end
    return arrangementssum
end

ans1 = part1()
println(ans1)
ans2 = part2()
println(ans2)
