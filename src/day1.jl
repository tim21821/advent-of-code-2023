const DIGITS = Dict(
    "one" => 1,
    "1" => 1,
    "two" => 2,
    "2" => 2,
    "three" => 3,
    "3" => 3,
    "four" => 4,
    "4" => 4,
    "five" => 5,
    "5" => 5,
    "six" => 6,
    "6" => 6,
    "seven" => 7,
    "7" => 7,
    "eight" => 8,
    "8" => 8,
    "nine" => 9,
    "9" => 9,
)

const DIGIT_RE = r"one|two|three|four|five|six|seven|eight|nine|\d"

function part1()
    lines = open("input/day1.txt") do f
        return readlines(f)
    end

    calibrationsum = 0
    for line in lines
        firstdigit = ""
        lastdigit = ""
        for c in line
            if isdigit(c)
                if firstdigit == ""
                    firstdigit = c
                end
                lastdigit = c
            end
        end
        calibrationvalue = parse(Int, firstdigit * lastdigit)
        calibrationsum += calibrationvalue
    end
    return calibrationsum
end

function part2()
    lines = open("input/day1.txt") do f
        return readlines(f)
    end

    calibrationsum = 0
    for line in lines
        m = collect(eachmatch(DIGIT_RE, line, overlap = true))
        firstdigit = DIGITS[m[1].match]
        lastdigit = DIGITS[m[end].match]
        calibrationsum += 10 * firstdigit + lastdigit
    end
    return calibrationsum
end

ans1 = part1()
println(ans1)
ans2 = part2()
println(ans2)
