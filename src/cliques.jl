"""
    unaryclique(fixedImg, movingImg, labels)
    unaryclique(fixedImg, movingImg, labels, potential)

Construct the **data cost**.
"""
function unaryclique{T,N,P<:DataCost}(fixedImg::Array{T,N}, movingImg::Array{T,N}, labels::Array{NTuple{N}}, potential::P=SAD())
    imageDims = size(fixedImg)
    imageDims == size(movingImg) || throw(ArgumentError("Fixed image and moving image are not in the same size!"))
    return potential.𝓕(fixedImg, movingImg, labels)
end


"""
    pairwiseclique(fixedImg, movingImg, labels, weight)
    pairwiseclique(fixedImg, movingImg, labels, weight, potential)
    pairwiseclique(imageDims, labels, potential)
    pairwiseclique(imageDims, labels, potential, weight)

Construct the **smooth cost**.
"""
function pairwiseclique{T,N}(fixedImg::Array{T,N}, movingImg::Array{T,N}, labels::Array{NTuple{N}}, weight::Real, potential::SmoothTerm=TAD())
    imageDims = size(fixedImg)
    imageDims == size(movingImg) || throw(ArgumentError("Fixed image and moving image are not in the same size!"))
    pairwiseclique(imageDims, reshape(labels, length(labels)), potential, weight)
end

function pairwiseclique{N,P<:SmoothCost}(imageDims::NTuple{N}, labels::Vector{NTuple{N}}, potential::P, weight=1)
    pixelNum = prod(imageDims)
    labelNum = length(labels)
    tensorDims = (pixelNum, labelNum, pixelNum, labelNum)
    args = map(x->getfield(potential,x), fieldnames(potential)[2:end])
    block = [potential.𝓕(α, β, args...) for α in labels, β in labels]
    block = e.^-block
    return BSSTensor([TensorBlock(weight*block, neighbors(SquareCubic,imageDims), tensorDims)], tensorDims)
end


"""
    treyclique(fixedImg, movingImg, labels, weight)
    treyclique(fixedImg, movingImg, labels, weight, potential)
    treyclique(imageDims, labels, potential)
    treyclique(imageDims, labels, potential, weight)

Construct the **high order cost** for topology preserving(2D).
"""
function treyclique{T,N}(fixedImg::Array{T,N}, movingImg::Array{T,N}, labels::Array{NTuple{N}}, weight::Real, potential::TopologyCost=TP())
    imageDims = size(fixedImg)
    imageDims == size(movingImg) || throw(ArgumentError("Fixed image and moving image are not in the same size!"))
    treyclique(imageDims, reshape(labels, length(labels)), potential, weight)
end

function treyclique(imageDims::NTuple{2}, labels::Vector{NTuple{2}}, potential::TP, weight=1)
    pixelNum = prod(imageDims)
    labelNum = length(labels)
    tensorDims = (pixelNum, labelNum, pixelNum, labelNum, pixelNum, labelNum)
    #   □ ⬓ □        ⬓                ⬓      r,c-->    ⬔ => ii => p1 => α
    #   ▦ ⬔ ▦  =>  ▦ ⬔   ▦ ⬔    ⬔ ▦   ⬔ ▦    |         ⬓ => jj => p2 => β
    #   □ ⬓ □              ⬓    ⬓            ↓         ▦ => kk => p3 => χ
    #              Jᵇᵇ   Jᶠᵇ    Jᶠᶠ   Jᵇᶠ
    indexJᶠᶠ, indexJᵇᶠ, indexJᶠᵇ, indexJᵇᵇ = neighbors(Connected8{3}, imageDims)

    blockJᶠᶠ = [potential.Jᶠᶠ(α, β, χ) for α in labels, β in labels, χ in labels]
    blockJᵇᶠ = [potential.Jᵇᶠ(α, β, χ) for α in labels, β in labels, χ in labels]
    blockJᶠᵇ = [potential.Jᶠᵇ(α, β, χ) for α in labels, β in labels, χ in labels]
    blockJᵇᵇ = [potential.Jᵇᵇ(α, β, χ) for α in labels, β in labels, χ in labels]

    return BSSTensor([TensorBlock(weight*e.^-blockJᶠᶠ, indexJᶠᶠ, tensorDims),
                      TensorBlock(weight*e.^-blockJᵇᶠ, indexJᵇᶠ, tensorDims),
                      TensorBlock(weight*e.^-blockJᶠᵇ, indexJᶠᵇ, tensorDims),
                      TensorBlock(weight*e.^-blockJᵇᵇ, indexJᵇᵇ, tensorDims)], tensorDims)
end

"""
    quadraclique(fixedImg, movingImg, labels, weight)
    quadraclique(fixedImg, movingImg, labels, weight, potential)
    quadraclique(imageDims, labels, potential)
    quadraclique(imageDims, labels, potential, weight)

Construct the **high order cost** for topology preserving(3D).
"""
function quadraclique{T,N}(fixedImg::Array{T,N}, movingImg::Array{T,N}, labels::Array{NTuple{N}}, weight::Real, potential::TopologyCost=TP())
    imageDims = size(fixedImg)
    imageDims == size(movingImg) || throw(ArgumentError("Fixed image and moving image are not in the same size!"))
    quadraclique(imageDims, reshape(labels, length(labels)), potential, weight)
end

function quadraclique(imageDims::NTuple{3}, labels::Vector{NTuple{3}}, potential::TP, weight=1)
    pixelNum = prod(imageDims)
    labelNum = length(labels)
    tensorDims = (pixelNum, labelNum, pixelNum, labelNum, pixelNum, labelNum, pixelNum, labelNum)
    indexJᶠᶠᶠ, indexJᵇᶠᶠ, indexJᶠᵇᶠ, indexJᵇᵇᶠ, indexJᶠᶠᵇ, indexJᵇᶠᵇ, indexJᶠᵇᵇ, indexJᵇᵇᵇ = neighbors(Connected26{4}, imageDims)

    blockJᶠᶠᶠ = [potential.Jᶠᶠᶠ(α, β, χ, δ) for α in labels, β in labels, χ in labels, δ in labels]
    blockJᵇᶠᶠ = [potential.Jᵇᶠᶠ(α, β, χ, δ) for α in labels, β in labels, χ in labels, δ in labels]
    blockJᶠᵇᶠ = [potential.Jᶠᵇᶠ(α, β, χ, δ) for α in labels, β in labels, χ in labels, δ in labels]
    blockJᵇᵇᶠ = [potential.Jᵇᵇᶠ(α, β, χ, δ) for α in labels, β in labels, χ in labels, δ in labels]
    blockJᶠᶠᵇ = [potential.Jᶠᶠᵇ(α, β, χ, δ) for α in labels, β in labels, χ in labels, δ in labels]
    blockJᵇᶠᵇ = [potential.Jᵇᶠᵇ(α, β, χ, δ) for α in labels, β in labels, χ in labels, δ in labels]
    blockJᶠᵇᵇ = [potential.Jᶠᵇᵇ(α, β, χ, δ) for α in labels, β in labels, χ in labels, δ in labels]
    blockJᵇᵇᵇ = [potential.Jᵇᵇᵇ(α, β, χ, δ) for α in labels, β in labels, χ in labels, δ in labels]

    return BSSTensor([TensorBlock(weight*e.^-blockJᶠᶠᶠ, indexJᶠᶠᶠ, tensorDims),
                      TensorBlock(weight*e.^-blockJᵇᶠᶠ, indexJᵇᶠᶠ, tensorDims),
                      TensorBlock(weight*e.^-blockJᶠᵇᶠ, indexJᶠᵇᶠ, tensorDims),
                      TensorBlock(weight*e.^-blockJᵇᵇᶠ, indexJᵇᵇᶠ, tensorDims),
                      TensorBlock(weight*e.^-blockJᶠᶠᵇ, indexJᶠᶠᵇ, tensorDims),
                      TensorBlock(weight*e.^-blockJᵇᶠᵇ, indexJᵇᶠᵇ, tensorDims),
                      TensorBlock(weight*e.^-blockJᶠᵇᵇ, indexJᶠᵇᵇ, tensorDims),
                      TensorBlock(weight*e.^-blockJᵇᵇᵇ, indexJᵇᵇᵇ, tensorDims)], tensorDims)
end

# function quadraclique(imageDims::NTuple{2}, labels::Vector{NTuple{2}}, potential::STP, weight=1)
#     pixelNum = prod(imageDims)
#     labelNum = length(labels)
#     tensorDims = (pixelNum, labelNum, pixelNum, labelNum, pixelNum, labelNum)
# end
