using DataStructures

"""
Return the least possible heat loss to reach the bottom right. Always move at least
`minsteps` and at most `maxsteps` in the same direction.
"""
function leastheatloss(costgrid::Matrix{Int}, minsteps::Int, maxsteps::Int)
    targetx, targety = size(costgrid)
    queue = PriorityQueue{Tuple{Int,Int,Bool},Int}()
    cost = typemax(Int) * ones(Int, size(costgrid)..., 2)
    cost[1, 1, :] .= 0
    enqueue!(queue, (1, 1, true), 0)
    enqueue!(queue, (1, 1, false), 0)
    while !isempty(queue)
        x, y, lastmovehorizontal = dequeue!(queue)
        if x == targetx && y == targety
            return min(cost[targetx, targety, 1], cost[targetx, targety, 2])
        end

        if lastmovehorizontal
            steps = 0
            for i in 1:maxsteps
                x - i < 1 && break
                steps += costgrid[x-i, y]
                if i >= minsteps && cost[x-i, y, 2] > steps + cost[x, y, 1]
                    cost[x-i, y, 2] = steps + cost[x, y, 1]
                    queue[(x - i, y, false)] = cost[x-i, y, 2]
                end
            end

            steps = 0
            for i in 1:maxsteps
                x + i > targetx && break
                steps += costgrid[x+i, y]
                if i >= minsteps && cost[x+i, y, 2] > steps + cost[x, y, 1]
                    cost[x+i, y, 2] = steps + cost[x, y, 1]
                    queue[(x + i, y, false)] = cost[x+i, y, 2]
                end
            end
        else
            steps = 0
            for j in 1:maxsteps
                y - j < 1 && break
                steps += costgrid[x, y-j]
                if j >= minsteps && cost[x, y-j, 1] > steps + cost[x, y, 2]
                    cost[x, y-j, 1] = steps + cost[x, y, 2]
                    queue[(x, y - j, true)] = cost[x, y-j, 1]
                end
            end

            steps = 0
            for j in 1:maxsteps
                y + j > targety && break
                steps += costgrid[x, y+j]
                if j >= minsteps && cost[x, y+j, 1] > steps + cost[x, y, 2]
                    cost[x, y+j, 1] = steps + cost[x, y, 2]
                    queue[(x, y + j, true)] = cost[x, y+j, 1]
                end
            end
        end
    end
end

leastheatloss(costgrid::Matrix{Int}) = leastheatloss(costgrid, 1, 3)

function part1()
    lines = open("input/day17.txt") do f
        return readlines(f)
    end

    costgrid = mapreduce(permutedims, vcat, [parse.(Int, collect(line)) for line in lines])

    return leastheatloss(costgrid)
end

function part2()
    lines = open("input/day17.txt") do f
        return readlines(f)
    end

    costgrid = mapreduce(permutedims, vcat, [parse.(Int, collect(line)) for line in lines])

    return leastheatloss(costgrid, 4, 10)
end

ans1 = part1()
println(ans1)
ans2 = part2()
println(ans2)
