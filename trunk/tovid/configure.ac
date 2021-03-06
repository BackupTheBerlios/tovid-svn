# Process this file with autoconf to produce a configure script.
# Autoconf documentation:
#     http://www.gnu.org/software/autoconf/manual/index.html

# Project homepage: http://www.tovid.org
#
#
# Copyright (C) 2005 tovid.org <http://www.tovid.org>
# 
# This program is free software; you can redistribute it and/or 
# modify it under the terms of the GNU General Public License 
# as published by the Free Software Foundation; either 
# version 2 of the License, or (at your option) any later 
# version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA. Or see:
#
#           http://www.gnu.org/licenses/gpl.txt

# ******************************************************************************
# ******************************************************************************
#
#
# INIT
#
#
# ******************************************************************************
# ******************************************************************************

# The first arugment sets the package name, the second sets the package version.
# eg [tovid], [0.40] would yield a tovid-0.40.tar.gz after "$ make dist"
#                    the version number is also substituted into tovid-init.in
AC_INIT([tovid], [svn])
AC_CONFIG_SRCDIR([src/tovid])

# Require minimum versions of the autotools
AC_PREREQ(2.5)
AM_INIT_AUTOMAKE([1.9])




# ******************************************************************************
# ******************************************************************************
#
#
# CHECK FOR DEPENDENCIES 
#
#
# ******************************************************************************
# ******************************************************************************

# All run-time dependencies are checked in tovid-init now. In addition to being
# the Correct Way to do things, it makes packaging much easier for deb|rpm|???
# maintainers.

# ******************************************************************************
# Python
# ******************************************************************************
# As seen on http://sources.redhat.com/automake/automake.html#Python
# AM_PATH_PYTHON sets many vars, including $(pythondir), which is the directory 
# name for the site-packages subdirectory of the standard Python install tree;
# and $(pyexecdir), which is the directory where Python extension modules 
# (shared libraries) should be installed.

# For example, on friedrij's debian system
# $(pythondir) = ${prefix}/lib/python2.3/site-packages
# $(pyexecdir) = ${exec_prefix}/lib/python2.3/site-packages

# From the autoconf manual, available in anything _but_ html (uf, fsf) from
# http://www.gnu.org/software/autoconf/manual/index.html
# $(prefix) is "The common installation prefix for all files. If $(exec_prefix)
# is defined to a different value, prefix is used only for architecture-
# independent files."
# $(exec_prefix) is "The installation prefix for architecture-dependent files. 
# By default it's the same as $(prefix). You should avoid installing anything
# directly to $(exec_prefix). However, the default value for directories 
# containing architecture-dependent files should be relative to $(exec_prefix)."

# The GNU Coding Standards, available in html (yosh) from
# (http://www.gnu.org/prep/standards/standards.html#Directory-Variables),
# clarifies the difference between $(prefix) and $(exec_prefix): "Generally, 
# $(exec_prefix) is used for directories that contain machine-specific files 
# (such as executables and subroutine libraries), while $(prefix) is used
# directly for other directories."

# So, this dev thinks we need $(pyexecdir) and some 'enlightened' python
# scripts, as pointed out by 
# http://sources.redhat.com/automake/automake.html#Hard_002dCoded-Install-Paths
# If you do [use $(pythondir) or $(pyexecdir)], then:
#    * root users can install your package with the same --prefix as Python (you
#      get the behavior of the previous attempt - eg /usr/lib/python-2.3/...)
#    * non-root users can install your package too, they will have the extension
#      module in a place that is not searched by Python but they can work around
#      this using environment variables (and if you installed scripts that use
#      this shared library, it's easy to tell Python were to look in the
#      beginning of your script, so the script works in both cases). 

# Using pyexecdir_PYTHON for libtovid will install it to 
# ${exec_prefix}/lib/python2.3/site-packages (for example)
# and the pytovid suite (left as bin_SCRIPTS, so that they are installed as
# executables and not byte-compiled like python_PYTHON would do) will need to be
# told how to look for libtovid.

AM_PATH_PYTHON(2.3)

AC_CONFIG_FILES([Makefile src/tovid-init])
AC_OUTPUT


# ******************************************************************************
# ******************************************************************************
#
# PRETTY SUMMARY
#
# ******************************************************************************
# ******************************************************************************

AC_MSG_NOTICE([

 You may now type 'su -c "make install"' to compile and install tovid.
 ])
