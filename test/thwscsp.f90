!
!     file thwscsp.f
!
!     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
!     *                                                               *
!     *                  copyright (c) 2005 by UCAR                   *
!     *                                                               *
!     *       University Corporation for Atmospheric Research         *
!     *                                                               *
!     *                      all rights reserved                      *
!     *                                                               *
!     *                    FISHPACK90  version 1.1                    *
!     *                                                               *
!     *                 A Package of Fortran 77 and 90                *
!     *                                                               *
!     *                Subroutines and Example Programs               *
!     *                                                               *
!     *               for Modeling Geophysical Processes              *
!     *                                                               *
!     *                             by                                *
!     *                                                               *
!     *        John Adams, Paul Swarztrauber and Roland Sweet         *
!     *                                                               *
!     *                             of                                *
!     *                                                               *
!     *         the National Center for Atmospheric Research          *
!     *                                                               *
!     *                Boulder, Colorado  (80307)  U.S.A.             *
!     *                                                               *
!     *                   which is sponsored by                       *
!     *                                                               *
!     *              the National Science Foundation                  *
!     *                                                               *
!     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
!
program thwscsp

    use, intrinsic :: iso_fortran_env, only: &
        wp => REAL64, &
        ip => INT32, &
        stdout => OUTPUT_UNIT

    use modern_fishpack_library, only: &
        FishpackWorkspace, &
        hwscsp

    ! Explicit typing only
    implicit none

    !-----------------------------------------------
    ! Dictionary
    !-----------------------------------------------
    type (FishpackWorkspace) :: workspace
    integer (ip) :: intl, m, mbdcnd, n, nbdcnd, idimf, mp1, i, np1, j, ierror
    real (wp), dimension(48, 33) :: f
    real (wp), dimension(33) :: bdtf, bdts, bdrs, bdrf
    real (wp), dimension(48) :: theta
    real (wp), dimension(33) :: r
    real (wp)                :: pi, dum, ts, tf, rs, rf, elmbda
    real (wp)                :: dtheta, dr, ci4, pertrb, discretization_error, z, dphi, si
    !-----------------------------------------------
    !
    !     program to illustrate the use of hwscsp
    !
    !
    pi = acos( -1.0 )
    intl = 0
    ts = 0.
    tf = pi/2.
    m = 36
    mbdcnd = 6
    rs = 0.
    rf = 1.
    n = 32
    nbdcnd = 5
    elmbda = 0.
    idimf = 48
    !
    !     generate and store grid points for the purpose of computing the
    !     boundary data and the right side of the equation.
    !
    mp1 = m + 1
    dtheta = tf/real(m)
    do i = 1, mp1
        theta(i) = real(i - 1)*dtheta
    end do
    np1 = n + 1
    dr = 1./real(n)
    do j = 1, np1
        r(j) = real(j - 1)*dr
    end do
    !
    !     generate normal derivative data at equator
    !
    bdtf(:np1) = 0.
    !
    !     compute boundary data on the surface of the sphere
    !
    do i = 1, mp1
        f(i, n+1) = cos(theta(i))**4
    end do
    !
    !     compute right side of equation
    !
    do i = 1, mp1
        ci4 = 12.*cos(theta(i))**2
        f(i, :n) = ci4*r(:n)**2
    end do

    ! Solve system
    call hwscsp(intl, ts, tf, m, mbdcnd, bdts, bdtf, rs, rf, n, &
        nbdcnd, bdrs, bdrf, elmbda, f, idimf, pertrb, ierror, workspace)
    !
    !     compute discretization error
    !
    discretization_error = 0.
    do i = 1, mp1
        ci4 = cos(theta(i))**4
        do j = 1, n
            z = abs(f(i, j)-ci4*r(j)**4)
            discretization_error = max(z, discretization_error)
        end do
    end do

    !     Print earlier output from platforms with 32 and 64 bit floating point
    !     arithemtic followed by the output from this computer
    write( stdout, '(A)') ''
    write( stdout, '(A)') '     hwscsp *** TEST RUN, EXAMPLE 1 *** '
    write( stdout, '(A)') '     Previous 64 bit floating point arithmetic result '
    write( stdout, '(A)') '     ierror = 0,  discretization error = 7.9984e-4 '
    write( stdout, '(A)') '     The output from your computer is: '
    write( stdout, '(A,I3,A,1pe15.6)') &
        '     ierror =', ierror, '     discretization error =', discretization_error
    !
    !     the following program illustrates the use of hwscsp to solve
    !     a three dimensional problem which has longitudnal dependence
    !
    mbdcnd = 2
    nbdcnd = 1
    dphi = pi/72.
    elmbda = -2.*(1. - cos(dphi))/dphi**2
    !
    !     compute boundary data on the surface of the sphere
    !
    do i = 1, mp1
        f(i, n+1) = sin(theta(i))
    end do
    !
    !     compute right side of the equation
    !
    f(:mp1, :n) = 0.

    ! Solve system
    call hwscsp(intl, ts, tf, m, mbdcnd, bdts, bdtf, rs, rf, n, &
        nbdcnd, bdrs, bdrf, elmbda, f, idimf, pertrb, ierror, workspace)
    !
    !     compute discretization error   (fourier coefficients)
    !
    discretization_error = 0
    do i = 1, mp1
        si = sin(theta(i))
        do j = 1, np1
            z = abs(f(i, j)-r(j)*si)
            discretization_error = max(z, discretization_error)
        end do
    end do
    !
    !     Print earlier output from platforms with 32 and 64 bit floating point
    !     arithemtic followed by the output from this computer

    write( stdout, '(A)') ''
    write( stdout, '(A)') '     hwscsp *** TEST RUN, EXAMPLE 2 *** '
    write( stdout, '(A)') '     Previous 64 bit floating point arithmetic result '
    write( stdout, '(A)') '     ierror = 0, discretization error = 5.8682e-5 '
    write( stdout, '(A)') '     The output from your computer is: '
    write( stdout, '(A,I3,A,1pe15.6)') &
        '     ierror =', ierror, '     discretization error =', discretization_error


    ! Release memory
    call workspace%destroy()

end program thwscsp