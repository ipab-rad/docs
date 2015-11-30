#!/usr/bin/env python

# Requires colorama

from __future__ import print_function
import os

import colorama
from colorama import Fore, Back, Style

import schecks

colorama.init()

class Server(object):

    def __init__(self, name):
        self.name = name
        # TODO make them selectable
        self.key = os.path.expanduser("~/.ssh/github_rsa")
        self.user = 'rad_admin'

    def ssh_connect(self):
        try:
            self.client = schecks.connect(self.name, 22, self.key, '', self.user)
        except:
            self.client = None

    def ping(self):
        response = os.system("ping -c 1 -w2 " +
                             self.name +
                             " > /dev/null 2>&1")
        return response == 0

    def uptime(self):
        raw = r"""cat /proc/uptime"""
        stdin, stdout, stderr = self.client.exec_command(raw)
        line = [l for l in stdout][0].strip()
        uptime, _ = tuple([int(float(v)) for v in line.split(' ')])
        return uptime

    def get_time(self):
        return None

class CheckServers(object):

    def __init__(self, names):
        self.names = names
        self.servers = {}
        self.active_servers = []

        for name in self.names:
            self.servers[name] = Server(name)

    def ping(self):
        print(Fore.WHITE + "##### Servers reachability" + Style.RESET_ALL)
        for name in self.names:
            print("Trying to ping %s..." % name, end="")
            if self.servers[name].ping():
                print(Fore.GREEN + "DONE" + Style.RESET_ALL)
            else:
                print(Fore.RED + "FAILED" + Style.RESET_ALL)

    def connect(self):
        print(Fore.WHITE + "##### SSH connection" + Style.RESET_ALL)
        for name in self.names:
            print("Trying to connect via ssh to %s..." % name, end="")
            self.servers[name].ssh_connect()
            if self.servers[name].client:
                self.active_servers.append(name)
                print(Fore.GREEN + "DONE" + Style.RESET_ALL)
            else:
                print(Fore.RED + "FAILED" + Style.RESET_ALL)

    def check_uptime(self):
        print(Fore.WHITE + "##### Uptime" + Style.RESET_ALL)
        for name in self.active_servers:
            up = int(self.servers[name].uptime()) / 60
            print(("Uptime for %s: " + Fore.YELLOW +
                   "%d minutes" + Style.RESET_ALL) % (name, up))


def main():

    cs = CheckServers(["cezanne.inf.ed.ac.uk",
                       "degas.inf.ed.ac.uk",
                       "dali.inf.ed.ac.uk",
                       "goya.inf.ed.ac.uk"])

    cs.ping()
    cs.connect()
    cs.check_uptime()

if __name__ == "__main__":
    main()
