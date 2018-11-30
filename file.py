
import multiprocessing
from monitor.monitor import monitor_devs_ng

server = net.hosts[0]
server.popen('iperf -s -p %s > ~/hedera/server.txt' % 5001, shell = True)

client = net.hosts[1]
client.popen('iperf -c %s -p %s -t %d > ~/hedera/client.txt' 
        % (server.IP(), 5001, 10 ), shell=True)

monitor = multiprocessing.Process(target = monitor_devs_ng, args =
            ('%s/rate.txt' % "~/hedera/", 0.01))

monitor.start()

sleep(args.time)

monitor.terminate()
 
