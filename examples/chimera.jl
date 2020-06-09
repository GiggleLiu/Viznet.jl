using Viznet
using Compose

function show_chimera(Lx, Ly)
    lt = ChimeraLattice(Lx, Ly)
    g = canvas() do
        r = compose(context(), bondstyle(:lcurve), stroke("red"))
        b = compose(context(), bondstyle(:ucurve), stroke("blue"))
        rb = compose(context(), bondstyle(:default), stroke("black"))
        rnode=compose(context(), nodestyle(:default), stroke("silver"), fill("red"), linewidth(0.2mm))
        bnode=compose(context(), nodestyle(:default), stroke("silver"), fill("blue"), linewidth(0.2mm))
        text_style=textstyle(:default)

        for node in vertices(lt)
            if mod1(node, 8) <=4
                rnode >> lt[node]
            else
                bnode >> lt[node]
            end
            if node <= 16
                text_style >> (lt[node], "$node")
            end
        end
        rbonds = Tuple{Int,Int}[]
        bbonds = Tuple{Int,Int}[]
        rbbonds = Tuple{Int,Int}[]
        Viznet.red_bond!(lt, 1, rbonds)
        Viznet.redblack_bond!(lt, 1, rbbonds)
        for i=2:lt.Nx
            # BLACK
            Viznet.black_bond!(lt, i-1, bbonds)
            # Contract with RED
            Viznet.red_bond!(lt, i, rbonds)
            Viznet.redblack_bond!(lt, i, rbbonds)
        end
        for bond in rbonds
            r >> lt[bond[1]; bond[2]]
        end
        for bond in bbonds
            b >> lt[bond[1]; bond[2]]
        end
        for bond in rbbonds
            rb >> lt[bond[1]; bond[2]]
        end
    end
    compose(context(0.05, 0.05, 0.9, 0.9), g)
end

show_chimera(5,3) |> SVG("_chimera.svg")
