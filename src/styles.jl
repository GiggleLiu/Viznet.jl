export bondstyle, nodestyle, textstyle

bondstyle(x::Symbol; kwargs...) = bondstyle(Val(x); kwargs...)
bondstyle(::Val{:default}) = bondstyle(Val(:line))
bondstyle(::Val{:line}) = compose(context(), line())
bondstyle(::Val{:rcurve}) = compose(context(), curve((0.0, 0.0), (0.075, 0.0), (0.075, 1.0), (0.0,1.0)))
bondstyle(::Val{:lcurve}) = compose(context(), curve((0.0, 0.0), (-0.075, 0.0), (-0.075, 1.0), (0.0,1.0)))
bondstyle(::Val{:dcurve}) = compose(context(), curve((0.0, 0.0), (0.0, 0.075), (1.0, 0.075), (1.0,0.0)))
bondstyle(::Val{:ucurve}) = compose(context(), curve((0.0, 0.0), (0.0, -0.075), (1.0, -0.075), (1.0,0.0)))
bondstyle(::Val{:arrow}) = compose(context(), arrow(),
                                   (context(), line()))

nodestyle(x::Symbol; kwargs...) = nodestyle(Val(x); kwargs...)
nodestyle(::Val{:default}; r::Real=0.02) = nodestyle(Val(:circle); r=r)
nodestyle(::Val{:circle}; r::Real=0.02) = compose(context(), circle(0.0, 0.0, r))
nodestyle(::Val{:diamond}; r::Real=0.02, θ::Real=0.0) = compose(context(), rot_ngon(θ, 0.0, 0.0, r, 4))
nodestyle(::Val{:square}; r::Real=0.02) = compose(context(), rectangle(-r, -r, 2r, 2r))
nodestyle(::Val{:triangle}; r::Real=0.02, θ::Real=0.0) = compose(context(), rot_ngon(θ, 0.0, 0.0, r, 3))

textstyle(x::Symbol; kwargs...) = textstyle(Val(x); kwargs...)
textstyle(::Val{:default}) = textstyle(Val(:center))
textstyle(::Val{:center}; r::Real=0.02, θ::Real=0.0) = compose(context(), text(0.0, 0.0, "", hcenter, vcenter))

"""
    rot(a, b, θ)

rotate variables `a` and `b` by an angle `θ`
"""
function rot(a, b, θ)
    s, c = sincos(θ)
    a*c-b*s, a*s+b*c
end

function rot_polygon(θ::Real, points::AbstractVector)
    polygon(map(x->rot(x..., θ), points))
end

function rot_ngon(θ::Real, args...; kwargs...)
    c = first(ngon(args..., kwargs...).primitives)
    rot_polygon(θ, map(x->_value.(x), c.points))
end

_value(x::Compose.Add) = _value(x.a) + _value(x.b)
_value(x::Compose.Length) = x.value
