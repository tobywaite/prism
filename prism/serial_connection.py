from contextlib import contextmanager
from serial import Serial
from time import sleep

from prism.fixed_width import FixedWidth


class SerialConnection(object):
    def __init__(self, port='/dev/tty.usbserial-A6008cQz', baud_rate=115200):
        self.port = Serial(port, baud_rate)
        response = self.port.readline(5)
        if response != "ready":
            raise InitializationFailed

    @contextmanager
    def connection(self):
        self.port.open()
        yield
        self.port.close()

    def send_command(self, index, color, delay=0.0012, debug=False):

        def concat_bits(bitstring, fixed_width_num):
            return (
                (bitstring << fixed_width_num.bit_length()) | fixed_width_num
            )

        bitstring = bytearray([
            concat_bits(0b1100, color.red),
            concat_bits(color.green, color.blue),
            color.intensity,
            index,
        ])

        bytes_written = self.port.write(bitstring)

        # delay to allow arduino to process command before continuing
        sleep(delay)

        return bytes_written

    def get_response(self):
        response = ""
        while(self.port.inWaiting() > 0):
            response += self.port.read()
        if response:
            print "resp:"
            print response
            print "done reading"


class InitializationFailed(Exception):
    pass
