# types for multi-dispatching
abstract Neighborhood{Dimension,CliqueSize}

abstract Connected4{CliqueSize} <: Neighborhood{2,CliqueSize}
abstract Connected8{CliqueSize} <: Neighborhood{2,CliqueSize}
abstract Connected6{CliqueSize} <: Neighborhood{3,CliqueSize}
abstract Connected26{CliqueSize} <: Neighborhood{3,CliqueSize}

typealias SquareCubic Union{Connected8{2}, Connected26{2}}

function neighbors{T<:SquareCubic}(::Type{T}, imageDims)
    idx = NTuple{2,Int}[]
    pixelRange = CartesianRange(imageDims)
    pixelFirst, pixelEnd = first(pixelRange), last(pixelRange)
    for 𝒊 in pixelRange
        i = sub2ind(imageDims, 𝒊.I...)
        neighborRange = CartesianRange(max(pixelFirst, 𝒊-pixelFirst), min(pixelEnd, 𝒊+pixelFirst))
        for 𝐣 in neighborRange
            if 𝐣 < 𝒊
                j = sub2ind(imageDims, 𝐣.I...)
                push!(idx, (i,j))
            end
        end
    end
    return idx
end

function neighbors(::Type{Connected8{3}}, imageDims::NTuple{2,Int})
    # 8-Connected neighborhood for 3-element cliques
    # since the tensor is symmetric, we only consider the following cliques:
    #   □ ⬓ □        ⬓                ⬓      r,c-->    ⬔ => 𝒊 => p1 => α
    #   ▦ ⬔ ▦  =>  ▦ ⬔   ▦ ⬔    ⬔ ▦   ⬔ ▦    |         ⬓ => 𝐣 => p2 => β
    #   □ ⬓ □              ⬓    ⬓            ↓         ▦ => 𝐤 => p3 => χ
    #              Jᵇᵇ   Jᶠᵇ    Jᶠᶠ   Jᵇᶠ
    idxJᶠᶠ = NTuple{3,Int}[]
    idxJᵇᶠ = NTuple{3,Int}[]
    idxJᶠᵇ = NTuple{3,Int}[]
    idxJᵇᵇ = NTuple{3,Int}[]
    pixelRange = CartesianRange(imageDims)
    pixelFirst, pixelEnd = first(pixelRange), last(pixelRange)
    for 𝒊 in pixelRange
        i = sub2ind(imageDims, 𝒊.I...)
        neighborRange = CartesianRange(max(pixelFirst, 𝒊-pixelFirst), min(pixelEnd, 𝒊+pixelFirst))

        𝐣 = 𝒊 + CartesianIndex(1,0)
        𝐤 = 𝒊 + CartesianIndex(0,1)
        if 𝐣 in neighborRange && 𝐤 in neighborRange
            j = sub2ind(imageDims, 𝐣.I...)
            k = sub2ind(imageDims, 𝐤.I...)
            push!(idxJᶠᶠ, (i,j,k))
        end

        𝐣 = 𝒊 - CartesianIndex(1,0)
        𝐤 = 𝒊 + CartesianIndex(0,1)
        if 𝐣 in neighborRange && 𝐤 in neighborRange
            j = sub2ind(imageDims, 𝐣.I...)
            k = sub2ind(imageDims, 𝐤.I...)
            push!(idxJᵇᶠ, (i,j,k))
        end

        𝐣 = 𝒊 + CartesianIndex(1,0)
        𝐤 = 𝒊 - CartesianIndex(0,1)
        if 𝐣 in neighborRange && 𝐤 in neighborRange
            j = sub2ind(imageDims, 𝐣.I...)
            k = sub2ind(imageDims, 𝐤.I...)
            push!(idxJᶠᵇ, (i,j,k))
        end

        𝐣 = 𝒊 - CartesianIndex(1,0)
        𝐤 = 𝒊 - CartesianIndex(0,1)
        if 𝐣 in neighborRange && 𝐤 in neighborRange
            j = sub2ind(imageDims, 𝐣.I...)
            k = sub2ind(imageDims, 𝐤.I...)
            push!(idxJᵇᵇ, (i,j,k))
        end
    end
    return idxJᶠᶠ, idxJᵇᶠ, idxJᶠᵇ, idxJᵇᵇ
end

function neighbors(::Type{Connected26{4}}, imageDims::NTuple{3,Int})
    # 26-Connected neighborhood for 4-element cliques
    # coordinate system(r,c,z):
    #  up  r     c --->        z × × (front to back)
    #  to  |   left to right     × ×
    # down ↓
    # coordinate => point => label:
    # 𝒊 => p1 => α   𝐣 => p2 => β   𝐤 => p3 => χ   𝐦 => p5 => δ
    idxJᶠᶠᶠ = NTuple{4,Int}[]
    idxJᵇᶠᶠ = NTuple{4,Int}[]
    idxJᶠᵇᶠ = NTuple{4,Int}[]
    idxJᵇᵇᶠ = NTuple{4,Int}[]
    idxJᶠᶠᵇ = NTuple{4,Int}[]
    idxJᵇᶠᵇ = NTuple{4,Int}[]
    idxJᶠᵇᵇ = NTuple{4,Int}[]
    idxJᵇᵇᵇ = NTuple{4,Int}[]
    pixelRange = CartesianRange(imageDims)
    pixelFirst, pixelEnd = first(pixelRange), last(pixelRange)
    for 𝒊 in pixelRange
        i = sub2ind(imageDims, 𝒊.I...)
        neighborRange = CartesianRange(max(pixelFirst, 𝒊-pixelFirst), min(pixelEnd, 𝒊+pixelFirst))

        𝐣 = 𝒊 + CartesianIndex(1,0,0)
        𝐤 = 𝒊 + CartesianIndex(0,1,0)
        𝐦 = 𝒊 + CartesianIndex(0,0,1)
        if 𝐣 in neighborRange && 𝐤 in neighborRange && 𝐦 in neighborRange
            j = sub2ind(imageDims, 𝐣.I...)
            k = sub2ind(imageDims, 𝐤.I...)
            m = sub2ind(imageDims, 𝐦.I...)
            push!(idxJᶠᶠᶠ, (i,j,k,m))
        end

        𝐣 = 𝒊 - CartesianIndex(1,0,0)
        𝐤 = 𝒊 + CartesianIndex(0,1,0)
        𝐦 = 𝒊 + CartesianIndex(0,0,1)
        if 𝐣 in neighborRange && 𝐤 in neighborRange && 𝐦 in neighborRange
            j = sub2ind(imageDims, 𝐣.I...)
            k = sub2ind(imageDims, 𝐤.I...)
            m = sub2ind(imageDims, 𝐦.I...)
            push!(idxJᵇᶠᶠ, (i,j,k,m))
        end

        𝐣 = 𝒊 + CartesianIndex(1,0,0)
        𝐤 = 𝒊 - CartesianIndex(0,1,0)
        𝐦 = 𝒊 + CartesianIndex(0,0,1)
        if 𝐣 in neighborRange && 𝐤 in neighborRange && 𝐦 in neighborRange
            j = sub2ind(imageDims, 𝐣.I...)
            k = sub2ind(imageDims, 𝐤.I...)
            m = sub2ind(imageDims, 𝐦.I...)
            push!(idxJᶠᵇᶠ, (i,j,k,m))
        end

        𝐣 = 𝒊 - CartesianIndex(1,0,0)
        𝐤 = 𝒊 - CartesianIndex(0,1,0)
        𝐦 = 𝒊 + CartesianIndex(0,0,1)
        if 𝐣 in neighborRange && 𝐤 in neighborRange && 𝐦 in neighborRange
            j = sub2ind(imageDims, 𝐣.I...)
            k = sub2ind(imageDims, 𝐤.I...)
            m = sub2ind(imageDims, 𝐦.I...)
            push!(idxJᵇᵇᶠ, (i,j,k,m))
        end

        𝐣 = 𝒊 + CartesianIndex(1,0,0)
        𝐤 = 𝒊 + CartesianIndex(0,1,0)
        𝐦 = 𝒊 - CartesianIndex(0,0,1)
        if 𝐣 in neighborRange && 𝐤 in neighborRange && 𝐦 in neighborRange
            j = sub2ind(imageDims, 𝐣.I...)
            k = sub2ind(imageDims, 𝐤.I...)
            m = sub2ind(imageDims, 𝐦.I...)
            push!(idxJᶠᶠᵇ, (i,j,k,m))
        end

        𝐣 = 𝒊 - CartesianIndex(1,0,0)
        𝐤 = 𝒊 + CartesianIndex(0,1,0)
        𝐦 = 𝒊 - CartesianIndex(0,0,1)
        if 𝐣 in neighborRange && 𝐤 in neighborRange && 𝐦 in neighborRange
            j = sub2ind(imageDims, 𝐣.I...)
            k = sub2ind(imageDims, 𝐤.I...)
            m = sub2ind(imageDims, 𝐦.I...)
            push!(idxJᵇᶠᵇ, (i,j,k,m))
        end

        𝐣 = 𝒊 + CartesianIndex(1,0,0)
        𝐤 = 𝒊 - CartesianIndex(0,1,0)
        𝐦 = 𝒊 - CartesianIndex(0,0,1)
        if 𝐣 in neighborRange && 𝐤 in neighborRange && 𝐦 in neighborRange
            j = sub2ind(imageDims, 𝐣.I...)
            k = sub2ind(imageDims, 𝐤.I...)
            m = sub2ind(imageDims, 𝐦.I...)
            push!(idxJᶠᵇᵇ, (i,j,k,m))
        end

        𝐣 = 𝒊 - CartesianIndex(1,0,0)
        𝐤 = 𝒊 - CartesianIndex(0,1,0)
        𝐦 = 𝒊 - CartesianIndex(0,0,1)
        if 𝐣 in neighborRange && 𝐤 in neighborRange && 𝐦 in neighborRange
            j = sub2ind(imageDims, 𝐣.I...)
            k = sub2ind(imageDims, 𝐤.I...)
            m = sub2ind(imageDims, 𝐦.I...)
            push!(idxJᵇᵇᵇ, (i,j,k,m))
        end
    end
    return idxJᶠᶠᶠ, idxJᵇᶠᶠ, idxJᶠᵇᶠ, idxJᵇᵇᶠ, idxJᶠᶠᵇ, idxJᵇᶠᵇ, idxJᶠᵇᵇ, idxJᵇᵇᵇ
end
