export vertices, bonds, distance, unit, isconnected
export showlattice

"""
    AbstractSites

Abstrat type for all lattice or non-lattice atom collections.
The interface includes

* `vertices`
* `bonds`
* `Base.getindex`
"""
abstract type AbstractSites end
abstract type AbstractLattice <: AbstractSites end

"""
    vertices(sites)

Get the vertices for the site collection.
"""
function vertices end

"""
    isconnected(lattice, i, j; kwargs...)

return true if sites `i` and `j` are connected.
"""
function bonds end

"""
    bond(sites, i, j)

Get the bond (a pair of tuples) for the site `i` and `j`.
One can also access it with `sites[i; j]`.
"""
function bond(lt::AbstractSites, loc1::Tuple, loc2::Tuple)
    lt[loc1...], lt[loc2...]
end
function bond(lt::AbstractSites, loc1, loc2)
    lt[loc1], lt[loc2]
end
function bond(lt::AbstractSites, loc1::CartesianIndex, loc2::CartesianIndex)
    lt[loc1.I...], lt[loc2.I...]
end

Base.typed_vcat(lt::AbstractSites, loc1, loc2) = bond(lt, loc1, loc2)

distance(i::Tuple{T,T}, j::Tuple{T,T}) where T<:Real = sqrt((i[1] - j[1])^2 + (i[2] - j[2])^2)
Base.length(lt::AbstractSites) = length(vertices(lt))

"""
    bonds(atoms)

Get the bonds for the atom collection.
"""
function bonds(ud::AbstractSites)
    edges = Tuple{Int,Int}[]
    n = length(ud)
    for i = 1:n
        for j = i+1:n
            if isconnected(ud, i, j)
                push!(edges, (i,j))
            end
        end
    end
    return edges
end

function showlattice(lt; line_style=compose(bondstyle(:default), stroke("black")),
        node_style=compose(context(), nodestyle(:default), stroke("black"), fill("white"), linewidth(0.5mm)),
        text_style=textstyle(:default))
    empty_cache!()
    for node in vertices(lt)
        node_style >> lt[node]
        text_style >> (lt[node], "$node")
    end
    for bond in bonds(lt)
        line_style >> lt[bond[1]; bond[2]]
    end
    flush!()
end


include("unitdisk.jl")
include("squarelattice.jl")
include("chimera.jl")
