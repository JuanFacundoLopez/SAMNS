% Validacion de los filtros

%         [recorderPicoA, gainAP] = filPK(audioDataA,fs,gainAP, lpFilt);
%         [recorderInstA, gainAI] = filterInst(audioDataA, fs, gainAI, lpFilt); 
%         [recorderFastA, gainAF] = filFast(audioDataA, fs, gainAF, lpFilt);
%         [recorderSlowA, gainAS] = filSlow(audioDataA, fs, gainAS, lpFilt);

gainAP=0;recorderPicoA=[];
gainAI=0;recorderInstA=[];
gainAF=0;recorderFastA=[];
gainAS=0;recorderSlowA=[];

timPK=50e-6;
timInst=35e-3;
timFast=125e-3;
timSlow=1000e-3;

% Validaciones burst
% [audioDataPK, fs] = audioread('Sinusoide-1kHz-RafagasDuracionVariable.wav');
% [audioDataIst,fs] = audioread('Sinusoide-1kHz-RafagasDuracionVariable.wav');
% [audioDataFst,fs] = audioread('Sinusoide-1kHz-RafagasDuracionVariable.wav');
% [audioDataSlo,fs] = audioread('Sinusoide-1kHz-RafagasDuracionVariable.wav');

audioDataPK = MakeBeep(500,5,44100);
audioDataIst = MakeBeep(500,5,44100);
audioDataFst = MakeBeep(500,5,44100);
audioDataSlo = MakeBeep(500,5,44100);
% fs          = 48000;
lpFilt      = designfilt('lowpassiir','FilterOrder', 1, ...
                                'PassbandFrequency', 100,...
                                'SampleRate', fs);
                            
timeVecPK = (1:length(audioDataPK))/fs;
[filterPicoA, gainAP] = filPK(audioDataPK,fs,gainAP, lpFilt);

timeVecIns = (1:length(audioDataIst))/fs;
[filterInstA, gainAI] = filterInst(audioDataIst, fs, gainAI, lpFilt); 

timeVecFst = (1:length(audioDataFst))/fs;
[filterFastA, gainAF] = filFast(audioDataFst, fs, gainAF, lpFilt);

timeVecSlo = (1:length(audioDataSlo))/fs;
[filterSlowA, gainAS] = filSlow(audioDataSlo, fs, gainAS, lpFilt);

recorderPicoA = [recorderPicoA filterPicoA];
recorderInstA = [recorderInstA filterInstA];
recorderFastA = [recorderFastA filterFastA];
recorderSlowA = [recorderSlowA filterSlowA];

figure(1)
plot(timeVecPK,audioDataPK,timeVecPK,recorderPicoA)
figure(2)
plot(timeVecIns,audioDataIst,timeVecIns,recorderInstA)
figure(3)
plot(timeVecFst,audioDataFst,timeVecFst,recorderFastA)
figure(4)
% size(timeVecSlo)
% size(recorderSlowA)
% size(lineSlo)
% % size()
plot(timeVecSlo,audioDataSlo,timeVecSlo,recorderSlowA)