function FT = fourierTransform(x)

FT = abs(fftshift(fft2(ifftshift(x))));
