abstract type AbstractSquareLattice <:AbstractParallelogram end

export SquareLattice

struct SquareLattice <: AbstractSquareLattice
    Nx::Int
    Ny::Int
end

function Base.getindex(lt::SquareLattice, i::Real, j::Real)
    step = unit(lt)
    (i-0.5)*step, (j-0.5)*step
end

Base.size(sq::SquareLattice) = (sq.Nx, sq.Ny)
vertices(sq::SquareLattice) = 1:sq.Nx*sq.Ny
vec_a(sq::SquareLattice) = [1.0, 0.0]
vec_b(sq::SquareLattice) = [0.0, 1.0]

function isconnected(sq::SquareLattice, i::Int, j::Int)
    u = unit(sq)
    d = distance(sq[i], sq[j])
    d > 0.999u && d < 1.001u
end

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
