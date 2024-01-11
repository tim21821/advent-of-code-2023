using DataStructures

@enum PULSE low = 1 high = 2

"""
Represent any type of communication module.
"""
abstract type CommunicationModule end

"""
Represent a Flip-flop module.
"""
mutable struct FlipFlop <: CommunicationModule
    name::String
    ison::Bool
    destinations::Vector{String}
end

FlipFlop(name::String, destinations::Vector{String}) = FlipFlop(name, false, destinations)

"""
Return all pulses send from `modul` in the format `(source, pulse, destination)`.
"""
function processpulse(modul::FlipFlop, pulse::PULSE, _source::String)
    if pulse == high
        return Vector{Tuple{String,PULSE,String}}()
    end

    modul.ison = !modul.ison
    if modul.ison
        return [(modul.name, high, destination) for destination in modul.destinations]
    else
        return [(modul.name, low, destination) for destination in modul.destinations]
    end
end

"""
Represent a conjunction module.
"""
mutable struct Conjunction <: CommunicationModule
    name::String
    pulsesreceived::Dict{String,PULSE}
    destinations::Vector{String}
end

Conjunction(name::String, destinations::Vector{String}) =
    Conjunction(name, Dict{String,PULSE}(), destinations)

function processpulse(modul::Conjunction, pulse::PULSE, source::String)
    modul.pulsesreceived[source] = pulse
    if all(p -> p == high, values(modul.pulsesreceived))
        return [(modul.name, low, destination) for destination in modul.destinations]
    else
        return [(modul.name, high, destination) for destination in modul.destinations]
    end
end

"""
Represent the broadcaster module.
"""
struct Broadcaster <: CommunicationModule
    name::String
    destinations::Vector{String}
end

function processpulse(modul::Broadcaster, pulse::PULSE, _source::String)
    return [(modul.name, pulse, destination) for destination in modul.destinations]
end

"""
Return a `Dict` (module name => module) of all the modules in `lines`.
"""
function constructmodules(lines::Vector{String})
    modules = Dict{String,CommunicationModule}()
    for line in lines
        (label, d) = split(line, " -> ")
        destinations = String.(split(d, ", "))
        if label == "broadcaster"
            modules["broadcaster"] = Broadcaster("broadcaster", destinations)
        elseif label[1] == '%'
            name = String(label[2:end])
            modules[name] = FlipFlop(name, destinations)
        elseif label[1] == '&'
            name = String(label[2:end])
            modules[name] = Conjunction(name, destinations)
        end
    end

    for (name, modul) in modules
        for d in modul.destinations
            if d in keys(modules)
                destination = modules[d]
                if destination isa Conjunction
                    destination.pulsesreceived[name] = low
                end
            end
        end
    end
    return modules
end

function part1()
    lines = open("input/day20.txt") do f
        return readlines(f)
    end

    modules = constructmodules(lines)

    lowcount = 0
    highcount = 0
    for _ in 1:1000
        pulses = Queue{Tuple{String,PULSE,String}}()
        enqueue!(pulses, ("button", low, "broadcaster"))
        lowcount += 1
        while !isempty(pulses)
            (source, pulse, d) = dequeue!(pulses)
            if !(d in keys(modules))
                continue
            end
            destination = modules[d]
            newpulses = processpulse(destination, pulse, source)
            for newpulse in newpulses
                if newpulse[2] == low
                    lowcount += 1
                else
                    highcount += 1
                end
                enqueue!(pulses, newpulse)
            end
        end
    end
    return lowcount * highcount
end

function part2()
    lines = open("input/day20.txt") do f
        return readlines(f)
    end

    modules = constructmodules(lines)
    rxsource = ""
    for (name, modul) in modules
        if "rx" in modul.destinations
            rxsource = name
        end
    end
    numvisits =
        Dict(name => false for (name, modul) in modules if rxsource in modul.destinations)
    lengthstorxsource = Dict{String,Int}()
    count = 0
    while true
        count += 1
        pulses = Queue{Tuple{String,PULSE,String}}()
        enqueue!(pulses, ("button", low, "broadcaster"))
        while !isempty(pulses)
            (source, pulse, d) = dequeue!(pulses)
            if !(d in keys(modules))
                continue
            end
            destination = modules[d]
            if destination.name == rxsource && pulse == high
                numvisits[source] = true
                if !(source in keys(lengthstorxsource))
                    lengthstorxsource[source] = count
                end

                if all(values(numvisits))
                    return lcm(values(lengthstorxsource)...)
                end
            end
            newpulses = processpulse(destination, pulse, source)
            for newpulse in newpulses
                enqueue!(pulses, newpulse)
            end
        end
    end
end

ans1 = part1()
println(ans1)
ans2 = part2()
println(ans2)
