function [LPA, LPC, LPZ, LeqA, LeqC, LeqZ] = fCalculosNivel(audioData,fs,lpFilt)
nMuest = 100;
c = round(length(audioData)/nMuest);
%% Variables para Tiempo y frecuencia
filterADataAudio = [];
filterCDataAudio = [];
filterZDataAudio = [];

%% Variables para Niveles de presion sonora
LPA = [];  LPC = [];  LPZ = [];
LeqA = []; LeqC = []; LeqZ = [];
gainAP = 0; gainAI = 0; gainAF = 0;
gainAS = 0; gainCP = 0; gainCI = 0;
gainCF = 0; gainCS = 0; gainZP = 0;
gainZI = 0; gainZF = 0; gainZS = 0;

    for i = 1:(c)
        if i == c
            audioDataZ = audioData(1+nMuest*(i-1):end);
        else
            audioDataZ = audioData(1+nMuest*(i-1):nMuest*i);
        end
        
        audioDataA = filterA(audioDataZ, fs);
        audioDataC = filterC(audioDataZ, fs);

        filterADataAudio = [filterADataAudio audioDataA];
        filterCDataAudio = [filterCDataAudio audioDataC];
        filterZDataAudio = [filterZDataAudio audioDataZ];

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
        LPA.Fast.Datos(i) = 20*log10(rms(recorderFastA)) ; %Revisar
        LPA.Fast.max(i)   = max(LPA.Fast.Datos);
        LPA.Fast.min(i)   = min(LPA.Fast.Datos);
        %--
        LPA.Slow.Datos(i) = 20*log10(rms(recorderSlowA)) ; %Revisar
        LPA.Slow.max(i)   = max(LPA.Slow.Datos);
        LPA.Slow.min(i)   = min(LPA.Slow.Datos);

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
            
    end

end