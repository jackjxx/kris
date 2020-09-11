#!/usr/bin/env python
# deviceio.relay.py
#
#  tcprelay wrapper for python
#
# pylint: disable=C0111, C0326, C0103, C0301

from __future__ import unicode_literals

import logging
import os
import re
import socket
import subprocess
import time
import fcntl


class TcprelayLock(object):

    def __init__(self, filename):
        self.filename = filename
        # This will create it if it does not exist already
        self.handle = open(filename, 'w')

    # Bitwise OR fcntl.LOCK_NB if you need a non-blocking lock
    def acquire(self):
        fcntl.flock(self.handle, fcntl.LOCK_EX)

    def release(self):
        fcntl.flock(self.handle, fcntl.LOCK_UN)

    def __del__(self):
        self.handle.close()


logger = logging.getLogger(__name__)


class TcpRelayError(Exception):
    pass


class TcpRelay(object):
    def __init__(self, locationid):
        """
        Arguments:
            locationid: (integer,hex string)    The locationid of the device
            logger:     (logging logger)        Logger for class
        """
        assert(type(locationid) in (int, long))

        if locationid == 0:
            logger.debug("Bad Location ID: {}".format(locationid))
            logger.debug("Attempting to find valid locationID")
            locationid = get_location_id_from_tcp_relay()

        self._relayproc = None
        self._relaypid = None
        self._locationid = locationid
        self._portoffset = None
        self._logfile = "/tmp/tcprelay.{0}.log"
        self._target = 'localhost'
        self._pwd = 'alpine'
        self._ssh_client = None
        self._lock = TcprelayLock("/tmp/py-tcprelay-open-port.lock")

    def __del__(self):
        self.close()

    @property
    def is_active(self):
        """
        Check if the tcprelay tunnel used by current object still valid
        """
        if not self._relaypid:
            return False

        self._lock.acquire()
        relaypid = None
        portoffset = None
        try:
            relaypid, portoffset = self._check_tcprelay()
        except AttributeError:
            logger.debug(
                "No active TCPRELAY tunnel on locationid - {0}"
                "".format(self.locationid_param))
        finally:
            self._lock.release()

        return (
                self._relaypid == relaypid and
                self._portoffset == portoffset
                )

    def open(self):
        """
        Will open a tcprelay connection or if one already exists it will
        piggyback on that
        """
        self._lock.acquire()
        try:
            self._relaypid, self._portoffset = self._check_tcprelay()
            logger.debug(
                "PIGGYBACK TCPRELAY"
                "PID: {0} PORT: {1}".format(self._relaypid,
                                            self._portoffset))
        except AttributeError:
            # TODO: tcprelays might want to close when test is over???
            self._portoffset = get_available_portoffset()
            command = "/usr/local/bin/tcprelay --portoffset {0} " \
                      "--locationid {1} rsync telnet " \
                      "ssh > /tmp/tcprelay.{1}.log 2>&1" \
                      " &".format(self._portoffset, self.locationid_param)
            logger.debug("SPAWNING TCPRELAY - {0}".format(command))
            child = subprocess.Popen(["bash", "-c", command], close_fds=True)
            time.sleep(0.5)
            try:
                self._relaypid, self._portoffset = self._check_tcprelay()
            except AttributeError:
                logger.error(
                    "FAILED to SPAWN TCPRELAY - CMD {0} "
                    "OUTPUT: {1} ERROR: {2} RC: {3}".format(command,
                                                            child.stdout,
                                                            child.stderr,
                                                            child.returncode))
        finally:
            self._lock.release()

    def _check_tcprelay(self):
        """
        Check the existing tcp relay mapped to our locationid
        Returns:
            tcp_relaypid, portoffset
        Raises AttributeError if no match
        """
        check = 'ps -e -opid -ocommand | grep tcprelay | grep -v ' \
                'grep | grep {0}'.format(self.locationid_param)
        output, _ = subprocess.Popen(
            ["bash", "-c", check], stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            universal_newlines=True).communicate()
        regex = re.search(
            r"^\s*([0-9]+).* --portoffset ([0-9]+).*", output)
        match = regex.groups()
        relaypid = int(match[0])
        portoffset = int(match[1])
        logger.debug(
            "CHECK TCPRELAY - CMD: {0} "
            "OUTPUT: {1} PID: {2} PORT: {3}".format(check,
                                                    output,
                                                    relaypid,
                                                    portoffset))
        return relaypid, portoffset

    @property
    def locationid_param(self):
        return hex(self._locationid).rstrip('L')

    def portoffset(self):
        """
        get port offset
        Returns:
            (integer) the port offset
        """
        return self._portoffset

    def close(self):
        """
        abandons the current tcprelay
        """
        self._relaypid = None
        self._portoffset = None

    def _rsync(self, rsync):
        """
        internal rsync via expect
        Arguments:
            rsync:  (string) the rysnc command
        """
        rsync_expect = "set timeout -1; spawn {rsync}; expect " \
                       "\"Password:\"; send \"{pwd}\n\"; expect eof"
        command = ["/usr/bin/expect", "-c",
                   rsync_expect.format(rsync=rsync, pwd=self._pwd)]
        logger.debug(command)
        proc = subprocess.Popen(command,
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        std, err = proc.communicate()
        if len(std):
            logger.info(std)
        if len(err):
            logger.error(err)
        #     return False
        return True

    def rsync_to(self, local, remote, flags='-av', user='root'):
        """
        rsync to device from host
        Arguments:
            local:  source path  - local host
            remote: destination path -remote device
            flags:  rsync flags
            user:   rsync username
        Returns:
            (Boolean) whether rsync was success
        """
        if self._portoffset:
            tail = "/" if local[-1] == "/" else ''
            local = os.path.abspath(os.path.expanduser(local)) + tail
            return self._rsync(
                'rsync {flags} {src} '
                'rsync://{usr}@{target}:{port}{dest}'.format(
                    flags=flags, src=local, usr=user, target=self._target,
                    port=(self._portoffset + 873), dest=remote))
        return False

    def rsync_from(self, remote, local, flags='-av', user='root'):
        """
        rsync to device from host
        Arguments:
            remote: source path -remote device
            local:  dest path  - local host
            flags:  rsync flags
            user:   rsync username
        Returns:
            (Boolean) whether rsync was success
        """
        if self._portoffset:
            tail = "/" if local[-1] == "/" else ''
            local = os.path.abspath(os.path.expanduser(local)) + tail
            return self._rsync(
                'rsync {flags} rsync://{usr}'
                '@{target}:{port}{src} {dest}'.format(
                    flags=flags, src=remote, usr=user, target=self._target,
                    port=(self._portoffset + 873), dest=local))
        return False

    def kill(self):
        """ Kill the tcprelay associated with this class. """
        subprocess.check_output(['sudo', 'kill', str(self._relaypid)])
        self.close()

    @property
    def is_device_attached(self):
        return self._locationid in get_all_location_ids_from_tcp_relay()


def get_all_location_ids_from_tcp_relay():
    """
    use tcprelay to get location ID for all connected USB devices,
    Returns:
        a list of matched location id decimal integers
    """
    # tcprelay has a default 5s timeout, but enumerates quickly
    # Run in the background and kill after 0.1s to avoid this
    cmd = "/usr/local/bin/tcprelay --list & sleep 0.1; kill $!"
    output = subprocess.check_output(cmd, shell=True)
    location_ids = re.findall(r"Location:\s*([0-9A-Fa-f]+)", output)

    # convert hex string in location_ids to integer
    def hex_to_int(x): return int(x, 16)

    return list(map(hex_to_int, location_ids))


def get_location_id_from_tcp_relay():
    location_ids = get_all_location_ids_from_tcp_relay()
    if len(location_ids):
        return location_ids[0]
    else:
        logger.error(
            "Cannot find a valid locationID. "
            "Is device panicked or not connected?")
        return 0


def get_available_portoffset(target="localhost"):
    """
    scans host ports for an available portoffset
    Returns:
        integer or None if no port offset exists
    """
    target_ip = socket.gethostbyname(target)
    for portoffset in range(10000, 61000, 1000):
        i = portoffset + 873
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        result = sock.connect_ex((target_ip, i))
        sock.close()
        if result != 0:
            logger.debug("port open {0}".format(portoffset))
            return portoffset
    return None
