from collections import namedtuple

from fixed_width import FixedWidth


class Color(object):
    def __init__(self, red=0, green=0, blue=0, intensity=128):
        self.red = red
        self.green = green
        self.blue = blue
        self.intensity = intensity

    def __setattr__(self, name, value):
        width = 8 if name == 'intensity' else 4
        super(Color, self).__setattr__(name, FixedWidth(value, width=width))

ColorQuantum = namedtuple('ColorQuantum', ['color', 'duration'])
