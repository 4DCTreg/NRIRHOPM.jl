using TensorOperations
import NRIRHOPM: contract

const TolTensor = 1e-10

info("Testing 2nd order SSTensor:")
n = 100
A = Symmetric(rand(n,n))
A -= diagm(diag(A))
x = rand(n)

data = Float64[]
index = NTuple{2,Int}[]
for i = 1:n, j = i+1:n
    push!(data, A[i,j])
    push!(index, (i,j))
end

@test vecnorm(contract(SSTensor(data, index, size(A)), x) - tensorcontract(A, [1,2], x, [2])) < TolTensor
@test vecnorm(SSTensor(data, index, size(A)) ⊙ x - tensorcontract(A, [1,2], x, [2])) < TolTensor
println("Passed.")

info("Testing 3rd order SSTensor:")
n = 100
a = rand(n)
A = kron(a, a', a)
A = reshape(A, n, n, n)

data = Float64[]
index = NTuple{3,Int}[]

for i = 1:n, j = 1:n, k = 1:n
    if i == j || i == k || j == k
        A[i,j,k] = 0
    elseif i < j < k
        push!(data, A[i,j,k])
        push!(index, (i,j,k))
    end
end

x = rand(n)
v = tensorcontract(A, [1,2,3], x, [3])
@test vecnorm(contract(SSTensor(data, index, size(A)), x) - tensorcontract(v, [1,2], x, [2])) < TolTensor
@test vecnorm(SSTensor(data, index, size(A)) ⊙ x - tensorcontract(v, [1,2], x, [2])) < TolTensor
println("Passed.")

info("Testing 4th order BSSTensor:")
imageDims = (32,32)
labels = [[(i,j) for i in -2:2, j in -2:2]...]
ss = pairwiseclique4validation(imageDims, labels);
bss = pairwiseclique(imageDims, labels, TAD());
x = rand(prod(imageDims)*length(labels))
@test ss ⊙ x == bss ⊙ x
println("Passed.")

info("Testing 6th order BSSTensor:")
imageDims = (16,16)
labels = [[(i,j) for i in -1:1, j in -1:1]...]
ss = treyclique4validation(imageDims, [[[i,j] for i in -1:1, j in -1:1]...]);
bss = treyclique(imageDims, labels, TP());
x = rand(prod(imageDims)*length(labels))
@test vecnorm(ss ⊙ x - bss ⊙ x) < TolTensor
println("Passed.")

info("Testing trivial interfaces:")
imageDims = (8,8)
labels = [[(i,j) for i in -2:2, j in -2:2]...]
ss = pairwiseclique4validation(imageDims, labels);
bss = pairwiseclique(imageDims, labels, TAD());
pixelNum = prod(imageDims)
labelNum = length(labels)

@test size(ss) == (pixelNum*labelNum, pixelNum*labelNum)
@test length(ss) == pixelNum*labelNum*pixelNum*labelNum

@test size(bss) == (pixelNum, labelNum, pixelNum, labelNum) == size(bss.blocks[])
@test length(bss) == length(bss.blocks[]) == length(ss)

@test nnz(bss)*labelNum^2 == nnz(ss)

println("Passed.")
