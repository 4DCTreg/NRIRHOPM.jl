# types for multi-dispatching
abstract AbstractPotential{Order}

# various dialects
typealias UnaryPotential AbstractPotential{1}
typealias DataTerm AbstractPotential{1}
typealias DataCost AbstractPotential{1}

typealias PairwisePotential AbstractPotential{2}
typealias SmoothTerm AbstractPotential{2}
typealias RegularTerm AbstractPotential{2}

typealias TreyPotential AbstractPotential{3}

# unary potentials
"""
Sum of Absolute Differences
"""
type SAD <: DataCost
end

"""
    sum_absolute_diff(fixedImg, movingImg, deformers) -> Vector

Calculates the sum of absolute differences between fixed(target) image
and moving(source) image. Returns a data term tensor(vector).

# Arguments
* `fixedImg::Array{T,N}`: the fixed(target) image.
* `movingImg::Array{T,N}`: the moving(source) image.
* `deformers::Vector{Vector{Int}}`: the transform vectors.
"""
function sum_absolute_diff{T,N}(
    fixedImg::Array{T,N},
    movingImg::Array{T,N},
    deformers::Vector{Vector{Int}}
    )
    imageDims = size(fixedImg)
    imageDims == size(movingImg) || throw(ArgumentError("Image Dimension Mismatch!"))

    imageLen = length(fixedImg)
    deformLen = length(deformers)

    𝐇¹ = zeros(T, imageLen, deformLen)

    pixelRange = CartesianRange(imageDims)
    pixelFirst, pixelEnd = first(pixelRange), last(pixelRange)
    for ii in pixelRange, a in eachindex(deformers)
        i = sub2ind(imageDims, ii[1], ii[2])
        # ϕ(x,y) = i(x,y) + d(x,y)
        ϕxᵢᵢ = ii[1] + deformers[a][1]
        ϕyᵢᵢ = ii[2] + deformers[a][2]
        if pixelFirst[1] <= ϕxᵢᵢ <= pixelEnd[1] && pixelFirst[2] <= ϕyᵢᵢ <= pixelEnd[2]
            ϕᵢ = sub2ind(imageDims, ϕxᵢᵢ, ϕyᵢᵢ)
            𝐇¹[i,a] = -abs(fixedImg[i] - movingImg[ϕᵢ])
        else
            𝐇¹[i,a] = Inf
        end
    end

    # force tensor₁ non-negative
    𝐇¹ -= 1.1minimum(𝐇¹)
    𝐇¹[𝐇¹.==Inf] = 0

    return reshape(𝐇¹, imageLen * deformLen)
end

"""
Mutual Information
"""
type MI <: DataCost
end


# pairwise potentials
"""
Potts Model
"""
type Potts <: SmoothTerm
end

"""
Truncated Absolute Difference
"""
type TAD <: SmoothTerm
end

"""
    truncated_absolute_diff(fp, fq, c, d) -> Float64

Calculates the truncated absolute difference between two transform vectors.
Returns the cost value.

Refer to the following paper for further details:

Felzenszwalb, Pedro F., and Daniel P. Huttenlocher. "Efficient belief propagation
for early vision." International journal of computer vision 70.1 (2006): 41-54.

# Arguments
* `fp::Vector{T<:Integer}`: the transform vector at pixel p.
* `fq::Vector{T<:Integer}`: the transform vector at pixel q.
* `c::Float64`: the rate of increase in the cost.
* `d::Float64`: controls when the cost stops increasing.
"""
truncated_absolute_diff{T<:Integer}(fp::Vector{T}, fq::Vector{T}, c::Float64, d::Float64) = min(c * abs(vecnorm(fp) - vecnorm(fq)), d)

"""
Quadratic Model
"""
type Quadratic <: SmoothTerm
end

# high-order potentials
"""
Topology Preservation
"""
type Topology <: TreyPotential
end
