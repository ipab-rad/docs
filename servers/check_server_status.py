#!/usr/bin/python

# Requires colorama

from __future__ import print_function
import os

import colorama
from colorama import Fore, Back, Style

colorama.init()

class Server(object):

    def __init__(self, name):
        self.name = name

    def ping(self):
        response = os.system("ping -c 1 -w2 " +
                             self.name +
                             " > /dev/null 2>&1")
        return response == 0

class CheckServers(object):

    def __init__(self, names):
        self.names = names
        self.servers = {}

        for name in self.names:
            self.servers[name] = Server(name)

    def ping_all(self):
        for name in self.names:
            print("Trying to ping %s..." % name, end="")
            if self.servers[name].ping():
                print(Fore.GREEN + "DONE" + Style.RESET_ALL)
            else:
                print(Fore.RED + "FAILED" + Style.RESET_ALL)


def main():

    cs = CheckServers(["cezanne.inf.ed.ac.uk",
                       "degas.inf.ed.ac.uk",
                       "dali.inf.ed.ac.uk",
                       "goya.inf.ed.ac.uk"])

    cs.ping_all()

if __name__ == "__main__":
    main()
