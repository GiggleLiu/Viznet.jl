struct MyOrderedDict{TK,TV}
    keys::Vector{TK}
    vals::Vector{TV}
end

function MyOrderedDict{K,V}() where {K,V}
    MyOrderedDict(K[], V[])
end

function Base.setindex!(d::MyOrderedDict, val, key)
    ind = findfirst(x->x===key, d.keys)
    if ind isa Nothing
        push!(d.keys, key)
        push!(d.vals, val)
    else
        @inbounds d.vals[ind] = val
    end
    return d
end

function Base.getindex(d::MyOrderedDict, key)
    ind = findfirst(x->x===key, d.keys)
    if ind isa Nothing
        throw(KeyError(ind))
    else
        return d.vals[ind]
    end
end

function Base.delete!(d::MyOrderedDict, key)
    ind = findfirst(x->x==key, d.keys)
    if ind isa Nothing
        throw(KeyError(ind))
    else
        deleteat!(d.vals, ind)
        deleteat!(d.keys, ind)
    end
end

Base.length(d::MyOrderedDict) = length(d.keys)

function Base.pop!(d::MyOrderedDict)
    k = pop!(d.keys)
    v = pop!(d.vals)
    k, v
end

Base.isempty(d::MyOrderedDict) = length(d.keys) == 0
function Base.empty!(d::MyOrderedDict)
    empty!(d.keys)
    empty!(d.vals)
    return d
end

function Base.haskey(d::MyOrderedDict, k)
    k ∈ d.keys
end

function Base.iterate(d::MyOrderedDict, state=1)
    state > length(d) ? nothing : ((d.keys[state], d.vals[state]), state+1)
end
