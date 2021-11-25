#print(open('/tmp/log.txt').read().split('\n'))

f = open('/tmp/log.txt', 'r')
content = f.read()
print(content, end='')
f.close()
