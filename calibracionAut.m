function calibracionAut(mModelo)

h=[];
h.fig=figure('Name','Calibración',...
             'NumberTitle','off',...
             'MenuBar','none',...
             'ToolBar','none',...
             'Units','normalized',...
             'Position',[0.35, 0.4, 0.3, 0.2]);

h.txExp = uicontrol(h.fig,'Style','text', 'Units', 'normalized', 'Position', [0.1, 0.42, 0.7, 0.53],...
                    'BackGroundColor','w','FontSize',13 );
h.pmTip = uicontrol(h.fig,'Style','popupmenu','String',{'Fuente externa de ref';'Fondo de escala (Eléctrico)';'Referencia interna en archivo de audio';},...
                    'Units', 'normalized', 'Position', [0.1, 0.25, 0.6, 0.125],...
                    'FontSize',13 ,'BackGroundColor','w','Callback',@fpmTipo);    
h.btBus = uicontrol(h.fig,'Style','pushbutton','String','...',...
                    'Units', 'normalized', 'Position', [0.72, 0.25, 0.08, 0.135],...
                    'BackGroundColor','w','Callback',@fBuscarArchiv);                

h.btCal = uicontrol(h.fig,'String','Calibrar',...
                    'Units', 'normalized', 'Position', [0.1, 0.08, 0.3, 0.12],...
                    'Callback',@fCalibrarAplicar);
h.btCan = uicontrol(h.fig,'String','Cancelar',...
                    'Units', 'normalized', 'Position', [0.5, 0.08, 0.3, 0.12],...
                    'Callback',@fCancelar);
h.btGen = uicontrol(h.fig,'String','Generador',...
                    'Units', 'normalized', 'Position', [0.82, 0.08, 0.15, 0.12],...
                    'Callback',@fGenerador);                

h.txMet = uicontrol(h.fig,'Style','text','String','85.0','FontSize',15,...
                    'Units', 'normalized', 'Position', [0.82, 0.65, 0.15, 0.3],...
                    'BackGroundColor','w');
h.edCal = uicontrol(h.fig,'Style','edit','String','77.0','FontSize',15,...
                    'Units', 'normalized', 'Position', [0.82, 0.35, 0.15, 0.3],...
                    'BackGroundColor','w');
h.btMen = uicontrol(h.fig,'Style','pushbutton','String','<',...
                    'Units', 'normalized', 'Position', [0.82, 0.25, 0.07, 0.1],...
                    'BackGroundColor','w','Callback',@fMas);
h.btMas = uicontrol(h.fig,'Style','pushbutton','String','>',...
                    'Units', 'normalized', 'Position', [0.9, 0.25, 0.07, 0.1],...
                    'BackGroundColor','w','Callback',@fMen);  
h.GUIGen.fig=0;
  fpmTipo              
                
                % Aplicamos el boton de "Calibrar" que luego se va a modificar
                % a "Aplicar"
    function fCalibrarAplicar(~,~)  

        fs = mModelo.getFrecMuestre();
        EntradaIndex = mModelo.getEntradaIndex();
        SalidaIndex = mModelo.getSalidaIndex();
        recorData = [];
        myBeep = MakeBeep(1000,15,fs);
        act = 0;

        phandle_entrada = PsychPortAudio('Open', EntradaIndex, 2, 3, fs , 1);%index de entrada 1
        
        switch get(h.pmTip,'Value')
            case 1
               %Emision de audio
                PsychPortAudio('GetAudioData', phandle_entrada,1);
                PsychPortAudio('Start', phandle_entrada);
                f = waitbar(0,'Capturando..');
                step = 1;
                while length(recorData)/fs < 3
                    audiodata = PsychPortAudio('GetAudioData', phandle_entrada);                   
                    if ~isempty(audiodata)
                        recorData = [recorData audiodata];
                        figure(5)
                        plot(recorData)
                        if act > 10
                            Lp = 20*log10(rms(recorData)/0.00002); % Lp sin calibracion
                            set(h.txMet,'String',num2str(round(Lp,1)));
                            act = 0;
                        end
                        act = act + 1;
                    end
                    if length(recorData)/fs > 1 && step == 1
                        waitbar(0.25,f,'Capturando..3');
                        step=2;
                    end
                    if length(recorData)/fs > 2 && step == 2
                        waitbar(0.5,f,'Capturando..2');
                        step=3;
                    end
                    if length(recorData)/fs > 3 && step == 3
                        waitbar(0.75,f,'Capturando..1');
                    end
                end
                Lref = str2double(get(h.edCal,'String'));
                refdB = (Lref - Lp);
                mModelo.setDBReferencia(refdB)
                pause(0.5)
                if refdB~=0, waitbar(1,f,'Referencia tomada!');end
            case 2
                i = 0;
                pahandle_salida = PsychPortAudio('Open', SalidaIndex, 1, 3, fs, 1);%index de salida 5
                PsychPortAudio('FillBuffer', pahandle_salida, myBeep);
                PsychPortAudio('Volume', pahandle_salida,0);
                PsychPortAudio('Start', pahandle_salida);                
                PsychPortAudio('GetAudioData', phandle_entrada,2);                     
                PsychPortAudio('Start', phandle_entrada);
                f = waitbar(0,'Capturando..');
                while i < 100
                    pause(0.02)
                    PsychPortAudio('Volume', pahandle_salida,0.01*i);                            
                    i=i+1;
                    audiodata = PsychPortAudio('GetAudioData', phandle_entrada);
                    if ~isempty(audiodata)
                        totDistHarm = thd(audiodata,fs,20);
                        if totDistHarm > -40 && i > 20
                            refFS = rms(audiodata);
                            dBFS = 20*log10(refFS)+1;
                            mModelo.setDBFullScale(dBFS)
                            waitbar(1,f,'Referencia tomada..');
                            break;
                        elseif i == 99
                            waitbar(1,f,'No se logro el fondo de escala, configure adecuadamente la tarjeta de sonido');
                        end
                    end
                end
        end
        set(h.btCal,'Enable','on');
        set(h.btMen,'Enable','on');
        set(h.btMas,'Enable','on');
        set(h.btCan,'Enable','on');

        pause(0.5)
        close(f);
        PsychPortAudio('Close');
        if isobject(h.GUIGen.fig), close(h.GUIGen.fig);end
        close(h.fig);
    end
    function fCancelar(~,~)
        close(h.fig);
    end   
    function fMas(~,~)
        set(h.edCal,'String', num2str(0.1 + str2double(get(h.edCal,'String'))));
    end
    function fMen(~,~)
        set(h.edCal,'String', num2str(str2double(get(h.edCal,'String')) - 0.1));
    end
    function fBuscarArchiv(~,~)
    end
    function fpmTipo(~,~)
        if get(h.pmTip,'Value') ==1
            text = 'Se precisa de una fuente externa o bien puede usar el generador de señales. Se realizara una captura de sonido durante 3 segundos y usted debera indicar el nivel medido por su instrumento patron';
            set(h.txExp,'String',text)
        elseif get(h.pmTip,'Value') ==2
            text = 'Se mide el maximo rango dinamico de la cadena de instrumentacion hasta que se de 1% de THD';
            set(h.txExp,'String',text)
        elseif get(h.pmTip,'Value') ==3
            text = '';
            set(h.txExp,'String',text)
        else
            text = 'Se introduce un archivo de audio y se especifica a que nivel se encuentra';
            set(h.txExp,'String',text)
        end
    end
    function fGenerador(~,~)
        h.GUIGen = generadorGUI(mModelo); 
    end
end

