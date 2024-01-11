import Base.copy

"""
Represent a part with its values in the four categories `x`, `m`, `a` and `s`.
"""
struct Part
    x::Int
    m::Int
    a::Int
    s::Int
end

"""
Construct a `Part` from a `String` input.
"""
function partfromstring(str::AbstractString)
    str = str[2:end-1]
    splits = split(str, ',')
    x = parse(Int, splits[1][3:end])
    m = parse(Int, splits[2][3:end])
    a = parse(Int, splits[3][3:end])
    s = parse(Int, splits[4][3:end])
    return Part(x, m, a, s)
end

"""
Represent `Part`s with a range of values in the four categories.
"""
mutable struct PartRange
    x::UnitRange{Int}
    m::UnitRange{Int}
    a::UnitRange{Int}
    s::UnitRange{Int}
end

copy(partrange::PartRange) = PartRange(partrange.x, partrange.m, partrange.a, partrange.s)

PartRange() = PartRange(1:4000, 1:4000, 1:4000, 1:4000)

"""
Return the total number of `Part`s within the `partrange`.
"""
function size(partrange::PartRange)
    return length(partrange.x) *
           length(partrange.m) *
           length(partrange.a) *
           length(partrange.s)
end

"""
Return two ranges where the first range is less than `splitter` and the second is larger or
equal to the `splitter`.
"""
function bisectsmaller(range::UnitRange{Int}, splitter::Int)
    return first(range):splitter-1, splitter:last(range)
end

"""
Return two ranges where the first range is less or equal to `splitter` and the second is
larger than `splitter`.
"""
function bisectlarger(range::UnitRange{Int}, splitter::Int)
    return first(range):splitter, splitter+1:last(range)
end

"""
Represent a rule that compares a part category to a value and the result of the comparison.
"""
struct Rule
    category::Union{Symbol,Nothing}
    operator::Union{Char,Nothing}
    threshold::Union{Int,Nothing}
    result::String
end

const FULL_RULE_RE =
    r"(?P<category>x|m|a|s)(?P<operator>>|<)(?P<threshold>\d+):(?P<result>[a-zA-Z]+)"

"""
Construct a `Rule` from a `String` input.
"""
function rulefromstring(str::AbstractString)
    m = match(FULL_RULE_RE, str)
    if isnothing(m)
        return Rule(nothing, nothing, nothing, str)
    end
    category = Symbol(m["category"])
    operator = only(m["operator"])
    threshold = parse(Int, m["threshold"])
    result = m["result"]
    return Rule(category, operator, threshold, result)
end

"""
Represent a workflow consisting of a sequence of `Rule`s.
"""
struct Workflow
    name::String
    rules::Vector{Rule}
end

"""
Construct a `Workflow` from a `String` input.
"""
function workflowfromstring(str::AbstractString)
    (name, rulesstr) = split(str, '{')
    rulesstr = rulesstr[1:end-1]
    rulessplit = split(rulesstr, ',')
    rules = Vector{Rule}(undef, length(rulessplit))
    for (i, rule) in enumerate(rulessplit)
        rules[i] = rulefromstring(rule)
    end
    return Workflow(name, rules)
end

"""
Return the end result (`"A"` or `"R"`) after processing the `part` according to the
workflow with name `workflowname`.
"""
function processpart(
    part::Part,
    workflowname::AbstractString,
    workflows::Dict{String,Workflow},
)
    workflow = workflows[workflowname]
    for rule in workflow.rules
        if isnothing(rule.category)
            if rule.result == "A" || rule.result == "R"
                return rule.result
            else
                return processpart(part, rule.result, workflows)
            end
        end

        (category, operator, threshold) = rule.category, rule.operator, rule.threshold
        if operator == '<' && getproperty(part, category) < threshold
            return rule.result == "A" || rule.result == "R" ? rule.result :
                   processpart(part, rule.result, workflows)
        elseif operator == '>' && getproperty(part, category) > threshold
            return rule.result == "A" || rule.result == "R" ? rule.result :
                   processpart(part, rule.result, workflows)
        end
    end
end

"""
Return the number of accepted parts in the `partrange` after being processed according to
the workflow with name `workflowname`.
"""
function processrange(
    partrange::PartRange,
    workflowname::AbstractString,
    workflows::Dict{String,Workflow},
)
    if workflowname == "A"
        return size(partrange)
    elseif workflowname == "R"
        return 0
    end

    workflow = workflows[workflowname]

    acceptedsum = 0
    for rule in workflow.rules
        if isnothing(rule.category)
            if rule.result == "A"
                return acceptedsum + size(partrange)
            elseif rule.result == "R"
                return acceptedsum
            else
                return acceptedsum + processrange(partrange, rule.result, workflows)
            end
        end

        (category, operator, threshold) = rule.category, rule.operator, rule.threshold
        if operator == '<'
            currentrange = getproperty(partrange, category)
            splitranges = bisectsmaller(currentrange, threshold)
            smallrange = copy(partrange)
            setproperty!(smallrange, category, splitranges[1])
            acceptedsum += processrange(smallrange, rule.result, workflows)
            setproperty!(partrange, category, splitranges[2])
        elseif operator == '>'
            currentrange = getproperty(partrange, category)
            splitranges = bisectlarger(currentrange, threshold)
            largerange = copy(partrange)
            setproperty!(largerange, category, splitranges[2])
            acceptedsum += processrange(largerange, rule.result, workflows)
            setproperty!(partrange, category, splitranges[1])
        end
    end
    return acceptedsum
end

function part1()
    lines = open("input/day19.txt") do f
        return readlines(f)
    end

    workflows = Dict{String,Workflow}()
    i = 1
    while lines[i] != ""
        workflow = workflowfromstring(lines[i])
        workflows[workflow.name] = workflow
        i += 1
    end

    i += 1
    parts = Vector{Part}()
    while i <= length(lines)
        part = partfromstring(lines[i])
        push!(parts, part)
        i += 1
    end

    acceptedsum = 0
    for part in parts
        result = processpart(part, "in", workflows)
        if result == "A"
            acceptedsum += part.x + part.m + part.a + part.s
        end
    end
    return acceptedsum
end

function part2()
    lines = open("input/day19.txt") do f
        return readlines(f)
    end

    workflows = Dict{String,Workflow}()
    i = 1
    while lines[i] != ""
        workflow = workflowfromstring(lines[i])
        workflows[workflow.name] = workflow
        i += 1
    end

    allparts = PartRange()
    return processrange(allparts, "in", workflows)
end

ans1 = part1()
println(ans1)
ans2 = part2()
println(ans2)
