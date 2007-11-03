
####################
#    Copyright (C) 2007 by Raphael Geissert <atomo64@gmail.com>
#
#    This file is part of DeBaBaReTools
#
#    DeBaBaReTools is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    DeBaBaReTools is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with DeBaBaReTools.  If not, see <http://www.gnu.org/licenses/>.
####################

# include some shared functions (not really dependent on the rep system)
probeFile "repository/shared"

#USAGE: installIncoming([incomingFile]): toBuild; toBuild "$HOME/reprepro/conf/incoming"
installIncoming() {
	local incomingFile rulesets rule OUTPUT

	if [ ! -z "${1:-}" ] && [ -f "${1:-}" ]; then
		incomingFile="${1:-}"
	elif [ -f "$BASE_DIR/conf/incoming" ]; then
		incomingFile="$BASE_DIR/conf/incoming"
	fi

	if [ ! -f "$incomingFile" ]; then
		Say "Couldn't find reprepro's conf/incoming, how am I going to processincoming then?"
		return 1
	fi

	rulesets="`cat "$incomingFile" | grep "Name:" | sed "s/[ \t]*Name:[ \t]*//gi" | sort -u`"

	if [ -z "$rulesets" ]; then
		Say "Couldn't find any ruleset in $incomingFile"
		return 1
	fi

	for rule in $rulesets; do
		OUTPUT="`reprepro processincoming "$rule"`"
		if [ "$?" != "0" ]; then
			Say "$OUTPUT"
			return "$?"
		fi
	done
}

#USAGE: getSupportedRepArchs([distributionsFile]): getSupportedRepArchs;
#. getSupportedRepArchs "$HOME/reprepro/conf/distributions"
getSupportedRepArchs() {
	local distributionsFile listedArchs ARCH archs

	if [ ! -z "${1:-}" ] && [ -f "${1:-}" ]; then
		distributionsFile="${1:-}"
	elif [ -f "$BASE_DIR/conf/incoming" ]; then
		distributionsFile="$BASE_DIR/conf/distributions"
	fi

	if [ ! -f "$distributionsFile" ]; then
		Say "Couldn't find reprepro's conf/distributions, how am I going to find out the supported archs then?"
		return 1
	fi

	listedArchs=`cat $distributionsFile | grep Architectures | sort -ru | awk '-F: ' '{ print $2 }'`

	for ARCH in $listedArchs; do
		if [ "$ARCH" != "source" ]; then
			archs+="$ARCH "
		fi
	done

	# make public the information:
	BUILDARCHS="$archs"
}

#USAGE: getArchsPackIsBuiltAInRepository(sourcePackage, packageVersion, codename, [dbDir]): 
#. getArchsPackIsBuiltAInRepository "php5" "5.2.4-1" "sid"; 
#. getArchsPackIsBuiltAInRepository "php5" "5.2.4-1" "sid" "$HOME/reprepro/db"
getArchsPackIsBuiltAInRepository() {

	if [ -z "${1:-}" ] || [ -z "${2:-}" ] || [ -z "${3:-}" ]; then
		Say "Wrong function usage! we expected three arguments"
		return 2
	fi

	local dbDir codename sourcePackage packageVersion
	sourcePackage="${1:-}"; packageVersion="${2:-}"; codename="${3:-}"

	if [ ! -z "${4:-}" ] && [ -d "${4:-}" ]; then
		dbDir="${4:-}"
	elif [ -d "$BASE_DIR/db" ]; then
		dbDir="$BASE_DIR/db"
	fi

	if [ ! -d "$dbDir" ]; then
		Say "Couldn't find reprepro's db/, where is reprepro going to take the data from?"
		return 1
	fi

	local queryResult alreadyBuiltIn p ARCH queryArchsOnly queryPackagesOnly
	queryResult="`reprepro --dbdir "$dbDir" -T deb listfilter "$codename" "Source (==$sourcePackage), Version (==$packageVersion)"`"

	queryArchsOnly="`echo $queryResult | sed "s/ /\n/g" | egrep ":$" | sort -u | cut -d: -f1 | cut '-d|' -f3`"
	queryPackagesOnly="`echo $queryResult | sed "s/ /\n/g" | egrep -v ":$" | grep -v "$packageVersion"`"

	alreadyBuiltIn=''

	for ARCH in $queryArchsOnly; do
		alreadyBuiltIn+="$ARCH "
	done

	for p in $queryPackagesOnly; do
		if [ repreproIsArchAll "$p" "$packageVersion" "$codename" "$dbDir" ]; then
			# if one of the arch-indep packages is found, all the other arch-indep
			#  should also be there
			alreadyBuiltIn+="all"
			break
		fi
	done

	# make public the information:
	ALREADY_BUILT_IN="$alreadyBuiltIn"
}

#USAGE: repreproIsArchAll(package, packageVersion, codename, [dbDir]): 
#. isPackageBuiltAInRepository "php-pear" "5.2.4-1" "sid"; 
#. isPackageBuiltAInRepository "php-pear" "5.2.4-1" "sid" "$HOME/reprepro/db"
repreproIsArchAll() {

	if [ -z "${1:-}" ] || [ -z "${2:-}" ] || [ -z "${3:-}" ]; then
		Say "Wrong function usage! we expected three arguments"
		return 2
	fi

	local dbDir codename sourcePackage packageVersion
	package="${1:-}"; packageVersion="${2:-}"; codename="${3:-}"

	if [ ! -z "${4:-}" ] && [ -d "${4:-}" ]; then
		dbDir="${4:-}"
	elif [ -d "$BASE_DIR/db" ]; then
		dbDir="$BASE_DIR/db"
	fi

	if [ ! -d "$dbDir" ]; then
		Say "Couldn't find reprepro's db/, where is reprepro going to take the data from?"
		return 2
	fi

	local queryResult
	queryResult="`reprepro --dbdir "$dbDir" -T deb listfilter "$codename" "Package (==$package), Architecture (==all), Version (==$packageVersion)"`"

	if [ ! -z "$queryResult" ]; then
		return 0
	else
		return 1
	fi
}

#USAGE: isDistroSupported(distribution, [distributionsFile]): isDistroSupported "unstable";
#. isDistroSupported "stable" "$HOME/reprepro/conf/distributions"
isDistroSupported() {
	local distributionsFile listedSuites distro suite

	if [ -z "${1:-}" ]; then
		Say "Please specify a distribution you want me to check!"
		return 1
	else
		distro="${1:-}"
	fi

	if [ ! -z "${2:-}" ] && [ -f "${2:-}" ]; then
		distributionsFile="${2:-}"
	elif [ -f "$BASE_DIR/conf/incoming" ]; then
		distributionsFile="$BASE_DIR/conf/distributions"
	fi

	if [ ! -f "$distributionsFile" ]; then
		Say "Couldn't find reprepro's conf/distributions, how am I going to find out the available suites then?"
		return 2
	fi

	listedSuites=`cat $distributionsFile | grep Suite | sort -ru | awk '-F: ' '{ print $2 }'`

	for suite in $listedSuites; do
		if [ "$suite" == "$distro" ]; then
			return 0
		fi
	done

	return 1
}

#USAGE: getSupportedRepDistros([distributionsFile]): getSupportedRepDistros;
#. getSupportedRepDistros "$HOME/reprepro/conf/distributions"
getSupportedRepDistros() {
	local distributionsFile listedSuites suite

	if [ ! -z "${1:-}" ] && [ -f "${1:-}" ]; then
		distributionsFile="${1:-}"
	elif [ -f "$BASE_DIR/conf/incoming" ]; then
		distributionsFile="$BASE_DIR/conf/distributions"
	fi

	if [ ! -f "$distributionsFile" ]; then
		Say "Couldn't find reprepro's conf/distributions, how am I going to find out the available suites then?"
		return 1
	fi

	listedSuites=`cat $distributionsFile | grep Suite | sort -ru | awk '-F: ' '{ print $2 }'`

	# make public the information:
	SUPPORTED_DISTROS="$listedSuites"
}
