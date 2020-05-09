using Compose

include("../Lattice.jl")

set_default_graphic_size(4cm, 4cm)

using Test
@testset "sq lattice" begin
    lt = SquareLattice(10, 20, 0.2)
    @test size(lt, 1) == 10
    @test size(lt, 2) == 20
    @test size(lt) == (10, 20)
    @test all(lt[1,1] .≈ (unit(lt) * (lt.r+0.5), unit(lt) * (lt.r+0.5)))
    lt = VizSquareLattice(10, 10, 0.2)
    @test all(lt[end,end] .≈ (1-unit(lt) * (lt.r+0.5), 1-unit(lt) * (lt.r+0.5)))
end

rs(lt::VizSquareLattice) = fill(lt.r*unit(lt), lt.Nx, lt.Ny)

function lattice(lt)
    circle(locs(lt)..., rs(lt))
end

using Colors
function showbonds(Nx::Int, Ny::Int, color_sites::AbstractMatrix, color_bonds::AbstractVector;
                filename="_lattice.svg")
    lt = SquareLattice(Nx, Ny, 0.3)
    scolors = LCHab.(vec(color_sites).*200, 230, 57)
    composition = compose(context(0.1,0.1,0.8,0.8,rotation=Rotation(π/4,0.5,0.5)),
        (context(), lattice(lt), fill(scolors), stroke("silver"), linewidth(0.05mm)),
        #(context(), circle(lt[1,1]..., 0.04)),
        #(context(), circle(lt[2,1]..., 0.04)),
        map(cb->(context(), line(map(x->bond(lt, x...), cb.second)), stroke(cb.first), linewidth(0.5mm)), color_bonds)...
        )
    composition |> SVG(filename)
end

# showbonds(10, 10, [("red"=>[(2,3), (4,5)])])