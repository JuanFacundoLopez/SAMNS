function [ error ] = grabacionSPL( pHandle, axHandle, tActualizacion, stop, htiempo, filtro, pnlTiempInt,TipoGraf)

modo_latencia = 2;       % Control de la libreria al dispositivo de audio
fs = 44100;

phandle_entrada = PsychPortAudio('Open', pHandle, 2, modo_latencia, fs , 1);
%        
PsychPortAudio('GetAudioData', phandle_entrada, 1);

recorderInst = [];

SPLInst = [];
SPLFast = [];
SPLSlow = [];
gain = 0;
act = 0;
PsychPortAudio('Start', phandle_entrada);

tic

while get(stop,'Value') == 1 && (length(recorderInst)/fs) < 5 % tengo que grabar hasta que toque el togglebutton

    audiodata = PsychPortAudio('GetAudioData', phandle_entrada);
    
    if ~isempty(audiodata)
        switch filtro
            case 'A'
                filtaudiodata = filterA(audiodata,fs);
            case 'C'
                filtaudiodata = filterC(audiodata,fs);                    
            case 'Z'
                filtaudiodata = audiodata;
        end
        
        recorderPK   = filterPK(filtaudiodata,fs);%detector de pico
        [recorderInst, gain] = filterInst(recorderPK,fs, gain); % aca tengo que ir actualizando la ganancia con la ultima que me va arrojando(es para escribir un papper con esto)
        recorderFast = filterFast(recorderPK,fs);
        recorderSlow = filterSlow(recorderPK,fs);
        
        SPLInstPuro =   10*log10(recorderInst.^2/0.0000004); % Guarda con este 0.02 porque no es el valor de referencia real
        SPLFastPuro =   10*log10(recorderFast.^2/0.0000004); % Guarda con este 0.02 porque no es el valor de referencia real
        SPLSlowPuro =   10*log10(recorderSlow.^2/0.0000004); % Guarda con este 0.02 porque no es el valor de referencia real

        time = [num2str(round(toc,2)) ' seg.'];
        set(htiempo,'String', time);

        SPLInst = [SPLInst sum(SPLInstPuro)/length(SPLInstPuro)];
        SPLFast = [SPLFast sum(SPLFastPuro)/length(SPLFastPuro)];
        SPLSlow = [SPLSlow sum(SPLSlowPuro)/length(SPLSlowPuro)];
        
        if act > 5
           set(pnlTiempInt.txInst,'String',[num2str(round(SPLInst(end),2)),' [dB]']); 
           set(pnlTiempInt.txFast,'String',[num2str(round(SPLFast(end),2)),' [dB]']); 
           set(pnlTiempInt.txSlow,'String',[num2str(round(SPLSlow(end),2)),' [dB]']); 
           act = 0;
        else
           act = act +1; 
        end
        
        x=1:length(SPLFast);
        
        plot(axHandle, x, SPLInst, x, SPLFast, x, SPLSlow) % dibuja todas las señales
        axHandle.XLabel.String = 'Tiempo [s]';
        axHandle.YLabel.String = 'Amplitud';
        axHandle.XLim = [0, inf];     %escala eje x
        axHandle.YLim = [-160, 20];   %escala eje y 
        drawnow;

    end
end

PsychPortAudio('Close');

end

