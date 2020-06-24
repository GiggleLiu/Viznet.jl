abstract type AbstractParallelogram <:AbstractLattice end

export Parallelogram, bravais_size, vec_a, vec_b, rectlattice

# square lattice
function Base.getindex(lt::AbstractParallelogram, i::Int)
    lt[CartesianIndices(bravais_size(lt))[i].I...]
end
Base.lastindex(lt::AbstractParallelogram, i::Int) = size(lt, i)
bravais_size(sq::AbstractParallelogram) = size(sq)
bravais_size(sq::AbstractParallelogram, i::Int) = size(sq, i)
function Base.size(sq::AbstractParallelogram, i::Int)
    size(sq)[i]
end
unit(lt::AbstractParallelogram) = 1/(maximum(size(lt, 1) .* vec_a(lt) .+ size(lt, 2) .* vec_b(lt)))
vertices(sq::AbstractParallelogram) = 1:size(sq, 1)*size(sq, 2)

function Base.getindex(lt::AbstractParallelogram, i::Real, j::Real)
    a, b = vec_a(lt), vec_b(lt)
    step = unit(lt)
    res = (i-0.5)*step .* a .+ (j-0.5)*step .* b
    (res[1], res[2])
end

struct Parallelogram <: AbstractParallelogram
    Nx::Int
    Ny::Int
    a::Vector{Float64}
    b::Vector{Float64}
end

rectlattice(Nx::Int, Ny::Int, a, b) = Parallelogram(Nx, Ny, Float64[a, 0], Float64[0, b])

vec_a(p::Parallelogram) = p.a
vec_b(p::Parallelogram) = p.b
Base.size(sq::Parallelogram) = (sq.Nx, sq.Ny)

function isconnected(sq::AbstractParallelogram, i::Int, j::Int)
    CI = CartesianIndices(sq)
    ci = CI[i]
    cj = CI[j]
    (abs(ci.I[1] - cj[1]) == 1 && ci.I[2] == cj.I[2]) ||
    (abs(ci.I[2] - cj[2]) == 1 && ci.I[1] == cj.I[1])
end
