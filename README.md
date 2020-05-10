# Viznet

A visualization tool for atoms (based on Compose.jl).

[![Build Status](https://travis-ci.com/GiggleLiu/Viznet.jl.svg?branch=master)](https://travis-ci.com/GiggleLiu/Viznet.jl)
[![Codecov](https://codecov.io/gh/GiggleLiu/Viznet.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/GiggleLiu/Viznet.jl)

## To start

To install, type `]` in a Julia REPL and then

```julia pkg
pkg> add https://github.com/GiggleLiu/Viznet.jl
```

As a first example, open a Julia REPL and type

```julia
using Viznet
using Compose

# define you atoms/lattice
ud = rand_unitdisk(20, 2.0)

# set the line brush and node brush
linebrush = bondstyle(:default)
nodebrush = nodestyle(:default)

# draw something on the canvas
canvas() do
    for i in vertices(ud)
        nodebrush >> ud[i]
    end
    for (i, j) in bonds(ud)
        linebrush >> ud[i;j]
    end
end |> SVG("_unitdisk.svg")
```

## Styles
Document eaten by blackhole.
