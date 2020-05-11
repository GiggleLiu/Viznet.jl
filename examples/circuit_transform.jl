using Compose, Viznet

set_default_graphic_size(12cm, 12cm)

dot = nodestyle(:circle;r = 0.005)
diamond = nodestyle(:diamond)
tri1 = nodestyle(:triangle; θ=π/2)
tri2 = nodestyle(:triangle; θ=-π/2)
sq = nodestyle(:square; r=0.015)
e1 = bondstyle(:default)
lt = SquareLattice(10, 10)

function vnode(node)
    canvas() do
        lt = SquareLattice(6, 6)
        for v in vertices(lt)
            node >> lt[v]
        end
    end
end

function circuit_body()
    for i in vertices(lt)
        dot >> lt[i]
    end
    for (i, j) in bonds(lt)
        center = (lt[i] .+ lt[j]) ./ 2
        (lt[i][1]!=lt[j][1] ? sq : diamond) >> center
    end
    for i=1:lt.Nx
        e1 >> lt[(i,1);(i,lt.Ny)]
    end
    for j=1:lt.Ny
        e1 >> lt[(1,j);(lt.Nx,j)]
    end
end

function circuit_ends()
    for j=1:lt.Ny
        e1 >> lt[(0,j);(lt.Nx+1,j)]
        tri1 >> lt[0,j]
        tri2 >> lt[lt.Nx+1,j]
    end
end

compose(context(0.1,0.1,0.8,0.8), canvas() do
    circuit_body()
    circuit_ends()
end)
