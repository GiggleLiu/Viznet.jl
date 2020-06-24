using Compose, Viznet
using Test

@testset "sq lattice" begin
    lt = rectlattice(10, 20, 1.0, 1.5)
    @test size(lt, 1) == 10
    @test bravais_size(lt) == (10, 20)
    @test size(lt, 2) == 20
    @test size(lt) == (10, 20)
    @test unit(lt) ≈ 1/30
    @test vec_a(lt) ≈ [1.0, 0.0]
    @test vec_b(lt) ≈ [0.0, 1.5]
end

@testset "bonds" begin
    lt = rectlattice(4, 5, 1.0, 2.0)
    b1s = bonds(lt)
    @test length(b1s) == 31
    ti = true
    for b in b1s
        ti = ti && isconnected(lt, b...)
    end
    @test ti
end
