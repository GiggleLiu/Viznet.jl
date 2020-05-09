using Compose: LinePrimitive, CirclePrimitive, Form
const PointT = Tuple{Float64,Float64}
const EdgeT = Tuple{PointT, PointT}
const NODE_CACHE = Dict{Context, Vector{PointT}}()
const EDGE_CACHE = Dict{Context, Vector{EdgeT}}()

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

using Test
@testset "basic" begin
    c = compose(context(), compose(context(), line()))
    n = compose(context(), compose(context(), circle()))
    ic = inner_most_container(c)
    @test first(ic.form_children) isa Compose.Form{<:Compose.LinePrimitive}
    put_edge!(c, (0.3, 0.4), (2.3, 1.4))
    put_edge!(c, (0.3, 0.5), (2.3, 1.4))
    put_node!(n, (0.3, 0.5))
    @test nnode() == 1
    @test nedge() == 2
    empty_cache!()
    @test nnode() == 0
    @test nedge() == 0
end

function inner_most_container(c::Context)
    if !isempty(c.container_children)
        return inner_most_container(first(c.container_children))
    end
    return c
end


edge0() = compose(context(), line())
node0(r::Real=0.1) = compose(context(), circle(0.0, 0.0, r))

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
        push!(lst, c)
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
        push!(lst, c)
    end
    empty!(NODE_CACHE)
    return lst
end

flush!() = compose(context(), flush_nodes!(NODE_CACHE), flush_edges!(EDGE_CACHE))

similar_edges(e::Form{<:LinePrimitive}, point_arrays) = line(point_arrays)
function similar_nodes(n::Form{<:CirclePrimitive}, xys)
    c = first(n.primitives)
    xs = map(p->c.center[1] + p[1]*cx, xys)
    ys = map(p->c.center[2] + p[2]*cy, xys)
    circle(xs, ys, [c.radius])
end

@testset "flush edges" begin
    empty_cache!()
    c = compose(context(), compose(context(), line()))
    c >> ((0.3, 0.4), (2.3, 1.4))
    c >> ((0.3, 0.8), (2.3, 1.9))
    c0 = line0()
    c0 >> ((0.3, 0.8), (2.3, 2.9))
    lst = flush_edges!(EDGE_CACHE)
    @test length(lst) == 2
end

@testset "flush nodes" begin
    empty_cache!()
    c = compose(context(), compose(context(), circle(0.2, 0.2, 2.0)))
    c >> (0.3, 0.4)
    c >> (0.3, 0.8)
    c0 = node0()
    c0 >> (0.3, 0.8)
    lst = flush_nodes!(NODE_CACHE)
    @test length(lst) == 2
end

nb = compose(context(), stroke("red"), circle(0.0, 0.0, 0.02))
eb = compose(context(), stroke("green"), line())

x = nb >> (0.2, 0.3)
y = nb >> (0.6, 0.6)
eb >> (x, y)
flush!()
