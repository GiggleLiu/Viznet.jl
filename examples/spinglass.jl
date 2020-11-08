using Viznet
using Compose
using Random
Random.seed!(4)

function spinglass(lt, coulping::Vector)
    nodebrush = nodestyle(:default; r=0.011)
    eb1 = bondstyle(:default, linewidth(1mm), stroke("skyblue"))
    eb2 = bondstyle(:default, linewidth(1mm), stroke("orange"))
    _coupling = copy(coulping)
    eb() = popfirst!(_coupling) > 0 ? eb1 : eb2
    g = canvas() do
        for v in vertices(lt)
            nodebrush >> lt[v]
        end
        for j=1:lt.Ny-1
            eb() >> lt[(1,j); (1,j+1)]
        end
        for i=2:lt.Nx
            for j=1:lt.Ny
                eb() >> lt[(i-1,j); (i,j)]
            end
            for j=1:lt.Ny-1
                eb() >> lt[(i,j); (i,j+1)]
            end
        end
    end
    compose(context(), g, )
end

L = 20
lt = SquareLattice(L, L)
set_default_graphic_size(12cm, 12cm)
spinglass(lt, rand([-1, 1], L*(L-1)*2)) |> SVG("_spinglass.svg")
