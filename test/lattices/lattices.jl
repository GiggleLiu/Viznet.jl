using Test
using Viznet

@testset "unit disk" begin
    @test rand_unitdisk(10, 1.8) isa UnitDisk
    ud = UnitDisk([(0.1, 0.02), (0.12, 0.03), (0.3, 0.3)], 0.1)
    @test length(ud) == 3
    @test (bonds(ud) |> length) == 1
end

include("squarelattice.jl")
