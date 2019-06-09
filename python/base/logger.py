import logging
import sys

logging.addLevelName(logging.DEBUG, "\033[0;35m%s\033[1;0m" % logging.getLevelName(logging.DEBUG))
logging.addLevelName(logging.WARNING, "\033[1;31m%s\033[1;0m" % logging.getLevelName(logging.WARNING))
logging.addLevelName(logging.ERROR, "\033[1;31m%s\033[1;0m" % logging.getLevelName(logging.ERROR))

log = logging.getLogger(__name__)
formatter = logging.Formatter('\033[0;33m%(asctime)s \033[1;0m%(levelname)-5s \033[1;37m%(filename)s'
                              ' \033[1;0m%(funcName)s@\033[1;33m%(lineno)d \033[1;0m|\033[1;32m  %(message)s \033[1;0m')
console_handler = logging.StreamHandler(sys.stdout)
console_handler.formatter = formatter

log.addHandler(console_handler)
log.setLevel(logging.INFO)
