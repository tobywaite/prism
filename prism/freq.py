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


def AudioStream(filename="./music.wav", chunk_size=1048):
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
    line, = plt.plot([])
    max_y_val = 0
    max_x_val = 0

    initial_line_data = yield

    # Rescale x to fit the length of the line
    line.set_xdata(range(len(initial_line_data)))
    line.axes.set_xlim(0, len(initial_line_data)/3)

    while True:
        line_data = yield
        # Rescale y axis to fit largest value seen
        max_y_val = max(max_y_val, line_data.max())
        line.axes.set_ylim(0, max_y_val)

        # Update line plot with new data
        line.set_ydata(line_data)
        plt.draw()


def BeatDetector():
    """for a given number of buckets, calculate the instantanious energy of the
    spectrum in that bucket. A beat is detected when the instantanious energy
    exceedes the local average for that bucket by more than the variance of the
    local average. Something to consider: Can I automatically distribute the
    buckets across the spectrum to each account for an equal ammount of energy?
    """
    spectrum = yield

    num_buckets = 32
    seg_size = len(spectrum) / 32

    bucketed_spectrum = [spectrum[idx:idx + seg_size] for idx in range(0, len(spectrum), seg_size)]

    for bucket in bucketed_spectrum:
        bucket_energy = sum(bucket) * num_buckets / seg_size

if __name__ == '__main__':

    plotter = LinePlotter()
    # initialize plotter coroutine
    plotter.next()

    for segment, rate, chunk_size in AudioStream():
        chunk = np.array(segment)
        # calculate the power spectrum from the real FFT
        power_spectrum = abs(np.fft.rfft(segment))
        plotter.send(power_spectrum)
