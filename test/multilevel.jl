@testset "multilevel-2D" begin
    fixed = [ 1  2  3  4  5;
             10  9  8  7  6;
             11 12 13 14 15;
             16 17 18 19 20;
             21 22 23 24 25]

    moving = [ 1  2  3  4  5;
              10  9  8  7  6;
              11 12 19 14 15;
              16 13 18 17 20;
              21 22 23 24 25]

    labels = [(i,j) for i in -2:2, j in -2:2]

    indicatorExpected = [13 13 13 13 13;
                         13 13 13 13 13;
                         13 13  9 13 13;
                         13 23 13  7 13;
                         13 13 13 13 13]'
    @testset "without topology preservation" begin
        energy, spectrum = optimize(fixed, moving, labels, SAD(), TAD(), 0.07)
        indicator = [indmax(spectrum[i,:]) for i in indices(spectrum,1)]
        @show indicator
    end
    @testset "with topology preservation" begin
        energy, spectrum = optimize(fixed, moving, labels, SAD(), TAD(), TP(), 0.07, 0.01)
        indicator = [indmax(spectrum[i,:]) for i in indices(spectrum,1)]
        @show indicator
    end
end

@testset "multilevel-3D" begin
    #  1  4  7        111  121  131
    #  2  5  8   <=>  211  221  231
    #  3  6  9        311  321  331
    #-----------front--------------
    # 10 13 16        112  122  132
    # 11 14 17   <=>  212  222  232
    # 12 15 18        312  322  332
    #-----------middle-------------
    # 19 22 25        113  123  133
    # 20 23 26   <=>  213  223  233
    # 21 24 27        313  323  333
    #-----------back---------------
    fixed = reshape([1:27;], 3, 3, 3)
    moving = copy(fixed)

    moving[1,3,2] = 14
    moving[2,2,2] = 23
    moving[2,2,3] = 25
    moving[1,3,3] = 16

    labels = [(i,j,k) for i in -1:1, j in -1:1, k in -1:1]
    @testset "without topology preservation" begin
        energy, spectrum = optimize(fixed, moving, labels, SAD(), TAD(), 0.07)
        indicator = [indmax(spectrum[i,:]) for i in indices(spectrum,1)]
        @show indicator
    end
    @testset "with topology preservation" begin
        energy, spectrum = optimize(fixed, moving, labels, SAD(), TAD(), TP(), 0.07, 0.01)
        indicator = [indmax(spectrum[i,:]) for i in indices(spectrum,1)]
        @show indicator
    end
end