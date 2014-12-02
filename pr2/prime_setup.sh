#!/bin/bash

# Author: Rethink Robotics
# Author: Nantas Nardelli <n.nardelli@sms.ed.ac.uk>

# This file is to be used in the *root* of your Catkin workspace.

# This is a convenient script which will set up your ROS environment and
# should be executed with every new instance of a shell in which you plan on
# working with PR2.

# Clear any previously set your_ip/your_hostname
unset your_ip
unset your_hostname
#-----------------------------------------------------------------------------#
#                 USER CONFIGURABLE ROS ENVIRONMENT VARIABLES                 #
#-----------------------------------------------------------------------------#
# Note: If ROS_MASTER_URI, ROS_IP, or ROS_HOSTNAME environment variables were
# previously set (typically in your .bashrc or .bash_profile), those settings
# will be overwritten by any variables set here.

# Specify Baxter's hostname
pr2_hostname="pr2_hostname"

# Set *Either* your computers ip address or hostname. Please note if using
# your_hostname that this must be resolvable to Baxter.
#your_ip="192.168.XXX.XXX"
your_hostname="my_computer"

# Specify ROS distribution (e.g. groovy, hydro)
ros_version="hydro"
#-----------------------------------------------------------------------------#

tf=$(tempfile)
trap "rm -f -- '${tf}'" EXIT

# If this file specifies an ip address or hostname - unset any previously set
# ROS_IP and/or ROS_HOSTNAME.
# If this file does not specify an ip address or hostname - use the
# previously specified ROS_IP/ROS_HOSTNAME environment variables.
if [ -n "${your_ip}" ] || [ -n "${your_hostname}" ]; then
	unset ROS_IP && unset ROS_HOSTNAME
else
	your_ip="${ROS_IP}" && your_hostname="${ROS_HOSTNAME}"
fi

# If argument provided, set pr2_hostname to argument
# If argument is sim or local, set pr2_hostname to localhost
if [ -n "${1}" ]; then
	if [[ "${1}" == "sim" ]] || [[ "${1}" == "local" ]]; then
		pr2_hostname="localhost"
		if [[ -z ${your_ip} || "${your_ip}" == "192.168.XXX.XXX" ]] && \
		[[ -z ${your_hostname} || "${your_hostname}" == "my_computer" ]]; then
			your_hostname="localhost"
			your_ip=""
		fi
	else
		pr2_hostname="${1}"
	fi
fi

topdir=$(basename $(readlink -f $(dirname ${BASH_SOURCE[0]})))

cat <<-EOF > ${tf}
	[ -s "\${HOME}"/.bashrc ] && source "\${HOME}"/.bashrc
	[ -s "\${HOME}"/.bash_profile ] && source "\${HOME}"/.bash_profile

	# verify ros_version lowercase
	ros_version="$(tr [A-Z] [a-z] <<< "${ros_version}")"

	# check for ros installation
	if [ ! -d "/opt/ros" ] || [ ! "$(ls -A /opt/ros)" ]; then
		echo "EXITING - No ROS installation found in /opt/ros."
		echo "Is ROS installed?"
		exit 1
	fi

	# if set, verify user has modified the pr2_hostname
	if [ -n ${pr2_hostname} ] && \
	[[ "${pr2_hostname}" == "pr2_hostname" ]]; then
		echo -ne "EXITING - Please edit this file, modifying the \
'pr2_hostname' variable to reflect pr2's current hostname.\n"
		exit 1
	fi

	# if set, verify user has modified their ip address (your_ip)
	if [ -n ${your_ip} ] && [[ "${your_ip}" == "192.168.XXX.XXX" ]]; then
		echo -ne "EXITING - Please edit this file, modifying the 'your_ip' \
variable to reflect your current IP address.\n"
		exit 1
	fi

	# if set, verify user has modified their computer hostname (your_hostname)
	if [ -n ${your_hostname} ] && \
	[[ "${your_hostname}" == "my_computer" ]]; then
		echo -ne "EXITING - Please edit this file, modifying the \
'your_hostname' variable to reflect your current PC hostname.\n"
		exit 1
	fi

	# verify user does not have both their ip *and* hostname set
	if [ -n "${your_ip}" ] && [ -n "${your_hostname}" ]; then
		echo -ne "EXITING - Please edit this file, modifying to specify \
*EITHER* your_ip or your_hostname.\n"
		exit 1
	fi

	# verify that one of your_ip, your_hostname, ROS_IP, or ROS_HOSTNAME is set
	if [ -z "${your_ip}" ] && [ -z "${your_hostname}" ]; then
		echo -ne "EXITING - Please edit this file, modifying to specify \
your_ip or your_hostname.\n"
		exit 1
	fi

	# verify specified ros version is installed
	ros_setup="/opt/ros/\${ros_version}"
	if [ ! -d "\${ros_setup}" ]; then
		echo -ne "EXITING - Failed to find ROS \${ros_version} installation \
in \${ros_setup}.\n"
		exit 1
	fi

	# verify the ros setup.sh file exists
	if [ ! -s "\${ros_setup}"/setup.sh ]; then
		echo -ne "EXITING - Failed to find the ROS environment script: \
"\${ros_setup}"/setup.sh.\n"
		exit 1
	fi

	# verify the user is running this script in the root of the catkin
	# workspace and that the workspace has been compiled.
	if [ ! -s "devel/setup.bash" ]; then
		echo -ne "EXITING - \n1) Please verify that this script is being run \
in the root of your catkin workspace.\n2) Please verify that your workspace \
has been built (source /opt/ros/\${ros_version}/setup.sh; catkin_make).\n\
3) Run this script again upon completion of your workspace build.\n"
		exit 1
	fi

	[ -n "${your_ip}" ] && export ROS_IP="${your_ip}"
	[ -n "${your_hostname}" ] && export ROS_HOSTNAME="${your_hostname}"
	[ -n "${pr2_hostname}" ] && \
		export ROS_MASTER_URI="http://${pr2_hostname}:11311"

	# source the catkin setup bash script
	source devel/setup.bash

	# setup the bash prompt
	export __ROS_PROMPT=\${__ROS_PROMPT:-0}
	[ \${__ROS_PROMPT} -eq 0 -a -n "\${PROMPT_COMMAND}" ] && \
		export __ORIG_PROMPT_COMMAND=\${PROMPT_COMMAND}

	__ros_prompt () {
		if [ -n "\${__ORIG_PROMPT_COMMAND}" ]; then
			eval \${__ORIG_PROMPT_COMMAND}
		fi
		if ! echo \${PS1} | grep '\[pr2' &>/dev/null; then
			export PS1="\[\033[00;31m\][pr2 - \
\${ROS_MASTER_URI}]\[\033[00m\] \${PS1}"
		fi
	}

	if [ "\${TERM}" != "dumb" ]; then
		export PROMPT_COMMAND=__ros_prompt
		__ROS_PROMPT=1
	elif ! echo \${PS1} | grep '\[pr2' &>/dev/null; then
		export PS1="[pr2 - \${ROS_MASTER_URI}] \${PS1}"
	fi

EOF

${SHELL} --rcfile ${tf}

rm -f -- "${tf}"
trap - EXIT

# vim: noet

# Useful aliases
alias prime='ssh primec1@inf.ed.ac.uk'
alias pr2_dash='rosrun rqt_pr2_dashboard rqt_pr2_dashboard'
alias rviz='rosrun rviz rviz'
