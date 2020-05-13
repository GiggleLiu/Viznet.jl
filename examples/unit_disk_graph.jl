using Viznet
using Compose
using Random
Random.seed!(4)

ud = rand_unitdisk(20, 2.0)

function fancy_unitdisk(ud)
    unitc = compose(context(),
        circle(0.0, 0.0, ud.unit/2),
        stroke("gray"),
        fill("transparent"),
        strokedash([1mm,1mm]),
        )
    g1 = showlattice(ud)
    g2 = canvas() do
        unitc >> ud[1]
        unitc >> ud[7]
    end
    compose(context(), g2, g1)
end


fancy_unitdisk(ud) |> SVG("_unitdisk.svg")
