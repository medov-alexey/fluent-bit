#print(open('/tmp/log.txt').read().split('\n'))

import time

for i in range(0, 600):
  f = open('/tmp/log.txt', 'r')
  content = f.read()
  print(content, end='')
  f.close()
  time.sleep(1)
