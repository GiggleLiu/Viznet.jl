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
