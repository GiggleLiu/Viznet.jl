using Viznet
using Viznet: inner_most_container, put_edge!, put_node!, empty_cache!, nedge, nnode,
    flush_edges!, flush_nodes!, EDGE_CACHE, NODE_CACHE
using Test
using Compose

@testset "basic" begin
    empty_cache!()
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


@testset "flush edges" begin
    empty_cache!()
    c = compose(context(), compose(context(), line()))
    c >> ((0.3, 0.4), (2.3, 1.4))
    c >> ((0.3, 0.8), (2.3, 1.9))
    c0 = bondstyle(:default)
    c0 >> ((0.3, 0.8), (2.3, 2.9))
    lst = flush_edges!(EDGE_CACHE)
    @test length(lst) == 2
end

@testset "flush nodes" begin
    empty_cache!()
    c = compose(context(), compose(context(), circle(0.2, 0.2, 2.0)))
    c >> (0.3, 0.4)
    c >> (0.3, 0.8)
    c0 = nodestyle(:default)
    c0 >> (0.3, 0.8)
    lst = flush_nodes!(NODE_CACHE)
    @test length(lst) == 2
end

@testset "system test" begin
    empty_cache!()
    nb = compose(context(), stroke("red"), circle(0.0, 0.0, 0.02))
    eb = compose(context(), stroke("green"), line())

    x = nb >> (0.2, 0.3)
    y = nb >> (0.6, 0.6)
    eb >> (x, y)
    @test flush!() isa Context
end
