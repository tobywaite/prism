from node import Node
from serial_connection import SerialConnection


class Controller(object):
    def __init__(self, nodes=None, serial=None):
        self.serial = serial or SerialConnection()
        self.nodes = (
            nodes or [Node(index, self.serial) for index in xrange(1, 50)]
        )

    def set_all(self, color):
        for node in self.nodes:
            node.color = color
