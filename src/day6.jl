using ProgressBars

function part1()
    lines = open("input/day6.txt") do f
        return readlines(f)
    end

    (_, time_str) = split(lines[1], ':')
    (_, distance_str) = split(lines[2], ':')
    times = parse.(Int, split(time_str))
    distances = parse.(Int, split(distance_str))

    waystowin_product = 1
    for (time, distance) in zip(times, distances)
        waystowin = 0
        for speed in 1:time-1
            distancetravelled = speed * (time - speed)
            if distancetravelled > distance
                waystowin += 1
            end
        end
        waystowin_product *= waystowin
    end
    return waystowin_product
end

function part2()
    lines = open("input/day6.txt") do f
        return readlines(f)
    end

    (_, time_str) = split(lines[1], ':')
    (_, distance_str) = split(lines[2], ':')
    times = split(time_str)
    distances = split(distance_str)
    time = parse(Int, join(times, ""))
    distance = parse(Int, join(distances, ""))

    waystowin = 0
    for speed in ProgressBar(1:time-1)
        distancetravelled = speed * (time - speed)
        if distancetravelled > distance
            waystowin += 1
        end
    end
    return waystowin
end

ans1 = part1()
println(ans1)
ans2 = part2()
println(ans2)
