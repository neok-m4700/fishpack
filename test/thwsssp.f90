!
!     file thwsssp.f90
!
!     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
!     *                                                               *
!     *                  copyright (c) 2005 by UCAR                   *
!     *                                                               *
!     *       University Corporation for Atmospheric Research         *
!     *                                                               *
!     *                      all rights reserved                      *
!     *                                                               *
!     *                    FISHPACK90  Version 1.1                    *
!     *                                                               *
!     *                      A Package of Fortran                     *
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
!     program to illustrate the use of hwsssp
!
program thwsssp

    use, intrinsic :: iso_fortran_env, only: &
        wp => REAL64, &
        ip => INT32, &
        stdout => OUTPUT_UNIT

    use fishpack_library, only: &
        FishpackSolver

    ! Explicit typing only
    implicit None

    !-----------------------------------------------
    ! Dictionary
    !-----------------------------------------------
    type (FishpackSolver)     :: solver
    integer (ip) :: m, mbdcnd, n, nbdcnd, idimf, mp1, i, np1, j, ierror
    real (wp), dimension(19, 73) :: f
    real (wp), dimension(73) :: bdtf, bdts, bdps, bdpf
    real (wp), dimension(19) :: sint
    real (wp), dimension(73) :: sinp
    real (wp) :: pi, ts, tf, ps, pf, elmbda, dtheta, dphi, pertrb, discretization_error, z
    !-----------------------------------------------

    pi = acos( -1.0 )
    ts = 0
    tf = pi/2.
    m = 18
    mbdcnd = 6
    ps = 0
    pf = pi + pi
    n = 72
    nbdcnd = 0
    elmbda = 0.
    idimf = 19
    !
    !     generate sines for use in subsequent computations
    !
    dtheta = tf/real(m)
    mp1 = m + 1
    do i = 1, mp1
        sint(i) = sin(real(i - 1)*dtheta)
    end do
    dphi = (pi + pi)/real(n)
    np1 = n + 1
    do j = 1, np1
        sinp(j) = sin(real(j - 1)*dphi)
    end do
    !
    !     compute right side of equation and store in f
    !
    do j = 1, np1
        f(:mp1, j) = 2. - 6.*(sint(:mp1)*sinp(j))**2
    end do
    !
    !     store derivative data at the equator
    !
    bdtf(:np1) = 0.
    !
    call solver%hwsssp(ts, tf, m, mbdcnd, bdts, bdtf, ps, pf, n, nbdcnd, &
        bdps, bdpf, elmbda, f, idimf, pertrb, ierror)
    !
    !     compute discretization error. since problem is singular, the
    !     solution must be normalized.
    !
    discretization_error = 0.0
    do j = 1, np1
        do i = 1, mp1
            z = abs(f(i, j)-(sint(i)*sinp(j))**2-f(1, 1))
            discretization_error = max(z, discretization_error)
        end do
    end do

    !
    !==> Print earlier output from platforms with 64-bit floating point
    !    arithmetic followed by the output from this computer
    !
    write( stdout, '(/a)') '     hwsssp *** TEST RUN *** '
    write( stdout, '(a)') '     Previous 64 bit floating point arithmetic result '
    write( stdout, '(a)') '     ierror = 0,  discretization error = 3.38107e-3'
    write( stdout, '(a)') '     The output from your computer is: '
    write( stdout, '(a,i3,a,1pe15.6/)') &
        '      ierror =', ierror, &
        ' discretization error = ', discretization_error

end program thwsssp
