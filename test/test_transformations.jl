using PGA3D, Test, SafeTestsets, Logging, PrettyPrinting, StaticArrays, Random

@safetestset "Point3D" begin
    using PGA3D, Test, SafeTestsets, Logging, PrettyPrinting, StaticArrays, Random

    @safetestset "Identity" begin
        using PGA3D, Test, SafeTestsets, Logging, PrettyPrinting, StaticArrays, Random
        for i in 1:100
            testpoint = Point3D(randn(3)...)
            motoridentity = identity_motor()
            @test transform(testpoint, motoridentity) ≈ testpoint
        end
    end

    @safetestset "Motor From To" begin
        using PGA3D, Test, SafeTestsets, Logging, PrettyPrinting, StaticArrays, Random, LinearAlgebra
        for i in 1:100
            testfrom = Point3D(randn(3)...)
            testto = Point3D(randn(3)...)
            mft = motor_fromto(testfrom, testto)
            @test transform(testfrom, mft) ≈ testto
        end
    end

    @safetestset "Motor Screw Displacement" begin
        using PGA3D, Test, SafeTestsets, Logging, PrettyPrinting, StaticArrays, Random, LinearAlgebra
        for i in 1:100
            # generate two random points
            testfrom = Point3D(randn(3)...)
            testto = Point3D(randn(3)...)
            dist = norm(internal_vec(testfrom) - internal_vec(testto))
            testline = line_fromto(testfrom, testto)
            mft = motor_screw(testline, 0, dist)
            @test transform(testfrom, mft) ≈ testto
        end
    end

    @safetestset "Motor Screw Rotation" begin
        using PGA3D, Test, SafeTestsets, Logging, PrettyPrinting, StaticArrays, Random, LinearAlgebra
        for i in 1:100
            # start with two random normalized points
            testfrom = Point3D(normalize(randn(3))...)
            testto = Point3D(normalize(randn(3))...)
            testfromar = SA[testfrom[1], testfrom[2], testfrom[3]]
            testtoar = SA[testto[1], testto[2], testto[3]]
            # calculate the angle between them in the plane they span
            y = cross(testfromar, testtoar)
            x = dot(testfromar, testtoar)
            angle = atan(norm(y), x)
            # create a unitized line from the origin to the cross product of the two points
            testline = line_fromto(Point3D(0.0, 0.0, 0.0), Point3D(y...))
            # now generate the screw that rotates from to to
            mft = motor_screw(testline, angle, 0)
            # and verify that the rotation works as intended
            rotatedfrom = transform(testfrom, mft)
            @test rotatedfrom ≈ testto
        end
    end

    @safetestset "Motor to and from TransformMatrix" begin
        using PGA3D, Test, SafeTestsets, Logging, PrettyPrinting, StaticArrays, Random, LinearAlgebra
        for i in 1:100
            testfrom = Point3D(randn(3)...)
            testto = Point3D(randn(3)...)
            testline = line_fromto(testfrom, testto)
            testangle = randn()
            testdisp = randn()
            testmotor = motor_screw(testline, testangle, testdisp)
            testmatrix = get_transform_matrix(testmotor)
            testmatrixinv = get_inv_transform_matrix(testmotor)
            testmatrix2, testmatrixinv2 = get_transform_and_inv_matrices(testmotor)
            @test testmatrix ≈ testmatrix2
            @test testmatrixinv ≈ testmatrixinv2
            SAI = SA[1.0 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1]
            @test testmatrix * testmatrixinv ≈ SAI
            @test testmatrixinv * testmatrix ≈ SAI
            testpoint = Point3D(randn(3)...)
            transformedpt = transform(testpoint, testmotor)
            matrixedpt = testmatrix * internal_vec(testpoint)
            @test internal_vec(transformedpt) ≈ matrixedpt
            @test testmatrixinv * matrixedpt ≈ internal_vec(testpoint)
            invmatrixedpt = testmatrixinv * internal_vec(testpoint)
            invtransformedpt = transform(testpoint, PGA3D.reverse(testmotor))
            @test internal_vec(invtransformedpt) ≈ invmatrixedpt
        end
    end
end