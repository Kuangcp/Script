import fire
import sys
import json

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
end='\033[0m'

def logError(msg):
    print('%s%s%s'%(red, msg, end))

def logInfo(msg):
    print('%s%s%s'%(green, msg, end))

def printParam(verb, args, comment):
    print('  %s%-5s %s%-12s %s%s'%(green, verb, yellow, args, end, comment))

def help():
    print('run: python3 app.py %s %s<verb>%s <args>%s'%('', green, yellow, end))
    printParam('-h', '', 'help')
    printParam('-a', 'name file', 'add')
    printParam('-r', 'name file', 'replace')

def main(verb=None, *args):
    if verb == '-h':
        help()
        sys.exit(0)
    if verb == '-a':
        if len(args) != 2 or  args[0]==None or args[1] == None:
            logError('invalid param, at least need 2')
            return
        name = args[0]
        file_path = args[1]

    if verb == '-r':
        pass


# docker11 start
# docker11 end


fire.Fire(main)