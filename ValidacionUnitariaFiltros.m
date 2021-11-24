% Validacion unitaria de los filtros

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
% Validaciones de attaque
audioDataPK  = ones(1,100);
audioDataIst  = ones(1,10000);
audioDataFst  = ones(1,30000);
audioDataSlo  = ones(1,320000);


% fs          = 48000;
lpFilt      = designfilt('lowpassiir','FilterOrder', 1, ...
                                'PassbandFrequency', 100,...
                                'SampleRate', fs);
                            
timeVecPK = (1:length(audioDataPK))/fs;
vectPK = (1/(fs*timPK))*(1:(fs*timPK));
linePK = [vectPK, ones(1,(length(audioDataPK) -round((fs*timPK))))];
[filterPicoA, gainAP] = filPK(audioDataPK,fs,gainAP, lpFilt);

timeVecIns = (1:length(audioDataIst))/fs;
vectIns = (1/(fs*timInst))*(1:(fs*timInst));
lineIns = [vectIns, ones(1,(length(audioDataIst) - round((fs*timInst))))];
[filterInstA, gainAI] = filterInst(audioDataIst, fs, gainAI, lpFilt); 

timeVecFst = (1:length(audioDataFst))/fs;
vectFst = (1/(fs*timFast))*(1:(fs*timFast));
lineFst = [vectFst, ones(1,(length(audioDataFst) - round((fs*timFast))))];
[filterFastA, gainAF] = filFast(audioDataFst, fs, gainAF, lpFilt);

timeVecSlo = (1:length(audioDataSlo))/fs;
vectSlo = (1/(fs*timSlow))*(1:(fs*timSlow));
lineSlo = [vectSlo, ones(1,(length(audioDataSlo)  - round((fs*timSlow))))];
[filterSlowA, gainAS] = filSlow(audioDataSlo, fs, gainAS, lpFilt);

recorderPicoA = [recorderPicoA filterPicoA];
recorderInstA = [recorderInstA filterInstA];
recorderFastA = [recorderFastA filterFastA];
recorderSlowA = [recorderSlowA filterSlowA];

figure(1)
plot(timeVecPK,recorderPicoA,timeVecPK,linePK)
figure(2)
plot(timeVecIns,recorderInstA,timeVecIns,lineIns)
figure(3)
plot(timeVecFst,recorderFastA,timeVecFst,lineFst)
figure(4)
% size(timeVecSlo)
% size(recorderSlowA)
% size(lineSlo)
% % size()
plot(timeVecSlo,recorderSlowA,timeVecSlo,lineSlo)