
from mininet.topo import Topo
from mininet.node import Controller, RemoteController, OVSKernelSwitch, CPULimitedHost
from mininet.net import Mininet
from mininet.link import TCLink
from mininet.cli import CLI
from mininet.util import custom
from mininet.log import setLogLevel, info, warn, error, debug

from DCTopo import FatTreeTopo, NonBlockingTopo
from DCRouting import Routing

from subprocess import Popen, PIPE
from argparse import ArgumentParser
import multiprocessing
from time import sleep
from monitor.monitor import monitor_devs_ng
import os
import sys
import hedera

K = 4

# Queue Size
QUEUE_SIZE = 100

# Link capacity (Mbps)
BW = 10

TIME = 10

setLogLevel( 'info' )

hedera.clean()

pox_c = Popen("~/pox/pox.py %s --topo=ft,4 --routing=ECMP"% "DCController", shell=True)

info('*** Creating the topology')
topo = hedera.FatTreeTopo(4)

host = custom(CPULimitedHost, cpu=0.03)
link = custom(TCLink, bw=10, max_queue_size=QUEUE_SIZE)

net = Mininet(topo, host=host, link=link, switch=OVSKernelSwitch,
        controller=RemoteController)

net.start()

info('** Waiting for switches to connect to the controller\n')
sleep(5)

hosts = net.hosts

host_list = {}
for h in hosts:
    print(h.IP())
    host_list[h.IP()] = h

port = 5001

data = open("/home/mininet/hedera/inputs/all_to_all_data")

hedera.start_tcpprobe()

info('*** Starting iperf ...\n')
for line in data:
    flow = line.split(' ')
    src_ip = flow[0]
    dst_ip = flow[1]
#    print("Generating flow from %s to %s" & (src_ip, dst_ip) )
    if src_ip not in host_list:
        print("Unique: %s not in host_list" % src_ip)
        continue
    sleep(0.2)
    server = host_list[dst_ip]
    server.popen('iperf -s -p %s' % port, shell = True )

    client = host_list[src_ip]
    #    client.popen('iperf -c %s -p %s -t %d > %s.txt'
    #        % (server.IP(), port, TIME, client.__str__()), shell = True )
    # works !! := client.popen('echo "Hello World!" > %s.txt' % client.__str__(), shell = True )
    print net.iperf(hosts = [server, client], seconds = TIME)


monitor = multiprocessing.Process(target = monitor_devs_ng, args =
            ('%s/rate.txt' % "/home/mininet/hedera/results", 0.01))

monitor.start()

sleep(TIME)

monitor.terminate()

info('*** stoping iperf ...\n')
hedera.stop_tcpprobe()

Popen("killall iperf", shell=True).wait()

net.stop()

hedera.clean()

Popen("killall -9 top bwm-ng", shell=True).wait()
os.system('sudo mn -c')
