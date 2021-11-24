function fGUIdataExport(controlador)

datExp = [];
datExp.hFig = figure(  'Name','Preferencias de exportación', 'NumberTitle','off',...
                    'Color','w', 'Unit','Normalized','Position',[0.35,0.35,0.4,0.3],...
                    'Toolbar','none', 'Menu', 'none');
                              
datExp.pnlFormato.main(1) = uibuttongroup(datExp.hFig,'Position',[0.05 0.75 0.9 0.23],'Title','Formato','BackgroundColor','w', 'FontSize', 13);                            
                            
datExp.pnlFormato.cbExcel = uicontrol('Parent', datExp.pnlFormato.main,'Style','checkbox','unit','normalized', 'Position', [0.05 0.4 0.18 0.3],...
                                'String','Planilla excel', 'FontSize', 11,'BackgroundColor','w');
datExp.pnlFormato.cbPlano = uicontrol('Parent', datExp.pnlFormato.main,'Style','checkbox','unit','normalized', 'Position', [0.3 0.4 0.3 0.3],...
                                'String','Archivo de texto plano', 'FontSize', 11,'BackgroundColor','w');
datExp.pnlFormato.cbJSON  = uicontrol('Parent', datExp.pnlFormato.main,'Style','checkbox','unit','normalized', 'Position', [0.62 0.4 0.12 0.3],...
                                'String','.JSON', 'FontSize', 11,'BackgroundColor','w'); 
datExp.pnlFormato.cbAWav  = uicontrol('Parent', datExp.pnlFormato.main,'Style','checkbox','unit','normalized', 'Position', [0.75 0.4 0.12 0.3],...
                                'String','.WAV', 'FontSize', 11,'BackgroundColor','w'); 
  
                            
datExp.pnlDiezmad.main(2) = uibuttongroup(datExp.hFig,'Position',[0.05 0.5 0.9 0.23],'Title','Diezmado','BackgroundColor','w', 'FontSize', 13); 


datExp.pnlDiezmad.txcyTi  = uicontrol('Parent', datExp.pnlDiezmad.main(2),'Style','text','unit','normalized', 'Position', [0.05 0.4 0.4 0.4],...
                                'String','Cicle Time (frames)', 'FontSize', 12,'BackgroundColor','w');

datExp.pnlDiezmad.edcyTi  = uicontrol('Parent', datExp.pnlDiezmad.main(2),'Style','edit','unit','normalized', 'Position', [0.50 0.2 0.4 0.6],...
                                'String','200', 'FontSize', 12,'BackgroundColor','w');
                            

datExp.pnlDiezmad.main(3) = uibuttongroup(datExp.hFig,'Position',[0.05 0.25 0.9 0.22],'Title','Dirección','BackgroundColor','w', 'FontSize', 13); 


datExp.pnlDiezmad.btBusc  = uicontrol('Parent', datExp.pnlDiezmad.main(3),'Style','pushbutton','unit','normalized', 'Position', [0.89 0.08 0.08 0.85],...
                                'String','...', 'FontSize', 12,'BackgroundColor','w','Callback',@buscarDir);

datExp.pnlDiezmad.edDire  = uicontrol('Parent', datExp.pnlDiezmad.main(3),'Style','edit','unit','normalized', 'Position', [0.05 0.08 0.81 0.85],...
                                'String','', 'FontSize', 12,'BackgroundColor','w');
                            
                            
datExp.pbAcept = uicontrol('Parent', datExp.hFig,'Style','pushbutton','unit','normalized', 'Position', [0.6 0.05 0.15 0.15],...
                                'String','Aceptar', 'FontSize', 12,'BackgroundColor','w','FontWeight','bold','Callback',@Aceptar);
datExp.pbCance = uicontrol('Parent', datExp.hFig,'Style','pushbutton','unit','normalized', 'Position', [0.8 0.05 0.15 0.15],...
                                'String','Cancelar', 'FontSize', 12,'BackgroundColor','w','FontWeight','bold','Callback',@Cancelar); 
                

    function buscarDir(~,~)
        datExp.path = uigetdir;
        set(datExp.pnlDiezmad.edDire, 'String', path)
    end

    function Aceptar(~,~)

        if isempty(get(datExp.pnlDiezmad.edDire,'String'))
            datExp.path = uigetdir;
        end
        
        mTPlano = get(datExp.pnlFormato.cbPlano,'Value');
        mExc    = get(datExp.pnlFormato.cbExcel ,'Value');
        mJSON   = get(datExp.pnlFormato.cbJSON,'Value');
        mWav    = get(datExp.pnlFormato.cbAWav,'Value');
        
        controlador.mModelo.setPath(datExp.path);
        controlador.fGenFilExpDat(mTPlano, mExc, mJSON, mWav)
        
        close(datExp.hFig)
    end

    function Cancelar(~,~)
        close(datExp.hFig)
    end
end