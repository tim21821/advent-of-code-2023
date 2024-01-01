@enum TypeOfHand begin
    HighCard
    OnePair
    TwoPair
    ThreeOfAKind
    FullHouse
    FourOfAKind
    FiveOfAKind
end

const CARD_VALUES1 = Dict{Char,Int}(
    '2' => 2,
    '3' => 3,
    '4' => 4,
    '5' => 5,
    '6' => 6,
    '7' => 7,
    '8' => 8,
    '9' => 9,
    'T' => 10,
    'J' => 11,
    'Q' => 12,
    'K' => 13,
    'A' => 14,
)

const CARD_VALUES2 = Dict{Char,Int}(
    '2' => 2,
    '3' => 3,
    '4' => 4,
    '5' => 5,
    '6' => 6,
    '7' => 7,
    '8' => 8,
    '9' => 9,
    'T' => 10,
    'J' => 1,
    'Q' => 12,
    'K' => 13,
    'A' => 14,
)

const JOKER_POSSIBILITIES = ('2', '3', '4', '5', '6', '7', '8', '9', 'T', 'Q', 'K', 'A')

"""
Represents a hand with `cards` and a `bid`.
"""
struct Hand
    cards::Vector{Char}
    bid::Int
end

"""
Parse a `line` into a `Hand`.
"""
function parsehand(line::String)
    (hand, bid) = split(line)
    return Hand(collect(hand), parse(Int, bid))
end

"""
Return the type of `hand`.
"""
function typeofhand(hand::Hand)
    counts = countcards(hand.cards)
    if 5 in counts
        return FiveOfAKind
    elseif 4 in counts
        return FourOfAKind
    elseif 3 in counts && 2 in counts
        return FullHouse
    elseif 3 in counts
        return ThreeOfAKind
    elseif 2 in counts && count(i -> i == 2, counts) == 4
        return TwoPair
    elseif 2 in counts
        return OnePair
    else
        return HighCard
    end
end

"""
`isless` function for part 1.
"""
function isless1(firsthand::Hand, secondhand::Hand)
    firsttype = typeofhand(firsthand)
    secondtype = typeofhand(secondhand)
    if firsttype < secondtype
        return true
    elseif firsttype > secondtype
        return false
    end

    for (cardfirst, cardsecond) in zip(firsthand.cards, secondhand.cards)
        if CARD_VALUES1[cardfirst] < CARD_VALUES1[cardsecond]
            return true
        elseif CARD_VALUES1[cardfirst] > CARD_VALUES1[cardsecond]
            return false
        end
    end

    return false
end

"""
`isless` function for part 2.
"""
function isless2(firsthand::Hand, secondhand::Hand)
    firsttype = besttypeofhand(firsthand)
    secondtype = besttypeofhand(secondhand)
    if firsttype < secondtype
        return true
    elseif firsttype > secondtype
        return false
    end

    for (cardfirst, cardsecond) in zip(firsthand.cards, secondhand.cards)
        if CARD_VALUES2[cardfirst] < CARD_VALUES2[cardsecond]
            return true
        elseif CARD_VALUES2[cardfirst] > CARD_VALUES2[cardsecond]
            return false
        end
    end

    return false
end

"""
Return the best type of `hand` when using Jokers.
"""
function besttypeofhand(hand::Hand)
    if !('J' in hand.cards)
        return typeofhand(hand)
    end

    besttype = typeofhand(hand)
    index = findfirst(x -> x == 'J', hand.cards)
    for card in JOKER_POSSIBILITIES
        newcards = copy(hand.cards)
        newcards[index] = card
        newtype = besttypeofhand(Hand(newcards, hand.bid))
        besttype = max(besttype, newtype)
    end
    return besttype
end

"""
Return a `Vector` of element counts.
"""
function countcards(vec::Vector{Char})
    return [count(i -> i == x, vec) for x in vec]
end

function part1()
    lines = open("input/day7.txt") do f
        return readlines(f)
    end

    hands = parsehand.(lines)
    sort!(hands, lt = isless1)

    winnings = 0
    for (i, hand) in enumerate(hands)
        winnings += i * hand.bid
    end
    return winnings
end

function part2()
    lines = open("input/day7.txt") do f
        return readlines(f)
    end

    hands = parsehand.(lines)
    sort!(hands, lt = isless2)

    winnings = 0
    for (i, hand) in enumerate(hands)
        winnings += i * hand.bid
    end
    return winnings
end

ans1 = part1()
println(ans1)
ans2 = part2()
println(ans2)
