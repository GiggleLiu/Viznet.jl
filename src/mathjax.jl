using Compose: x_measure, y_measure, Rotation, Vec, Vec2, svg_print_float, resolve, Form, FormPrimitive,
    @makeform, Transform, UnitBox, AbsoluteBox, empty_tag, indent, print_vector_properties

export mathjax

# MathJaxPrimitive form
struct MathJaxPrimitive{P<:Vec, S<:Vec, R<:Rotation, O<:Vec} <: FormPrimitive
    position::P
    size::S
    value::AbstractString
    rot::R
    offset::O
end

const MathJax{P<:MathJaxPrimitive} = Form{P}
Compose.form_string(::MathJax) = "MATH"

"""
    mathjax(x, y, width, heigh, value [,rot::Rotation])

Draw the text `value` at the position (`x`,`y`) relative to the current context.
Parameters `width` and `height` specify the bounding box size.
"""
function mathjax(x, y, width, height, value::AbstractString,
              rot=Rotation(), offset::Vec2=(0mm,0mm);
              tag::Symbol=empty_tag)
    moffset = (x_measure(offset[1]), y_measure(offset[2]))
    prim = MathJaxPrimitive((x_measure(x), y_measure(y)), (x_measure(width), y_measure(height)), string(value), rot, moffset)
    MathJax{typeof(prim)}([prim], tag)
end

"""
    mathjax(xs::AbstractArray, ys::AbstractArray, ws::AbstractArray, hs::AbstractArray, values::AbstractArray [,rots::Rotation])

Arguments can be passed in arrays in order to perform multiple drawing operations at once.
"""
mathjax(xs::AbstractArray, ys::AbstractArray, ws::AbstractArray, hs::AbstractArray, values::AbstractArray{<:AbstractString},
              rots::AbstractArray=[Rotation()], offsets::AbstractArray=[(0mm,0mm)];
              tag::Symbol=empty_tag) =
    @makeform (x in xs, y in ys, w in ws, h in hs, value in values, rot in rots, offset in offsets),
    MathJaxPrimitive((x_measure(x), y_measure(y)), (x_measure(w), y_measure(h)), value, rot, (x_measure(offset[1]), y_measure(offset[2]))) tag

function Compose.resolve(box::AbsoluteBox, units::UnitBox, t::Transform, p::MathJaxPrimitive)
    rot = resolve(box, units, t, p.rot)
    return MathJaxPrimitive(
                resolve(box, units, t, p.position),
                resolve(box, units, t, p.size),
                p.value, rot, p.offset)
end

function Compose.boundingbox(form::MathJaxPrimitive, linewidth::Measure,
                     font::AbstractString, fontsize::Measure)

    width, height = form.size
    x0 = form.position.x
    y0 = form.position.y

    return BoundingBox(x0 - linewidth + form.offset[1],
                       y0 - linewidth + form.offset[2],
                       width + linewidth,
                       height + linewidth)
end

function Compose.draw(img::SVG, prim::MathJaxPrimitive, idx::Int)
    indent(img)

    img.indentation += 1
    print(img.out, "<g transform=\"translate(")
    svg_print_float(img.out, prim.position[1].value)
    print(img.out, ",")
    svg_print_float(img.out, prim.position[2].value)
    print(img.out, ")\"")
    print_vector_properties(img, idx, true)
    print(img.out, ">\n")
    indent(img)

    print(img.out, "<g class=\"primitive\">\n")
    img.indentation += 1
    indent(img)
    print(img.out, """<foreignObject x="0" y="0" """)

    if abs(prim.rot.theta) > 1e-4 || sum(abs.(prim.offset)) > 1e-4mm
        print(img.out, " transform=\"")
        if abs(prim.rot.theta) > 1e-4
            print(img.out, "rotate(")
            svg_print_float(img.out, rad2deg(prim.rot.theta))
            print(img.out, ",")
            svg_print_float(img.out, prim.rot.offset[1].value-prim.position[1].value)
            print(img.out, ", ")
            svg_print_float(img.out, prim.rot.offset[2].value-prim.position[2].value)
            print(img.out, ")")
        end
        if sum(abs.(prim.offset)) > 1e-4mm
            print(img.out, "translate(")
            svg_print_float(img.out, prim.offset[1].value)
            print(img.out, ",")
            svg_print_float(img.out, prim.offset[2].value)
            print(img.out, ")")
        end
        print(img.out, "\"")
    end

    print(img.out, """ width="$(prim.size[1])" height="$(prim.size[2])">
          <div xmlns="http://www.w3.org/1999/xhtml">
    \\(\\displaystyle{$(prim.value)}\\)
    </div>
</foreignObject>""")

    img.indentation -= 1
    indent(img)
    print(img.out, "</g>\n")
    img.indentation -= 1
    indent(img)
    print(img.out, "</g>\n")
end

