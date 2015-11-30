#!/usr/bin/env python

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
        self.mountpoints = ['/', '/data/one', '/data/two']

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

    def get_mpstat(self):
        stdin, stdout, stderr = self.client.exec_command(
            'export LC_LANG=C && unset LANG && mpstat -P ALL 1 1')
        stats = {}
        pos = {'%usr':-1, '%nice':-1, '%sys':-1, '%iowait':-1,
               '%irq':-1, '%soft':-1, '%steal':-1, '%guest':-1,
               '%idle':-1}

        for line in stdout:
            line = line.strip()
            if not line:
                continue

            if 'CPU' in line and (r'%usr' in line or r'%user' in line):
                elts = [e for e in line.split(' ') if e]
                for k in pos:
                    try:
                        pos[k] = elts.index(k)
                    except ValueError:
                        if k == '%usr':
                            pos[k] = elts.index('%user')
                        elif k == '%guest':
                            pass
                        else:
                            raise
                continue

            if not line.startswith('Average:'):
                continue
            if line.startswith('CPU'):
                continue

            tmp = [e for e in line.split(' ') if e]
            cpu = tmp[1]
            stats[cpu] = {'%usr':0, '%nice':0, '%sys':0, '%iowait':0,
                          '%irq':0, '%soft':0, '%steal':0, '%guest':0,
                          '%idle':0}
            for (k, idx) in pos.iteritems():
                if idx == -1:
                    continue
                stats[cpu][k] = float(tmp[idx])
            return stats

    def get_df(self):
        stdin, stdout, stderr = self.client.exec_command(
            'export LC_LANG=C && unset LANG && df -l -T -k -P')
        dfs = {}

        for line in stdout:
            line = line.strip()

            if not line or line.startswith('Filesystem'):
                continue

            tmp = [s for s in line.split(' ') if s]

            _type = tmp[1]
            if _type in ['tmpfs', 'devtmpfs', 'iso9660']:
                continue


            to_check = True
            if self.mountpoints:
                to_check = False
                for mnt in self.mountpoints:
                    if tmp[6].startswith(mnt):
                        to_check = True


            if not to_check:
                continue

            fs =  tmp[0]
            size = int(tmp[2])*1024
            used = int(tmp[3])*1024
            avail = int(tmp[4])*1024
            used_pct = int(tmp[5][:-1]) # we remove the %
            mounted = ' '.join(tmp[6:])
            dfs[mounted] = {'fs':fs, 'size':size, 'used':used,
                            'avail':avail, 'used_pct':used_pct}

        return dfs


class CheckServers(object):

    def __init__(self, names):
        self.names = names
        self.servers = {}
        self.active_servers = []
        self.s_unit = "MB"

        self.warning, self.critical = schecks.get_warn_crit('75%', '90%')
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

    def cpu_stats(self):
        print(Fore.WHITE + "##### CPU stats" + Style.RESET_ALL)
        for name in self.active_servers:
            stats = self.servers[name].get_mpstat()
            if not stats:
                continue

            perfdata = []
            for (cpu, v) in stats.iteritems():
                s_cpu = 'cpu_%s' % cpu
                for (k,j) in v.iteritems():
                    # We remove the % of the %usr for example in k
                    perfdata.append('%s_%s=%.2f%%' % (s_cpu, k[1:], j))
            print("CPU stats for %s:" % name)
            print((Fore.YELLOW + "\t%s" + Style.RESET_ALL)
                  % ('\n\t'.join(perfdata)))

    def _convert_to(self, unit, value):
        UNITS= {'B': 0,
                'KB': 1,
                'MB': 2,
                'GB': 3,
                'TB': 4}
        power = 0
        if unit in UNITS:
            power = UNITS[unit]
        return round(float(value)/(1024**power), power)

    def disk_stats(self):
        print(Fore.WHITE + "##### Disk stats" + Style.RESET_ALL)
        for name in self.active_servers:

            dfs = self.servers[name].get_df()
            perfdata = ''

            for (mount, df) in dfs.iteritems():
                size =  self._convert_to(self.s_unit ,df['size'])
                used =  self._convert_to(self.s_unit,df['used'])
                used_pct =  df['used_pct']

                _size_warn = (self._convert_to(self.s_unit,df['size']
                                               * float( self.warning)/100))
                _size_crit = (self._convert_to(self.s_unit,df['size']
                                               * float( self.critical)/100))

                if perfdata != "":
                    perfdata += "\n"
                perfdata += ('\t%s : %s%s (%s%% of %s%s)'
                             % (mount, used, self.s_unit, used_pct, size,
                                self.s_unit))
            print(("Disk stas for %s" + Fore.YELLOW) % name)
            print(("%s" + Style.RESET_ALL) % (perfdata))

def main():

    cs = CheckServers(["cezanne.inf.ed.ac.uk",
                       "degas.inf.ed.ac.uk",
                       "dali.inf.ed.ac.uk",
                       "goya.inf.ed.ac.uk"])

    cs.ping()
    cs.connect()
    cs.check_uptime()
    cs.cpu_stats()
    cs.disk_stats()

if __name__ == "__main__":
    main()
