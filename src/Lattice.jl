export vertices, bonds, distance, render
abstract type AbstractSites end
abstract type AbstractLattice <: AbstractSites end

"""
    vertices(sites)

Get the vertices for the site collection.
"""
function vertices end

"""
    bonds(sites)

Get the bonds for the site collection.
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
Base.typed_vcat(lt::AbstractSites, loc1, loc2) = bond(lt, loc1, loc2)

distance(i::Tuple{T,T}, j::Tuple{T,T}) where T<:Real = sqrt((i[1] - j[1])^2 + (i[2] - j[2])^2)
Base.length(lt::AbstractSites) = length(vertices(lt))

function render(lt; line_style=bondstyle(:default), node_style=nodestyle(:default))
    empty_cache!()
    for node in vertices(lt)
        node_style >> lt[node]
    end
    for bond in bonds(lt)
        line_style >> lt[bond[1]; bond[2]]
    end
    flush!()
end
