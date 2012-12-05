from controller import Controller


if __name__ == '__main__':
    prism = Controller()
    with prism.serial.connection():
        prism.set_all(Color(red=15))
        sleep(5)
        prism.set_all(Color(green=15))
        sleep(5)
        prism.set_all(Color(blue=15))
        sleep(6)
