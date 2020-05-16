using Viznet
using Test

@testset "chimera" begin
    lt = ChimeraLattice(3,3)
    @test length(lt) == 72 == length(CartesianIndices(lt)) == length(LinearIndices(lt))
    @test length(bonds(lt)) == 16*9 + (2*4*3)*2
end
