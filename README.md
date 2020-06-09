# Viznet

A visualization tool for atoms (based on Compose.jl).

Warning: still under development...

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
sq = SquareLattice(5, 5)

# set the line brush and node brush
linebrush = compose(context(), bondstyle(:default), stroke("black"))
nodebrush = nodestyle(:default)

# draw something on the canvas
canvas() do
    for i in vertices(sq)
        nodebrush >> sq[i]
    end
    for (i, j) in bonds(sq)
        linebrush >> sq[i;j]
    end
end |> SVG("squarelattice.svg")
```

To learn more about customizing styles, please go to the documentation of [Compose.jl](http://giovineitalia.github.io/Compose.jl/latest/).

## Gallery
##### [Spin glass](examples/spinglass.jl)

![spinglass](examples/spinglass.svg)

##### [Chimera Lattice](examples/chimera.jl)
![chimera](examples/chimera.svg)


## Styles
Document eaten by a blackhole.
