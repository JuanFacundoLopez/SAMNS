%***************************************************************************************
%*            SISTEMA AUTOMÁTICO DE MEDICIÓN DE NIVELES SONOROS (SAMNS)                * 
%***************************************************************************************
% CINTRA, UTN - CONICET                                                                * 
% Proyecto: SAMDA (PID UTN 7838)                                                       *
% Linea: Acustica de recintos e innovacion en metrologia acustica (ARIMA)              *
% Autores: Lopez, Juan Facundo - Ferreyra, Sebastian Pablo                             *
% E-mail: ing.juanfacundolopez@gmail.com - sferreyra@frc.utn.edu.ar                    *
% Fecha: 21-09-2021                                                                    *
% Version: 1.0                                                                         *
%***************************************************************************************/

function main()
InitializePsychSound2compile();
% InitializePsychSound();
clc;
mymodel = samnsModelo();
mycontroller = samnsControlador(mymodel);