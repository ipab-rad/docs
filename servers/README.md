## Installation

* `pip install -r requirements.txt`

### On the servers

* `$ sudo apt-get install sysstat`
* `$ sudo cp cpufreq.service /etc/systemd/system/cpufreq.service`
* `$ sudo systemctl daemon-reload`
* `$ sudo systemctl enable cpufreq.service`
