%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Peak Filter                      %
%              with MATLAB Implementation              %
%                                                      %
% Author: Ing. Facundo Lopez                  07/05/21 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xA = filterPK(x, fs)
% function: xA = filterF(x, fs)
% x - original signal in the time domain
% fs - sampling frequency, Hz
% xA - filtered signal in the time domain

xlen = length(x);
% number of unique points
NumUniquePts = ceil((xlen+1)/2);
% FFT
X = fft(x);
% fft is symmetric, throw away the second half
X = X(1:NumUniquePts);
% frequency vector with NumUniquePts points
f = (0:NumUniquePts-1)*fs/xlen;
% Coeficientes de un filtro... defino funcion de transferencia
c1 = 0.000050;
% evaluate the A-weighting filter in the frequency domain

num = 1/c1;
den = (f+1/c1);
A = num./den;
% filtering in the frequency domain
XA = X(:).*A(:);
% reconstruct the whole spectrum
if rem(xlen, 2)                     % odd xlen excludes the Nyquist point
    XA = [XA; conj(XA(end:-1:2))];
else                                % even xlen includes the Nyquist point
    XA = [XA; conj(XA(end-1:-1:2))];
end
% IFFT
xA1 = real(ifft(XA));
    
% represent the filtered signal in the form of the original one
xA = reshape(xA1, size(x));
end