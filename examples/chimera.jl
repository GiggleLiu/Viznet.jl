
struct ChimeraLattice <: AbstractLattice
    Lx::Int
    Ly::Int
end

struct ChimeraApp{TYPE<:Jtype, T}
    lt::ChimeraLattice
    Js::Vector{T}
    jtype::TYPE
end

bravais_size(cl::ChimeraLattice) = (cl.Lx, cl.Ly)
function bravais_size(cl::ChimeraLattice, i::Int)
    if i==1
        cl.Lx
    elseif i==2
        cl.Ly
    else
        DimensionMismatch("expect dimension 1 or 2, got $i")
    end
end
