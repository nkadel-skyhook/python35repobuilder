python35repobuilder - Python 3.5 Module builder RHEL 6

License:  GPLv3
	  (Except where noted in subpackages)
Maintainer:   Nico Kadel-Garcia
Maintainer Email: nkadel@skyhookwireless.com

Usage:

    make [ install ] - build, and install for local access, the full build
    requirements for aws in diferent operating systems This is the
    default bootstrap operation.

    make build - try and build all the components in the local
    environment, without using "mock"

    make all - build all comopnents using "mock" and the local
    PYTHON repository, called "pythonrepo"

Requirements: This toolkit requires the following tools:

     * The "mock" software for building RPM's, available from EPEL for
       RHEL based cystems.

     * Spare diskspace at /var/lib/mock and /var/cache/mock for the
       builky builds of mock chroot environments.

     * Reliable access to yum repositories for CentOS, RHEL, or
       Scietific Linux repositories, for the standard "mock"
       configuration.

     * Reliable access to the IUS repository, needed for Python 3.5
       access.  This repo is *not* compatible with "software
       collections" from RHEL or CentOS.

     * Membership in the "mock" group for permissions to exucute the
       mock software.

     * PATH setting or an alias that accfess "/usr/bin/mock", not
       "/usr/sbin/mock".
