using Compose, Viznet
using Test

@testset "sq lattice" begin
    lt = SquareLattice(10, 20)
    @test size(lt, 1) == 10
    @test bravais_size(lt) == (10, 20)
    @test size(lt, 2) == 20
    @test size(lt) == (10, 20)
    @test all(lt[1,1] .≈ (unit(lt) * (0.5), unit(lt) * (0.5)))
    lt = SquareLattice(10, 10)
    @test all(lt[end,end] .≈ (1-unit(lt) * (0.5), 1-unit(lt) * (0.5)))
end

@testset "bonds" begin
    lt = SquareLattice(4, 5)
    b1s = bonds(lt; nth=1)
    @test length(b1s) == 31
    for b in b1s
        @test isconnected(lt, b...)
    end
    @test length(bonds(lt; nth=2)) == 24
    @test length(bonds(lt; nth=3)) == 22
    @test length(bonds(lt; nth=4)) == 34
end
