function [LPA, LPC, LPZ, LeqA, LeqC, LeqZ, timeLapse, audioSignal]  = grabacion(varagin)

EntradaIndex = varagin{1};
axHandle     = varagin{2};
stop         = varagin{3};
htiempo      = varagin{4};
pnlTiempInt  = varagin{5};
filtro       = varagin{6};
TipoGraf     = varagin{7};
ref          = varagin{8};
pnlNivelesEst= varagin{9};
mlpFilt      = varagin{10};
tTimer       = varagin{11};
pmNivel      = varagin{12};
sliderXY     = varagin{13};
btOver       = varagin{14};
fs           = varagin{15};

modo_latencia = 3;       % Control de la libreria al dispositivo de audio
refresh = 0;
i = 1;    % control del valor del pico maximo
aux=0;
audioSignal = [];
 
%% Variables para Tiempo y frecuencia
filterADataAudio = [];
filterCDataAudio = [];
filterZDataAudio = [];
% 
%% Variables para Niveles de presion sonora
SPL = [];
LPA = [];  LPC = [];  LPZ = [];
LeqA = []; LeqC = []; LeqZ = [];
timeLapse = [];
gainAP = 0; gainAI = 0; gainAF = 0;
gainAS = 0; gainCP = 0; gainCI = 0;
gainCF = 0; gainCS = 0; gainZP = 0;
gainZI = 0; gainZF = 0; gainZS = 0;
act = 0;

%% Filtro pasa bajo

lpFilt = mlpFilt;


%% Empiezo a parametrizar la grabacion
phandle_entrada = PsychPortAudio('Open', EntradaIndex, 2, modo_latencia, fs , 1);      
PsychPortAudio('GetAudioData', phandle_entrada, 1);
PsychPortAudio('Start', phandle_entrada);

tic

while get(stop,'Value')  % tengo que grabar hasta que toque el togglebutton
        %% Arranco la adquisicion de datos
        
    audioDataZ = PsychPortAudio('GetAudioData', phandle_entrada); 
    audioSignal = [audioSignal audioDataZ];
    if tTimer > 0
        if toc > tTimer,set(stop,'Value',0); end
    end
    
    if ~isempty(audioDataZ) % Validacion de datos
        %% Actualizacion de tiempo en la GUI 
        if toc > 999
            timeNum = round(toc,2);
        else
            timeNum = round(toc,3);
        end
        
        timeShowStr = num2str(timeNum);
        set(htiempo,'String', timeShowStr);
        
        
        LPA.tiempo(i) = timeNum; 
        LPC.tiempo(i) = timeNum;
        LPZ.tiempo(i) = timeNum;
        
        audioDataA = filterA(audioDataZ, fs);
        audioDataC = filterC(audioDataZ, fs);
        
        filterADataAudio = [filterADataAudio audioDataA];
        filterCDataAudio = [filterCDataAudio audioDataC];
        filterZDataAudio = [filterZDataAudio audioDataZ];
                        
        longitudVector = length(filterADataAudio);
          
        %% Encuentro los LP para las señales ponderadas A
        
        [recorderPicoA, gainAP] = filPK(audioDataA,fs,gainAP, lpFilt);
        [recorderInstA, gainAI] = filterInst(audioDataA, fs, gainAI, lpFilt); %Revisar
        [recorderFastA, gainAF] = filFast(audioDataA, fs, gainAF, lpFilt);
        [recorderSlowA, gainAS] = filSlow(audioDataA, fs, gainAS, lpFilt);
        %--
        LPA.PK(i)         = 20*log10(rms(recorderPicoA)); %Revisar
        LPA.PK(i)         = max(LPA.PK);
        %--
        LPA.Inst.Datos(i) = 20*log10(rms(recorderInstA)); %Revisar
        LPA.Inst.max(i)   = max(LPA.Inst.Datos);%
        LPA.Inst.min(i)   = min(LPA.Inst.Datos);%
        %--
        LPA.Fast.Datos(i) = 20*log10(rms(recorderFastA)); %Revisar
        LPA.Fast.max(i)   = max(LPA.Fast.Datos);
        LPA.Fast.min(i)   = min(LPA.Fast.Datos);
        %--
        LPA.Slow.Datos(i) = 20*log10(rms(recorderSlowA)); %Revisar
        LPA.Slow.max(i)   = max(LPA.Slow.Datos);
        LPA.Slow.min(i)   = min(LPA.Slow.Datos);
            
        if (20*log10(rms(recorderPicoA)) + ref.dBFS ) > - 3, set(btOver,'BackgroundColor','r');end
        
        %% Encuentro los LP para las señales ponderadas C
        
        [recorderPicoC, gainCP] = filPK(audioDataC,fs,gainCP, lpFilt);
        [recorderInstC, gainCI] = filterInst(audioDataC, fs, gainCI, lpFilt); %Revisar
        [recorderFastC, gainCF] = filFast(audioDataC, fs, gainCF, lpFilt);
        [recorderSlowC, gainCS] = filSlow(audioDataC, fs, gainCS, lpFilt);

        %--
        LPC.PK(i)         = 20*log10(rms(recorderPicoC));
        LPC.PK(i)         = max(LPC.PK);
        %--
        LPC.Inst.Datos(i) = 20*log10(rms(recorderInstC)); %Revisar
        LPC.Inst.max(i)   = max(LPC.Inst.Datos);
        LPC.Inst.min(i)   = min(LPC.Inst.Datos);
        %--
        LPC.Fast.Datos(i) = 20*log10(rms(recorderFastC)); %Revisar
        LPC.Fast.max(i)   = max(LPC.Fast.Datos);
        LPC.Fast.min(i)   = min(LPC.Fast.Datos);
        %--
        LPC.Slow.Datos(i) = 20*log10(rms(recorderSlowC)); %Revisar
        LPC.Slow.max(i)   = max(LPC.Slow.Datos);
        LPC.Slow.min(i)   = min(LPC.Slow.Datos);
            
        %% Encuentro los LP para las señales ponderadas Z
        
        [recorderPicoZ, gainZP] = filPK(audioDataZ,fs,gainZP, lpFilt);
        [recorderInstZ, gainZI] = filterInst(audioDataZ, fs, gainZI, lpFilt); %Revisar
        [recorderFastZ, gainZF] = filFast(audioDataZ, fs, gainZF, lpFilt);
        [recorderSlowZ, gainZS] = filSlow(audioDataZ, fs, gainZS, lpFilt);
        %--
        LPZ.PK(i)         = 20*log10(rms(recorderPicoZ));%Revisar
        LPZ.PK(i)         = max(LPZ.PK);
        %--
        LPZ.Inst.Datos(i) = 20*log10(rms(recorderInstZ));%Revisar
        LPZ.Inst.max(i)   = max(LPZ.Inst.Datos);%
        LPZ.Inst.min(i)   = min(LPZ.Inst.Datos);%
        %--
        LPZ.Fast.Datos(i) = 20*log10(rms(recorderFastZ));%Revisar
        LPZ.Fast.max(i)   = max(LPZ.Fast.Datos);
        LPZ.Fast.min(i)   = min(LPZ.Fast.Datos);
        %--
        LPZ.Slow.Datos(i) = 20*log10(rms(recorderSlowZ));%Revisar
        LPZ.Slow.max(i)   = max(LPZ.Slow.Datos);
        LPZ.Slow.min(i)   = min(LPZ.Slow.Datos);
        
        %% Calculo de Leq para distintos niveles ponderados    
            
        LeqA.Datos(i) = rms(LPA.Fast.Datos);
        LeqC.Datos(i) = rms(LPC.Fast.Datos);
        LeqZ.Datos(i) = rms(LPZ.Fast.Datos);
        
        %% Calculo de los percentiles
        
        LeqA.L01(i) = prctile(LeqA.Datos,1);
        LeqA.L10(i) = prctile(LeqA.Datos,10);
        LeqA.L50(i) = prctile(LeqA.Datos,50);
        LeqA.L90(i) = prctile(LeqA.Datos,90);
        LeqA.L99(i) = prctile(LeqA.Datos,99);
        %--
        LeqC.L01(i) = prctile(LeqC.Datos,1);
        LeqC.L10(i) = prctile(LeqC.Datos,10);
        LeqC.L50(i) = prctile(LeqC.Datos,50);
        LeqC.L90(i) = prctile(LeqC.Datos,90);
        LeqC.L99(i) = prctile(LeqC.Datos,99);
        %--
        LeqZ.L01(i) = prctile(LeqZ.Datos,1);
        LeqZ.L10(i) = prctile(LeqZ.Datos,10);
        LeqZ.L50(i) = prctile(LeqZ.Datos,50);
        LeqZ.L90(i) = prctile(LeqZ.Datos,90);
        LeqZ.L99(i) = prctile(LeqZ.Datos,99);
            

%% Data que se expone en el tiempo
        if get(TipoGraf.tbTiemp, 'Value') && refresh > 4
            timeLapse = toc;
            timeLapseTim = (1:length(audioDataA))/fs;
            y = max(abs(audioDataZ));
            if(get(filtro.rbA,'Value')), plot(axHandle,timeLapseTim,audioDataA); end
            if(get(filtro.rbC,'Value')), plot(axHandle,timeLapseTim,audioDataC); end
            if(get(filtro.rbZ,'Value')), plot(axHandle,timeLapseTim,audioDataZ); end
            
            axHandle.XScale         = 'lin';
            axHandle.XAxisLocation  = 'origin';
            axHandle.YGrid          = 'on';
            axHandle.Box            = 'on';
            axHandle.XAxisLocation  = 'origin';
            axHandle.XLabel.String  = 'Tiempo [s]';
            axHandle.YLabel.String  = 'Amplitud Normalizada';
            axHandle.XLim           = [0, longitudVector/fs];     %escala eje x
            axHandle.YLim           = [-y, y];     %escala eje x
            refresh = 0;
        else
            refresh = refresh + 1;
        end  
        
%% Data que se expone en frecuencia
        if get(TipoGraf.tbFrecu, 'Value') && refresh > 5
            timeLapse = toc;
            ACZ_len = length(filterADataAudio);
            if(get(filtro.rbA,'Value')), fftRecorder = abs(fft(filterADataAudio)/ACZ_len);end %creo el vector espectro %Revisar
            if(get(filtro.rbC,'Value')), fftRecorder = abs(fft(filterCDataAudio)/ACZ_len);end %creo el vector espectro %Revisar
            if(get(filtro.rbZ,'Value')), fftRecorder = abs(fft(filterZDataAudio)/ACZ_len);end %creo el vector espectro %Revisar
                       
            if get(pmNivel.Espectro,'Value') == 1
                fftRecorder = 20*log10(fftRecorder/0.000002)-ref.dB;
            elseif get(pmNivel.Espectro,'Value') == 2 
                fftRecorder = 20*log10(fftRecorder);
            elseif get(pmNivel.Espectro,'Value') == 3

            end
                        
            frecLaps = fs*(1:(length(fftRecorder)/2))/length(fftRecorder);          %creo el vector de la base de frecuencia %Revisar
            plot(axHandle,frecLaps,fftRecorder(1:(length(frecLaps))))    

            if get(pmNivel.Espectro,'Value') == 1
                axHandle.YLabel.String = 'Nivel';
                axHandle.YLim = [-20,140];    %escala eje y 
            elseif get(pmNivel.Espectro,'Value') == 2 
                axHandle.YLabel.String = 'Nivel fondo de escala';
                axHandle.YLim = [-120,20];    %escala eje y 
            elseif get(pmNivel.Espectro,'Value') == 3
                if aux < max(fftRecorder)
                     aux = max(fftRecorder);                              
                end
                axHandle.YLabel.String = 'Amplitud relativa instantanea';
                axHandle.YLim = [0,aux];    %escala eje y 
            end
            
            axHandle.XScale = 'log';
            axHandle.XLim = [1,22000];     %escala eje x            
            axHandle.XGrid = 'on';
            axHandle.XAxisLocation = 'origin';
            axHandle.YGrid = 'on';
            axHandle.Box   = 'on';
            axHandle.XLabel.String = 'Frecuencia [Hz]';     
            refresh = 0;
        else
            refresh = refresh + 1;
        end  
%% Data que se expone en LP
        if get(TipoGraf.tbLP, 'Value') 
            if get(pmNivel.Nivel,'Value') == 1
                offset.PK = ref.dBFS;
                offset.In = ref.dBFS;
                offset.Fs = ref.dBFS;
                offset.Sl = ref.dBFS;
            elseif get(pmNivel.Nivel,'Value') == 2 
                offset.PK = - 20*log10(0.00002)+ ref.dB;
                offset.In = - 20*log10(0.00002)+ ref.dB;
                offset.Fs = - 20*log10(0.00002)+ ref.dB;
                offset.Sl = - 20*log10(0.00002)+ ref.dB;
            end
            
            if act > 5 % actualizacion en tiempos de ejecucion
                % Panel de la ventana 2 de tiempo de integracion
               set(pnlTiempInt.txPicoA,'String',num2str(round(LPA.PK(end),2)+offset.PK)); 
               set(pnlTiempInt.txPicoC,'String',num2str(round(LPC.PK(end),2)+offset.PK)); 
               set(pnlTiempInt.txPicoZ,'String',num2str(round(LPZ.PK(end),2)+offset.PK)); 
               set(pnlTiempInt.txInstA,'String',num2str(round(LPA.Inst.Datos(end),2)+offset.In));
               set(pnlTiempInt.txInstC,'String',num2str(round(LPC.Inst.Datos(end),2)+offset.In)); 
               set(pnlTiempInt.txInstZ,'String',num2str(round(LPZ.Inst.Datos(end),2)+offset.In)); 
               set(pnlTiempInt.txFastA,'String',num2str(round(LPA.Fast.Datos(end),2)+offset.Fs)); 
               set(pnlTiempInt.txFastC,'String',num2str(round(LPC.Fast.Datos(end),2)+offset.Fs));
               set(pnlTiempInt.txFastZ,'String',num2str(round(LPZ.Fast.Datos(end),2)+offset.Fs)); 
               set(pnlTiempInt.txSlowA,'String',num2str(round(LPA.Slow.Datos(end),2)+offset.Sl)); 
               set(pnlTiempInt.txSlowC,'String',num2str(round(LPC.Slow.Datos(end),2)+offset.Sl)); 
               set(pnlTiempInt.txSlowZ,'String',num2str(round(LPZ.Slow.Datos(end),2)+offset.Sl));
               
               % Panel de la ventana 2 de timepo estadistico PARA MAXIMOS Y
               % MINIMOS
               set(pnlNivelesEst.pnlA.txLIAmax,'String',num2str(round(LPA.Inst.max(end),2)+offset.In)); 
               set(pnlNivelesEst.pnlC.txLICmax,'String',num2str(round(LPC.Inst.max(end),2)+offset.In)); 
               set(pnlNivelesEst.pnlZ.txLIZmax,'String',num2str(round(LPZ.Inst.max(end),2)+offset.In)); 
               
               set(pnlNivelesEst.pnlA.txLFAmax,'String',num2str(round(LPA.Fast.max(end),2)+offset.Fs)); 
               set(pnlNivelesEst.pnlC.txLFCmax,'String',num2str(round(LPC.Fast.max(end),2)+offset.Fs)); 
               set(pnlNivelesEst.pnlZ.txLFZmax,'String',num2str(round(LPZ.Fast.max(end),2)+offset.Fs)); 
               
               set(pnlNivelesEst.pnlA.txLSAmax,'String',num2str(round(LPA.Slow.max(end),2)+offset.Sl)); 
               set(pnlNivelesEst.pnlC.txLSCmax,'String',num2str(round(LPC.Slow.max(end),2)+offset.Sl)); 
               set(pnlNivelesEst.pnlZ.txLSZmax,'String',num2str(round(LPZ.Slow.max(end),2)+offset.Sl)); 
               
               set(pnlNivelesEst.pnlA.txLIAmin,'String',num2str(round(LPA.Inst.min(end),2)+offset.In)); 
               set(pnlNivelesEst.pnlC.txLICmin,'String',num2str(round(LPC.Inst.min(end),2)+offset.In)); 
               set(pnlNivelesEst.pnlZ.txLIZmin,'String',num2str(round(LPZ.Inst.min(end),2)+offset.In)); 
               
               set(pnlNivelesEst.pnlA.txLFAmin,'String',num2str(round(LPA.Fast.min(end),2)+offset.Fs)); 
               set(pnlNivelesEst.pnlC.txLFCmin,'String',num2str(round(LPC.Fast.min(end),2)+offset.Fs)); 
               set(pnlNivelesEst.pnlZ.txLFZmin,'String',num2str(round(LPZ.Fast.min(end),2)+offset.Fs)); 
               
               set(pnlNivelesEst.pnlA.txLSAmin,'String',num2str(round(LPA.Slow.min(end),2)+offset.Sl)); 
               set(pnlNivelesEst.pnlC.txLSCmin,'String',num2str(round(LPC.Slow.min(end),2)+offset.Sl)); 
               set(pnlNivelesEst.pnlZ.txLSZmin,'String',num2str(round(LPZ.Slow.min(end),2)+offset.Sl));
               
               % Panel de la ventana 2 de timepo estadistico
               set(pnlNivelesEst.pnlA.txLeqA,'String',num2str(round(LeqA.Datos(end)+offset.Fs,2))); 
               set(pnlNivelesEst.pnlC.txLeqC,'String',num2str(round(LeqC.Datos(end)+offset.Fs,2))); 
               set(pnlNivelesEst.pnlZ.txLeqZ,'String',num2str(round(LeqZ.Datos(end)+offset.Fs,2))); 
               
               set(pnlNivelesEst.pnlA.txL01A,'String',num2str(round(LeqA.L01(end)+offset.Fs,2)));
               set(pnlNivelesEst.pnlA.txL10A,'String',num2str(round(LeqA.L10(end)+offset.Fs,2))); 
               set(pnlNivelesEst.pnlA.txL50A,'String',num2str(round(LeqA.L50(end)+offset.Fs,2))); 
               set(pnlNivelesEst.pnlA.txL90A,'String',num2str(round(LeqA.L90(end)+offset.Fs,2))); 
               set(pnlNivelesEst.pnlA.txL99A,'String',num2str(round(LeqA.L99(end)+offset.Fs,2)));
               
               set(pnlNivelesEst.pnlC.txL01C,'String',num2str(round(LeqC.L01(end)+offset.Fs,2)));
               set(pnlNivelesEst.pnlC.txL10C,'String',num2str(round(LeqC.L10(end)+offset.Fs,2))); 
               set(pnlNivelesEst.pnlC.txL50C,'String',num2str(round(LeqC.L50(end)+offset.Fs,2))); 
               set(pnlNivelesEst.pnlC.txL90C,'String',num2str(round(LeqC.L90(end)+offset.Fs,2))); 
               set(pnlNivelesEst.pnlC.txL99C,'String',num2str(round(LeqC.L99(end)+offset.Fs,2)));               
               
               set(pnlNivelesEst.pnlZ.txL01Z,'String',num2str(round(LeqZ.L01(end)+offset.Fs,2)));
               set(pnlNivelesEst.pnlZ.txL10Z,'String',num2str(round(LeqZ.L10(end)+offset.Fs,2))); 
               set(pnlNivelesEst.pnlZ.txL50Z,'String',num2str(round(LeqZ.L50(end)+offset.Fs,2))); 
               set(pnlNivelesEst.pnlZ.txL90Z,'String',num2str(round(LeqZ.L90(end)+offset.Fs,2))); 
               set(pnlNivelesEst.pnlZ.txL99Z,'String',num2str(round(LeqZ.L99(end)+offset.Fs,2)));               
               
               act = 0;
            else
               act = act +1; 
            end

            if get(pnlTiempInt.cbPicoA, 'Value'), SPL = [SPL; (LPA.PK+offset.PK)];end
            if get(pnlTiempInt.cbPicoC, 'Value'), SPL = [SPL; (LPC.PK+offset.PK)];end
            if get(pnlTiempInt.cbPicoZ, 'Value'), SPL = [SPL; (LPZ.PK+offset.PK)];end
            
            if get(pnlTiempInt.cbInstA, 'Value'), SPL = [SPL; (LPA.Inst.Datos+offset.In)];end %
            if get(pnlTiempInt.cbInstC, 'Value'), SPL = [SPL; (LPC.Inst.Datos+offset.In)];end % Expongo los niveles INSTANTANEOS
            if get(pnlTiempInt.cbInstZ, 'Value'), SPL = [SPL; (LPZ.Inst.Datos+offset.In)];end %
            
            if get(pnlTiempInt.cbLAImax,'Value'), SPL = [SPL; (LPA.Inst.max+offset.In)];end %
            if get(pnlTiempInt.cbLAImin,'Value'), SPL = [SPL; (LPA.Inst.min+offset.In)];end %
            if get(pnlTiempInt.cbLCImax,'Value'), SPL = [SPL; (LPC.Inst.max+offset.In)];end % Expongo niveles maximos y minimos
            if get(pnlTiempInt.cbLCImin,'Value'), SPL = [SPL; (LPC.Inst.min+offset.In)];end % de los niveles instantaneos
            if get(pnlTiempInt.cbLZImax,'Value'), SPL = [SPL; (LPZ.Inst.max+offset.In)];end %
            if get(pnlTiempInt.cbLZImin,'Value'), SPL = [SPL; (LPZ.Inst.min+offset.In)];end %
           
            if get(pnlTiempInt.cbFastA, 'Value'), SPL = [SPL; (LPA.Fast.Datos+offset.Fs)];end %
            if get(pnlTiempInt.cbFastC, 'Value'), SPL = [SPL; (LPC.Fast.Datos+offset.Fs)];end % Expongo los niveles Fast
            if get(pnlTiempInt.cbFastZ, 'Value'), SPL = [SPL; (LPZ.Fast.Datos+offset.Fs)];end %----
            
            if get(pnlTiempInt.cbLAFmax,'Value'), SPL = [SPL; (LPA.Fast.max+offset.Fs)];end %
            if get(pnlTiempInt.cbLAFmin,'Value'), SPL = [SPL; (LPA.Fast.min+offset.Fs)];end %
            if get(pnlTiempInt.cbLCFmax,'Value'), SPL = [SPL; (LPC.Fast.max+offset.Fs)];end % Expongo niveles maximos y minimos
            if get(pnlTiempInt.cbLCFmin,'Value'), SPL = [SPL; (LPC.Fast.min+offset.Fs)];end % de los niveles Fast
            if get(pnlTiempInt.cbLZFmax,'Value'), SPL = [SPL; (LPZ.Fast.max+offset.Fs)];end %
            if get(pnlTiempInt.cbLZFmin,'Value'), SPL = [SPL; (LPZ.Fast.min+offset.Fs)];end %
            
            if get(pnlTiempInt.cbSlowA, 'Value'), SPL = [SPL; (LPA.Slow.Datos+offset.Sl)];end % 
            if get(pnlTiempInt.cbSlowC, 'Value'), SPL = [SPL; (LPC.Slow.Datos+offset.Sl)];end % Expongo los niveles Slow
            if get(pnlTiempInt.cbSlowZ, 'Value'), SPL = [SPL; (LPZ.Slow.Datos+offset.Sl)];end %
            
            if get(pnlTiempInt.cbLASmax,'Value'), SPL = [SPL; (LPA.Slow.max+offset.Sl)];end %
            if get(pnlTiempInt.cbLASmin,'Value'), SPL = [SPL; (LPA.Slow.min+offset.Sl)];end %
            if get(pnlTiempInt.cbLCSmax,'Value'), SPL = [SPL; (LPC.Slow.max+offset.Sl)];end % Expongo niveles maximos y minimos
            if get(pnlTiempInt.cbLCSmin,'Value'), SPL = [SPL; (LPC.Slow.min+offset.Sl)];end % de los niveles Slow
            if get(pnlTiempInt.cbLZSmax,'Value'), SPL = [SPL; (LPZ.Slow.max+offset.Sl)];end %
            if get(pnlTiempInt.cbLZSmin,'Value'), SPL = [SPL; (LPZ.Slow.min+offset.Sl)];end %
            
            if get(pnlNivelesEst.cbLAeq,'Value'), SPL = [SPL; LeqA.Datos+offset.Fs];end %
            if get(pnlNivelesEst.cbLCeq,'Value'), SPL = [SPL; LeqC.Datos+offset.Fs];end % Expongo los niveles estadisticos Leq
            if get(pnlNivelesEst.cbLZeq,'Value'), SPL = [SPL; LeqZ.Datos+offset.Fs];end %
            %%--
            if get(pnlNivelesEst.cbLA01,'Value'), SPL = [SPL; LeqA.L01+offset.Fs];end %
            if get(pnlNivelesEst.cbLA10,'Value'), SPL = [SPL; LeqA.L10+offset.Fs];end %
            if get(pnlNivelesEst.cbLA50,'Value'), SPL = [SPL; LeqA.L50+offset.Fs];end %
            if get(pnlNivelesEst.cbLA90,'Value'), SPL = [SPL; LeqA.L90+offset.Fs];end %
            if get(pnlNivelesEst.cbLA99,'Value'), SPL = [SPL; LeqA.L99+offset.Fs];end %
            
            if get(pnlNivelesEst.cbLC01,'Value'), SPL = [SPL; LeqC.L01+offset.Fs];end % 
            if get(pnlNivelesEst.cbLC10,'Value'), SPL = [SPL; LeqC.L10+offset.Fs];end %           
            if get(pnlNivelesEst.cbLC50,'Value'), SPL = [SPL; LeqC.L50+offset.Fs];end %
            if get(pnlNivelesEst.cbLC90,'Value'), SPL = [SPL; LeqC.L90+offset.Fs];end % 
            if get(pnlNivelesEst.cbLC99,'Value'), SPL = [SPL; LeqC.L99+offset.Fs];end %            
            
            if get(pnlNivelesEst.cbLZ01,'Value'), SPL = [SPL; LeqZ.L01+offset.Fs];end %             
            if get(pnlNivelesEst.cbLZ10,'Value'), SPL = [SPL; LeqZ.L10+offset.Fs];end % 
            if get(pnlNivelesEst.cbLZ50,'Value'), SPL = [SPL; LeqZ.L50+offset.Fs];end % 
            if get(pnlNivelesEst.cbLZ90,'Value'), SPL = [SPL; LeqZ.L90+offset.Fs];end % 
            if get(pnlNivelesEst.cbLZ99,'Value'), SPL = [SPL; LeqZ.L99+offset.Fs];end % 
            
            timeLapse = toc;
            lenSPL = length(SPL);
            timeLapseSPL = (1:lenSPL) * timeLapse/lenSPL;

            if ~isempty(SPL)
                plot(axHandle, timeLapseSPL, SPL') % dibuja todas las señales.
                axHandle.XAxisLocation = 'top';
                axHandle.XLabel.String = '';
                axHandle.XGrid = 'on';
                axHandle.YGrid = 'on';
                if toc > 40
                    axHandle.XLim = [(toc - 40) , inf];
                    set(sliderXY.x,'Value',100);
                else
                    limSl = 1000/(1+toc*100);
                    set(sliderXY.x,'SliderStep',[0.1 limSl])
                    set(sliderXY.x,'Value',100);
                    axHandle.XLim = [0, inf];     %escala eje x
                end
                
                if get(pmNivel.Nivel,'Value') == 1
                    axHandle.YLim = [-inf, 0];
                    axHandle.YLabel.String = 'Amplitud';  
                elseif get(pmNivel.Nivel,'Value') == 2 
                    axHandle.YLabel.String = 'Nivel';  
                end
                
            else
                cla(axHandle)
            end 
            SPL=[];
        end
        drawnow;
        i = i+1;
        
        filterADataAudio = [];   
        filterCDataAudio = [];
        filterZDataAudio = [];
        
        [~, sys] = memory;
        barAlto = (sys.PhysicalMemory.Total - sys.PhysicalMemory.Available)/sys.PhysicalMemory.Total;
        set(TipoGraf.txRam, 'Position',[0.05 0.05 0.9 barAlto],'String',[num2str(round(barAlto*100,1)), '%'],'ForegroundColor', [1 1 1]);
        
        set(sliderXY.y,'SliderStep',[0.0000001 max(abs(audioSignal))])
        set(sliderXY.y,'Value',50)    
    end
end

PsychPortAudio('Close', phandle_entrada);

end