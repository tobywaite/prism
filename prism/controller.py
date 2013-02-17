from color import Color, ColorQuantum
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

    def fade_node(self, node, start, end, duration):
        # fade a node from one color to another over a duration.
        r_delta = start.red - end.red
        g_delta = start.green - end.green
        b_delta = start.blue - end.blue
        i_delta = start.intensity - end.intensity

        # The number of steps in the transition will be equal to largest
        # magnitude delta between the starting and ending colors
        steps = max(r_delta, g_delta, b_delta, i_delta, key=lambda x: x * x)
        time_step = float(duration) / steps

        transition_states = [ColorQuantum(start, time_step)]

        new_val = old_val + float(delta) / step

        for step in range(steps):
            red = start.red + (r_delta / float(step))
            green = start.green + (g_delta / float(step))
            blue = start.blue + (b_delta / float(step))
            intensity = start.intensity + (i_delta / float(step))

            trans_color = Color(red, green, blue, intensity)

            transition_states.append(ColorQuantum(trans_color, time_step))

        for state in transition_states:
            node.set_color(state.color)
            time.sleep(state.duration)
