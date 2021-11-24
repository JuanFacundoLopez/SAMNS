function samnsPreferenciasGUI(Modelo)
% Aca se va a definir las preferencias del SAMNS

dataAudio = [];
dataAudio.Entradas  = Modelo.getDispEntrada();
dataAudio.Salidas   = Modelo.getDispSalida();

% Constantes

clc
CONF = [];

CONF.hFig = findall(0, '-depth',1, 'type','figure', 'Name','Configuración');
if isempty(CONF.hFig)
    CONF.hFig = figure( 'Name','Configuracion', 'NumberTitle','off', 'Visible','off',...
                        'Color','w','Units','normalized', 'Position',[0.25,0.3,0.45,0.3],...
                        'Toolbar','none', 'Menu', 'none');
else
    clf(CONF.hFig);
    hc=findall(gcf); 
    delete(hc(2:end)); 
end

set(CONF.hFig,'Visible','on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------------PANEL DE Interface-------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CONF.config.btSave   =  uicontrol(CONF.hFig,'Style','pushbutton','Units','normalized',...
                        'Position', [0.65 0.02 0.13 0.11],...
                        'String','Aplicar', 'FontSize', 10,'BackgroundColor','w',...
                        'FontWeight','bold','Callback',@(h,e)fbtSave);
                    
CONF.config.btCancel =  uicontrol(CONF.hFig,'Style','pushbutton','Units','normalized',...
                        'Position', [0.82 0.02 0.13 0.11],...
                        'String','Cancelar', 'FontSize', 10,'BackgroundColor','w',...
                        'FontWeight','bold','Callback',@(h,e)fbtCancel);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------------PANEL DE AUDIO-----------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %% Agrego objetos al panel 2 
        
CONF.audio.txCA = uicontrol(CONF.hFig,'Style','text','Units','normalized', 'Position', [0.02 0.75 0.3 0.2],...
                        'String','Canales de audio', 'FontSize', 13,'BackgroundColor','w','FontWeight','bold');
                    
CONF.audio.txEA = uicontrol(CONF.hFig,'Style','text','Units','normalized', 'Position', [0.02 0.55 0.3 0.2],...
                        'String','Entrada', 'FontSize', 13,'BackgroundColor','w','FontWeight','bold');
        
CONF.audio.txSA = uicontrol(CONF.hFig,'Style','text','Units','normalized', 'Position', [0.02 0.35 0.3 0.2],...
                        'String','Salida', 'FontSize', 13,'BackgroundColor','w','FontWeight','bold');
                    
CONF.audio.txRM = uicontrol(CONF.hFig,'Style','text','Units','normalized', 'Position', [0.02 0.15 0.3 0.2],...
                        'String','Resolucion / Muestreo', 'FontSize', 13,'BackgroundColor','w','FontWeight','bold');
 
CONF.audio.txBT = uicontrol(CONF.hFig,'Style','text','Units','normalized', 'Position', [0.47 0.15 0.1 0.2],...
                        'String','[ bits ]', 'FontSize', 13,'BackgroundColor','w','FontWeight','bold');
                     
CONF.audio.txKH = uicontrol(CONF.hFig,'Style','text','Units','normalized', 'Position', [0.85 0.15 0.1 0.2],...
                        'String','[ Hz ]', 'FontSize', 13,'BackgroundColor','w','FontWeight','bold');

CONF.pmNCha = uicontrol(CONF.hFig,'Style','popupmenu','Units','normalized', 'Position', [0.35 0.75 0.6 0.2],'String',{'1 Canal';'2 Canales';},...
                        'FontSize', 11,'BackgroundColor','w');                            
       
CONF.pmEntr = uicontrol(CONF.hFig,'Style','popupmenu','Units','normalized', 'Position', [0.35 0.55 0.6 0.2],...
                       'String', dataAudio.Entradas.Str, 'FontSize', 13,'BackgroundColor','w');
                   
CONF.pmSali = uicontrol(CONF.hFig,'Style','popupmenu','Units','normalized', 'Position', [0.35 0.35 0.6 0.2],...
                       'String', dataAudio.Salidas.Str, 'FontSize', 13,'BackgroundColor','w');
                           
CONF.pmReso = uicontrol(CONF.hFig,'Style','popupmenu','Units','normalized', 'Position', [0.35 0.15 0.1  0.2],...
                       'String',{'16';'24';'32'}, 'FontSize', 13,'BackgroundColor','w','HorizontalAlignment','Center');
        
CONF.pmMues = uicontrol(CONF.hFig,'Style','popupmenu','Units','normalized', 'Position', [0.58 0.15 0.25  0.2],...
                       'String', {'44100';'48000';'88100';'96000';'192000'}, 'FontSize', 13,'BackgroundColor','w', 'HorizontalAlignment', 'Center', 'Value', 2);
                   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----------------------------------FUNCIONES--------------------------------------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fbtSave(~,~)

    Res = [16,24,32];
    Fre = [44100, 48000, 88000, 96000, 192000];
    Entrada = dataAudio.Entradas.Num(get(CONF.pmEntr,'Value'));
    Salida = dataAudio.Salidas.Num(get(CONF.pmSali,'Value'));
    Frecuencia = Fre(get(CONF.pmMues,'Value'));
    Resolucion = Res(get(CONF.pmReso,'Value'));
    Canales = get(CONF.pmNCha,'Value');
    Modelo.setEntradaIndex(Entrada)%
    Modelo.setSalidaIndex(Salida)%
    Modelo.setFrecMuestre(Frecuencia)%
    Modelo.setNBits(Resolucion)%
    Modelo.setNCanales(Canales)%
    close(CONF.hFig);
end
function fbtCancel(~,~)
    close(CONF.hFig);
end
end

