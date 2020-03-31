#!/usr/bin/env python3
#
# (c) 2020 Yoichi Tanibayashi
#
"""
BLE Tag ID Publisher
"""
__author__ = 'Yoichi Tanibayashi'
__date__   = '2020/03'

from BlePeripheral import BlePeripheral, BlePeripheralApp
from MyLogger import get_logger, DEBUG, INFO, WARNING, ERROR, CRITICAL
import time
import click
CONTEXT_SETTINGS = dict(help_option_names=['-h', '--help'])


class BleTagPublisher(BlePeripheral):
    MYNAME = 'Yt'
    TAGID_PREFIX = 'T'

    _log = get_logger(__name__, False)

    def __init__(self, tagid, debug=False):
        self._dbg = debug
        __class__._log = get_logger(__class__.__name__, self._dbg)
        self._log.debug('tagid=%s', tagid)

        self._tagid = tagid

        self._myname = self.MYNAME
        self._ms_data = (self.TAGID_PREFIX + self._tagid).encode('utf-8')
        self._log.debug('_ms_data=%a', self._ms_data)

        super().__init__(self._myname, [], self._ms_data, debug=self._dbg)

    def start(self):
        super().start()

    def end(self):
        super().end()


class BleTagPublisherApp(BlePeripheralApp):
    _log = get_logger(__name__, False)

    def __init__(self, tagid, debug=False):
        self._dbg = debug
        __class__._log = get_logger(__class__.__name__, self._dbg)
        self._log.debug('tagid=%s', tagid)

        self._ble = BleTagPublisher(tagid, debug=self._dbg)

    def main(self):
        self._log.debug('')

        self._ble.start()

        self._active = True
        while self._active:
            time.sleep(1)

        return

    def end(self):
        self._active = False
        self._ble.end()


@click.command(context_settings=CONTEXT_SETTINGS, help='')
@click.argument('tagid', type=str)
@click.option('--debug', '-d', 'debug', is_flag=True, default=False,
              help='debug flag')
def main(tagid, debug):
    _log = get_logger(__name__, debug)
    _log.info('tagid=%s', tagid)

    app = BleTagPublisherApp(tagid, debug=debug)
    try:
        app.main()
    finally:
        _log.debug('finally')
        app.end()
        _log.debug('done')


if __name__ == '__main__':
    main()