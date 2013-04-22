import itertools

from fixed_width import FixedWidth
from serial_connection import SerialConnection


class NodeController(object):

    INDEX_MAP = (
        None, # The first light of the string of 50 isn't used.
        (6, 6), (6, 5), (6, 4), (6, 3), (6, 2), (6, 1), (6, 0),
        (5, 0), (5, 1), (5, 2), (5, 3), (5, 4), (5, 5), (5, 6),
        (4, 6), (4, 5), (4, 4), (4, 3), (4, 2), (4, 1), (4, 0),
        (3, 0), (3, 1), (3, 2), (3, 3), (3, 4), (3, 5), (3, 6),
        (2, 6), (2, 5), (2, 4), (2, 3), (2, 2), (2, 1), (2, 0),
        (1, 0), (1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6),
        (0, 6), (0, 5), (0, 4), (0, 3), (0, 2), (0, 1), (0, 0),
    )

    X_Y_MAP = (
        (49, 36, 35, 22, 21,  8, 7),
        (48, 37, 34, 23, 20,  9, 6),
        (47, 38, 33, 24, 19, 10, 5),
        (46, 39, 32, 25, 18, 11, 4),
        (45, 40, 31, 26, 17, 12, 3),
        (44, 41, 30, 27, 16, 13, 2),
        (43, 42, 29, 28, 15, 14, 1),
    )

    def __init__(self):
        self.serial = SerialConnection()
        self.nodes = [Node(index) for index in xrange(1, 50)]
        self._previous_nodes = [Node(index) for index in xrange(1, 50)]
        self.transmit_state()

    def set_all(self, value):
        for node in self.nodes:
            node.value = value

    def transmit_state(self, debug=False):
        changed_nodes = [node for node, _ in itertools.dropwhile(
            lambda node, prev: node == prev,
            izip(self.nodes, self._previous_nodes))
        ]

        for node in changed_nodes:
            self.serial.send_command(node.index, node.value, debug=debug)


class Node(object):
    def __init__(self, index, color=None):
        self._index = index
        self.color = color

    def _get_index(self):
        return self._index

    def _set_index(self, value):
        # limit the possible values for _index to 8 bits.
        self._index = FixedWidth(value, width=8)

    index = property(_get_index, _set_index)


class NodeValue(object):
    def __init__(self, red=0, green=0, blue=0, intensity=128):
        self.red = red
        self.green = green
        self.blue = blue
        self.intensity = intensity

    def __setattr__(self, name, value):
        # All NodeValue properties are of limited bitwidth
        width = 8 if name == 'intensity' else 4
        super(NodeValue, self).\
            __setattr__(name, FixedWidth(value, width=width))
