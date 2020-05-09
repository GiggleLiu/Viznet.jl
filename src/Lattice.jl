abstract type SiteCollection end
abstract type AbstractLattice <: SiteCollection end

function bond(lt::SiteCollection, loc1, loc2)
    lt[loc1...], lt[loc2...]
end
Base.typed_vcat(lt::SiteCollection, loc1, loc2) = bond(lt, loc1, loc2)

unit(lt::SquareLattice) = 1/(max(lt.Nx, lt.Ny)+2*lt.r)

function locs(sq::SquareLattice)
    xs = Float64[]
    ys = Float64[]
    for j=1:size(sq, 2), i=1:size(sq, 1)
        xi, yi = sq[i,j]
        push!(xs, xi)
        push!(ys, yi)
    end
    return xs, ys
end

@testset "lattice" begin
    lt = SquareLattice(5,5)
end

function lattice(lt; line_style=compose(context()), node_style=compose(context()))
    cvs = canvas(lt) do
        for node in vertices(lt)
            line_style >> lt[node]
            line_style >> lt[node]
            line_style >> lt[i; j]
        end
    end
end
