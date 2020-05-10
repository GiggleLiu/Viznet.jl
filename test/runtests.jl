using Viznet
using Test

@testset "brush" begin
    include("brush.jl")
end

@testset "lattices" begin
    include("lattices/lattices.jl")
end
