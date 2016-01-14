# spec file for mysql-connector-python35u
#
# Copyright (c) 2011-2014 Remi Collet
# License: CC-BY-SA
# http://creativecommons.org/licenses/by-sa/3.0/
#
# Updated by Nico Kadel-Garcia <nkadel@skyhookwireless.com>
#
# Please, preserve the changelog entries
#

# Tests only run on manual build --with tests
# Tests rely on MySQL version 5.6
%global with_tests   %{?_with_tests:1}%{!?_with_tests:0}
# Package has customized name
%global srcname  mysql-connector-python

%global __python3 /usr/bin/python3.5m

%{!?__python3:       %global __python3 %{__python}}
%{!?python3_sitelib: %global python3_sitelib %(%{__python3} -c "from distutils.sysconfig import get_python_lib; print get_python_lib()")}



Name:           mysql-connector-python35u
Version:        1.1.6
Release:        0.1%{?dist}
Summary:        MySQL Connector for Python 3.5

Group:          Development/Languages
License:        GPLv2 with exceptions
URL:            https://dev.mysql.com/doc/connector-python/en/index.html
# Upstream has a mirror redirector for downloads, so the URL is hard to
# represent statically.  You can get the tarball by following a link from
# http://dev.mysql.com/downloads/connector/python/
#Source0:        %{name}-%{version}.tar.gz
Source0:        %{srcname}-%{version}.tar.gz

BuildArch:      noarch
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
# Use Python 3.5 specific packages
BuildRequires:  python35u-devel >= 3.5
BuildRequires:  mysql-server

%description
MySQL Connector/Python is implementing the MySQL Client/Server protocol
completely in Python. No MySQL libraries are needed, and no compilation
is necessary to run this Python DB API v2.0 compliant driver.

Not that This version is specifically for Python 3.5 from IUS.

Documentation: http://dev.mysql.com/doc/connector-python/en/index.html

%prep
%setup -q -n %{srcname}-%{version}
chmod -x python?/examples/*py


%build
# nothing to build


%install
rm -rf %{buildroot}

%{__python3} setup.py install --root %{buildroot}
rm -rf build

%check
%if %{with_tests}
# known failed tests
# bugs.BugOra14201459.test_error1426

%{__python3} unittests.py \
    --with-mysql=%{_prefix} \
    --verbosity=1
%else
: echo test suite disabled, need '--with tests' option
%endif


%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%doc ChangeLog COPYING README* docs/README_DOCS.txt
%doc python3/examples
%{python3_sitelib}/*

%changelog
* Thu Jan 14 2016 Nico Kadel-Garcia <nkadel@skyhookwireless.co> - 1.1.6-0.1
- Rename and configure spefically for Python 3.5 from IUS

* Wed Apr 16 2014 Remi Collet <remi@fedoraproject.org> - 1.1.6-1
- version 1.1.6 GA
  http://dev.mysql.com/doc/relnotes/connector-python/en/news-1-1-6.html

* Tue Feb  4 2014 Remi Collet <remi@fedoraproject.org> - 1.1.5-1
- version 1.1.5 GA
  http://dev.mysql.com/doc/relnotes/connector-python/en/news-1-1-5.html

* Tue Dec 17 2013 Remi Collet <remi@fedoraproject.org> - 1.1.4-1
- version 1.1.4 GA
  http://dev.mysql.com/doc/relnotes/connector-python/en/news-1-1.html
- add link to documentation in package description
- raise dependency on python 2.6

* Mon Aug 26 2013 Remi Collet <remi@fedoraproject.org> - 1.0.12-1
- version 1.0.12 GA

* Wed May  8 2013 Remi Collet <remi@fedoraproject.org> - 1.0.10-1
- version 1.0.10 GA
- archive is now free (no more doc to strip)

* Wed Feb 27 2013 Remi Collet <remi@fedoraproject.org> - 1.0.9-1
- version 1.0.9 GA
- disable test suite in mock, fix FTBFS #914203

* Sat Dec 29 2012 Remi Collet <remi@fedoraproject.org> - 1.0.8-1
- version 1.0.8 GA

* Wed Oct  3 2012 Remi Collet <remi@fedoraproject.org> - 1.0.7-1
- version 1.0.7 GA
- remove non GPL documentation
- disable test_network and test_connection on EL-5

* Fri Aug 10 2012 Remi Collet <remi@fedoraproject.org> - 1.0.5-2
- disable test_bugs with MySQL 5.1 (EL-6)

* Wed Aug  8 2012 Remi Collet <remi@fedoraproject.org> - 1.0.5-1
- version 1.0.5 (beta)
- move from launchpad (devel) to dev.mysql.com

* Sun Jul 29 2012 Remi Collet <remi@fedoraproject.org> 0.3.2-2
- EL6 build

* Sun Mar 20 2011 Remi Collet <Fedora@famillecollet.com> 0.3.2-2
- run unittest during %%check
- fix License
- add python3 sub package

* Wed Mar 09 2011 Remi Collet <Fedora@famillecollet.com> 0.3.2-1
- first RPM
