classdef samnsControlador < handle
    
    properties
        mModelo
        mVista
        
        mZoomX   = 40;
        mSliderX = 20;
        mZoomY   = 2;
        mSliderY = 20;
        mLimSup  = 1;
        mLimInf  =-1;
        pHandleSalida = 0;
        pHandleEntrada= 0;
    end    
    properties(Access = private, Hidden = true)
        mTipoSenial                = 'sweep';      % 'sweep' / 'lineal'     
        mSeleccionExcitacion       = false;
    end    
    properties(Dependent = true, Hidden = false)
        tipoSenial 
        seleccionExcitacion
    end

    methods
        
        function obj = samnsControlador(modelo)
            obj.mModelo = modelo;
            obj.mVista = samnsVista(obj);
        end % Constructor
        
        %% Geters
        
        %% Seters
     
        %% Funciones de desarrollo
        function fsamnsPreferenciaGUI(this)     
            samnsPreferenciasGUI(this.mModelo);             
        end
        function fGrabacion(this,nPer)
            %Variables de entrada
            ref = [];
            ref.dB      = this.mModelo.getDBReferencia();
            ref.dBFS    = this.mModelo.getDBFullScale();
            axHandle    = this.mVista.mGui.axSenialTiem;
            htiempo     = this.mVista.mGui.txTiempo;
            pnlTiempInt = this.mVista.mGui.pnlTiempInt;
            pnlFilt     = this.mVista.mGui.DomTiemp.pnlFilt;
            TipoGraf    = this.mVista.mGui.pnlTipoGraf;
            pnlNivelesEst = this.mVista.mGui.pnlNivelesEst;
            pmNivel     = this.mVista.mGui.pmNivel;
            sliderXY    = this.mVista.mGui.axeSlider;
            stop        = this.mVista.mGui.btGrabar;
            btOver      = this.mVista.mGui.DomTiemp.btOver;
            fs          = this.mModelo.getFrecMuestre();
            mlpFlt      = designfilt('lowpassiir','FilterOrder', 1, ...
                                'PassbandFrequency', 100,...
                                'SampleRate', fs);
            if nPer > 0 
                Tempo   = this.mModelo.getPGraba();%aca tengo que seleccionar el periodo de grabacion
                tPGraba = Tempo(nPer).P;
            else
                tPGraba = -1;
            end
            EntradaIndex = this.mModelo.getEntradaIndex();
            
            
            %Funcion
            [LPA,LPC,LPZ, LeqA,LeqC,LeqZ, LPtimeLapse, audioSignal] = grabacion({EntradaIndex, axHandle, stop, htiempo, pnlTiempInt, pnlFilt, TipoGraf, ref, pnlNivelesEst, mlpFlt, tPGraba, pmNivel, sliderXY, btOver, fs});        
            %Variables de salida
            this.mModelo.setLPA(LPA);
            this.mModelo.setLPC(LPC);
            this.mModelo.setLPZ(LPZ);
            this.mModelo.setLeqA(LeqA);
            this.mModelo.setLeqC(LeqC);
            this.mModelo.setLeqZ(LeqZ);
            this.mModelo.setLPtimeLapse(LPtimeLapse);
            this.mModelo.setAudioSignal(audioSignal);
            
            if tPGraba > 0, this.fGenFilExpDat(1,1,1,1);end
        end
        function fCalibracion(this)
            calibracionAut(this.mModelo);
        end
        function fGenerador(this)
            generadorGUI(this.mModelo);  
        end  
        function fStartStopButton(this)
            audioData     = this.mModelo.getAudioSignal();
            fs            = this.mModelo.getFrecMuestre();
            IndexSalida   = this.mModelo.getSalidaIndex();
            btStarStop    = this.mVista.mGui.btPlaySto;
            filtroPondera = this.mVista.mGui.DomTiemp.pnlFilt;
            if get(filtroPondera.rbA,'Value')
                audioData = filterA(audioData, fs);
            end
            if get(filtroPondera.rbC,'Value')
                audioData = filterC(audioData, fs);
            end
            
            
            if get(btStarStop,'Value')
                this.pHandleEntrada = PsychPortAudio('Open', IndexSalida, 1, 3, fs , 1); 
                PsychPortAudio('FillBuffer',this.pHandleEntrada,audioData);
                PsychPortAudio('Start',this.pHandleEntrada);
            else
                PsychPortAudio('Stop',this.pHandleEntrada);
                PsychPortAudio('Close',this.pHandleEntrada);
            end
            
        end
        function fShowAudioData(this)
            axHandle      = this.mVista.mGui.axSenialTiem;
            filtroPondera = this.mVista.mGui.DomTiemp.pnlFilt;

            audioData     = this.mModelo.getAudioSignal();
            fs            = this.mModelo.getFrecMuestre();
            
            if get(filtroPondera.rbA,'Value')
                audioData = filterA(audioData, fs);
            end
            if get(filtroPondera.rbC,'Value')
                audioData = filterC(audioData, fs);
            end

            if ~isempty(audioData)
                x = (1:length(audioData))/fs;
                y = max(abs(audioData));
                plot(axHandle, x, audioData) % dibuja todas las señales
                
                axHandle.XScale         = 'lin';
                axHandle.XAxisLocation  = 'origin';
                axHandle.YGrid          = 'on';
                axHandle.Box            = 'on';
                axHandle.XAxisLocation  = 'top';
                axHandle.XLabel.String  = 'Tiempo [s]';
                axHandle.YLabel.String  = 'Amplitud Normalizada';
                axHandle.YLim           = [-y, y];     %escala eje x
            else
                cla(axHandle)
            end
        end
        function fShowLP(this)
            SPL    = [];
            offset = [];
            axHandle      = this.mVista.mGui.axSenialTiem;
            pnlTiempInt   = this.mVista.mGui.pnlTiempInt;
            pnlNivelesEst = this.mVista.mGui.pnlNivelesEst;
            pmNivel       = this.mVista.mGui.pmNivel;
            sldAxe        = this.mVista.mGui.axeSlider;
            handZoom      = this.mVista.mGui.zoom;
            
            if get(handZoom.xMas,'Value') && this.mZoomX > 3
                this.mZoomX = this.mZoomX / 2; 
                this.mSliderX = this.mSliderX / 4;
                set(sldAxe.x,'SliderStep',[0.1 this.mSliderX]);
            end
            if get(handZoom.xMen,'Value') && this.mZoomX < 200
                this.mZoomX = this.mZoomX * 2; 
                this.mSliderX = this.mSliderX * 4;
                set(sldAxe.x,'SliderStep',[0.1 this.mSliderX]);
            end
            
            if get(handZoom.xMas,'Value') && this.mZoomX < 3,
                set(handZoom.xMas,'Enable','off');
            else
                set(handZoom.xMas,'Enable','on'); 
            end
            if get(handZoom.xMen,'Value') && this.mZoomX > 200, 
                set(handZoom.xMen,'Enable','off');
            else
                set(handZoom.xMen,'Enable','on');
            end
            
            LPA = this.mModelo.getLPA();
            LPC = this.mModelo.getLPC();
            LPZ = this.mModelo.getLPZ();
            LeqA = this.mModelo.getLeqA();
            LeqC = this.mModelo.getLeqC();
            LeqZ = this.mModelo.getLeqZ();
            timeLapse = this.mModelo.getLPtimeLapse();
            refdB   = this.mModelo.getDBReferencia();
            refdBFS = this.mModelo.getDBFullScale();
            
            if get(pmNivel.Nivel,'Value') == 1
                offset.PK = refdBFS;  
                offset.In = refdBFS;  
                offset.Fs = refdBFS;    
                offset.Sl = refdBFS;    
            elseif get(pmNivel.Nivel,'Value') == 2 
                offset.PK = - 20*log10(0.00002) + refdB;
                offset.In = - 20*log10(0.00002) + refdB;
                offset.Fs = - 20*log10(0.00002) + refdB;
                offset.Sl = - 20*log10(0.00002) + refdB;
            end
            if ~isempty(LPA) && ~isempty(LPC) && ~isempty(LPZ) && ~isempty(LeqA) && ~isempty(LeqC) && ~isempty(LeqZ)
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
            end
            
            if ~isempty(SPL)
                axHandle      = this.mVista.mGui.axSenialTiem;
                x = get(sldAxe.x,'Value');
                
                lenSPL = length(SPL');
                timeLapseSPL = (1:lenSPL)*timeLapse/lenSPL;
                plot(axHandle, timeLapseSPL, SPL') % dibuja todas las señales
                axHandle.XLabel.String = '';
                axHandle.XAxisLocation = 'top';
                axHandle.YLabel.String = 'Nivel fondo escala';% cambiar cuando varia pm de la escala
                axHandle.XGrid = 'on';
                axHandle.YGrid = 'on';
                
                if get(pmNivel.Nivel,'Value') == 1
                    axHandle.YLim = [-inf, 0];
                elseif get(pmNivel.Nivel,'Value') == 2 
                    axHandle.YLabel.String = 'Nivel';
                end
                
                if timeLapseSPL(end) > this.mZoomX
                    lInf = (timeLapseSPL(end)- this.mZoomX) * x/100;
                    lSup = lInf + this.mZoomX;
                    axHandle.XLim = [lInf, lSup];
                else
                    axHandle.XLim = [0, inf];     %escala eje x
    %             axHandle.YLim = [refDB - 20, refDB + 40];   %escala eje y
                end
            else
                cla(axHandle)
            end
        end
        function fModAxis(this) % faltan detalles
            %% Carga de datos
            timeLapse   = this.mModelo.getLPtimeLapse();            
            sldAxe      = this.mVista.mGui.axeSlider;
            handZoom    = this.mVista.mGui.zoom;
            axHandle    = this.mVista.mGui.axSenialTiem;
            modo        = this.mVista.mGui.pnlTipoGraf;
            
            if get(modo.tbTiemp,'Value')
                %% modificacion del eje Y
                if get(handZoom.yMas, 'Value')
                    SStepY = get(sldAxe.y,'SliderStep');
                    set(sldAxe.y,'SliderStep',[1 SStepY(2)/ 2]);
                    axHandle.YLim = axHandle.YLim / 2;
                    if axHandle.YLim(2) < 0.000001
                        set(handZoom.yMas, 'Enable', 'off')
                        set(handZoom.yMen, 'Enable', 'on')
                    else
                        set(handZoom.yMas, 'Enable', 'on')
                        set(handZoom.yMen, 'Enable', 'on')                
                    end
                    set(sldAxe.y,'Value',50)
                    ylimSupInf = axHandle.YLim;
                    this.mLimSup = ylimSupInf(2);
                    this.mLimInf = ylimSupInf(1);
                end

                if get(handZoom.yMen, 'Value')
                    SStepY = get(sldAxe.y,'SliderStep');
                    set(sldAxe.y,'SliderStep',[1 SStepY(2)* 2]);
                    axHandle.YLim = axHandle.YLim * 2;
                    if axHandle.YLim(2) > 1
                        set(handZoom.yMas, 'Enable', 'on')
                        set(handZoom.yMen, 'Enable', 'off')
                    else
                        set(handZoom.yMas, 'Enable', 'on')
                        set(handZoom.yMen, 'Enable', 'on')                
                    end
                    set(sldAxe.y,'Value',50)
                    ylimSupInf = axHandle.YLim;
                    this.mLimSup = ylimSupInf(2);
                    this.mLimInf = ylimSupInf(1);
                end

                %% modificacion del eje X
                if get(handZoom.xMas,'Value') && this.mZoomX > 3
                    this.mZoomX = this.mZoomX / 2; 
                    this.mSliderX = this.mSliderX / 4;
                    set(sldAxe.x,'SliderStep',[0.1 this.mSliderX]);
                end
                if get(handZoom.xMen,'Value') && this.mZoomX < 200
                    this.mZoomX = this.mZoomX * 2; 
                    this.mSliderX = this.mSliderX * 4;
                    set(sldAxe.x,'SliderStep',[0.1 this.mSliderX]);
                end

                if get(handZoom.xMas,'Value') && this.mZoomX < 3,
                    set(handZoom.xMas,'Enable','off');
                else
                    set(handZoom.xMas,'Enable','on'); 
                end
                if get(handZoom.xMen,'Value') && this.mZoomX > 200, 
                    set(handZoom.xMen,'Enable','off');
                else
                    set(handZoom.xMen,'Enable','on');
                end

                %% actualizacion de los ejes
                x = get(sldAxe.x,'Value');            
                if get(handZoom.xMas,'Value') && ~isempty(timeLapse);
                    if timeLapse(end) > this.mZoomX 
                        lInf = (timeLapse(end)- this.mZoomX) * x/100;
                        lSup = lInf + this.mZoomX;
                        axHandle.XLim = [lInf, lSup];
                    end
                else
                    axHandle.XLim = [0, inf];     %escala eje x
                end
%                            
                y = get(sldAxe.y,'Value');
                lInf = this.mLimInf + ((0.5-this.mLimSup) * (y-50)/100);
                lSup = this.mLimSup + ((0.5-this.mLimSup) * (y-50)/100);
                axHandle.YLim = [lInf, lSup];

            end
            if get(modo.tbFrecu,'Value')
                
                
                
                
            end
            if get(modo.tbLP,'Value')
                
                
                
                
            end
        end
        function fExportData(this)
            fGUIdataExport(this);
        end      
        function fImportDataAudio(this)
            [name,path] = uigetfile('*.wav','Selecciona el archivo para cargar');
            [y, fs] = audioread([path,name]);
            this.mModelo.setAudioSignal(y');
            this.mModelo.setFrecMuestre(fs);
            this.fCalculosLP(y',fs)
        end
        function fCalculosLP(this,audioData, fs)
            clc
            mlpFlt      = designfilt('lowpassiir','FilterOrder', 1, ...
                                'PassbandFrequency', 100,...
                                'SampleRate', fs);
                            
           [LPA, LPC, LPZ, LeqA, LeqC, LeqZ] = fCalculosNivel(audioData,fs,mlpFlt);
           
           tiempo = length(audioData)/fs;
           size(LPA.PK)
           LPtimeLapse = (1:length(LPA.PK)) * tiempo/length(LPA.PK);
%            length(LPA)
%            size(LPA)
           this.mModelo.setLPA(LPA);
           this.mModelo.setLPC(LPC);
           this.mModelo.setLPZ(LPZ);
           this.mModelo.setLeqA(LeqA);
           this.mModelo.setLeqC(LeqC);
           this.mModelo.setLeqZ(LeqZ);
           this.mModelo.setLPtimeLapse(LPtimeLapse);
           this.fShowLP();
        end       
        function fGenFilExpDat(this, mTPlano, mExc, mJSON, mWav)
            c = clock;
            cStr = [num2str(c(1)),num2str(c(2)),num2str(c(3)),num2str(c(4)),num2str(c(5)),num2str(round(c(6)))];
            
            introTxt = ['Este es un ejemplo que simboliza el encabezado de un archivo de texto\nque se realizo el dia ', datestr(datetime), ...
                   '\nes una medicion de SPL bla bla bla bla\n' ...
                   'Temperatura ambiente:\n\n'];
            refdB      = this.mModelo.getDBReferencia();
            refdBFS    = this.mModelo.getDBFullScale();
            fs         = this.mModelo.getFrecMuestre();
            LPA        = this.mModelo.getLPA();
            LPC        = this.mModelo.getLPC();
            LPZ        = this.mModelo.getLPZ();
            LAeq       = this.mModelo.getLeqA();
            LCeq       = this.mModelo.getLeqC();
            LZeq       = this.mModelo.getLeqZ();
            path       = this.mModelo.getPath();
            
            offsetdB = [];
            offsetdBFS = [];
            
            offsetdB.PK = refdBFS + 12;  
            offsetdB.In = refdBFS - 41;  
            offsetdB.Fs = refdBFS - 60;    
            offsetdB.Sl = refdBFS - 78;    

            offsetdBFS.PK = - 20*log10(0.000002) + 6    - refdB;
            offsetdBFS.In = - 20*log10(0.000002) - 48.4 - refdB;
            offsetdBFS.Fs = - 20*log10(0.000002) - 66   - refdB;
            offsetdBFS.Sl = - 20*log10(0.000002) - 83.8 - refdB;

            Titulos = {'Tiempo [s]';'LZpeak';'LZI'; 'LZF';'LZS';'LZeq';'LZ01';'LZ10';'LZ50';'LZ90';'LZ99';...
                                    'LCpeak';'LCI'; 'LCF';'LCS';'LCeq';'LC01';'LC10';'LC50';'LC90';'LC99';...
                                    'LApeak';'LAI'; 'LAF';'LAS';'LAeq';'LA01';'LA10';'LA50';'LA90';'LA99';};

            DatosExpdB = [LPZ.tiempo; 
                            LPZ.PK + offsetdB.PK; LPZ.Inst.Datos + offsetdB.In; LPZ.Fast.Datos + offsetdB.Fs; LPZ.Slow.Datos + offsetdB.Sl; LZeq.Datos + offsetdB.Fs; LZeq.L01 + offsetdB.Fs;LZeq.L10 + offsetdB.Fs;LZeq.L50 + offsetdB.Fs;LZeq.L90 + offsetdB.Fs;LZeq.L99 + offsetdB.Fs;...
                            LPC.PK + offsetdB.PK; LPC.Inst.Datos + offsetdB.In; LPC.Fast.Datos + offsetdB.Fs; LPC.Slow.Datos + offsetdB.Sl; LCeq.Datos + offsetdB.Fs; LCeq.L01 + offsetdB.Fs;LCeq.L10 + offsetdB.Fs;LCeq.L50 + offsetdB.Fs;LCeq.L90 + offsetdB.Fs;LCeq.L99 + offsetdB.Fs;...
                            LPA.PK + offsetdB.PK; LPA.Inst.Datos + offsetdB.In; LPA.Fast.Datos + offsetdB.Fs; LPA.Slow.Datos + offsetdB.Sl; LAeq.Datos + offsetdB.Fs; LAeq.L01 + offsetdB.Fs;LAeq.L10 + offsetdB.Fs;LAeq.L50 + offsetdB.Fs;LAeq.L90 + offsetdB.Fs;LAeq.L99 + offsetdB.Fs;];
            DatosExpdBFS = [LPZ.tiempo; 
                            LPZ.PK + offsetdBFS.PK; LPZ.Inst.Datos + offsetdBFS.In; LPZ.Fast.Datos + offsetdBFS.Fs; LPZ.Slow.Datos + offsetdBFS.Sl; LZeq.Datos + offsetdBFS.Fs; LZeq.L01 + offsetdBFS.Fs;LZeq.L10 + offsetdBFS.Fs;LZeq.L50 + offsetdBFS.Fs;LZeq.L90 + offsetdBFS.Fs;LZeq.L99 + offsetdBFS.Fs;...
                            LPC.PK + offsetdBFS.PK; LPC.Inst.Datos + offsetdBFS.In; LPC.Fast.Datos + offsetdBFS.Fs; LPC.Slow.Datos + offsetdBFS.Sl; LCeq.Datos + offsetdBFS.Fs; LCeq.L01 + offsetdBFS.Fs;LCeq.L10 + offsetdBFS.Fs;LCeq.L50 + offsetdBFS.Fs;LCeq.L90 + offsetdBFS.Fs;LCeq.L99 + offsetdBFS.Fs;...
                            LPA.PK + offsetdBFS.PK; LPA.Inst.Datos + offsetdBFS.In; LPA.Fast.Datos + offsetdBFS.Fs; LPA.Slow.Datos + offsetdBFS.Sl; LAeq.Datos + offsetdBFS.Fs; LAeq.L01 + offsetdBFS.Fs;LAeq.L10 + offsetdBFS.Fs;LAeq.L50 + offsetdBFS.Fs;LAeq.L90 + offsetdBFS.Fs;LAeq.L99 + offsetdBFS.Fs;];

            if mExc
%                 disp('entra a excel')
                filename = ['\testdata' cStr '.xlsx'];
                xlswrite([path, filename],Titulos',1,'A1')           
                xlswrite([path, filename],DatosExpdB',1,'A3')
                xlswrite([path, filename],Titulos',2,'A1')           
                xlswrite([path, filename],DatosExpdBFS',2,'A3')
            end

            if mTPlano
%                 disp('entra a plano')
                filename = ['\export_dB' cStr '.txt'];
                fileID = fopen([path filename],'w');

                fprintf(fileID,introTxt);%introduccion del archivo
                fprintf(fileID,'%11s    %6s    %6s    %6s   %6s   %6s   %6s    %6s    %6s    %6s   %6s   %6s   %6s    %6s    %6s    %6s   %6s   %6s   %6s   %6s    %6s    %6s   %6s   %6s   %6s    %6s    %6s    %6s   %6s   %6s   %6s\n',...
                               'Tiempo [s]','LZpk','LZI', 'LZF','LZS','LZeq','LZ01','LZ10','LZ50','LZ90','LZ99',...
                                            'LCpk','LCI', 'LCF','LCS','LCeq','LC01','LC10','LC50','LC90','LC99',...
                                            'LApk','LAI', 'LAF','LAS','LAeq','LA01','LA10','LA50','LA90','LA99');
                fprintf(fileID,'%11s    %6s    %6s    %6s   %6s   %6s   %6s    %6s    %6s    %6s   %6s   %6s   %6s    %6s    %6s    %6s   %6s   %6s   %6s    %6s    %6s    %6s   %6s   %6s   %6s    %6s    %6s    %6s   %6s   %6s   %6s\n',...
                                '---------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------');          
                fprintf(fileID,'   %4.3f      %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f\n',DatosExpdB);
                fclose(fileID);
                
                filename = ['\export_dBFS' cStr '.txt'];
                fileID = fopen([path filename],'w');

                fprintf(fileID,introTxt);%introduccion del archivo
                fprintf(fileID,'%11s    %6s    %6s    %6s   %6s   %6s   %6s    %6s    %6s    %6s   %6s   %6s   %6s    %6s    %6s    %6s   %6s   %6s   %6s   %6s    %6s    %6s   %6s   %6s   %6s    %6s    %6s    %6s   %6s   %6s   %6s\n',...
                               'Tiempo [s]','LZpk','LZI', 'LZF','LZS','LZeq','LZ01','LZ10','LZ50','LZ90','LZ99',...
                                            'LCpk','LCI', 'LCF','LCS','LCeq','LC01','LC10','LC50','LC90','LC99',...
                                            'LApk','LAI', 'LAF','LAS','LAeq','LA01','LA10','LA50','LA90','LA99');
                fprintf(fileID,'%11s    %6s    %6s    %6s   %6s   %6s   %6s    %6s    %6s    %6s   %6s   %6s   %6s    %6s    %6s    %6s   %6s   %6s   %6s    %6s    %6s    %6s   %6s   %6s   %6s    %6s    %6s    %6s   %6s   %6s   %6s\n',...
                                '---------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------','------');          
                fprintf(fileID,'   %4.3f      %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f  %4.4f\n',DatosExpdBFS);
                fclose(fileID);            
            end
            if mJSON
                filename = ['\exportJson' cStr '.dat'];
                fileID = fopen([path filename],'w');

                dataExpStruc = struct('Tiempo',LPZ.tiempo,...
                                      'LZpk',LPZ.PK,    'LZI', LPZ.Inst.Datos,   'LZF',LPZ.Fast.Datos,'LZS',LPZ.Slow.Datos,...
                                      'LZeq',LZeq.Datos,'LZ01',LZeq.L01,         'LZ10',LZeq.L10,     'LZ50',LZeq.L50, 'LZ90',LZeq.L90,'LZ99',LZeq.L99,...
                                      'LCpk',LPC.PK,    'LCI', LPC.Inst.Datos,   'LCF',LPC.Fast.Datos,'LCS',LPC.Slow.Datos,...
                                      'LCeq',LCeq.Datos,'LC01',LCeq.L01,         'LC10',LCeq.L10,     'LC50',LCeq.L50, 'LC90',LCeq.L90,'LC99',LCeq.L99,...
                                      'LApk',LPA.PK,    'LAI', LPA.Inst.Datos,   'LAF',LPA.Fast.Datos,'LAS',LPA.Slow.Datos,...
                                      'LAeq',LAeq.Datos,'LA01',LAeq.L01,         'LA10',LAeq.L10,     'LA50',LAeq.L50, 'LA90',LAeq.L90,'LA99',LAeq.L99);

                dataExpJSon = savejson('jExp',dataExpStruc);
                fprintf(fileID,dataExpJSon);%introduccion del archivo

                fclose(fileID);
            end
            if mWav
                filename = ['\exportAudio' cStr '.wav'];
                audioSignal = this.mModelo.getAudioSignal();
                audiowrite([path filename],audioSignal,fs);
            end
        end                
        function fCTRLAutomatizacion(this)
            fAutomatizacion(this)
        end
        function activeTimerGrab1(this,temporizadores)
            this.mModelo.setPGraba(temporizadores);
            objTmr = this.mModelo.getPGraba;
            if ~isempty(objTmr)
                objTmr(1).T.TimerFcn   = @(~,~)this.activeTimerGrab(1);
                start(objTmr(1).T)
            end
            if length(objTmr) > 1
                objTmr(2).T.TimerFcn   = @(~,~)this.activeTimerGrab(2);
                start(objTmr(2).T)
            end
            if length(objTmr) > 2
                objTmr(3).T.TimerFcn   = @(~,~)this.activeTimerGrab(3);
                start(objTmr(3).T)
            end
            if length(objTmr) > 3
                objTmr(4).T.TimerFcn   = @(~,~)this.activeTimerGrab(4);
                start(objTmr(4).T)
            end
        end
        function activeTimerGrab(this, nPer)
            grabar = this.mVista.mGui.btGrabar;
            if  get(grabar,'Value')
                msgbox('ERROR: No se realizó la automatizacion porque ya se estaba grabando')
            else
                set(grabar,'Value',1);
                this.fGrabacion(nPer);
            end
        end
        function fShowEsp(this)
            
        end

        
    end
end