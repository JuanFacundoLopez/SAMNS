classdef samnsModelo < handle    
    
    properties(Constant, Hidden = true)
       label_oct   = {'31.5Hz','63Hz','125Hz','250Hz','500Hz','1kHz','2kHz','4kHz','8kHz','16kHz'};
       label_ter   = {'25Hz','31.5Hz','40Hz','50Hz','63Hz','80Hz','100Hz','125Hz','160Hz','200Hz',...
        '250Hz','315Hz','400Hz','500Hz','630Hz','800Hz','1kHz','1.25kHz','1.6kHz','2kHz',... 
        '2.5kHz','3.15kHz','4kHz','5kHz','6.3kHz','8kHz','10kHz','12.5kHz','16kHz','20kHz'};
    end % DEfino los string de las octavas y tercios
    properties(Access = private)
      % Caracteristicas se la señal
       mSamplingRate         = 44100;
       mNBits                = 16;
       mGradoFft             = 16;
       mAmplitudSenialAudio  = 100;
              
       
      % Caracteristicas de los filtros 
       mVectorFrecuencias    = [31.5,63,125,250,500,1000,2000,4000,8000,16000];
       mBandasOctava         = 1;
       mOrdenFiltro          = 10;
       mFrec                 = 0;
       
      % Caracteristicas de la placa de audio
       mEntradaAudio  = [];
       mSalidaAudio   = [];
       mEntSalAudio   = [];
       mObjTARS       = [];
       mEntradaIndex  = 0;
       mSalidaIndex   = 0;
       mNCanales      = 1;
      % Parametros del archivo
       mDirectorioGuardar    = '';
       
      % Caracteristicas de la implemenacion de los filtros  en el dominio
      % del tiempo
      mTiempoModo            = '1/1';
      mTiempoFrecuencia      = 20;
      mTiempoVentana         = 'Rect';
      mTiempoLongitud        = 8192;
      
      % Caracteristicas de la implemenacion de los filtros  en el dominio
      % de la frecuencia
      mFrecueDimencion       = 2;
      mFrecueModo            = 31.5;
      mFrecueVentana         = 'Rect';
      mFrecueLongitud        = 8192;
      
      % Referencia por calibracion automatica
      mRefeCalibracion = 0; 
      mRefFS = 0;
      
      %Niveles de presion sonora
      mLPA = [];
      mLPC = [];
      mLPZ = [];
      mLPtimeLapse = [];
      
      %Señal grabada
      mAudioSignal = [];
      
      %Niveles estadisticos
      mLeqA = [];
      mLeqC = [];
      mLeqZ = [];
      
      %temporizadores   
      mTempo      = [];
      mTempoArray = [];
      
      %Estetica
      BGC = [1,1,1];%[35, 35, 35]/255;%[1,1,1];%;
      LC = [0,0,0];%[0 0.4470 0.7410];%[0,0,0];%;
      
      %path
      mPath = ''; 
    end

    methods
        function obj = samnsModelo() % constructor del objeto
            [ obj.mEntradaAudio, obj.mSalidaAudio, ~, ~, obj.mObjTARS, obj.mEntSalAudio ] = ConsulDisp();
            obj.mEntradaIndex = obj.mEntradaAudio.Num(1); %Al iniciar se cargan los disp por defecto
            obj.mSalidaIndex = obj.mSalidaAudio.Num(1); %al iniciar se carga la salida por defecto
        end

        %% Seters
        
        function setReferenciaCalibracion(this,value)
            this.mRefeCalibracion = value;
        end
        function setPath(this,value)
            this.mPath = value;
        end
        function setSamplingRate(this,value)
            if isscalar(value)
                this.mSamplingRate = value;
            else
                error('%s.set.samplingRate  samplingRate must be a scalar value',mfilename);
            end
        end       
        function setGradoFft(this,value)
                this.mGradoFft =value;
        end
        function setDatos(this,value)
               this.mDatos = value;
        end                
        function setPotenciaTonodB(this, value)
            this.mPotenciaTonodB = value;
        end        
        function setTipoExcitacion(this,value)
                this.mTipoExcitacion = value;
        end
        function setTipoVentana(this,value)
                this.mTipoVentana =value;
        end
        function setOctavas(this, value)
           
            if(strcmp(value, '1/1 Octava'))
               this.mBandasOctava = 1;
               this.mVectorFrecuencias = [31.5,63,125,250,500,1000,2000,4000,8000,16000];
            elseif (strcmp(value, '1/3 Octava'))
               this.mBandasOctava = 3;
               this.mVectorFrecuencias = [25,31.5,40,50,63,80,100,125,160,200,250,315,400,500,630,...
                    800,1000,1250,1600,2000,2500,3150,4000,5000,6300,8000,10000,12500,16000,20000];
            else
                disp('Error')
            end
          
        end
        function setOrdenFiltro  (this, value)
            this.mOrdenFiltro = value;
        end
        function setFrec  (this, value)
            this.mFrec = value;
        end
        function setPotenciadB(this, value)
            this.mPotenciadB = value;
        end
        function setParametros(this, value)
            this.mParametros = value;
        end
        function setDirectorioGuardar(this, value)
            this.mDirectorioGuardar = value;
        end                   
        function setGuardaIR(this, value)
            this.mGuardaIR = value;
        end 
        function setNBits(this, value)
            this.mNBits = value;
        end
        function setDispEntradaStr(this, value)
            this.mEntradaAudioNombre = value;
        end
        function setDispEntradaNum(this, value)
            this.mEntradaAudioIndex = value;
        end
        function setDispSalidaStr(this,value)
            this.mSalidaAudioNombre = value;
        end
        function setDispSalidaNum(this,value)
            this.mSalidaAudioIndex  = value;
        end
        function setFrecMuestre(this,value)
            this.mSamplingRate = value;
        end
        function setEntradaIndex(this, value)
            this.mEntradaIndex = value;
        end
        function setSalidaIndex(this, value)
            this.mSalidaIndex = value;
        end
        function setNCanales(this, value)
           this.mNCanales = value; 
        end
        function setTARSObj(this,value)
            this.mObjTARS = value;
        end       
        function setDBReferencia(this,value)
            this.mRefeCalibracion = value;
        end 
        function setDBFullScale(this,value)
            this.mRefFS = value;
        end 
        
        function setLPA(this,value)
            this.mLPA = value;
        end       
        function setLPC(this,value)
            this.mLPC = value;
        end
        function setLPZ(this,value)
            this.mLPZ = value;
        end       
        function setLeqA(this,value)
            this.mLeqA = value;   
        end
        function setLeqC(this,value)
            this.mLeqC = value;   
        end
        function setLeqZ(this,value)
            this.mLeqZ = value;   
        end       
        function setLPtimeLapse(this,value)
            this.mLPtimeLapse =value;
        end
        function setPGraba(this,value)
            this.mTempoArray = value;
            this.mTempo = [];
            if ~isempty(value)
                this.mTempo(1).T = timer;
                this.mTempo(1).T.StartDelay = value(1).timSec1;
                this.mTempo(1).P = value(1).timSec2 - value(1).timSec1;
            end
            if length(value) > 1
                this.mTempo(2).T = timer;
                this.mTempo(2).T.StartDelay = value(2).timSec1;
                this.mTempo(2).P = value(2).timSec2 - value(2).timSec1;
            end
            if length(value) > 2
                this.mTempo(3).T = timer;
                this.mTempo(3).T.StartDelay = value(3).timSec1;    
                this.mTempo(3).P = value(3).timSec2 - value(3).timSec1;
            end
            if length(value) > 3
                this.mTempo(4).T = timer;
                this.mTempo(4).T.StartDelay = value(4).timSec1;
                this.mTempo(4).P = value(4).timSec2 - value(4).timSec1;
            end
        end%defino los tiempos de los temporizadores
        function setAudioSignal(this,value)
           this.mAudioSignal = value; 
        end        
        function setBackgroundColor(this,value)
            this.BGC = value;
        end
        function setLetterColor(this,value)
            this.LC = value;
        end

        %% Geters
        
        function result = getReferenciaCalibracion(this)
            result = this.mRefeCalibracion;
        end
        function result = getAudioSignal(this)
           result = this.mAudioSignal; 
        end      
        function result = getGradoFft(this)
            result = this.mGradoFft;
        end
        function result = getDispEntradaStr(this)
            result = this.mEntradaAudioNombre;
        end
        function result = getDispEntradaNum(this)
            result = this.mEntradaAudioIndex;
        end
        function result = getDispSalidaStr(this)
            result = this.mSalidaAudioNombre;
        end
        function result = getDispSalidaNum(this)
            result = this.mSalidaAudioIndex;
        end       
        function result = getTipoExcitacion(this)
            result = this.mTipoExcitacion;           
        end
        function result = getTipoVentana(this)
            result = this.mTipoVentana;
        end
        function result = getVectorFrecuencias(this)
            result = this.mVectorFrecuencias;
        end
        function result = getOctavas(this)
           
            result = this.mBandasOctava;
        end
        function result = getOrdenFiltro(this)
            result = this.mOrdenFiltro;
        end
        function result = getFrec(this)
            result = this.mFrec;
        end
        function result = getDirectorioGuardar(this)
            result = this.mDirectorioGuardar;
        end
        function result = getNBits(this)
            result = this.mNBits;
        end
        function result = getDispEntrada(this)
            result = this.mEntradaAudio;
        end
        function result = getDispSalida(this)
            result = this.mSalidaAudio;
        end
        function result = getFrecMuestre(this)
            result = this.mSamplingRate;
        end
        function result = getPath(this)
           result = this.mPath;
        end
        function result = getTARSObj(this)
            result = this.mObjTARS;
        
        end
        function result = getDuracion(this)
            result = this.mDuracion;
        
        end
        function result = getFrecuencia(this)
            result = this.mFrecuencia;
        end
        function result = getFrecInicial(this)
            result = this.mFrecuenciaInicial;
        
        end
        function result = getFrecFinal(this)
            result = this.mFrecuenciaFinal;
        
        end
        function result = getSilencio(this)
            result = this.mSilencio;   
        end
        function result = getRepeticion(this)
            result = this.mRepeticion;   
        end
        function result = getAmplitud(this)
            result = this.mAmplitud;   
        end
        function result = getDBReferencia(this)
            result = this.mRefeCalibracion;   
        end
        function result = getDBFullScale(this)
            result = this.mRefFS;   
        end
        function result = getEntradaIndex(this)
            result = this.mEntradaIndex;
        end
        function result = getSalidaIndex(this)
            result = this.mSalidaIndex;
        end
        function result = getLPA(this)
            result = this.mLPA;   
        end
        function result = getLPC(this)
            result = this.mLPC;   
        end
        function result = getLPZ(this)
            result = this.mLPZ;   
        end
        function result = getLeqA(this)
            result = this.mLeqA;   
        end
        function result = getLeqC(this)
            result = this.mLeqC;   
        end
        function result = getLeqZ(this)
            result = this.mLeqZ;   
        end
        function result = getLPtimeLapse(this)
           result = this.mLPtimeLapse; 
        end

        function result = getPGraba(this)
           result = this.mTempo; 
        end
        %-----Datos de la GUI
        function result = getBackgroundColor(this)
            result = this.BGC;
        end
        function result = getLetterColor(this)
            result = this.LC;
        end

      end
end
       