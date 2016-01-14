#
# Makefile - build wrapper for python 3.5 based modules for RHEL 6
#
#	git clone RHEL 6 SRPM building tools from
#	https://github.com/nkadel-skyhook/python35repobuilder

# Base directory for yum repository
REPOBASEDIR="`/bin/pwd`"
# Base subdirectories for RPM deployment
REPOBASESUBDIRS+=$(REPOBASEDIR)/python35repo/6/SRPMS
REPOBASESUBDIRS+=$(REPOBASEDIR)/python35repo/6/x86_64

# These require the IUS repository enabled for Python 3.5
# Specify python35 in package name, to avoid confusion with
# python3 and similar standard naming
IUSPKGS+=mysql-connector-python35-srpm

# Currently no packages require the local dependencies
PYTHON35PKGS+=

# Populate python35repo with packages that require python35repo
# Verify build setup first!
all:: /usr/bin/createrepo
all:: tarballs
all:: python35repo-6-x86_64.cfg
all:: iuspy35-6-x86_64.cfg

all:: python35-install

install:: ius-install python35-install

ius-install:: $(IUSOKGS)

# Ensure availability of createrepo
/usr/bin/createrepo:

# Ensure working configs for python
python35-install:: python35repo-6-x86_64.cfg
python35-install:: $(PYTHONPKGS)

python35repo-6-x86_64.cfg:: python35repo-6-x86_64.cfg.in
	sed "s|@@@REPOBASEDIR@@@|$(REPOBASEDIR)|g" $? > $@

python35repo-6-x86_64.cfg:: FORCE
	@diff -u $@ /etc/mock/$@ || \
		(echo Warning: /etc/mock/$@ does not match $@, exiting; exit 1)

iuspy35-6-x86_64.cfg:: iuspy35-6-x86_64.cfg.in
	sed "s|@@@REPOBASEDIR@@@|$(REPOBASEDIR)|g" $? > $@

iuspy35-6-x86_64.cfg:: FORCE
	@diff -u $@ /etc/mock/$@ || \
		(echo Warning: /etc/mock/$@ does not match $@, exiting; exit 1)

# Used for make build with local components
python35repo.repo:: python35repo.repo.in
	sed "s|@@@REPOBASEDIR@@@|$(REPOBASEDIR)|g" $? > $@

python35repo.repo:: FORCE
	@diff -u $@ /etc/yum.repos.d/$@ || \
		(echo Warning: /etc/yum.repos.d/$@ does not match $@, exiting; exit 1)

TARBALLS+=mysql-connector-python35-srpm/mysql-connector-python-2.0.4.zip
tarballs:: $(TARBALLS)

# Ensure that local tarballs match or are downloaded from master
mysql-connector-python35-srpm/mysql-connector-python-2.0.4.zip::
	wget --quiet --mirror --no-host-directories --cut-dirs=4 --directory-prefix=`dirname $@` \
		http://cdn.mysql.com/Downloads/Connector-Python/`basename $@`

ius:: $(IUSPKGS)

$(REPOBASESUBDIRS)::
	mkdir -p $@

ius-install:: $(REPOBASESUBDIRS)

ius-install:: FORCE
	@for name in $(IUSPKGS); do \
		(cd $$name && $(MAKE) all install) || exit 1; \
	done

# Git clone operations, not normally required
# Targets may change

# Build IUS compatible softwaer in place
$(IUSPKGS):: iuspy35-6-x86_64.cfg
$(IUSPKGS):: FORCE
	(cd $@ && $(MAKE) $(MLAGS) all install) || exit 1

$(PYTHON35PKGS):: iuspy35-6-x86_64.cfg
$(PYTHON35PKGS):: python35repo-6-x86_64.cfg

$(PYTHON35PKGS):: FORCE
	(cd $@ && $(MAKE) $(MLAGS) all install) || exit 1

# Needed for local compilation, only use for dev environments
build:: python35repo.repo

build clean realclean distclean:: FORCE
	@for name in $(IUSPKGS) $(PYTHON35PKGS); do \
	     (cd $$name && $(MAKE) $(MFLAGS) $@); \
	done

realclean distclean:: clean

clean::
	find . -name \*~ -exec rm -f {} \;

# Use this only to build completely from scratch
# Leave the rest of python35repo alone.
maintainer-clean:: clean
	@echo Clearing local yum repository
	find python35repo -type f ! -type l -exec rm -f {} \; -print

# Leave a safe repodata subdirectory
maintainer-clean:: FORCE

safe-clean:: maintainer-clean FORCE
	@echo Populate python35repo with empty, safe repodata
	find python35repo -noleaf -type d -name repodata | while read name; do \
		createrepo -q $$name/..; \
	done

# This is only for upstream repository publication.
# Modify for local use as needed, but do try to keep passwords and SSH
# keys out of the git repository fo this software.
RSYNCTARGET=rsync://localhost/python35repo
RSYNCOPTS=-a -v --ignore-owner --ignore-group --ignore-existing
RSYNCSAFEOPTS=-a -v --ignore-owner --ignore-group
publish:: all
publish:: FORCE
	@echo Publishing RPMs to $(RSYNCTARGET)
	rsync $(RSYNCSAFEOPTS) --exclude=repodata $(RSYNCTARGET)/

publish:: FORCE
	@echo Publishing repodata to $(RSYNCTARGET)
	find repodata/ -type d -name repodata | while read name; do \
	     rsync $(RSYNCOPTS) $$name/ $(RSYNCTARGET)/$$name/; \
	done

FORCE::

