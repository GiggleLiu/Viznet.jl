export UnitDisk, rand_unitdisk

struct UnitDisk{T} <: AbstractSites
    locs::Vector{Tuple{T,T}}
    unit::T
end

unit(ud::UnitDisk) = ud.unit

vertices(ud::UnitDisk) = 1:length(ud.locs)
Base.getindex(ud::UnitDisk, i::Int) = ud.locs[i]

isconnected(ud, i, j) = distance(ud[i], ud[j]) <= ud.unit

function rand_unitdisk(n::Int, ρ::Real; ndims::Int=2)
    unit = (ρ/n)^(1/ndims)
    UnitDisk([(rand(ndims)...,) for i=1:n], unit)
end
