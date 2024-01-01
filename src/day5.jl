import Base.in
using FLoops
using ProgressBars

const MAP_RE = r"^[a-z]+-to-[a-z]+ map:$"
const RANGE_RE = r"^(?P<destinationstart>\d+) (?P<sourcestart>\d+) (?P<length>\d+)$"

"""
Represent a range from `lower` to `upper`, inclusively.
"""
struct Range
    lower::Int
    upper::Int
end

in(e::Int, range::Range) = e >= range.lower && e <= range.upper

"""
Represent a mapping from a source range to a destination range.
"""
struct Mapping
    source::Range
    destinationstart::Int
end

"""
Return whether `e` is in `mapping`'s source range.
"""
in(e::Int, mapping::Mapping) = e in mapping.source

"""
Return a `Mapping` representing the input line.
"""
function parsemapping(line::String)
    m = match(RANGE_RE, line)
    destinationstart = parse(Int, m[:destinationstart])
    sourcestart = parse(Int, m[:sourcestart])
    rangelength = parse(Int, m[:length])
    sourcerange = Range(sourcestart, sourcestart + rangelength - 1)
    return Mapping(sourcerange, destinationstart)
end

"""
Represent an entire source-destination map.
"""
struct Map
    mappings::Vector{Mapping}
end

"""
Return the destination of `source` based on `map`.
"""
function getdestination(source::Int, map::Map)
    for mapping in map.mappings
        if source in mapping
            return mapping.destinationstart + source - mapping.source.lower
        end
    end
    return source
end

"""
Return a `Vector` of seed numbers.
"""
function parseseeds(s::String)
    (_, seeds) = split(s, ':')
    return parse.(Int, split(seeds))
end

"""
Return a `Vector` of `UnitRange`s representing the seed ranges.
"""
function getseedranges(seednums::Vector{Int})
    ranges = Vector{UnitRange{Int}}()
    for i in 1:length(seednums)÷2
        start = seednums[2i-1]
        len = seednums[2i]
        push!(ranges, start:start+len-1)
    end
    return ranges
end

function part1()
    lines = open("input/day5.txt") do f
        return readlines(f)
    end

    filter!(s -> s != "", lines) # remove empty lines

    seeds = parseseeds(lines[1])

    maps = Vector{Map}()
    currentmappings = Vector{Mapping}()
    for line in lines[3:end]
        if occursin(MAP_RE, line)
            push!(maps, Map(currentmappings))
            currentmappings = Vector{Mapping}()
        else
            push!(currentmappings, parsemapping(line))
        end
    end
    if currentmappings != Vector{Mapping}()
        push!(maps, Map(currentmappings))
    end

    currentlowest = typemax(Int)
    for seed in seeds
        currentlocation = seed
        for map in maps
            currentlocation = getdestination(currentlocation, map)
        end
        currentlowest = min(currentlowest, currentlocation)
    end
    return currentlowest
end

function part2()
    lines = open("input/day5.txt") do f
        return readlines(f)
    end

    filter!(s -> s != "", lines) # remove empty lines

    seednums = parseseeds(lines[1])
    seedranges = getseedranges(seednums)

    maps = Vector{Map}()
    currentmappings = Vector{Mapping}()
    for line in lines[3:end]
        if occursin(MAP_RE, line)
            push!(maps, Map(currentmappings))
            currentmappings = Vector{Mapping}()
        else
            push!(currentmappings, parsemapping(line))
        end
    end
    if currentmappings != Vector{Mapping}()
        push!(maps, Map(currentmappings))
    end

    @floop begin
        currentlowest = typemax(Int)
        for seedrange in ProgressBar(seedranges)
            for seed in seedrange
                currentlocation = seed
                for map in maps
                    currentlocation = getdestination(currentlocation, map)
                end
                currentlowest = min(currentlowest, currentlocation)
            end
        end
    end
    return currentlowest
end

ans1 = part1()
println(ans1)
ans2 = part2()
println(ans2)
