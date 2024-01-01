"""
Return number of matches between `mynumbers` and `winningnumbers`.
"""
function getwincount((winningnumbers, mynumbers)::Tuple{Vector{Int},Vector{Int}})
    wincounter = 0
    for number in mynumbers
        if number in winningnumbers
            wincounter += 1
        end
    end
    return wincounter
end

"""
Return the number of points for `mynumbers` based on `winningnumbers`.
"""
function getpoints((winningnumbers, mynumbers)::Tuple{Vector{Int},Vector{Int}})
    wins = getwincount((winningnumbers, mynumbers))
    return floor(Int, 2.0^(wins - 1))
end

"""
Parse a line into `winningnumbers` und `mynumbers`.
"""
function parsecard(line::String)
    (_, game) = split(line, ':')
    (winning, mine) = split(game, '|')
    winningnumbers = parse.(Int, split(winning))
    mynumbers = parse.(Int, split(mine))
    return (winningnumbers, mynumbers)
end

function part1()
    lines = open("input/day4.txt") do f
        return readlines(f)
    end

    cards = parsecard.(lines)
    totalpoints = 0

    for card in cards
        totalpoints += getpoints(card)
    end
    return totalpoints
end

function part2()
    lines = open("input/day4.txt") do f
        return readlines(f)
    end

    cards = parsecard.(lines)
    numberofcards = ones(Int, length(cards))
    for (i, (card, num)) in enumerate(zip(cards, numberofcards))
        points = getwincount(card)
        for j in i+1:i+points
            numberofcards[j] += num
        end
    end
    return sum(numberofcards)
end

ans1 = part1()
println(ans1)
ans2 = part2()
println(ans2)
