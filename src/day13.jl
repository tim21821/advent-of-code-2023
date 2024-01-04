"""
Return whether `row` has a vertical reflection between `index` and `index + 1`.
"""
function isverticalreflection(row::String, index::Int)
    j = 0
    while index - j >= 1 && index + 1 + j <= length(row)
        if row[index-j] != row[index+1+j]
            return false
        end
        j += 1
    end
    return true
end

"""
Return whether `pattern` has a vertical reflextion between `index` and `index + 1`,
assuming one smudge.
"""
function isverticalreflection_smudges(pattern::Vector{String}, index::Int)
    smudges = sum(neededsmudgesvertical.(pattern, index))
    return smudges == 1
end

"""
Return how many smudges there have to be in `row` for a vertical reflection to exist
between `index` and `index + 1`.
"""
function neededsmudgesvertical(row::String, index::Int)
    smudges = 0
    j = 0
    while index - j >= 1 && index + 1 + j <= length(row)
        if row[index-j] != row[index+1+j]
            smudges += 1
        end
        j += 1
    end
    return smudges
end

"""
Return whether `pattern` has a horizontal reflextion between `index` and `index + 1`.
"""
function ishorizontalreflextion(pattern::Vector{String}, index::Int)
    j = 0
    while index - j >= 1 && index + 1 + j <= length(pattern)
        if !all([
            pattern[index-j][i] == pattern[index+1+j][i] for
            i in eachindex(pattern[index-j])
        ])
            return false
        end
        j += 1
    end
    return true
end

"""
Return whether `pattern` has a horizontal reflextion between `index` and `index + 1`,
assuming one smudge.
"""
function ishorizontalreflextion_smudges(pattern::Vector{String}, index::Int)
    smudges = 0
    j = 0
    while index - j >= 1 && index + 1 + j <= length(pattern)
        for i in eachindex(pattern[index-j])
            if pattern[index-j][i] != pattern[index+1+j][i]
                smudges += 1
            end
        end
        j += 1
    end
    return smudges == 1
end

function part1()
    lines = open("input/day13.txt") do f
        return readlines(f)
    end

    patterns = Vector{Vector{String}}()
    currentpattern = Vector{String}()
    for line in lines
        if line == ""
            push!(patterns, currentpattern)
            currentpattern = Vector{String}()
        else
            push!(currentpattern, line)
        end
    end
    if length(currentpattern) > 0
        push!(patterns, currentpattern)
    end

    patternsum = 0
    for pattern in patterns
        for i in 1:length(pattern[1])-1
            if all(isverticalreflection.(pattern, i))
                patternsum += i
            end
        end

        for i in 1:length(pattern)-1
            if ishorizontalreflextion(pattern, i)
                patternsum += 100 * i
            end
        end
    end
    return patternsum
end

function part2()
    lines = open("input/day13.txt") do f
        return readlines(f)
    end

    patterns = Vector{Vector{String}}()
    currentpattern = Vector{String}()
    for line in lines
        if line == ""
            push!(patterns, currentpattern)
            currentpattern = Vector{String}()
        else
            push!(currentpattern, line)
        end
    end
    if length(currentpattern) > 0
        push!(patterns, currentpattern)
    end

    patternsum = 0
    for pattern in patterns
        for i in 1:length(pattern[1])-1
            if isverticalreflection_smudges(pattern, i)
                patternsum += i
            end
        end

        for i in 1:length(pattern)-1
            if ishorizontalreflextion_smudges(pattern, i)
                patternsum += 100 * i
            end
        end
    end
    return patternsum
end

ans1 = part1()
println(ans1)
ans2 = part2()
println(ans2)
