## General Requirements

For some of the script, you need to be able to access `rad_admin` without
password. 
To do so you should create a ssh key and copy it over the admin user:

* `$ ssh-keygen -t rsa -b 4096 -C "your_email_address"`
* `$ ssh-copy-id rad_admin@cezanne.inf.ed.ac.uk`
* Repeat the last command for all the servers

The password for `rad_admin` can be found in the wiki.


## `install.sh`

Run this on the server itself! The script will install all
the required packages. See the install folder to see what
gets installed.


## `add-server-user.sh`

Run this on your machine! The script will ask you for the
name of the new user. *NOTA BENE:$* the user will be an
admin and therefore will have sudo powers.


## `give-internet.sh`

Run this on the server itself!

Example usage: 
* `./give-internet.sh youbot starscream`
* `./give-internet.sh edran primec1.inf.ed.ac.uk`


## `check-server-status.sh`

Run this on your machine! Gives an overview of the status
of all the servers.

### Installation

#### On your machine

* `pip install -r requirements.txt`
* Make sure you can ssh into the servers without typing the password.

#### On the servers

* `$ sudo apt-get install sysstat`
* `$ sudo cp cpufrequtils.config /etc/defaults/cpufrequtils`
* `$ sudo update-rc.d ondemand disable`
* `$ sudo /etc/init.d/cpufrequtils restart`


