abstract type AbstractSquareLattice <:AbstractLattice end

# square lattice
function Base.getindex(lt::AbstractSquareLattice, i::Int)
    lt[CartesianIndices(bravais_size(lt))[i].I...]
end
Base.lastindex(lt::AbstractSquareLattice, i::Int) = size(lt, i)
bravais_size(sq::AbstractSquareLattice) = (sq.Nx, sq.Ny)
function bravais_size(sq::AbstractSquareLattice, i::Int)
    if i==1
        size(sq)[1]
    elseif i==2
        size(sq)[2]
    else
        throw(DimensionMismatch("expected dimension 1 or 2, got $i."))
    end
end
Base.size(sq::AbstractSquareLattice, args...) = bravais_size(sq, args...)

struct SquareLattice <: AbstractSquareLattice
    Nx::Int
    Ny::Int
end

function Base.getindex(lt::SquareLattice, i::Int, j::Int)
    step = unit(lt)
    (i-0.5 + lt.r)*step, (j-0.5 + lt.r)*step
end

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
