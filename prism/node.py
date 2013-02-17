from fixed_width import FixedWidth


X_Y_TO_INDEX = (
    (49, 36, 35, 22, 21,  8, 7),
    (48, 37, 34, 23, 20,  9, 6),
    (47, 38, 33, 24, 19, 10, 5),
    (46, 39, 32, 25, 18, 11, 4),
    (45, 40, 31, 26, 17, 12, 3),
    (44, 41, 30, 27, 16, 13, 2),
    (43, 42, 29, 28, 15, 14, 1),
)

INDEX_TO_X_Y = (
    None, (6, 6), (6, 5), (6, 4), (6, 3), (6, 2), (6, 1), (6, 0),
          (5, 0), (5, 1), (5, 2), (5, 3), (5, 4), (5, 5), (5, 6),
          (4, 6), (4, 5), (4, 4), (4, 3), (4, 2), (4, 1), (4, 0),
          (3, 0), (3, 1), (3, 2), (3, 3), (3, 4), (3, 5), (3, 6),
          (2, 6), (2, 5), (2, 4), (2, 3), (2, 2), (2, 1), (2, 0),
          (1, 0), (1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6),
          (0, 6), (0, 5), (0, 4), (0, 3), (0, 2), (0, 1), (0, 0),
)


class Node(object):
    def __init__(self, serial, index, color=None, commands=None):
        self.serial = serial
        self.index = index
        self.x, self.y = INDEX_TO_X_Y[index]
        self.color = color

    def _get_color(self):
        return self._color

    def _set_color(self, color):
        self._color = color
        # send the serial command to set the color on the light grid.
        self.serial.send_command(self.index, color, debug=True)

    color = property(_get_color, _set_color)

    def _get_index(self):
        return self._index

    def _set_index(self, value):
        # Cast all values to FixedWidth types when set.
        self._index = FixedWidth(value, width=8)

    index = property(_get_index, _set_index)
