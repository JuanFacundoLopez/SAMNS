%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 General Enveloped                    %
%              with MATLAB Implementation              %
%                                                      %
% Author: Ing. Facundo Lopez                  17/05/21 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  [xAInst, gainUlt]= filFast(x, fs, gainAux,lpFilt)
% function: xA = filterF(x, fs)
% x - original signal in the time domain
% fs - sampling frequency, Hz
% xA - filtered signal in the time domain

%===================================%
% Parametros del ataque y el relaje %
%===================================%
ATT = 125e-3; % Attack time [ms]
RLS = 125e-3; % Release time [ms]
T = 1/fs; % Periodo de muestreo T.
consAT = 1-exp(-1*T/ATT);
consRL = 1-exp(-1*T/RLS);
% encontrar envuelta le clavo un FPB 
                
env = filter(lpFilt,x); %aplico el filtro de tipo FIR FPB de fc = 100Hz. hay que tener en cuenta que este tiene que ser un filtro IIR porque sino te distorsiona la se�al

%En este momento tengo la envuelta y la se�al original, lo que al comparar
%puedo obtener la ecuacion de relese y attack para la se�al de salida

gain = zeros(1,length(x));% la ganancia inicialmente es un vector de ceros
gain(1) = gainAux; % debido a que nosotros trabajamos con vectores de corta duracion, siempre se esta reseteando a cero la ganancia

for i = 2:length(x) 
    if abs(x(i-1))== env(i-1)
        gain(i) = gain(i-1)*(1-consRL);
    else
        if abs(x(i-1))>env(i-1)
            gain(i) =  gain(i-1)*(1-consAT) + abs(x(i));
        else
            gain(i) = gain(i-1)*(1-consRL);
        end
    end
end
xAInst = gain*consAT;
gainUlt = gain(end);
end