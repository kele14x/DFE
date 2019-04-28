# -*- coding: utf-8 -*-

import numpy as _np
import matplotlib.pyplot as _plt


def db2l(db):
    """Convert an dB value to linear"""
    return 10**(db/10)


def l2db(l):
    """Convert an linear value to dB"""
    return 10*_np.log10(l)


def rms(x):
    """Get the RMS value of signal"""
    return _np.sqrt(_np.average(_np.abs(x)**2))


def pwr(x):
    """Get the digital power of an signal"""
    return _np.average(_np.abs(x)**2)


def pwr_db(x):
    """Get the digital power of an signal in dB"""
    return db2l(pwr(x))


def psd(x, Fs=None, plot=True):
    """PSD estimation using FFT method"""
    # Do FFT on signal x, average by NFFT, then do square
    Px = _np.fft.fftshift(_np.fft.fft(x))
    n = len(Px)
    Px = (_np.abs(Px) / n)**2

    # The FFT sample frequencies vector
    if Fs:
        f = _np.fft.fftshift(_np.fft.fftfreq(n, 1/Fs))
    else:
        f = _np.fft.fftshift(_np.fft.fftfreq(n, 1/2))

    # Plot the PSD with log Y axis
    if plot:
        _plt.figure()
        _plt.plot(f, l2db(Px))

        _plt.title('PSD (NFFT={0})'.format(n))
        if Fs:
            _plt.xlim(-0.5*Fs, 0.5*Fs)
            _plt.xlabel('Frequency (Hz)')
        else:
            _plt.xlim(-1, 1)
            _plt.xlabel('Frequency (rad/Pi)')
        _plt.ylabel('Power (dB)')

        _plt.grid(True)
        _plt.show()

    # Return the PSD and frequency, incase other usage
    return Px, f


def ccdf(x):
    """Measure complementary cumulative distribution function"""
    # Average power of signal
    avg = pwr(x)
    CCDFx = l2db(_np.sort(_np.abs(x)**2)/avg)
    CCDFy = 1 - _np.arange(0, len(x))/len(x)

    # Plot the CCDF
    _plt.figure()
    _plt.semilogy(CCDFx, CCDFy, '.')

    _plt.xlim(-2, 14)
    _plt.xticks(_np.arange(-2, 16, 2))
    _plt.xlabel('Instantaneous/Average Power (dB)')

    _plt.ylabel('Possibility')

    _plt.grid(True)
    _plt.show()


def dec2bin(x, n=None):
    """Convert decimal number to character vector representing binary number"""
    ret = bin(x)[2:]
    if n:
        ret = ret.zfill(n)
    return ret


def bin2dec(x):
    """Convert text representation of binary number to decimal number"""
    ret = int(x, 2)
    return ret


def dec2hex(x, n=None):
    """Convert decimal number to character vector representing hexadecimal 
    number"""
    ret = hex(x)[2:].upper()
    if n:
        ret = ret.zfill(n)
    return ret


def hex2dec(x):
    """Convert text representation of hexadecimal number to decimal number"""
    ret = int(x, 16)
    return ret
