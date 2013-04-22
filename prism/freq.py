from contextlib import contextmanager
import numpy as np
import pyaudio
import wave

import matplotlib.pyplot as plt


@contextmanager
def SysAudioOutput(width, channels, rate):
    """A context manager for streaming audio to hardware speakers"""
    # Initizlize a stream to the speakers
    p = pyaudio.PyAudio()
    stream = p.open(
        format=p.get_format_from_width(width),
        channels=channels,
        rate=rate,
        output=True,
    )
    yield stream

    # Clean up stream after context expires
    self.stream.stop_stream()
    self.stream.close()
    p.terminate()


def AudioStream(filename="./music.wav", chunk_size=2048):
    """Generator that plays and yields segments of audio from a wav file."""
    audio = wave.open(filename)

    width = audio.getsampwidth()
    n_channels = audio.getnchannels()
    rate = audio.getframerate()

    with SysAudioOutput(width, n_channels, rate) as output_stream:
        while True:
            data = audio.readframes(chunk_size)
            if not data:
                break
            # Send raw audio output to speakers
            output_stream.write(data)
            # Unpack raw audio for further processing
            unpacked_audio = wave.struct.unpack(
                "%dh" % (len(data) / width),
                data
            )
            yield unpacked_audio, rate, chunk_size


def LinePlotter():
    """Plot a line when given an array"""
    # Initialize an empty plot
    plt.ion()
    plt.figure()
    line, = plt.plot(range(220))
    max_y_val = 0
    while True:
        line_data = yield
        # Rescale y axis to fit largest value seen
        max_y_val = max(max_y_val, line_data.max())
        line.axes.set_ylim(0, max_y_val)

        # Update line plot with new data
        line.set_ydata(line_data[:1200])
        line.set_xdata(range(len(line_data[:1200])))
        plt.draw()


if __name__ == '__main__':

    plotter = LinePlotter()
    # initialize plotter coroutine
    plotter.next()

    for segment, rate, chunk_size in AudioStream():
        chunk = np.array(segment)
        # calculate the power spectrum from the real FFT
        power_spectrum = abs(np.fft.rfft(segment))
        plotter.send(power_spectrum)
        print power_spectrum.argmax() * rate / chunk_size
