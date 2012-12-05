class ValueOutOfBounds(Exception):
    pass


class FixedWidth(int):
    """Represents a fixed width integer. Trying to create a number that
    cannot be represented in the specified width will raise an exception.
    """
    def __new__(cls, value, width=4):
        # Value must be between 0 and the max value for an int of given width.
        if value < 0 or value > (2 ** width - 1):
            raise ValueOutOfBounds
        inst = super(FixedWidth, cls).__new__(cls, value)
        inst.width = width
        return inst

    # For standard arithmatic, return FixedWidth types for bounds checking.
    def __add__(self, other):
        return FixedWidth(int(self) + other)

    def __sub__(self, other):
        return FixedWidth(int(self) - other)

    def bit_length(self):
        return self.width
