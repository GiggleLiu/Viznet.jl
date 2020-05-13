export intersection
using Dierckx: Spline1D

"""
get the intersection point from direction specified by theta.

Args:
    line (2darray): an array of points.
    theta (float): direction of the intersection line.
    align (len-2 tuple): align to this point in the free dimension.

Returns:
    tuple: the nearest intersection point.
"""
function intersection(line::Vector{PointT}, theta::Real, align::PointT)
    trans(dot, theta) = Base.reverse(rot(dot..., -theta))
    trans_r(dot, theta) = rot(dot[2], dot[1], theta)

    # rotate to y-axis
    rotated_line = trans.(line, theta)
    rotated_xy = trans(align, theta)

    # get segments
    p_pre = rotated_line[1]
    segment = [p_pre]
    segments = Vector{PointT}[]
    direction_pre = 0
    for i = 2:size(rotated_line, 1)
        p = rotated_line[i]
        direction = p[1] > p_pre[1] ? 1 : -1
        if direction * direction_pre < 0
            push!(segments, segment)
            segment = [p_pre, p]
        else
            push!(segment, p)
        end
        direction_pre = direction
        p_pre = p
    end
    push!(segments, segment)

    # intersect segments
    x = rotated_xy[1]
    ys = []
    for segment in segments
        x_ = getindex.(segment, 1)
        y_ = getindex.(segment, 2)
        @show x_, y_
        try
            f = Spline1D(x_, y_; k=1)
            push!(ys, f(x))
        catch e
        end
    end

    # interpolate x
    if isempty(ys)
        error("Can not find connection point!")
    end
    index = argmax(ys)
    trans_r((x, ys[index]), theta)
end
