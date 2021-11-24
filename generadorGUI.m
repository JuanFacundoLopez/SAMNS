function h = generadorGUI(modelo)

h=[];
h.fig = figure('Name','Generador de señales',...
             'NumberTitle','off',...
             'MenuBar','none',...
             'ToolBar','none',...
             'Units','normalized',...
             'Color','w',...
             'Position',[0.25, 0.5, 0.4, 0.3]);
                         
h.hAxis.main = axes;
h.hAxis.main.Parent = h.fig;
h.hAxis.main.Position = [0.67 0.27 0.3 0.65];
h.hAxis.main.YLim  = [-1 1];
h.hAxis.main.Box   = 'on';
h.hAxis.main.XAxisLocation = 'origin';

         
             %--Frecuencia inicial--- Frecuencia final ---- Frecuencia 
h.edFIn = uicontrol(h.fig,'Style','edit','String','200','FontSize',15,...
                    'Units', 'normalized', 'Position', [0.15, 0.53, 0.2, 0.125],...
                    'BackGroundColor','w','Visible','off','Callback',@fSelect);
h.txFIn = uicontrol(h.fig,'Style','text','String','Frecuencia inicial','FontSize',12,...
                    'Units', 'normalized', 'Position', [0.15, 0.53, 0.2, 0.12],...
                    'BackGroundColor','w','Visible','off');
                
h.edFFi = uicontrol(h.fig,'Style','edit','String','2000','FontSize',15,...
                    'Units', 'normalized', 'Position', [0.4, 0.53, 0.2, 0.125],...
                    'BackGroundColor','w','Visible','off','Callback',@fSelect); 
h.txFFi = uicontrol(h.fig,'Style','text','String','Frecuencia final','FontSize',12,...
                    'Units', 'normalized', 'Position', [0.4, 0.53, 0.2, 0.12],...
                    'BackGroundColor','w','Visible','off');   
                
h.edFre = uicontrol(h.fig,'Style','edit','String','2000','FontSize',15,...
                    'Units', 'normalized', 'Position', [0.050, 0.53, 0.550, 0.125],...
                    'BackGroundColor','w','Visible','on','Callback',@fSelect); 
h.txFre = uicontrol(h.fig,'Style','text','String','Frecuencia:','FontSize',12,...
                    'Units', 'normalized', 'Position', [0.050, 0.53, 0.2, 0.12],...
                    'BackGroundColor','w','Visible','off');                 
                
                %--Amplitud---Dutycicle---- Offset 
h.edAmp = uicontrol(h.fig,'Style','edit','String','1.0','FontSize',15,...
                    'Units', 'normalized', 'Position', [0.05, 0.73, 0.175, 0.125],...
                    'BackGroundColor','w','Callback',@fSelect);
h.txAmp = uicontrol(h.fig,'Style','text','String','Amplitud:','FontSize',12,...
                    'Units', 'normalized', 'Position', [0.05, 0.53, 0.2, 0.12],...
                    'BackGroundColor','w','Visible','off');   
                
h.edDcy = uicontrol(h.fig,'Style','edit','String','0.5','FontSize',15,...
                    'Units', 'normalized', 'Position', [0.275, 0.73, 0.15, 0.125],...
                    'BackGroundColor','w','Callback',@fSelect);
h.txDcy = uicontrol(h.fig,'Style','text','String','Duty cicle:','FontSize',12,...
                    'Units', 'normalized', 'Position', [0.275, 0.53, 0.2, 0.12],...
                    'BackGroundColor','w','Visible','off');      
                
h.edOfS = uicontrol(h.fig,'Style','edit','String','0.0','FontSize',15,...
                    'Units', 'normalized', 'Position', [0.45, 0.73, 0.15, 0.125],...
                    'BackGroundColor','w','Callback',@fSelect);
h.txOfS = uicontrol(h.fig,'Style','text','String','Offset:','FontSize',12,...
                    'Units', 'normalized', 'Position', [0.45, 0.53, 0.2, 0.12],...
                    'BackGroundColor','w','Visible','off');                 
 
                %-- Forma de onda
h.bgWaveForm.main = uibuttongroup(h.fig,'Title','Forma de onda',...
                    'Units', 'normalized', 'Position', [0.05, 0.25, 0.55, 0.25],...
                    'FontSize',10 ,'BackGroundColor','w');
         
h.bgWaveForm.btSin =  uicontrol(h.bgWaveForm.main,'Style','togglebutton','String','Seno',...
                    'Units', 'normalized', 'Position', [0.05, 0.05, 0.12, 0.9],...
                    'FontSize',10 ,'BackGroundColor','w','Callback',@fSelect);

h.bgWaveForm.btSqr =  uicontrol(h.bgWaveForm.main,'Style','togglebutton','String','Cuadrada',...
                    'Units', 'normalized', 'Position', [0.2, 0.05, 0.12, 0.9],...
                    'FontSize',8 ,'BackGroundColor','w','Callback',@fSelect);

h.bgWaveForm.btTri =  uicontrol(h.bgWaveForm.main,'Style','togglebutton','String','Triangular',...
                    'Units', 'normalized', 'Position', [0.35, 0.05, 0.12, 0.9],...
                    'FontSize',8 ,'BackGroundColor','w','Callback',@fSelect);
                               
h.bgWaveForm.btSwp =  uicontrol(h.bgWaveForm.main,'Style','togglebutton','String','Sweep',...
                    'Units', 'normalized', 'Position', [0.5, 0.05, 0.12, 0.9],...
                    'FontSize',9 ,'BackGroundColor','w','Callback',@fSelect);
                
h.bgWaveForm.btWNo =  uicontrol(h.bgWaveForm.main,'Style','togglebutton','String','W Noise',...
                    'Units', 'normalized', 'Position', [0.65, 0.05, 0.12, 0.9],...
                    'FontSize',8 ,'BackGroundColor','w','Callback',@fSelect);             
                
h.bgWaveForm.btBus = uicontrol(h.bgWaveForm.main,'Style','togglebutton','String','...',...
                    'Units', 'normalized', 'Position', [0.8, 0.05, 0.12, 0.9],...
                    'FontSize',10 ,'BackGroundColor','w','Callback',@fSelect);

h.btAce = uicontrol(h.fig,'String','Aceptar',...
                    'Units', 'normalized', 'Position', [0.1, 0.08, 0.21, 0.12],...
                    'Callback',@fAceptar);
h.btBus = uicontrol(h.fig,'Style','togglebutton','String','Play',...
                    'Units', 'normalized', 'Position', [0.41, 0.08, 0.21, 0.12],...
                    'BackGroundColor','w','Callback',@fGenerate);                
h.btCan = uicontrol(h.fig,'String','Cancelar',...
                    'Units', 'normalized', 'Position', [0.72, 0.08, 0.21, 0.12],...
                    'Callback',@fCancelar);
fSelect

	function fSelect(~,~)
        set(h.edFIn, 'Visible', 'off');
        set(h.edFFi, 'Visible', 'off');
        set(h.edDcy, 'Visible', 'off'); 
        set(h.edFre, 'Visible', 'off');        
        set(h.txDcy, 'Visible', 'off'); 
        set(h.txFIn, 'Visible', 'off');
        set(h.txFFi, 'Visible', 'off');
        set(h.txFre, 'Visible', 'off');
        
        if get(h.bgWaveForm.btSin,'Value')
            set(h.edFre, 'Visible', 'on'); 
            set(h.txFre, 'Visible', 'on');              
            set(h.txOfS, 'Visible', 'on');  
            set(h.txAmp, 'Visible', 'on');

            set(h.edFre, 'Position', [0.050, 0.50, 0.550, 0.12]); 
            set(h.txFre, 'Position', [0.050, 0.65, 0.15, 0.068]); 
            
            set(h.edAmp, 'Position', [0.050, 0.73, 0.275, 0.12]); 
            set(h.txAmp, 'Position', [0.050, 0.88, 0.12, 0.068]);
            
            set(h.edOfS, 'Position', [0.325, 0.73, 0.275, 0.12]);  
            set(h.txOfS, 'Position', [0.325, 0.88, 0.10, 0.068]);
            
            y = sin(0:0.1:2*pi);
        end
        
        if get(h.bgWaveForm.btSqr,'Value')
            set(h.edFre, 'Visible', 'on');  
            set(h.edDcy, 'Visible', 'on');
            set(h.txFre, 'Visible', 'on');  
            set(h.txDcy, 'Visible', 'on');

            set(h.edFre, 'Position', [0.050, 0.50, 0.550, 0.125]); 
            set(h.txFre, 'Position', [0.050, 0.65, 0.15, 0.068]);             
            
            set(h.edAmp, 'Position', [0.050, 0.73, 0.180, 0.125]);   
            set(h.txAmp, 'Position', [0.050, 0.88, 0.15, 0.068]);             
            
            set(h.edOfS, 'Position', [0.236, 0.73, 0.180, 0.125]);
            set(h.txOfS, 'Position', [0.236, 0.88, 0.150, 0.068]);            
            
            set(h.edDcy, 'Position', [0.420, 0.73, 0.180, 0.125]);
            set(h.txDcy, 'Position', [0.420, 0.88, 0.150, 0.068]);           
         
            dcy = str2double(get(h.edDcy,'String'));
            
            y = [0 ones(1,round(358*dcy)) 0 (-1)*ones(1,round(358*(1-dcy)))];
        end
        
        if get(h.bgWaveForm.btTri,'Value')
            
            set(h.edFre, 'Visible', 'on');
            set(h.txFre, 'Visible', 'on');
             
            set(h.edFre, 'Position', [0.050, 0.50, 0.550, 0.125]); 
            set(h.txFre, 'Position', [0.050, 0.65, 0.550, 0.068]);         
            
            set(h.edAmp, 'Position', [0.050, 0.73, 0.275, 0.125]);
            set(h.txAmp, 'Position', [0.050, 0.88, 0.275, 0.068]);     
            
            set(h.edOfS, 'Position', [0.325, 0.73, 0.275, 0.125]);  
            set(h.txOfS, 'Position', [0.325, 0.88, 0.275, 0.068]);
            
            y = [0:179 -179:0]./179;
        end
        
        if get(h.bgWaveForm.btSwp,'Value')
            
            set(h.edFIn, 'Visible', 'on');
            set(h.edFFi, 'Visible', 'on');
            set(h.txFIn, 'Visible', 'on');
            set(h.txFFi, 'Visible', 'on');
            
            set(h.edFIn, 'Position', [0.050, 0.50, 0.275, 0.125]); 
            set(h.txFIn, 'Position', [0.050, 0.65, 0.275, 0.068]);            
            
            set(h.edFFi, 'Position', [0.325, 0.50, 0.275, 0.125]);   
            set(h.txFFi, 'Position', [0.325, 0.65, 0.275, 0.068]);            
            
            t = (1:3600)./3600;
            fo = 1;
            f1 = 250;
            y = chirp(t,fo,1,f1,'logarithmic',270);
        end
        
        if get(h.bgWaveForm.btWNo,'Value')
%             set(h.edFIn, 'Visible', 'off');
%             set(h.txFIn, 'Visible', 'off');
%          
%             set(h.edFFi, 'Visible', 'off');
%             set(h.txFFi, 'Visible', 'off');   
            
            y = (rand(1,3600).*2)-1;
        end 
        
        if get(h.bgWaveForm.btBus,'Value')

        end    
        
        x = (1:length(y))*360/length(y);
        Amp = str2double(get(h.edAmp,'String'));
        OfS = str2double(get(h.edOfS,'String'));
        senial = (Amp*y)+OfS; % multiplico por la amplitud y le sumo el offset
        plot(h.hAxis.main,x,senial);
        h.hAxis.main.YLim  = [-1 1];
        h.hAxis.main.XLim  = [0 x(end)];
    end

    function fGenerate(~,~)
        fs = modelo.getFrecMuestre(); 
        IndexSalida = modelo.getSalidaIndex();
        t = 0:1/fs:10; 
                
        Amp = str2double(get(h.edAmp,'String'));
        OfS = str2double(get(h.edOfS,'String'));
        Dcy = round(str2double(get(h.edAmp,'String'))* 100) ;
        FIn = str2double(get(h.edFIn,'String'));
        FFi = str2double(get(h.edFFi,'String'));
        Fre = round(str2double(get(h.edFre,'String')));
        
        if get(h.bgWaveForm.btSin,'Value')
            Tono = Amp * MakeBeep(Fre,100,44100) + OfS;%(frecuencia, duracion, fs)
        end
        if get(h.bgWaveForm.btSqr,'Value')
            Tono = Amp * square(2*pi*Fre*t) + OfS;
                    
        end
        if get(h.bgWaveForm.btTri,'Value')
            Tono = Amp * sawtooth(2*pi*Fre*t) + OfS;
        end
        if get(h.bgWaveForm.btSwp,'Value')
            fo = FIn;
            f1 = FFi;
            Tono = Amp * chirp(t,fo,1,f1,'logarithmic',270) + OfS;
        end
        
        if get(h.bgWaveForm.btWNo,'Value')
            Tono = Amp * (rand(1,10*fs).*2)-1;
        end    
        
        if get(h.btBus,'Value')
            h.phandle_salida = PsychPortAudio('Open', IndexSalida, 1, 3, fs , 1); 
            PsychPortAudio('FillBuffer',h.phandle_salida,Tono);
            PsychPortAudio('Start',h.phandle_salida);
        else
            PsychPortAudio('Stop',h.phandle_salida);
            PsychPortAudio('Close',h.phandle_salida);
        end
    end
    function fAceptar(~,~)
        if get(h.btBus,'Value')
            PsychPortAudio('Stop',h.phandle_salida);
            PsychPortAudio('Close',h.phandle_salida);
        end
        close(h.fig)
    end
    function fCancelar(~,~)
        if get(h.btBus,'Value')
            PsychPortAudio('Stop',h.phandle_salida);
            PsychPortAudio('Close',h.phandle_salida);
        end
        close(h.fig)
    end

end