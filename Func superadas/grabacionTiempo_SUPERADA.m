function [ error ] = grabacionTiempo( pHandle, axHandle, tActualizacion, stop, htiempo, filtro, TipoGraf)

modo_latencia = 2;       % Control de la libreria al dispositivo de audio
fs = 44100;
   
filterADataAudio = [];
filterCDataAudio = [];
filterZDataAudio = [];

phandle_entrada = PsychPortAudio('Open', pHandle, 2, modo_latencia, fs , 1);      
PsychPortAudio('GetAudioData', phandle_entrada, 1);
PsychPortAudio('Start', phandle_entrada);

tic

while get(stop,'Value') == 1  % tengo que grabar hasta que toque el togglebutton
    audiodata = PsychPortAudio('GetAudioData', phandle_entrada);
    if ~isempty(audiodata)
        
        filterADataAudio = [filterADataAudio filterA(audiodata, fs)];
        filterCDataAudio = [filterCDataAudio filterC(audiodata, fs)];
        filterZDataAudio = [filterZDataAudio audiodata];
                
        time = [num2str(round(toc,2)) ' seg.'];
        set(htiempo,'String', time);

        if length(filterADataAudio)/fs > tActualizacion
            x=(1:length(filterADataAudio))/fs;
           
            if(get(filtro.rbA,'Value')), plot(axHandle,x,filterADataAudio); end
            if(get(filtro.rbC,'Value')), plot(axHandle,x,filterCDataAudio); end
            if(get(filtro.rbZ,'Value')), plot(axHandle,x,filterZDataAudio); end
            
            axHandle.XScale         = 'lin';
            axHandle.XAxisLocation  = 'origin';
            axHandle.YGrid          = 'on';
            axHandle.Box            = 'on';
            axHandle.XLabel.String  = 'Tiempo [s]';
            axHandle.YLabel.String  = 'Amplitud';
            axHandle.XLim = [0, length(filterADataAudio)/fs];     %escala eje x
            axHandle.YLim = [-0.01,0.01];               %escala eje y 
            drawnow;
            filterADataAudio = [];
            filterCDataAudio = [];
            filterZDataAudio = [];
        end  
    end
end

PsychPortAudio('Close');

end

