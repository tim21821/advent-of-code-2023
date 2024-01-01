"""
Return the extrpolated value to `values`.
"""
function extrapolate(values::Vector{Int})
    if all(x -> x == 0, values)
        return 0
    end

    differences = [values[i+1] - values[i] for i in 1:length(values)-1]
    return values[end] + extrapolate(differences)
end

function part1()
    lines = open("input/day9.txt") do f
        return readlines(f)
    end

    values = [parse.(Int, x) for x in split.(lines)]

    sumextrapolated = 0
    for v in values
        sumextrapolated += extrapolate(v)
    end
    return sumextrapolated
end

function part2()
    lines = open("input/day9.txt") do f
        return readlines(f)
    end

    values = [parse.(Int, x) for x in split.(lines)]
    values = [reverse(x) for x in values]

    sumextrapolated = 0
    for v in values
        sumextrapolated += extrapolate(v)
    end
    return sumextrapolated
end

ans1 = part1()
println(ans1)
ans2 = part2()
println(ans2)
