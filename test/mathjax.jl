using Viznet, Test

@testset "mathjax" begin
    @test isa(mathjax(0.5,0.4,0.1,0.2,raw"\frac{x}{2}"), Viznet.MathJax)
    @test isa(mathjax(rand(2),rand(2),rand(2),rand(2),[raw"\frac{x}{2}",raw"\frac{x}{3}"]), Viznet.MathJax)
end
