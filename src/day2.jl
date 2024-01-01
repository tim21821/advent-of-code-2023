const RED_RE = r"(\d+) red"
const GREEN_RE = r"(\d+) green"
const BLUE_RE = r"(\d+) blue"

"""
Return the number of balls of the color specified by `re`
"""
function getballcount(re::Regex, game::AbstractString)
    m = match(re, game)
    return isnothing(m) ? 0 : parse(Int, m.captures[1])
end

function part1()
    lines = open("input/day2.txt") do f
        return readlines(f)
    end

    idsum = 0
    for (i, line) in enumerate(lines)
        games = split(line[8:end], ';')

        maxred = 0
        maxgreen = 0
        maxblue = 0

        for game in games
            rednum = getballcount(RED_RE, game)
            greennum = getballcount(GREEN_RE, game)
            bluenum = getballcount(BLUE_RE, game)
            maxred = max(maxred, rednum)
            maxgreen = max(maxgreen, greennum)
            maxblue = max(maxblue, bluenum)
        end

        if maxred <= 12 && maxgreen <= 13 && maxblue <= 14
            idsum += i
        end
    end
    return idsum
end

function part2()
    lines = open("input/day2.txt") do f
        return readlines(f)
    end

    powersum = 0

    for line in lines
        games = split(line[8:end], ';')

        maxred = 0
        maxgreen = 0
        maxblue = 0

        for game in games
            rednum = getballcount(RED_RE, game)
            greennum = getballcount(GREEN_RE, game)
            bluenum = getballcount(BLUE_RE, game)
            maxred = max(maxred, rednum)
            maxgreen = max(maxgreen, greennum)
            maxblue = max(maxblue, bluenum)
        end
        powersum += maxred * maxgreen * maxblue
    end
    return powersum
end

ans1 = part1()
println(ans1)
ans2 = part2()
println(ans2)
