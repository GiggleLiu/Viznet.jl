export bondstyle, nodestyle, textstyle

function bondstyle(shape::Symbol, properties...; r=0.075, dashed=false, dash_params=[1mm, 1mm])
    if !any(x->x isa Compose.Property{Compose.StrokePrimitive}, properties)
        properties = (properties..., stroke("black"))
    end
    if dashed
        properties = (properties..., strokedash(dash_params))
    end
    if shape == :arrow
        return compose(context(), arrow(), (context(), line()), properties...)
    end
    geometry = if shape == :line || shape==:default
        line()
    elseif shape == :rcurve
        curve((0.0, 0.0), (r, 0.0), (r, 1.0), (0.0,1.0))
    elseif shape == :lcurve
        curve((0.0, 0.0), (-r, 0.0), (-r, 1.0), (0.0,1.0))
    elseif shape == :dcurve
        curve((0.0, 0.0), (0.0, r), (1.0, r), (1.0,0.0))
    elseif shape == :ucurve
        curve((0.0, 0.0), (0.0, -r), (1.0, -r), (1.0,0.0))
    else
        error("shape $shape not defined.")
    end
    compose(context(), geometry, properties...)
end

function nodestyle(shape::Symbol, properties...; r=0.02, θ=0.0)
    geometry = if shape == :circle || shape==:default
        circle(0.0, 0.0, r)
    elseif shape == :diamond
        rot_ngon(θ, 0.0, 0.0, r, 4)
    elseif shape == :square
        rectangle(-r, -r, 2r, 2r)
    elseif shape == :triangle
        rot_ngon(θ, 0.0, 0.0, r, 3)
    else
        error("shape $shape not defined.")
    end
    compose(context(), geometry, properties...)
end

function textstyle(shape::Symbol, properties...)
    if shape == :default
        compose(context(), text(0.0, 0.0, "", hcenter, vcenter), properties...)
    else
        error("shape $shape not defined.")
    end
end

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
