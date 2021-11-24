function varargout = samnsGUI(varargin)

% Display the GUI window

    %clc
    GUI = [];
    varargout{1} = initGUI(varargin{2});

% Display the initial GUI window
function varargout =  initGUI(controlador)
        %Inicializa Archivos y Path necesarios
                
GUI.BGC = controlador.mModelo.getBackgroundColor();
GUI.LC  = controlador.mModelo.getLetterColor();
GUI.axTop2 = 0;

%%
GUI.handles.controller = controlador; % Controlador cargado en vista
GUI.imagen.logo   = imread('img/LogoCINTRA1.png');
GUI.imagen.x      = imread('img/LogoCINTRA.png');
GUI.imagen.record = imread('img/recorder.png');
GUI.imagen.play   = imread('img/play.jpg');
GUI.imagen.stop   = imread('img/stop.png');

% Crea una figura nueva
GUI.hFig = findall(0, '-depth',1, 'type','figure', 'Name','Samri');
if isempty(GUI.hFig)
    GUI.hFig = figure(  'Name','SAMNS', 'NumberTitle','off', 'Visible','off',...
                        'Color',GUI.BGC, 'Position',[100,100,1500,900],...
                        'Toolbar','none', 'Menu', 'none');
else
    clf(GUI.hFig);
    hc=findall(gcf); delete(hc(2:end)); 
end

%%
set(GUI.hFig,'Visible','on') 
%% Agrego los uimenu FILE

GUI.menu(1) = uimenu(GUI.hFig,'Label','Archivo');                                                 %CREO EL MENU

GUI.subMenuArchivo(1) = uimenu(GUI.menu(1), 'Label','Abrir','Accelerator','O');                   %CREO LOS SUBMENU
GUI.subMenuArchivo(2) = uimenu(GUI.menu(1), 'Label','Guardar','Accelerator','S');                 %
GUI.subMenuArchivo(3) = uimenu(GUI.menu(1), 'Label','Guardar como...');                           %
GUI.subMenuArchivo(4) = uimenu(GUI.menu(1), 'Label','Importar señal de audio','Separator','on',...       % Crear GUI para importar
                                            'Accelerator','I','Callback',@fImportData);                                   % señales
GUI.subMenuArchivo(5) = uimenu(GUI.menu(1), 'Label','Exportar datos','Accelerator','E','Callback',@fExportData);                %
GUI.subMenuArchivo(6) = uimenu(GUI.menu(1), 'Label','Configuraciones...','Separator','on');       %
GUI.subMenuArchivo(7) = uimenu(GUI.menu(1), 'Label','Salir','Separator','on','Accelerator','Q');  %

% Agrego los uimenu CALIBRACION
GUI.menu(3) = uimenu(GUI.hFig,'Label','Calibracion'); 

GUI.subMenuAyuda(1) = uimenu(GUI.menu(3),'Label','Calibracion','Accelerator','R',...
                                         'Callback',@fcalibracion);          %Calibraciones manuales

% Agrego los uimenu Preferencias
GUI.menu(4) = uimenu(GUI.hFig,'Label','Configuracion'); 
GUI.subMenuConfig(1) = uimenu(GUI.menu(4),'Label','Preferencias','Accelerator','P','Callback',@fPreferencias);      %CREO LOS SUBMENU
GUI.subMenuConfig(2) = uimenu(GUI.menu(4),'Label','Generador de señales','Accelerator','G','Callback',@fGenerador);      %CREO LOS SUBMENU
GUI.subMenuConfig(3) = uimenu(GUI.menu(4),'Label','Automatización','Accelerator','A','Callback',@fAutomatizacion);      %CREO LOS SUBMENU

% Agrego los uimenu AYUDA
GUI.menu(5) = uimenu(GUI.hFig,'Label','Ayuda'); 
GUI.subMenuAyuda(1) = uimenu(GUI.menu(5),'Label','Buscar...','Accelerator','B');                  %CREO LOS SUBMENU
GUI.subMenuAyuda(2) = uimenu(GUI.menu(5),'Label','Manual','Accelerator','M');                        %

% Agrego los uimenu ACERCA DE...
GUI.menu(6) = uimenu(GUI.hFig,'Label','Acerca de...');        
GUI.subMenuAyuda(1) = uimenu(GUI.menu(6),'Label','SAMNS');                                         %CREO LOS SUBMENU
GUI.subMenuAyuda(2) = uimenu(GUI.menu(6),'Label','SAMDA');                                          %
           
      %% establezco los tabs

GUI.hTabGroup = uitabgroup(GUI.hFig); 
GUI.tab(1) = uitab(GUI.hTabGroup, 'title','Ventana 1 ','BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC);
GUI.tab(2) = uitab(GUI.hTabGroup, 'title','Ventana 2 ','BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Agrego grafico principal

GUI.axSenialTiem = axes;      
GUI.axSenialTiem.Parent = GUI.tab(1);
GUI.axSenialTiem.Position = [0.05 0.16 0.79 0.79];
GUI.axSenialTiem.YLim  = [-1 1];
GUI.axSenialTiem.XGrid = 'on';
GUI.axSenialTiem.YGrid = 'on';
GUI.axSenialTiem.XAxisLocation = 'origin';
GUI.axSenialTiem.Box   = 'on';
GUI.axSenialTiem.Color = GUI.BGC;
GUI.axSenialTiem.XLabel.String = 'Tiempo [s]';

GUI.axSenialTiem.YLabel.String = 'Amplitud Normalizada'; % Nivel [Lp](cuando esta calibrado), Nivel relativo(sin calibrar) 

%% -- Slider --

GUI.axeSlider.y = uicontrol('Parent', GUI.tab(1),'Style','slider','Value', 100, 'min', 0, 'max', 100, 'Units', 'Normalized',...
                        'Position',[0.002 0.16 0.0081 0.74],'SliderStep',[0.1 1000], 'Callback',@fModAxis);
GUI.zoom.yMas = uicontrol('Parent', GUI.tab(1),'Style','pushbutton', 'Units', 'Normalized',...
                        'Position',[0.002 0.93 0.0081 0.02],'String','+', 'Callback',@fModAxis); 
GUI.zoom.yMen = uicontrol('Parent', GUI.tab(1),'Style','pushbutton', 'Units', 'Normalized',...
                        'Position',[0.002 0.91 0.0081 0.02],'String','-', 'Callback',@fModAxis);                     

GUI.axeSlider.x = uicontrol('Parent', GUI.tab(1),'Style','slider','Value', 100, 'min', 0, 'max', 100, 'Units', 'Normalized',...
                        'Position',[0.080 0.14 0.74 0.0185],'SliderStep',[0.1 1000], 'Callback',@fModAxis);      
GUI.zoom.xMas = uicontrol('Parent', GUI.tab(1),'Style','pushbutton', 'Units', 'Normalized',...
                        'Position',[0.82 0.14 0.01 0.0185],'String','+', 'Callback',@fModAxis); 
GUI.zoom.xMen = uicontrol('Parent', GUI.tab(1),'Style','pushbutton', 'Units', 'Normalized',...
                        'Position',[0.83 0.14 0.01 0.0185],'String','-', 'Callback',@fModAxis);                     
%%
GUI.pmNivel.Nivel = uicontrol('Parent', GUI.tab(1),'Style','popupmenu','unit','normalized', 'Position', [0.1 0.83 0.08 0.08],...
                        'FontSize', 10,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'String',{'LFS (dB)','Lp (dB)'},'Visible','off','Callback',@fShowLP);
GUI.pmNivel.Espectro = uicontrol('Parent', GUI.tab(1),'Style','popupmenu','unit','normalized', 'Position', [0.1 0.83 0.08 0.08],...
                        'FontSize', 10,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'String',{'Lp (dB)','LFS (dB)','Arel'},'Visible','off','Callback',@fShowEsp );
% -- Botones --

GUI.btGrabar = uicontrol('Parent', GUI.tab(1),'Style','togglebutton','unit','normalized', 'Position', [0.76 0.03 0.08 0.08],...
                                'CData',GUI.imagen.record, 'FontSize', 10,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'Callback',@fToggleButton);
                            
GUI.btPlaySto= uicontrol('Parent', GUI.tab(1),'Style','togglebutton','unit','normalized', 'Position', [0.66 0.03 0.08 0.08],'Enable','off',...
                                'CData',GUI.imagen.play, 'FontSize', 10,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'Callback',@fStartStopButton);
                           
GUI.txTiempo = uicontrol('Parent', GUI.tab(1),'Style','text', 'unit','normalized','Position', [0.03 0.045 0.07 0.05],...
                                'String','0.000','FontSize', 20,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC);
               uicontrol('Parent', GUI.tab(1),'Style','text', 'unit','normalized','Position', [0.1 0.045 0.04 0.05],...
                                'String',' Seg','FontSize', 20,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC);
                
GUI.btExport = uicontrol('Parent', GUI.tab(2),'Style','pushbutton','unit','normalized', 'Position', [0.6 0.2 0.2 0.1],...
                                 'String','Exportar datos','FontSize', 12,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'Callback',@fExportData);
                            
GUI.DomTiemp.btOver   = uicontrol('Parent', GUI.tab(1),'Style','pushbutton', 'unit','normalized','Position', [0.73 0.89 0.1 0.05],...
                                 'String','OVER','FontSize', 25,'BackgroundColor','k','ForegroundColor',GUI.BGC,'Callback',@fOver);

                            %-- Tipo de grafico --
                            
GUI.pnlTipoGraf.main = uibuttongroup(GUI.tab(1),'Position',[0.8535 0.819 0.105 0.15],'Title','Tipo de grafico','BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC);                            
                            
GUI.pnlTipoGraf.tbTiemp = uicontrol('Parent', GUI.pnlTipoGraf.main,'Style','togglebutton','unit','normalized', 'Position', [0.1 0.7 0.8 0.3],...
                                'String','Tiempo', 'FontSize', 12,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'FontWeight','bold','Callback',@fCambioAx);
GUI.pnlTipoGraf.tbFrecu = uicontrol('Parent', GUI.pnlTipoGraf.main,'Style','togglebutton','unit','normalized', 'Position', [0.1 0.4 0.8 0.3],...
                                'String','Frecuencia', 'FontSize', 12,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'FontWeight','bold','Callback',@fCambioAx);
GUI.pnlTipoGraf.tbLP    = uicontrol('Parent', GUI.pnlTipoGraf.main,'Style','togglebutton','unit','normalized', 'Position', [0.1 0.1 0.8 0.3],...
                                'String','Nivel', 'FontSize', 12,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'FontWeight','bold','Callback',@fCambioAx);   
                            
                            %-- Memoria RAM
GUI.pnlTipoGraf.panelMem = uipanel(GUI.tab(1),'Position',[0.9635 0.819 0.03 0.15],'Title','RAM','BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC);                           
GUI.pnlTipoGraf.txRam    = uicontrol('Parent', GUI.pnlTipoGraf.panelMem,'Style', 'text','unit','normalized', 'Position', [0.05 0.05 0.9 0.01],...
                                'BackgroundColor',[0 0.4470 0.7410]);                       
                            
                            %-- Filtros --
GUI.DomTiemp.pnlFiltros = uibuttongroup(GUI.tab(1),'Position',[0.8535 0.76 0.14 0.06],'Title','Filtros Ponderados','BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC);

GUI.DomTiemp.pnlFilt.rbA = uicontrol('Parent', GUI.DomTiemp.pnlFiltros,'Style','radiobutton','unit','normalized', 'Position', [0.7 0.2 0.2 0.5],...
                                'String','A', 'FontSize', 10,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'Callback',@fShowAudioData);
GUI.DomTiemp.pnlFilt.rbC = uicontrol('Parent', GUI.DomTiemp.pnlFiltros,'Style','radiobutton','unit','normalized', 'Position', [0.4 0.2 0.2 0.5],...
                                'String','C', 'FontSize', 10,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'Callback',@fShowAudioData);
GUI.DomTiemp.pnlFilt.rbZ = uicontrol('Parent', GUI.DomTiemp.pnlFiltros,'Style','radiobutton','unit','normalized', 'Position', [0.1 0.2 0.2 0.5],...
                                'String','Z', 'FontSize', 10,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'Callback',@fShowAudioData);
                            
%% Panel de niveles estadisticos                            
                            
GUI.pnlNivelesEst.main = uipanel(GUI.tab(1),'Position',[0.8535 0.57 0.14 0.19],'Title','Niveles Estadisticos','BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC);

GUI.pnlNivelesEst.cbLZeq = uicontrol('Parent', GUI.pnlNivelesEst.main,'Style','checkbox','unit','normalized', 'Position', [0.05 0.8 0.22 0.09],...
                                'String','LZeq', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'Enable','off','Callback',@fShowLP);
GUI.pnlNivelesEst.cbLZ01 = uicontrol('Parent', GUI.pnlNivelesEst.main,'Style','checkbox','unit','normalized', 'Position', [0.05 0.65 0.22 0.09],...
                                'String','LZ01', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'Enable','off','Callback',@fShowLP);
GUI.pnlNivelesEst.cbLZ10 = uicontrol('Parent', GUI.pnlNivelesEst.main,'Style','checkbox','unit','normalized', 'Position', [0.05 0.5 0.22 0.09],...
                                'String','LZ10', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'Enable','off','Callback',@fShowLP);                            
GUI.pnlNivelesEst.cbLZ50 = uicontrol('Parent', GUI.pnlNivelesEst.main,'Style','checkbox','unit','normalized', 'Position', [0.05 0.35 0.22 0.09],...
                                'String','LZ50', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'Enable','off','Callback',@fShowLP);
GUI.pnlNivelesEst.cbLZ90 = uicontrol('Parent', GUI.pnlNivelesEst.main,'Style','checkbox','unit','normalized', 'Position', [0.05 0.2 0.22 0.09],...
                                'String','LZ90', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'Enable','off','Callback',@fShowLP);
GUI.pnlNivelesEst.cbLZ99 = uicontrol('Parent', GUI.pnlNivelesEst.main,'Style','checkbox','unit','normalized', 'Position', [0.05 0.05 0.22 0.09],...
                                'String','LZ99', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'Enable','off','Callback',@fShowLP);                              
GUI.pnlNivelesEst.cbLCeq = uicontrol('Parent', GUI.pnlNivelesEst.main,'Style','checkbox','unit','normalized', 'Position', [0.35 0.8 0.22 0.09],...
                                'String','LCeq', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'Enable','off','Callback',@fShowLP);
GUI.pnlNivelesEst.cbLC01 = uicontrol('Parent', GUI.pnlNivelesEst.main,'Style','checkbox','unit','normalized', 'Position', [0.35 0.65 0.22 0.09],...
                                'String','LC01', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'Enable','off','Callback',@fShowLP);
GUI.pnlNivelesEst.cbLC10 = uicontrol('Parent', GUI.pnlNivelesEst.main,'Style','checkbox','unit','normalized', 'Position', [0.35 0.5 0.22 0.09],...
                                'String','LC10', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'Enable','off','Callback',@fShowLP);                            
GUI.pnlNivelesEst.cbLC50 = uicontrol('Parent', GUI.pnlNivelesEst.main,'Style','checkbox','unit','normalized', 'Position', [0.35 0.35 0.22 0.09],...
                                'String','LC50', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'Enable','off','Callback',@fShowLP);
GUI.pnlNivelesEst.cbLC90 = uicontrol('Parent', GUI.pnlNivelesEst.main,'Style','checkbox','unit','normalized', 'Position', [0.35 0.2 0.22 0.09],...
                                'String','LC90', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'Enable','off','Callback',@fShowLP);
GUI.pnlNivelesEst.cbLC99 = uicontrol('Parent', GUI.pnlNivelesEst.main,'Style','checkbox','unit','normalized', 'Position', [0.35 0.05 0.22 0.09],...
                                'String','LC99', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'Enable','off','Callback',@fShowLP);                                                         
GUI.pnlNivelesEst.cbLAeq = uicontrol('Parent', GUI.pnlNivelesEst.main,'Style','checkbox','unit','normalized', 'Position', [0.65 0.8 0.22 0.09],...
                                'String','LAeq', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'Enable','off','Callback',@fShowLP);
GUI.pnlNivelesEst.cbLA01 = uicontrol('Parent', GUI.pnlNivelesEst.main,'Style','checkbox','unit','normalized', 'Position', [0.65 0.65 0.22 0.09],...
                                'String','LA01', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'Enable','off','Callback',@fShowLP);
GUI.pnlNivelesEst.cbLA10 = uicontrol('Parent', GUI.pnlNivelesEst.main,'Style','checkbox','unit','normalized', 'Position', [0.65 0.5 0.22 0.09],...
                                'String','LA10', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'Enable','off','Callback',@fShowLP);                            
GUI.pnlNivelesEst.cbLA50 = uicontrol('Parent', GUI.pnlNivelesEst.main,'Style','checkbox','unit','normalized', 'Position', [0.65 0.35 0.22 0.09],...
                                'String','LA50', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'Enable','off','Callback',@fShowLP);
GUI.pnlNivelesEst.cbLA90 = uicontrol('Parent', GUI.pnlNivelesEst.main,'Style','checkbox','unit','normalized', 'Position', [0.65 0.2 0.22 0.09],...
                                'String','LA90', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'Enable','off','Callback',@fShowLP);
GUI.pnlNivelesEst.cbLA99 = uicontrol('Parent', GUI.pnlNivelesEst.main,'Style','checkbox','unit','normalized', 'Position', [0.65 0.05 0.22 0.09],...
                                'String','LA99', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'Enable','off','Callback',@fShowLP);                             
                            
GUI.pnlNivelesEst.btClear = uicontrol('Parent', GUI.pnlNivelesEst.main,'Style', 'pushbutton','unit','normalized', 'Position', [0.85 0.9 0.14 0.1],...
                                'String','Clear', 'FontSize', 7,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'Callback',@fClearNE);                            
                            
                            
%% -- Panel de tiempo de integracion --

GUI.pnlTiempInt.main = uipanel(GUI.tab(1),'Position',[0.8535 0.3 0.14 0.27],'Title','Niveles de integracion','BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC); % uipanel porque puedo mostrar las señales que quiera

                            % -- titulo de tiempo de integracion pico
GUI.pnlTiempInt.txPico = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'text','unit','normalized', 'Position', [0.05 0.85 0.2 0.1],...
                                'String','Pico', 'FontSize', 12,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'FontWeight','bold', 'Enable', 'off');
                            % -- radiobutton de tiempo de integracion pico
GUI.pnlTiempInt.cbPicoA = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'checkbox','unit','normalized', 'Position', [0.3 0.85 0.2 0.1],...
                                'String','A', 'FontSize', 9,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'Enable', 'off','Callback',@fShowLP);                            
GUI.pnlTiempInt.cbPicoC = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'checkbox','unit','normalized', 'Position', [0.5 0.85 0.2 0.1],...
                                'String','C', 'FontSize', 9,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'Enable', 'off','Callback',@fShowLP);                            
GUI.pnlTiempInt.cbPicoZ = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'checkbox','unit','normalized', 'Position', [0.7 0.85 0.2 0.1],...
                                'String','Z', 'FontSize', 9,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'Enable', 'off','Callback',@fShowLP);                            
                                                                                
                            % -- titulo de tiempo de integracion
                            % Instantaneo
GUI.pnlTiempInt.txInst = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'text','unit','normalized', 'Position', [0.05 0.64 0.2 0.1],...
                                'String','Inst', 'FontSize', 12,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'FontWeight','bold', 'Enable', 'off');                      
                            % -- radiobutton de tiempo de integracion inst
GUI.pnlTiempInt.cbInstA = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'checkbox','unit','normalized', 'Position', [0.28 0.73 0.14 0.07],...
                                'String','A', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'Enable', 'off','Callback',@fShowLP);                            
GUI.pnlTiempInt.cbInstC = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'checkbox','unit','normalized', 'Position', [0.28 0.66 0.14 0.07],...
                                'String','C', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'Enable', 'off','Callback',@fShowLP);                            
GUI.pnlTiempInt.cbInstZ = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'checkbox','unit','normalized', 'Position', [0.28 0.59 0.14 0.07],...
                                'String','Z', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'Enable', 'off','Callback',@fShowLP);  

GUI.pnlTiempInt.cbLAImin = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'checkbox','unit','normalized', 'Position', [0.44 0.73 0.27 0.07],...
                                'String','LAImin', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'Enable', 'off','Callback',@fShowLP);                            
GUI.pnlTiempInt.cbLCImin = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'checkbox','unit','normalized', 'Position', [0.44 0.66 0.27 0.07],...
                                'String','LCImin', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'Enable', 'off','Callback',@fShowLP);                            
GUI.pnlTiempInt.cbLZImin = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'checkbox','unit','normalized', 'Position', [0.44 0.59 0.27 0.07],...
                                'String','LZImin', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'Enable', 'off','Callback',@fShowLP);                            

GUI.pnlTiempInt.cbLAImax = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'checkbox','unit','normalized', 'Position', [0.7 0.73 0.27 0.07],...
                                'String','LAImax', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'Enable', 'off','Callback',@fShowLP);                            
GUI.pnlTiempInt.cbLCImax = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'checkbox','unit','normalized', 'Position', [0.7 0.66 0.27 0.07],...
                                'String','LCImax', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'Enable', 'off','Callback',@fShowLP);                            
GUI.pnlTiempInt.cbLZImax = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'checkbox','unit','normalized', 'Position', [0.7 0.59 0.27 0.07],...
                                'String','LZImax', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'Enable', 'off','Callback',@fShowLP); 
                            
                            % -- titulo de tiempo de integracion
                            % fast
GUI.pnlTiempInt.txFast = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'text','unit','normalized', 'Position', [0.05 0.35 0.2 0.1],...
                                'String','Fast', 'FontSize', 12,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'FontWeight','bold', 'Enable', 'off');                      
                            % -- radiobutton de tiempo de integracion fast
GUI.pnlTiempInt.cbFastA = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'checkbox','unit','normalized', 'Position', [0.28 0.45 0.2 0.07],...
                                'String','A', 'FontSize', 9,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'Enable', 'off','Callback',@fShowLP);                            
GUI.pnlTiempInt.cbFastC = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'checkbox','unit','normalized', 'Position', [0.28 0.38 0.2 0.07],...
                                'String','C', 'FontSize', 9,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'Enable', 'off','Callback',@fShowLP);                            
GUI.pnlTiempInt.cbFastZ = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'checkbox','unit','normalized', 'Position', [0.28 0.31 0.2 0.07],...
                                'String','Z', 'FontSize', 9,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'Enable', 'off','Callback',@fShowLP);
                            
GUI.pnlTiempInt.cbLAFmin = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'checkbox','unit','normalized', 'Position', [0.44 0.45 0.27 0.07],...
                                'String','LAFmin', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'Enable', 'off','Callback',@fShowLP);                            
GUI.pnlTiempInt.cbLCFmin = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'checkbox','unit','normalized', 'Position', [0.44 0.38 0.27 0.07],...
                                'String','LCFmin', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'Enable', 'off','Callback',@fShowLP);                            
GUI.pnlTiempInt.cbLZFmin = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'checkbox','unit','normalized', 'Position', [0.44 0.31 0.27 0.07],...
                                'String','LZFmin', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'Enable', 'off','Callback',@fShowLP); 
                            
GUI.pnlTiempInt.cbLAFmax = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'checkbox','unit','normalized', 'Position', [0.7 0.45 0.27 0.07],...
                                'String','LAFmax', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'Enable', 'off','Callback',@fShowLP);                            
GUI.pnlTiempInt.cbLCFmax = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'checkbox','unit','normalized', 'Position', [0.7 0.38 0.27 0.07],...
                                'String','LCFmax', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'Enable', 'off','Callback',@fShowLP);                            
GUI.pnlTiempInt.cbLZFmax = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'checkbox','unit','normalized', 'Position', [0.7 0.31 0.27 0.07],...
                                'String','LZFmax', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'Enable', 'off','Callback',@fShowLP);                             
                                                          
                            % -- titulo de tiempo de integracion
                            % slow
GUI.pnlTiempInt.txSlow = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'text','unit','normalized', 'Position', [0.05 0.1 0.2 0.1],...
                                'String','Slow', 'FontSize', 12,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'FontWeight','bold', 'Enable', 'off');                      
                            % -- radiobutton de tiempo de integracion fast
GUI.pnlTiempInt.cbSlowA = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'checkbox','unit','normalized', 'Position', [0.28 0.17 0.2 0.07],...
                                'String','A', 'FontSize', 9,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'Enable', 'off','Callback',@fShowLP);                            
GUI.pnlTiempInt.cbSlowC = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'checkbox','unit','normalized', 'Position', [0.28 0.10 0.2 0.07],...
                                'String','C', 'FontSize', 9,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'Enable', 'off','Callback',@fShowLP);                            
GUI.pnlTiempInt.cbSlowZ = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'checkbox','unit','normalized', 'Position', [0.28 0.03 0.2 0.07],...
                                'String','Z', 'FontSize', 9,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'Enable', 'off','Callback',@fShowLP);
                            
GUI.pnlTiempInt.cbLASmin = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'checkbox','unit','normalized', 'Position', [0.44 0.17 0.27 0.07],...
                                'String','LASmin', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'Enable', 'off','Callback',@fShowLP);                            
GUI.pnlTiempInt.cbLCSmin = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'checkbox','unit','normalized', 'Position', [0.44 0.10 0.27 0.07],...
                                'String','LCSmin', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'Enable', 'off','Callback',@fShowLP);                            
GUI.pnlTiempInt.cbLZSmin = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'checkbox','unit','normalized', 'Position', [0.44 0.03 0.27 0.07],...
                                'String','LZSmin', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'Enable', 'off','Callback',@fShowLP);  
                            
GUI.pnlTiempInt.cbLASmax = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'checkbox','unit','normalized', 'Position', [0.7 0.17 0.27 0.07],...
                                'String','LASmax', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'Enable', 'off','Callback',@fShowLP);                            
GUI.pnlTiempInt.cbLCSmax = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'checkbox','unit','normalized', 'Position', [0.7 0.10 0.27 0.07],...
                                'String','LCSmax', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'Enable', 'off','Callback',@fShowLP);                            
GUI.pnlTiempInt.cbLZSmax = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'checkbox','unit','normalized', 'Position', [0.7 0.03 0.27 0.07],...
                                'String','LZSmax', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'Enable', 'off','Callback',@fShowLP);                             
                            
GUI.pnlTiempInt.btClear = uicontrol('Parent', GUI.pnlTiempInt.main,'Style', 'pushbutton','unit','normalized', 'Position', [0.85 0.9 0.14 0.11],...
                                'String','Clear', 'FontSize', 7,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'Callback',@fClearTI);                             
                            %% En ventana 2 tengo que agregar un panel que
                            %muestre todos los valores actualizados de los
                            %LP
GUI.pnlTiempInt.main2 = uipanel(GUI.tab(2),'Position',[0.02 0.5 0.3 0.48],'Title','Niveles instantaneos (dB)','BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'FontSize', 15); % uipanel porque puedo mostrar las señales que quiera
    
%Creo el menu de columnas
uicontrol('Parent', GUI.pnlTiempInt.main2,'Style', 'text','unit','normalized', 'Position', [0.1 0.8 0.15 0.07],...
                                'String','LApk', 'FontSize', 12,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'FontWeight','bold');                            
uicontrol('Parent', GUI.pnlTiempInt.main2,'Style', 'text','unit','normalized', 'Position', [0.3 0.8 0.15 0.07],...
                                'String','LAI', 'FontSize', 12,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'FontWeight','bold');                            
uicontrol('Parent', GUI.pnlTiempInt.main2,'Style', 'text','unit','normalized', 'Position', [0.5 0.8 0.15 0.07],...
                                'String','LAF', 'FontSize', 12,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'FontWeight','bold');
uicontrol('Parent', GUI.pnlTiempInt.main2,'Style', 'text','unit','normalized', 'Position', [0.7 0.8 0.15 0.07],...
                                'String','LAS', 'FontSize', 12,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'FontWeight','bold'); 
                            
                            % -- texto de tiempo de integracion filtro
                            % ponderado A
                            
GUI.pnlTiempInt.txPicoA = uicontrol('Parent', GUI.pnlTiempInt.main2,'Style', 'text','unit','normalized', 'Position', [0.1 0.7 0.16 0.07],...
                                'String','-Inf', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC); 
GUI.pnlTiempInt.txInstA = uicontrol('Parent', GUI.pnlTiempInt.main2,'Style', 'text','unit','normalized', 'Position', [0.3 0.7 0.16 0.07],...
                                'String','-Inf', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC);                             
GUI.pnlTiempInt.txFastA = uicontrol('Parent', GUI.pnlTiempInt.main2,'Style', 'text','unit','normalized', 'Position', [0.5 0.7 0.16 0.07],...
                                'String','-Inf', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC); 
GUI.pnlTiempInt.txSlowA = uicontrol('Parent', GUI.pnlTiempInt.main2,'Style', 'text','unit','normalized', 'Position', [0.7 0.7 0.16 0.07],...
                                'String','-Inf', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC); 

                            
                            
                            
%Creo el menu de columnas
uicontrol('Parent', GUI.pnlTiempInt.main2,'Style', 'text','unit','normalized', 'Position', [0.1 0.5 0.15 0.07],...
                                'String','LCpk', 'FontSize', 12,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'FontWeight','bold');                            
uicontrol('Parent', GUI.pnlTiempInt.main2,'Style', 'text','unit','normalized', 'Position', [0.3 0.5 0.15 0.07],...
                                'String','LCI', 'FontSize', 12,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'FontWeight','bold');                            
uicontrol('Parent', GUI.pnlTiempInt.main2,'Style', 'text','unit','normalized', 'Position', [0.5 0.5 0.15 0.07],...
                                'String','LCF', 'FontSize', 12,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'FontWeight','bold');
uicontrol('Parent', GUI.pnlTiempInt.main2,'Style', 'text','unit','normalized', 'Position', [0.7 0.5 0.15 0.07],...
                                'String','LCS', 'FontSize', 12,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'FontWeight','bold');                             
                            % -- texto de tiempo de integracion inst filtro
                            % ponderado C
                            
GUI.pnlTiempInt.txPicoC = uicontrol('Parent', GUI.pnlTiempInt.main2,'Style', 'text','unit','normalized', 'Position', [0.1 0.4 0.16 0.07],...
                                'String','-Inf', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC);
GUI.pnlTiempInt.txInstC = uicontrol('Parent', GUI.pnlTiempInt.main2,'Style', 'text','unit','normalized', 'Position', [0.3 0.4 0.16 0.07],...
                                'String','-Inf', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC); 
GUI.pnlTiempInt.txFastC = uicontrol('Parent', GUI.pnlTiempInt.main2,'Style', 'text','unit','normalized', 'Position', [0.5 0.4 0.16 0.07],...
                                'String','-Inf', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC); 
GUI.pnlTiempInt.txSlowC = uicontrol('Parent', GUI.pnlTiempInt.main2,'Style', 'text','unit','normalized', 'Position', [0.7 0.4 0.16 0.07],...
                                'String','-Inf', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC); 
                            

                            
%Creo el menu de columnas
uicontrol('Parent', GUI.pnlTiempInt.main2,'Style', 'text','unit','normalized', 'Position', [0.1 0.2 0.15 0.07],...
                                'String','LZpk', 'FontSize', 12,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'FontWeight','bold');                            
uicontrol('Parent', GUI.pnlTiempInt.main2,'Style', 'text','unit','normalized', 'Position', [0.3 0.2 0.15 0.07],...
                                'String','LZI', 'FontSize', 12,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'FontWeight','bold');                            
uicontrol('Parent', GUI.pnlTiempInt.main2,'Style', 'text','unit','normalized', 'Position', [0.5 0.2 0.15 0.07],...
                                'String','LZF', 'FontSize', 12,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'FontWeight','bold');
uicontrol('Parent', GUI.pnlTiempInt.main2,'Style', 'text','unit','normalized', 'Position', [0.7 0.2 0.15 0.07],...
                                'String','LZS', 'FontSize', 12,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC,'FontWeight','bold');                             
                            % -- texto de tiempo de integracion inst filtro
                            % ponderado Z
GUI.pnlTiempInt.txPicoZ = uicontrol('Parent', GUI.pnlTiempInt.main2,'Style', 'text','unit','normalized', 'Position', [0.1 0.1 0.16 0.07],...
                                'String','-Inf', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC);                   
GUI.pnlTiempInt.txInstZ = uicontrol('Parent', GUI.pnlTiempInt.main2,'Style', 'text','unit','normalized', 'Position', [0.3 0.1 0.16 0.07],...
                                'String','-Inf', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC);                           
GUI.pnlTiempInt.txFastZ = uicontrol('Parent', GUI.pnlTiempInt.main2,'Style', 'text','unit','normalized', 'Position', [0.5 0.1 0.16 0.07],...
                                'String','-Inf', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC);                         
GUI.pnlTiempInt.txSlowZ = uicontrol('Parent', GUI.pnlTiempInt.main2,'Style', 'text','unit','normalized', 'Position', [0.7 0.1 0.16 0.07],...
                                'String','-Inf', 'FontSize', 8,'BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC);  
            
                            
                            %valor de tiempos estadisticos
nEstadisticos = uipanel(GUI.tab(2),'Position',[0.34 0.5 0.65 0.48],'Title','Niveles estadisticos (dB)','BackgroundColor',GUI.BGC,'ForegroundColor',GUI.LC, 'FontSize', 15); % uipanel porque puedo mostrar las señales que quiera

GUI.pnlNivelesEst.pnlZ = nivelesEstadisticosPonderadosZ(nEstadisticos,GUI.BGC,GUI.LC);

GUI.pnlNivelesEst.pnlC = nivelesEstadisticosPonderadosC(nEstadisticos,GUI.BGC,GUI.LC);

GUI.pnlNivelesEst.pnlA = nivelesEstadisticosPonderadosA(nEstadisticos,GUI.BGC,GUI.LC);
                           
GUI.config.axImagen1          = axes;      
GUI.config.axImagen1.Parent   = GUI.tab(1);
GUI.config.axImagen1.Position = [0.8535 0.10 0.14 0.19];
imshow(GUI.imagen.logo);

GUI.config.axImagen2          = axes;      
GUI.config.axImagen2.Parent   = GUI.tab(1);
GUI.config.axImagen2.Position = [0.86 0.015 0.13 0.1];
imshow(GUI.imagen.x);

GUI.config.axImagen3          = axes;      
GUI.config.axImagen3.Parent   = GUI.tab(2);
GUI.config.axImagen3.Position = [0.8535 0.10 0.14 0.19];
imshow(GUI.imagen.logo);

GUI.config.axImagen4          = axes;      
GUI.config.axImagen4.Parent   = GUI.tab(2);
GUI.config.axImagen4.Position = [0.86 0.015 0.13 0.1];
imshow(GUI.imagen.x);

%% Actualizacion de la GUI
    if nargout
            [varargout{1}] = GUI;
    end   
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                %FUNCIONES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function fPreferencias(~,~)
         GUI.handles.controller.fsamnsPreferenciaGUI;
    end
    function fToggleButton(~,~)
        set(GUI.btPlaySto,'Enable','on')
        GUI.handles.controller.fGrabacion(-1);
    end
    function fStartStopButton(~,~)
        if ~get(GUI.btGrabar,'Value')
            GUI.handles.controller.fStartStopButton();
        end
    end
    function fCambioAx(~,~)
        if get(GUI.pnlTipoGraf.tbTiemp,'Value') 
            GUI.axSenialTiem.YLim  = [-1 1];
            GUI.axSenialTiem.XGrid = 'on';
            GUI.axSenialTiem.XScale = 'lin';
            GUI.axSenialTiem.XLim  = [0 1];
            GUI.axSenialTiem.XAxisLocation = 'origin';
            GUI.axSenialTiem.YGrid = 'on';
            GUI.axSenialTiem.Box   = 'on';
            GUI.axSenialTiem.XLabel.String = 'Tiempo [s]';
            GUI.axSenialTiem.YLabel.String = 'Amplitud normalizada';
            
            set(GUI.pmNivel.Nivel,'Visible','off');
            set(GUI.pmNivel.Espectro,'Visible','off');
            
            set(GUI.DomTiemp.pnlFilt.rbA, 'Enable', 'on' )
            set(GUI.DomTiemp.pnlFilt.rbC, 'Enable', 'on' )
            set(GUI.DomTiemp.pnlFilt.rbZ, 'Enable', 'on' )
            
            set(GUI.pnlTiempInt.txPico, 'Enable', 'off' )
            set(GUI.pnlTiempInt.cbPicoA,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbPicoC,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbPicoZ,'Enable', 'off' )
            
            set(GUI.pnlTiempInt.txInst, 'Enable', 'off' )
            set(GUI.pnlTiempInt.cbInstA,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbInstC,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbInstZ,'Enable', 'off' )
            
            set(GUI.pnlTiempInt.txFast, 'Enable', 'off' )
            set(GUI.pnlTiempInt.cbFastA,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbFastC,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbFastZ,'Enable', 'off' )
            
            set(GUI.pnlTiempInt.txSlow, 'Enable', 'off' )
            set(GUI.pnlTiempInt.cbSlowA,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbSlowC,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbSlowZ,'Enable', 'off' ) 
                        %--
            set(GUI.pnlTiempInt.cbLASmin,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbLCSmin,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbLZSmin,'Enable', 'off' )

            set(GUI.pnlTiempInt.cbLASmax,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbLCSmax,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbLZSmax,'Enable', 'off' )
            
            set(GUI.pnlTiempInt.cbLAFmin,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbLCFmin,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbLZFmin,'Enable', 'off' )

            set(GUI.pnlTiempInt.cbLAFmax,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbLCFmax,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbLZFmax,'Enable', 'off' )  
            
            set(GUI.pnlTiempInt.cbLAImin,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbLCImin,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbLZImin,'Enable', 'off' )

            set(GUI.pnlTiempInt.cbLAImax,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbLCImax,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbLZImax,'Enable', 'off' )
            
            set(GUI.pnlNivelesEst.cbLZeq, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLZ01, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLZ10, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLZ50, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLZ90, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLZ99, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLCeq, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLC01, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLC10, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLC50, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLC90, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLC99, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLAeq, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLA01, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLA10, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLA50, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLA90, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLA99, 'Enable', 'off')
            fShowAudioData
        end
        if get(GUI.pnlTipoGraf.tbFrecu,'Value') 
            
            set(GUI.pmNivel.Nivel,'Visible','off');
            set(GUI.pmNivel.Espectro,'Visible','on');
            
            
            GUI.axSenialTiem.YLim  = [0 1];
            GUI.axSenialTiem.XScale = 'log';
            GUI.axSenialTiem.XLim  = [1 22000];
            GUI.axSenialTiem.XGrid = 'on';
            GUI.axSenialTiem.XAxisLocation = 'top';
            GUI.axSenialTiem.YGrid = 'on';
            GUI.axSenialTiem.Box   = 'on';
            GUI.axSenialTiem.XLabel.String = '';
            
           if get(GUI.pmNivel.Espectro,'Value') == 1
                GUI.axSenialTiem.YLabel.String = 'Nivel de presión sonora (dB)';
            end
            
            if get(GUI.pmNivel.Espectro,'Value') == 2
                GUI.axSenialTiem.YLabel.String = 'Nivel fondo de escala (dB)';
            end
            if get(GUI.pmNivel.Espectro,'Value') == 3
                GUI.axSenialTiem.YLabel.String = 'Amplitud relativa instantanea';
            end
            
            set(GUI.DomTiemp.pnlFilt.rbA, 'Enable', 'on' )
            set(GUI.DomTiemp.pnlFilt.rbC, 'Enable', 'on' )
            set(GUI.DomTiemp.pnlFilt.rbZ, 'Enable', 'on' )
            
            set(GUI.pnlTiempInt.txPico, 'Enable', 'off' )
            set(GUI.pnlTiempInt.cbPicoA,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbPicoC,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbPicoZ,'Enable', 'off' )
            
            set(GUI.pnlTiempInt.txInst, 'Enable', 'off' )
            set(GUI.pnlTiempInt.cbInstA,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbInstC,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbInstZ,'Enable', 'off' )

            set(GUI.pnlTiempInt.txFast, 'Enable', 'off' )
            set(GUI.pnlTiempInt.cbFastA,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbFastC,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbFastZ,'Enable', 'off' )
            
            set(GUI.pnlTiempInt.txSlow, 'Enable', 'off' )
            set(GUI.pnlTiempInt.cbSlowA,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbSlowC,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbSlowZ,'Enable', 'off' )
            
            %--
            set(GUI.pnlTiempInt.cbLASmin,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbLCSmin,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbLZSmin,'Enable', 'off' )

            set(GUI.pnlTiempInt.cbLASmax,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbLCSmax,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbLZSmax,'Enable', 'off' )
            
            set(GUI.pnlTiempInt.cbLAFmin,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbLCFmin,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbLZFmin,'Enable', 'off' )

            set(GUI.pnlTiempInt.cbLAFmax,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbLCFmax,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbLZFmax,'Enable', 'off' )  
            
            set(GUI.pnlTiempInt.cbLAImin,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbLCImin,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbLZImin,'Enable', 'off' )

            set(GUI.pnlTiempInt.cbLAImax,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbLCImax,'Enable', 'off' )
            set(GUI.pnlTiempInt.cbLZImax,'Enable', 'off' )
            
            set(GUI.pnlNivelesEst.cbLZeq, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLZ01, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLZ10, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLZ50, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLZ90, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLZ99, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLCeq, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLC01, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLC10, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLC50, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLC90, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLC99, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLAeq, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLA01, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLA10, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLA50, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLA90, 'Enable', 'off')
            set(GUI.pnlNivelesEst.cbLA99, 'Enable', 'off')
        end
        if get(GUI.pnlTipoGraf.tbLP,'Value') 
            set(GUI.pmNivel.Nivel,'Visible','on');
            set(GUI.pmNivel.Espectro,'Visible','off');
            
            if get(GUI.pmNivel.Nivel,'Value') == 1
                GUI.axSenialTiem.YLabel.String = 'Nivel fondo de escala(dB)';
            end
            
            if get(GUI.pmNivel.Nivel,'Value') == 2
                GUI.axSenialTiem.YLabel.String = 'Nivel de presión sonora (dB)';
            end
                        
            set(GUI.DomTiemp.pnlFilt.rbA, 'Enable', 'off' )
            set(GUI.DomTiemp.pnlFilt.rbC, 'Enable', 'off' )
            set(GUI.DomTiemp.pnlFilt.rbZ, 'Enable', 'off' )
            
            set(GUI.pnlTiempInt.txPico, 'Enable', 'on' )
            set(GUI.pnlTiempInt.cbPicoA,'Enable', 'on' )
            set(GUI.pnlTiempInt.cbPicoC,'Enable', 'on' )
            set(GUI.pnlTiempInt.cbPicoZ,'Enable', 'on' )

            set(GUI.pnlTiempInt.txInst, 'Enable', 'on' )
            set(GUI.pnlTiempInt.cbInstA,'Enable', 'on' )
            set(GUI.pnlTiempInt.cbInstC,'Enable', 'on' )
            set(GUI.pnlTiempInt.cbInstZ,'Enable', 'on' )
            
            set(GUI.pnlTiempInt.txFast, 'Enable', 'on' )
            set(GUI.pnlTiempInt.cbFastA,'Enable', 'on' )
            set(GUI.pnlTiempInt.cbFastC,'Enable', 'on' )
            set(GUI.pnlTiempInt.cbFastZ,'Enable', 'on' )

            set(GUI.pnlTiempInt.txSlow, 'Enable', 'on' )
            set(GUI.pnlTiempInt.cbSlowA,'Enable', 'on' )
            set(GUI.pnlTiempInt.cbSlowC,'Enable', 'on' )
            set(GUI.pnlTiempInt.cbSlowZ,'Enable', 'on' )    
            %--
            set(GUI.pnlTiempInt.cbLASmin,'Enable', 'on' )
            set(GUI.pnlTiempInt.cbLCSmin,'Enable', 'on' )
            set(GUI.pnlTiempInt.cbLZSmin,'Enable', 'on' )

            set(GUI.pnlTiempInt.cbLASmax,'Enable', 'on' )
            set(GUI.pnlTiempInt.cbLCSmax,'Enable', 'on' )
            set(GUI.pnlTiempInt.cbLZSmax,'Enable', 'on' )
            
            set(GUI.pnlTiempInt.cbLAFmin,'Enable', 'on' )
            set(GUI.pnlTiempInt.cbLCFmin,'Enable', 'on' )
            set(GUI.pnlTiempInt.cbLZFmin,'Enable', 'on' )

            set(GUI.pnlTiempInt.cbLAFmax,'Enable', 'on' )
            set(GUI.pnlTiempInt.cbLCFmax,'Enable', 'on' )
            set(GUI.pnlTiempInt.cbLZFmax,'Enable', 'on' )  
            
            set(GUI.pnlTiempInt.cbLAImin,'Enable', 'on' )
            set(GUI.pnlTiempInt.cbLCImin,'Enable', 'on' )
            set(GUI.pnlTiempInt.cbLZImin,'Enable', 'on' )

            set(GUI.pnlTiempInt.cbLAImax,'Enable', 'on' )
            set(GUI.pnlTiempInt.cbLCImax,'Enable', 'on' )
            set(GUI.pnlTiempInt.cbLZImax,'Enable', 'on' )
            
            set(GUI.pnlNivelesEst.cbLZeq, 'Enable', 'on')
            set(GUI.pnlNivelesEst.cbLZ01, 'Enable', 'on')
            set(GUI.pnlNivelesEst.cbLZ10, 'Enable', 'on')
            set(GUI.pnlNivelesEst.cbLZ50, 'Enable', 'on')
            set(GUI.pnlNivelesEst.cbLZ90, 'Enable', 'on')
            set(GUI.pnlNivelesEst.cbLZ99, 'Enable', 'on')
            set(GUI.pnlNivelesEst.cbLCeq, 'Enable', 'on')
            set(GUI.pnlNivelesEst.cbLC01, 'Enable', 'on')
            set(GUI.pnlNivelesEst.cbLC10, 'Enable', 'on')
            set(GUI.pnlNivelesEst.cbLC50, 'Enable', 'on')
            set(GUI.pnlNivelesEst.cbLC90, 'Enable', 'on')
            set(GUI.pnlNivelesEst.cbLC99, 'Enable', 'on')
            set(GUI.pnlNivelesEst.cbLAeq, 'Enable', 'on')
            set(GUI.pnlNivelesEst.cbLA01, 'Enable', 'on')
            set(GUI.pnlNivelesEst.cbLA10, 'Enable', 'on')
            set(GUI.pnlNivelesEst.cbLA50, 'Enable', 'on')
            set(GUI.pnlNivelesEst.cbLA90, 'Enable', 'on')
            set(GUI.pnlNivelesEst.cbLA99, 'Enable', 'on')
            fShowLP
        end
        
    end
    function fImportData(~,~)
        GUI.handles.controller.fImportDataAudio();
    end
    function fcalibracion(~,~)
        if ~get(GUI.btGrabar,'Value')
            GUI.handles.controller.fCalibracion();
        end
    end
    function fGenerador(~,~)
         GUI.handles.controller.fGenerador();
    end
    function fAutomatizacion(~,~)
         GUI.handles.controller.fCTRLAutomatizacion();
    end
    function fShowLP(~,~)
        if  ~get(GUI.btGrabar,'Value')
            GUI.handles.controller.fShowLP();
        end
    end
    function fShowAudioData(~,~)
        if  ~get(GUI.btGrabar,'Value')
            GUI.handles.controller.fShowAudioData();
        end
    end
    function fExportData(~,~)
        GUI.handles.controller.fExportData()
    end
    function fShowEsp(~,~)
        GUI.handles.controller.fShowEsp()
    end
    function fModAxis(~,~)
        GUI.handles.controller.fModAxis()        
    end
    function fOver(~,~)
        set(GUI.DomTiemp.btOver,'BackgroundColor','k');
           
    end
    function fClearNE(~,~)

            set(GUI.pnlNivelesEst.cbLZeq,'Value',0)
            set(GUI.pnlNivelesEst.cbLZ01,'Value',0)
            set(GUI.pnlNivelesEst.cbLZ10,'Value',0)
            set(GUI.pnlNivelesEst.cbLZ50,'Value',0)
            set(GUI.pnlNivelesEst.cbLZ90,'Value',0)
            set(GUI.pnlNivelesEst.cbLZ99,'Value',0)
            set(GUI.pnlNivelesEst.cbLAeq,'Value',0)
            set(GUI.pnlNivelesEst.cbLA01,'Value',0)
            set(GUI.pnlNivelesEst.cbLA10,'Value',0)
            set(GUI.pnlNivelesEst.cbLA50,'Value',0)
            set(GUI.pnlNivelesEst.cbLA90,'Value',0)
            set(GUI.pnlNivelesEst.cbLA99,'Value',0)
            set(GUI.pnlNivelesEst.cbLCeq,'Value',0)
            set(GUI.pnlNivelesEst.cbLC01,'Value',0)
            set(GUI.pnlNivelesEst.cbLC10,'Value',0)
            set(GUI.pnlNivelesEst.cbLC50,'Value',0)
            set(GUI.pnlNivelesEst.cbLC90,'Value',0)
            set(GUI.pnlNivelesEst.cbLC99,'Value',0)

            if  ~get(GUI.btGrabar,'Value')
                GUI.handles.controller.fShowLP();
            end
    end
    function fClearTI(~,~)

            set(GUI.pnlTiempInt.cbPicoA,'Value',0)
            set(GUI.pnlTiempInt.cbPicoC,'Value',0)
            set(GUI.pnlTiempInt.cbPicoZ,'Value',0)
            set(GUI.pnlTiempInt.cbInstA,'Value',0)
            set(GUI.pnlTiempInt.cbInstC,'Value',0)
            set(GUI.pnlTiempInt.cbInstZ,'Value',0)
            set(GUI.pnlTiempInt.cbFastA,'Value',0)
            set(GUI.pnlTiempInt.cbFastC,'Value',0)
            set(GUI.pnlTiempInt.cbFastZ,'Value',0)
            set(GUI.pnlTiempInt.cbSlowA,'Value',0)
            set(GUI.pnlTiempInt.cbSlowC,'Value',0)
            set(GUI.pnlTiempInt.cbSlowZ,'Value',0)

            set(GUI.pnlTiempInt.cbLAImin,'Value',0)
            set(GUI.pnlTiempInt.cbLAImax,'Value',0)        
            set(GUI.pnlTiempInt.cbLCImin,'Value',0)
            set(GUI.pnlTiempInt.cbLCImax,'Value',0)
            set(GUI.pnlTiempInt.cbLZImin,'Value',0)
            set(GUI.pnlTiempInt.cbLZImax,'Value',0)
            set(GUI.pnlTiempInt.cbLAFmin,'Value',0)
            set(GUI.pnlTiempInt.cbLAFmax,'Value',0)        
            set(GUI.pnlTiempInt.cbLCFmin,'Value',0)
            set(GUI.pnlTiempInt.cbLCFmax,'Value',0)
            set(GUI.pnlTiempInt.cbLZFmin,'Value',0)
            set(GUI.pnlTiempInt.cbLZFmax,'Value',0)
            set(GUI.pnlTiempInt.cbLASmin,'Value',0)
            set(GUI.pnlTiempInt.cbLASmax,'Value',0)        
            set(GUI.pnlTiempInt.cbLCSmin,'Value',0)
            set(GUI.pnlTiempInt.cbLCSmax,'Value',0)
            set(GUI.pnlTiempInt.cbLZSmin,'Value',0)
            set(GUI.pnlTiempInt.cbLZSmax,'Value',0)

            if  ~get(GUI.btGrabar,'Value')
                GUI.handles.controller.fShowLP();
            end
    end

end