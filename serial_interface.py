import serial
import time

class RGBController:

    INITIALIZATION_COMMAND = '%'
    DEFAULT_BAUD_RATE = 115200
    DEFAULT_SERIAL_PORT = '/dev/tty.usbserial-A6008cQz'

    def __init__(self, serial_port=DEFAULT_SERIAL_PORT, baud_rate=DEFAULT_BAUD_RATE, grid=None):
        if grid:
            self.grid = grid
        else:
            self.grid = [
                [LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor()],
                [LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor()],
                [LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor()],
                [LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor()],
                [LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor()],
                [LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor()],
                [LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor()],
                [LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor()],
                [LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor()],
                [LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor(), LEDColor()]]

        self.serial = serial.Serial(serial_port, baud_rate)
        self.serial.write(self.INITIALIZATION_COMMAND) # send initialization command

        time.sleep(1) # sleep to ensure the initialization is completed before continuing.

        print "initialization complete"

    def set_lights(self):
        self.serial.flush()

        time.sleep(0.15)

        bytestring_command = []
        for col in self.grid:
            for cell in col:
                bytestring_command.extend(cell.to_bytelist())

        self.serial.write('.') #indicates start of command
        self.serial.write(bytearray(bytestring_command))
        
        waiting_for_response = True
        start_time = time.clock()
        while(waiting_for_response):
            if self.serial.inWaiting() > 0:
                waiting_for_response = False
            if time.clock() - start_time > 2:
                waiting_for_response = False
                print "timeout :-("
        print "time elapsed: %f" % (time.clock() - start_time)

    def set_whole_grid(self, led_color):
        for col in self.grid:
            for cell in col:
                cell.set_color(led_color)
        self.set_lights()

    
class LEDColor:
    INTENSITY_MAX = 0xFF
    COLOR_MAX = 0xF

    def __init__(self, i=INTENSITY_MAX, r=COLOR_MAX, g=COLOR_MAX, b=COLOR_MAX):
        self.i = i
        self.r = r
        self.g = g
        self.b = b

    def set_red(self):
        self.r = self.COLOR_MAX
        self.g = 0x00
        self.b = 0x00

    def set_green(self):
        self.r = 0x00
        self.g = self.COLOR_MAX
        self.b = 0x00

    def set_blue(self):
        self.r = 0x00
        self.g = 0x00
        self.b = self.COLOR_MAX

    def set_white(self):
        self.r = self.COLOR_MAX
        self.g = self.COLOR_MAX
        self.b = self.COLOR_MAX

    def set_color(self, led_color):
        self.i = led_color.i
        self.r = led_color.r
        self.g = led_color.g
        self.b = led_color.b

    def brighten(self):
        self.i = self.i + 16
        if self.i > self.INTENSITY_MAX:
            self.i = self.INTENSITY_MAX

    
    def dim(self):
        self.i = self.i - 16
        if self.i < 0:
            self.i = 0
    
    def to_bytelist(self):
        return [self.i, self.r, self.g, self.b]

    def __repr__(self):
        return "Color: [I:%d, R:%d, G:%d, B:%d]" % (self.i, self.r, self.g, self.b)

if __name__ == '__main__':

    lights = RGBController()
    color = LEDColor()
    color.set_red()

    lights.set_whole_grid(color)

    iterations = 1

    for _ in range(iterations):
        for _ in xrange(16):
            print color
            color.dim()
            lights.set_whole_grid(color)
        color.set_blue()
        for _ in xrange(16):
            print color
            color.brighten()
            lights.set_whole_grid(color)