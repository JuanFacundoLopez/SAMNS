classdef samnsVista < handle
    properties
        mGui
        mModelo
        mControlador
    end
    
    methods
        function obj = samnsVista(controlador) % creo el constructor del objeto vista
            obj.mControlador = controlador;
            obj.mModelo = controlador.mModelo;
            obj.mGui = samnsGUI('controlador',obj.mControlador);
         end
    end
end