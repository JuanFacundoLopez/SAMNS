%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 General Enveloped                    %
%              with MATLAB Implementation              %
%                                                      %
% Author: Ing. Facundo Lopez                  17/05/21 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  [xAInst, gainUlt]= filterInst(x, fs, gainAux, lpFilt)
% function: xA = filterF(x, fs)
% x - original signal in the time domain
% fs - sampling frequency, Hz
% xA - filtered signal in the time domain

%===================================%
% Parametros del ataque y el relaje %
%===================================%
ATT = 35e-3; % Attack time [ms]
RLS = 1500e-3; % Release time [ms]
T = 1/fs; % Periodo de muestreo T.
consAT = 1-exp(-1*T/ATT); % Formula anterior: consAT = 1-exp(-2.2*T/ATT);
% consAT = 1-exp(-2.2*T/ATT);
consRL = 1-exp(-1*T/RLS);

% encontrar envuelta le clavo un FPB 

env = filter(lpFilt,x); %aplico el filtro de tipo FIR FPB de fc = 100Hz. hay que tener en cuenta que este tiene que ser un filtro IIR porque sino te distorsiona la señal

%En este momento tengo la envuelta y la señal original, lo que al comparar
%puedo obtener la ecuacion de relese y attack para la señal de salida

gain = zeros(1,length(x));% la ganancia inicialmente es un vector de ceros
gain(1) = gainAux; % debido a que nosotros trabajamos con vectores de corta duracion, siempre se esta reseteando a cero la ganancia

for i = 2:length(x) % este bucle representa a un filtro FIR selectivo para una 
    if abs(x(i-1))>env(i-1)
        gain(i) = gain(i-1)*(1-consAT) + abs(x(i));
    else
        gain(i) = gain(i-1)*(1-consRL);
    end
end
xAInst = gain*consAT;
gainUlt = gain(end);
end