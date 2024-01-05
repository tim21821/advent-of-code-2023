mutable struct Box
    lenses::Dict{String,Int}
    labels::Vector{String}
end

function add!(box::Box, label::AbstractString, lens::Int)
    if label in keys(box.lenses)
        box.lenses[label] = lens
    else
        box.lenses[label] = lens
        push!(box.labels, label)
    end
end

function remove!(box::Box, label::AbstractString)
    delete!(box.lenses, label)
    return filter!(l -> l != label, box.labels)
end

function holidayasciistringhelper(s::AbstractString)
    h = 0
    for c in s
        h += Int(c)
        h *= 17
        h %= 256
    end
    return h
end

function part1()
    sequence = open("input/day15.txt") do f
        return readline(f)
    end

    steps = split(sequence, ',')

    hashsum = 0
    for step in steps
        hashsum += holidayasciistringhelper(step)
    end
    return hashsum
end

function part2()
    sequence = open("input/day15.txt") do f
        return readline(f)
    end

    steps = split(sequence, ',')

    boxes = Vector{Box}(undef, 256)
    for i in eachindex(boxes)
        boxes[i] = Box(Dict{String,Int}(), Vector{String}())
    end

    for step in steps
        if '=' in step
            (label, lens) = split(step, '=')
            hashvalue = holidayasciistringhelper(label)
            add!(boxes[hashvalue+1], label, parse(Int, lens))
        elseif '-' in step
            label = step[1:end-1]
            hashvalue = holidayasciistringhelper(label)
            remove!(boxes[hashvalue+1], label)
        end
    end

    totalfocusingpower = 0
    for (i, box) in enumerate(boxes)
        for (j, label) in enumerate(box.labels)
            totalfocusingpower += i * j * box.lenses[label]
        end
    end
    return totalfocusingpower
end

ans1 = part1()
println(ans1)
ans2 = part2()
println(ans2)
