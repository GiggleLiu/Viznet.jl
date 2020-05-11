using Compose: LinePrimitive, CirclePrimitive, Form, SimplePolygonPrimitive,
    RectanglePrimitive, TextPrimitive, ArcPrimitive, CurvePrimitive
const PointT = Tuple{Float64,Float64}
const EdgeT = Tuple{PointT, PointT}
const NODE_CACHE = Dict{Context, Vector{PointT}}()
const EDGE_CACHE = Dict{Context, Vector{EdgeT}}()

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

function empty_cache!()
    empty!(NODE_CACHE)
    empty!(EDGE_CACHE)
end

nnode() = isempty(NODE_CACHE) ? 0 : sum(length, values(NODE_CACHE))
nedge() = isempty(EDGE_CACHE) ? 0 : sum(length, values(EDGE_CACHE))

function inner_most_container(c::Context)
    if !isempty(c.container_children)
        return inner_most_container(first(c.container_children))
    end
    return c
end

function Base.:>>(brush::Context, x::Tuple{<:NTuple{2,T}, <:NTuple{2,T}}) where T<:Real
    put_edge!(brush, Float64.(x[1]), Float64.(x[2]))
end

function Base.:>>(brush::Context, position::NTuple{2,Real})
    put_node!(brush, Float64.(position))
end

function flush_edges!(edges::Dict)
    lst = Context[]
    for (brush, lines) in edges
        b = deepcopy(brush)
        c = inner_most_container(b)
        line = first(c.form_children)
        c.form_children.head = similar_edges(line, lines)
        push!(lst, b)
    end
    empty!(EDGE_CACHE)
    return lst
end

function flush_nodes!(nodes::Dict)
    lst = Context[]
    for (brush, vs) in nodes
        b = deepcopy(brush)
        c = inner_most_container(b)
        v = first(c.form_children)
        c.form_children.head = similar_nodes(v, vs)
        push!(lst, b)
    end
    empty!(NODE_CACHE)
    return lst
end

function flush!()
    compose(context(), flush_nodes!(NODE_CACHE)...,
        flush_edges!(EDGE_CACHE)...)
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

similar_edges(e::Form{<:LinePrimitive}, point_arrays) = line(point_arrays)
function similar_edges(e::Form{<:ArcPrimitive}, point_arrays)
    c = first(e.primitives)
    as = getindex.(point_arrays,1)
    bs = getindex.(point_arrays,2)
    arc(as, bs, [c.radius], [c.angle1], [c.angle2], [c.sector])
end

function similar_edges(e::Form{<:CurvePrimitive}, point_arrays)
    c = first(e.primitives)
    as = getindex.(point_arrays,1)
    bs = getindex.(point_arrays,2)
    ctrl0s = map(x->x[1] .* (cx, cy) .+ c.ctrl0, point_arrays)
    ctrl1s = map(x->x[2] .* (cx, cy) .+ c.ctrl1, point_arrays)
    curve(as, bs, ctrl0s, ctrl1s)
end

function similar_nodes(n::Form{<:CirclePrimitive}, xys)
    c = first(n.primitives)
    xs = map(p->c.center[1] + p[1]*cx, xys)
    ys = map(p->c.center[2] + p[2]*cy, xys)
    circle(xs, ys, [c.radius])
end

function similar_nodes(p::Form{<:SimplePolygonPrimitive}, xys)
    c = first(p.primitives)
    polygon(map(x-> map(pi->(x[1]*cx + pi[1], x[2]*cy + pi[2]), c.points), xys))
end

function similar_nodes(n::Form{<:RectanglePrimitive}, xys)
    c = first(n.primitives)
    xs = map(p->c.corner[1] + p[1]*cx, xys)
    ys = map(p->c.corner[2] + p[2]*cy, xys)
    rectangle(xs, ys, [c.width], [c.height])
end

function similar_nodes(n::Form{<:TextPrimitive}, xys)
    c = first(n.primitives)
    xs = map(p->c.position[1] + p[1]*cx, xys)
    ys = map(p->c.position[2] + p[2]*cy, xys)
    text(xs, ys, [c.value], [c.halign], [c.valign], [c.rot], [tt.offset])
end
