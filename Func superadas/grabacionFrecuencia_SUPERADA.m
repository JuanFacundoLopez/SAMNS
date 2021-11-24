function [ error ] = grabacionFrecuencia( pHandle, axHandle, tActualizacion, stop, htiempo, filtro,TipoGraf)

modo_latencia = 2;       % Control de la libreria al dispositivo de audio
fs = 44100;
        
phandle_entrada = PsychPortAudio('Open', pHandle, 2, modo_latencia, fs , 1);
%        
PsychPortAudio('GetAudioData', phandle_entrada, 1);

filterADataAudio = [];
filterCDataAudio = [];
filterZDataAudio = [];

PsychPortAudio('Start', phandle_entrada);

tic

while get(stop,'Value') == 1 %&& length(filtfftdata)/fs <5 % tengo que grabar hasta que toque el togglebutton

    audiodata = PsychPortAudio('GetAudioData', phandle_entrada);
    if ~isempty(audiodata)
        
        filterADataAudio = [filterADataAudio filterA(audiodata, fs)];
        filterCDataAudio = [filterCDataAudio filterC(audiodata, fs)];
        filterZDataAudio = [filterZDataAudio audiodata];
        
%         recorder = [recorder audiodata]; %audio limpio
%         filtfftdata =[filtfftdata filtaudiodata];

        time = [num2str(round(toc,2)) ' seg.']; % aporta al cronometro
        set(htiempo,'String', time);
        
        if length(filterADataAudio)/fs > 0.4 
            if(get(filtro.rbA,'Value'))
                fftRecorder = abs(fft(filterADataAudio)/length(filterADataAudio));    %creo el vector espectro
                frecLaps = fs*(1:(length(fftRecorder)/2))/length(fftRecorder);  %creo el vector de la base de frecuencia
                plot(axHandle,frecLaps,fftRecorder(1:(length(frecLaps))))
            end
            
            if(get(filtro.rbC,'Value')) 
                fftRecorder = abs(fft(filterCDataAudio)/length(filterCDataAudio));    %creo el vector espectro
                frecLaps = fs*(1:(length(fftRecorder)/2))/length(fftRecorder);  %creo el vector de la base de frecuencia
                plot(axHandle,frecLaps,fftRecorder(1:(length(frecLaps))))
            end
            
            if(get(filtro.rbZ,'Value')) 
                fftRecorder = abs(fft(filterZDataAudio)/length(filterZDataAudio));    %creo el vector espectro
                frecLaps = fs*(1:(length(fftRecorder)/2))/length(fftRecorder);  %creo el vector de la base de frecuencia
                plot(axHandle,frecLaps,fftRecorder(1:(length(frecLaps))))
            end
                        
            axHandle.XLabel.String = 'Tiempo [s]';
            axHandle.YLabel.String = 'Amplitud';
            axHandle.XScale = 'log';
            axHandle.XLim = [1,22050];     %escala eje x
            axHandle.YLim = [0,0.001];    %escala eje y 
            drawnow;
            
            filterADataAudio = [];   
            filterCDataAudio = [];
            filterZDataAudio = [];
        end  
    end
end

PsychPortAudio('Close');

end

