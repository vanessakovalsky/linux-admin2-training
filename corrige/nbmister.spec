
%define name nbmister
%define version 1.0
%define release 1
%define _tmppath /home/vanessa/rpmbuild
%define _bindir /usr/local/bin

Summary: find the misterious number
Name: %{name}
Version: %{version}
Release: %{release}
License: GPL
Group: Games
Source: nbmister-1.0.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot

%description
nbmister software is a game
you must find the misterious number

%global debug_package %{nil}

%prep
%setup -q

%build
make
%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/usr/local/bin
install -s -m 755 nbmister $RPM_BUILD_ROOT/usr/local/bin/

%files
%defattr(0755,root,root)
%{_bindir}/nbmister

%changelog
* Fri Feb 19 2021 VD B
- ver 1.0

