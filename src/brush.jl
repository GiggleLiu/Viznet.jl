using Compose: LinePrimitive, CirclePrimitive, Form, SimplePolygonPrimitive,
    RectanglePrimitive, TextPrimitive, ArcPrimitive, CurvePrimitive
const PointT = Tuple{Float64,Float64}
const TextT = Tuple{Float64,Float64,String}
const EdgeT = Tuple{PointT, PointT}
const NODE_CACHE = Dict{Context, Vector{PointT}}()
const EDGE_CACHE = Dict{Context, Vector{EdgeT}}()
const TEXT_CACHE = Dict{Context, Vector{TextT}}()
const TextBrush = Pair{Context,String}

export flush!, canvas

function put_node!(brush::Context, x::PointT)
    if haskey(NODE_CACHE, brush)
        push!(NODE_CACHE[brush], x)
    else
        NODE_CACHE[brush] = [x]
    end
    return x
end

function put_edge!(brush::Context, x::PointT, y::PointT)
    if haskey(EDGE_CACHE, brush)
        push!(EDGE_CACHE[brush], (x, y))
    else
        EDGE_CACHE[brush] = [(x, y)]
    end
    return (x, y)
end

function put_text!(brush::Context, x::PointT, y::String)
    if haskey(TEXT_CACHE, brush)
        push!(TEXT_CACHE[brush], (x..., y))
    else
        TEXT_CACHE[brush] = [(x..., y)]
    end
    return (x..., y)
end

function empty_cache!()
    empty!(NODE_CACHE)
    empty!(EDGE_CACHE)
    empty!(TEXT_CACHE)
end

nnode() = isempty(NODE_CACHE) ? 0 : sum(length, values(NODE_CACHE))
nedge() = isempty(EDGE_CACHE) ? 0 : sum(length, values(EDGE_CACHE))
ntext() = isempty(TEXT_CACHE) ? 0 : sum(length, values(TEXT_CACHE))

function inner_most_container(c::Context)
    if !isempty(c.container_children)
        return inner_most_container(first(c.container_children))
    end
    return c
end

function Base.:>>(brush::Context, x::Tuple{<:NTuple{2,T}, <:NTuple{2,T}}) where T<:Real
    put_edge!(brush, Float64.(x[1]), Float64.(x[2]))
end

function Base.:>>(brush::Context, x::Tuple{<:NTuple{2,T}, TS}) where {T<:Real,TS<:AbstractString}
    put_text!(brush, Float64.(x[1]), string(x[2]))
end

function Base.:>>(brush::Context, position::NTuple{2,Real})
    put_node!(brush, Float64.(position))
end

function flush!(d::Dict)
    lst = Context[]
    for (brush, lines) in d
        b = deepcopy(brush)
        c = inner_most_container(b)
        line = first(c.form_children)
        c.form_children.head = similar(line, lines)
        push!(lst, b)
    end
    empty!(d)
    return lst
end

function flush!()
    compose(context(),
        flush!(TEXT_CACHE)...,
        flush!(NODE_CACHE)...,
        flush!(EDGE_CACHE)...,
        )
end

"""
    canvas(f)

paint on global canvas.
"""
function canvas(f)
    empty_cache!()
    f()
    flush!()
end

similar(e::Form{<:LinePrimitive}, point_arrays) = line(point_arrays)
function similar(e::Form{<:ArcPrimitive}, point_arrays)
    c = first(e.primitives)
    as = getindex.(point_arrays,1)
    bs = getindex.(point_arrays,2)
    arc(as, bs, [c.radius], [c.angle1], [c.angle2], [c.sector])
end

function similar(e::Form{<:CurvePrimitive}, point_arrays)
    c = first(e.primitives)
    as = getindex.(point_arrays,1)
    bs = getindex.(point_arrays,2)
    ctrl0s = map(x->x[1] .- _value.(c.anchor0) .+ _value.(c.ctrl0), point_arrays)
    ctrl1s = map(x->x[2] .- _value.(c.anchor1) .+ _value.(c.ctrl1), point_arrays)
    curve(as, ctrl0s, ctrl1s, bs)
end

function similar(n::Form{<:CirclePrimitive}, xys)
    c = first(n.primitives)
    xs = map(p->_value(c.center[1]) + p[1], xys)
    ys = map(p->_value(c.center[2]) + p[2], xys)
    circle(xs, ys, [c.radius])
end

function similar(p::Form{<:SimplePolygonPrimitive}, xys)
    c = first(p.primitives)
    polygon(map(x-> map(pi->(x[1] + _value(pi[1]), x[2] + _value(pi[2])), c.points), xys))
end

function similar(n::Form{<:RectanglePrimitive}, xys)
    c = first(n.primitives)
    xs = map(p->_value(c.corner[1]) + p[1], xys)
    ys = map(p->_value(c.corner[2]) + p[2], xys)
    rectangle(xs, ys, [c.width], [c.height])
end

function similar(n::Form{<:TextPrimitive}, xys)
    c = first(n.primitives)
    xs = map(p->_value(c.position[1]) + p[1], xys)
    ys = map(p->_value(c.position[2]) + p[2], xys)
    ts = getindex.(xys, 3)
    text(xs, ys, ts, [c.halign], [c.valign], [c.rot], [c.offset])
end
