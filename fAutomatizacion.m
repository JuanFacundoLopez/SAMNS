function [datAut] = fAutomatizacion(controlador)

datAut = [];
datAut.cont = 1;
datAut.temporizadores = []; 
datAut.hFig = figure(  'Name','Automatización', 'NumberTitle','off',...
                    'Color','w', 'Unit','Normalized','Position',[0.35,0.35,0.4,0.3],...
                    'Toolbar','none', 'Menu', 'none');
                
datAut.pnlTiempo.main = uibuttongroup(datAut.hFig,'Position',[0.05 0.78 0.9 0.2],'Title','Tiempo','BackgroundColor','w', 'FontSize', 10);                            
                
datAut.pnlTiempo.txIni = uicontrol('Parent', datAut.pnlTiempo.main,'Style','text','unit','normalized', 'Position', [0.01 0.3 0.17 0.47],...
                                'String','Tiempo inicio', 'FontSize', 10,'BackgroundColor','w','FontWeight','bold');

datAut.pnlTiempo.txFin = uicontrol('Parent', datAut.pnlTiempo.main,'Style','text','unit','normalized', 'Position', [0.47 0.3 0.17 0.47],...
                                'String','Tiempo final', 'FontSize', 10,'BackgroundColor','w','FontWeight','bold');
                                                   
datAut.pnlTiempo.edIni(1) = uicontrol('Parent', datAut.pnlTiempo.main,'Style','edit','unit','normalized', 'Position', [0.20 0.3 0.037 0.47],...
                                'String','19', 'FontSize', 10,'BackgroundColor','w','ForegroundColor',[0.5 0.5 0.5]);                            
datAut.pnlTiempo.edIni(2) = uicontrol('Parent', datAut.pnlTiempo.main,'Style','edit','unit','normalized', 'Position', [0.24 0.3 0.037 0.47],...
                                'String','09', 'FontSize', 10,'BackgroundColor','w','ForegroundColor',[0.5 0.5 0.5]);                            
datAut.pnlTiempo.edIni(3) = uicontrol('Parent', datAut.pnlTiempo.main,'Style','edit','unit','normalized', 'Position', [0.28 0.3 0.037 0.47],...
                                'String','21', 'FontSize', 10,'BackgroundColor','w','ForegroundColor',[0.5 0.5 0.5]);                            
datAut.pnlTiempo.edIni(4) = uicontrol('Parent', datAut.pnlTiempo.main,'Style','edit','unit','normalized', 'Position', [0.32 0.3 0.037 0.47],...
                                'String','hh', 'FontSize', 10,'BackgroundColor','w','ForegroundColor',[0.5 0.5 0.5]);                            
datAut.pnlTiempo.edIni(5) = uicontrol('Parent', datAut.pnlTiempo.main,'Style','edit','unit','normalized', 'Position', [0.36 0.3 0.037 0.47],...
                                'String','mm', 'FontSize', 10,'BackgroundColor','w','ForegroundColor',[0.5 0.5 0.5]);                            
datAut.pnlTiempo.edIni(6) = uicontrol('Parent', datAut.pnlTiempo.main,'Style','edit','unit','normalized', 'Position', [0.40 0.3 0.037 0.47],...
                                'String','ss', 'FontSize', 10,'BackgroundColor','w','ForegroundColor',[0.5 0.5 0.5]);  
                            
datAut.pnlTiempo.edFin(1) = uicontrol('Parent', datAut.pnlTiempo.main,'Style','edit','unit','normalized', 'Position', [0.66 0.3 0.037 0.47],...
                                'String','19', 'FontSize', 10,'BackgroundColor','w','ForegroundColor',[0.5 0.5 0.5]);
datAut.pnlTiempo.edFin(2) = uicontrol('Parent', datAut.pnlTiempo.main,'Style','edit','unit','normalized', 'Position', [0.70 0.3 0.037 0.47],...
                                'String','09', 'FontSize', 10,'BackgroundColor','w','ForegroundColor',[0.5 0.5 0.5]);
datAut.pnlTiempo.edFin(3) = uicontrol('Parent', datAut.pnlTiempo.main,'Style','edit','unit','normalized', 'Position', [0.74 0.3 0.037 0.47],...
                                'String','21', 'FontSize', 10,'BackgroundColor','w','ForegroundColor',[0.5 0.5 0.5]);
datAut.pnlTiempo.edFin(4) = uicontrol('Parent', datAut.pnlTiempo.main,'Style','edit','unit','normalized', 'Position', [0.78 0.3 0.037 0.47],...
                                'String','hh', 'FontSize', 10,'BackgroundColor','w','ForegroundColor',[0.5 0.5 0.5]);
datAut.pnlTiempo.edFin(5) = uicontrol('Parent', datAut.pnlTiempo.main,'Style','edit','unit','normalized', 'Position', [0.82 0.3 0.037 0.47],...
                                'String','mm', 'FontSize', 10,'BackgroundColor','w','ForegroundColor',[0.5 0.5 0.5]);
datAut.pnlTiempo.edFin(6) = uicontrol('Parent', datAut.pnlTiempo.main,'Style','edit','unit','normalized', 'Position', [0.86 0.3 0.037 0.47],...
                                'String','ss', 'FontSize', 10,'BackgroundColor','w','ForegroundColor',[0.5 0.5 0.5]);
                            
datAut.pnlTiempo.btAgreAt = uicontrol('Parent',datAut.pnlTiempo.main,'Style','pushbutton','unit','normalized','Position',[0.92 0.20 0.07 0.65],...
                                'String','+','Callback',@(h,e)AgregarAut);

                            %% -- MENU DE EXPORTACION DE DATOS ---  
datAut.pnlFormato.main = uibuttongroup(datAut.hFig,'Position',[0.05 0.5 0.9 0.27],'Title','Formato','BackgroundColor','w', 'FontSize', 10);                            
                            
datAut.pnlFormato.cbExcel = uicontrol('Parent', datAut.pnlFormato.main,'Style','checkbox','unit','normalized', 'Position', [0.05 0.5 0.25 0.35],...
                                'String','Planilla excel', 'FontSize', 10,'BackgroundColor','w');
datAut.pnlFormato.cbPlano = uicontrol('Parent', datAut.pnlFormato.main,'Style','checkbox','unit','normalized', 'Position', [0.33 0.5 0.35 0.35],...
                                'String','Archivo de texto plano', 'FontSize', 10,'BackgroundColor','w');
datAut.pnlFormato.cbJSON  = uicontrol('Parent', datAut.pnlFormato.main,'Style','checkbox','unit','normalized', 'Position', [0.75 0.5 0.15 0.35],...
                                'String','JSON', 'FontSize', 10,'BackgroundColor','w');  
datAut.pnlFormato.btBusc  = uicontrol('Parent', datAut.pnlFormato.main,'Style','pushbutton','unit','normalized', 'Position', [0.89 0.02 0.04 0.35],...
                                'String','...', 'FontSize', 10,'BackgroundColor','w','Callback',@(h,e)buscarDir);
datAut.pnlFormato.edDire  = uicontrol('Parent', datAut.pnlFormato.main,'Style','edit','unit','normalized', 'Position', [0.05 0.02 0.81 0.35],...
                                'String','', 'FontSize', 10,'BackgroundColor','w');                            

                           %% este es el panel de automatizaciones 
datAut.listaAut.main = uipanel(datAut.hFig,'Position',[0.05 0.22 0.9 0.27],'Title','Automatizaciones activas','BackgroundColor','w', 'FontSize', 10); 


datAut.listaAut.desc(1) =  uicontrol('Parent', datAut.listaAut.main,'Style','text','unit','normalized', 'Position', [0.01 0.76 0.95 0.22],...
                                 'String', '', 'FontSize',8,'BackgroundColor','w', 'Visible', 'off');
datAut.listaAut.rest(1) =  uicontrol('Parent', datAut.listaAut.main,'Style','pushbutton','unit','normalized', 'Position', [0.96 0.76 0.03 0.22],...
                                  'String',' - ', 'FontSize', 11,'BackgroundColor','w', 'Visible', 'off','Callback',@(h,e)frestar);

datAut.listaAut.desc(2) =  uicontrol('Parent', datAut.listaAut.main,'Style','text','unit','normalized', 'Position', [0.01 0.53 0.95 0.22],...
                                 'String', '', 'FontSize', 8,'BackgroundColor','w', 'Visible', 'off');
datAut.listaAut.rest(2) =  uicontrol('Parent', datAut.listaAut.main,'Style','pushbutton','unit','normalized', 'Position', [0.96 0.53 0.03 0.22],...
                                  'String',' - ', 'FontSize', 11,'BackgroundColor','w', 'Visible', 'off','Callback',@(h,e)frestar);
                              
datAut.listaAut.desc(3) =  uicontrol('Parent', datAut.listaAut.main,'Style','text','unit','normalized', 'Position', [0.01 0.30 0.95 0.22],...
                                 'String', '', 'FontSize', 8,'BackgroundColor','w', 'Visible', 'off');
datAut.listaAut.rest(3) =  uicontrol('Parent', datAut.listaAut.main,'Style','pushbutton','unit','normalized', 'Position', [0.96 0.30 0.03 0.22],...
                                  'String',' - ', 'FontSize', 11,'BackgroundColor','w', 'Visible', 'off','Callback',@(h,e)frestar);
                              
datAut.listaAut.desc(4) =  uicontrol('Parent', datAut.listaAut.main,'Style','text','unit','normalized', 'Position', [0.01 0.07 0.95 0.22],...
                                 'String', '', 'FontSize', 8,'BackgroundColor','w', 'Visible', 'off');
datAut.listaAut.rest(4) =  uicontrol('Parent', datAut.listaAut.main,'Style','pushbutton','unit','normalized', 'Position', [0.96 0.07 0.03 0.22],...
                                  'String',' - ', 'FontSize', 11,'BackgroundColor','w', 'Visible', 'off','Callback',@(h,e)frestar);


datAut.pbAcept = uicontrol('Parent', datAut.hFig,'Style','pushbutton','unit','normalized', 'Position', [0.6 0.05 0.14 0.14],...
                                'String','Aceptar', 'FontSize', 10,'BackgroundColor','w','FontWeight','bold','Callback',@(h,e)Aceptar);
datAut.pbCance = uicontrol('Parent', datAut.hFig,'Style','pushbutton','unit','normalized', 'Position', [0.8 0.05 0.14 0.14],...
                                'String','Cancelar', 'FontSize', 10,'BackgroundColor','w','FontWeight','bold','Callback',@(h,e)Cancelar); 
                                       
    function Aceptar(~,~)
        
        if isempty(datAut.temporizadores)
            msgbox('Debe de agregar una automatización, insertando una fecha y apretar el boton "+", de lo contrario presione cancelar');
        else
            %%           
            for i = 1:(datAut.cont-1)
                %aca tengo que agregar una condicion para que no se repitan
                %los temporizadores
                fechaHoy = datetime('now'); % la fecha de hoy
                tt1 = duration(datAut.temporizadores(i).fecInicNum - fechaHoy,'Format','s');

                tt2 = duration(datAut.temporizadores(i).fecFinaNum - fechaHoy,'Format','s');

                datAut.temporizadores(i).timSec1 = round(seconds(tt1)); % diferencia en segundos en la fecha de inicio

                datAut.temporizadores(i).timSec2 = round(seconds(tt2)); % diferencia en segundos en la fecha de final
                datAut.temporizadores(i).fecHoy  = datestr(fechaHoy);

            end
            %%
            
            controlador.activeTimerGrab1(datAut.temporizadores)
            close(datAut.hFig)
        end
    end
    function buscarDir
        datAut.path = uigetdir;
        set(datAut.pnlFormato.edDire,'String',datAut.path);
        controlador.mModelo.setPath(datAut.path);
    end
    function Cancelar(~,~)
        close(datAut.hFig)
    end
    function AgregarAut(~,~)       
        if datAut.cont < 5
            [timSec1, timSec2, fechaHoy, fechaIni, fechaFin] = upgrade;

            str = [ num2str(datAut.cont), '- Est:', datestr(fechaHoy), '   T. Inic: ', datestr(fechaIni),...
                    '   T. Final: ', datestr(fechaFin), '    Dur.[s]: ', num2str(timSec2-timSec1)];
            set(datAut.listaAut.desc(datAut.cont), 'Visible', 'on')
            set(datAut.listaAut.desc(datAut.cont), 'String', str)
            set(datAut.listaAut.rest(datAut.cont), 'Visible', 'on')
            
            datAut.temporizadores(datAut.cont).fecInicNum = fechaIni;
            datAut.temporizadores(datAut.cont).fecFinaNum = fechaFin;
            datAut.cont = datAut.cont + 1;
        else 
            msgbox('No se puede agregar mas de 4 temporisadores');
        end
    end
    function [timSec1, timSec2,fechaHoy,fechaIni,fechaFin] = upgrade()
        %Levanto los datos de la GUI
            aa1 = round(str2double(get(datAut.pnlTiempo.edIni(3),'String')) + 2000);
            mm1 = round(str2double(get(datAut.pnlTiempo.edIni(2),'String')));
            dd1 = round(str2double(get(datAut.pnlTiempo.edIni(1),'String')));
            hh1 = round(str2double(get(datAut.pnlTiempo.edIni(4),'String')));
            mi1 = round(str2double(get(datAut.pnlTiempo.edIni(5),'String')));
            ss1 = round(str2double(get(datAut.pnlTiempo.edIni(6),'String')));
            %Levanto los datos de la GUI
            aa2 = round(str2double(get(datAut.pnlTiempo.edFin(3),'String')) + 2000);
            mm2 = round(str2double(get(datAut.pnlTiempo.edFin(2),'String')));
            dd2 = round(str2double(get(datAut.pnlTiempo.edFin(1),'String')));
            hh2 = round(str2double(get(datAut.pnlTiempo.edFin(4),'String')));
            mi2 = round(str2double(get(datAut.pnlTiempo.edFin(5),'String')));
            ss2 = round(str2double(get(datAut.pnlTiempo.edFin(6),'String')));

            fechaHoy = datetime('now'); % la fecha de hoy

            fechaIni = datetime(aa1,mm1,dd1,hh1,mi1,ss1); % la fecha de inicio de grabacion

            fechaFin = datetime(aa2,mm2,dd2,hh2,mi2,ss2); % la fecha de final de la grabacion

            tt1 = duration(fechaIni-fechaHoy,'Format','s');

            tt2 = duration(fechaFin-fechaHoy,'Format','s');

            timSec1 = round(seconds(tt1)); % diferencia en segundos en la fecha de inicio

            timSec2 = round(seconds(tt2)); % diferencia en segundos en la fecha de final
        
    end

    function frestar(~,~)
        if get(datAut.listaAut.rest(1),'Value')
            set(datAut.listaAut.desc(1),'Visible','off')
            set(datAut.listaAut.rest(1),'Visible','off')
            if length(datAut.temporizadores)>1
                datAut.temporizadores(1)= datAut.temporizadores(2)
            end
        end
            
        if get(datAut.listaAut.rest(2),'Value')
            set(datAut.listaAut.desc(2),'Visible','off')
            set(datAut.listaAut.rest(2),'Visible','off')

        end
        if get(datAut.listaAut.rest(3),'Value')
            set(datAut.listaAut.desc(3),'Visible','off')
            set(datAut.listaAut.rest(3),'Visible','off')

        end
        if get(datAut.listaAut.rest(4),'Value')
            set(datAut.listaAut.desc(4),'Visible','off')
            set(datAut.listaAut.rest(4),'Visible','off')

        end
        datAut.cont = datAut.cont-1;
        
    end
end