export bondstyle, nodestyle

bondstyle(x::Symbol; kwargs...) = bondstyle(Val(x); kwargs...)
bondstyle(::Val{:default}) = compose(context(), line(), stroke("black"))

nodestyle(x::Symbol; kwargs...) = nodestyle(Val(x); kwargs...)
nodestyle(::Val{:default}; r::Real=0.02) = compose(context(), circle(0.0, 0.0, r))
