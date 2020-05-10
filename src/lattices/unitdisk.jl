export UnitDisk, rand_unitdisk

struct UnitDisk{T} <: AbstractSites
    locs::Vector{Tuple{T,T}}
    unit::T
end

unit(ud::UnitDisk) = ud.unit

vertices(ud::UnitDisk) = 1:length(ud.locs)
Base.getindex(ud::UnitDisk, i::Int) = ud.locs[i]

function bonds(ud::UnitDisk)
    edges = Tuple{Int,Int}[]
    n = length(ud)
    for i = 1:n
        for j = i+1:n
            if distance(ud[i], ud[j]) <= ud.unit
                push!(edges, (i,j))
            end
        end
    end
    return edges
end

function rand_unitdisk(n::Int, ρ::Real; ndims::Int=2)
    unit = (ρ/n)^(1/ndims)
    UnitDisk([(rand(ndims)...,) for i=1:n], unit)
end
