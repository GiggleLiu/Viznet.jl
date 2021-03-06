export ChimeraLattice

struct ChimeraLattice <: AbstractLattice
    Nx::Int
    Ny::Int
end

vertices(lt::ChimeraLattice) = 1:8*lt.Nx*lt.Ny
bravais_size(cl::ChimeraLattice) = (cl.Nx, cl.Ny)
function bravais_size(cl::ChimeraLattice, i::Int)
    if i==1
        cl.Nx
    elseif i==2
        cl.Ny
    else
        DimensionMismatch("expect dimension 1 or 2, got $i")
    end
end
Base.size(lt::ChimeraLattice) = (8, lt.Nx, lt.Ny)

gap_x(lt::ChimeraLattice) = 0.5
gap_y(lt::ChimeraLattice) = 0.5
unit(lt::ChimeraLattice) = 1/(max(lt.Nx*(2+gap_x(lt)), lt.Ny*(4+gap_y(lt))))

# for beautiful printing.
function Base.getindex(lt::ChimeraLattice, k::Int, i::Int, j::Int)
    ki = (k-1) ÷ 4
    kj = mod1(k, 4)-1
    x = ((i-1)*(gap_x(lt) + 2)+ki+0.5)*unit(lt)
    y = ((j-1)*(gap_y(lt) + 4)+kj+0.5)*unit(lt)
    return (x+0.01*kj, y+0.02*ki)
end

function Base.getindex(lt::ChimeraLattice, i::Int)
    CI = CartesianIndices(size(lt))
    lt[CI[i].I...]
end

function bonds(lt::ChimeraLattice)
    bonds = Tuple{Int,Int}[]
    red_bond!(lt, 1, bonds)
    redblack_bond!(lt, 1, bonds)
    for i=2:lt.Nx
        # BLACK
        black_bond!(lt, i-1, bonds)
        # Contract with RED
        red_bond!(lt, i, bonds)
        redblack_bond!(lt, i, bonds)
    end
    return bonds
end

function red_bond!(lt, i::Int, bonds)
    CI = LinearIndices(lt |> size)
    for j=1:lt.Ny-1
        for k = 1:4
            push!(bonds, (CI[k, i, j], CI[k, i, j+1]))
        end
    end
    return bonds
end

function redblack_bond!(lt, i::Int, bonds)
    CI = LinearIndices(lt |> size)
    for j=1:lt.Ny
        for k2=5:8
            for k1=1:4
                push!(bonds, (CI[k2, i, j], CI[k1, i, j]))
            end
        end
    end
    return bonds
end

function black_bond!(lt, i::Int, bonds)
    CI = LinearIndices(lt |> size)
    for j=1:lt.Ny
        for k = 5:8
            push!(bonds, (CI[k,i,j], CI[k,i+1,j]))
        end
    end
    return bonds
end
