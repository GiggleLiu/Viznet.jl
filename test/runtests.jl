using Viznet
using Test

@testset "brush" begin
    include("brush.jl")
end

@testset "lattices" begin
    include("lattices/lattices.jl")
end

@testset "intersection" begin
    ring = [(0.0, 0.0), (0.0, 1.0), (1.0, 1.0), (1.0, 0.0), (0.0, 0.0)]
    theta = π / 4.
    res = intersection(ring, theta, (-0.5, 0.0))
    @test all(res .≈ (0, 0.5))
end
