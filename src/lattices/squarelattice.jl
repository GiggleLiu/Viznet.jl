abstract type AbstractSquareLattice <:AbstractLattice end

export SquareLattice, bravais_size

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
    (i-0.5)*step, (j-0.5)*step
end

vertices(sq::SquareLattice) = 1:sq.Nx*sq.Ny

function bonds(sq::SquareLattice; nth::Int=1)
    bbb = [1.0, sqrt(2), 2.0, sqrt(5)]
    if nth > length(bbb)
        error("We haven't implemented more than a general n-th order gradient for n>4.
            Please give us a PR or file an issue!")
    end
    d =  bbb[nth] * unit(sq)
    edges = Tuple{Int,Int}[]
    nv = length(sq)
    for i=1:nv
        for j=i+1:nv
            di = distance(sq[i], sq[j])
            if di > d*0.999 && di < d*1.001
                push!(edges, (i, j))
            end
        end
    end
    edges
end

"""
    unit(lattice)

The unit scale of the lattice.
"""
unit(lt::SquareLattice) = 1/(max(lt.Nx, lt.Ny))
