classdef samnsAudio
    %   Debido a que la clase samnsAudio va a contener los datos en el
    %   dominio del tiempo y en el dominio de la frecuencia se va a necesitar
    %   contener en variables determinados datos, por ejemplo mDomain nos va a
    %   especificar si los datos los tenemos en el tiempo o en la frecuencia.
    %   La variable mEvenSamples nos indica si la señal es par o impar.
    %   Contener los datos en el dominio de la frecuencia nos facilita
    %   realizar las operaciones, como la convolucion y correlacion.
    %   Este script está basado en ITA-Toolbox, proyecto desarrollado por
    %   Institute of Technical Acoustics, RWTH Aachen University.
    %   Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
    
    
    %   Las propiedades en Matlab se definen segun ciertos atributos entre ellos estan
    %     los siguientes:
    %    *Hidden: Determina si una propiedad se va a mostrar o no en una lista
    %     de propiedades que sale en el prompt. Si es true no se muestra de lo
    %     contrario si es false se muestra por pantalla. Por defecto es false.
    %     *Access: este atributo refiere al acceso de las propiedades, y
    %     tiene practicamente tres tipos, public su acceso no esta
    %     restringido, protected solo puede ser accedida por clases o
    %     subclases y private solo puede ser accedida por los miembros de
    %     la clase unicamente (no por subclases). Por defecto es public.
    %     *Dependent: este tipo de propiedades no almacenan datos, ya que
    %     una propiedad dependent depende del estado actual de otra, como
    %     por ejemplo el valor concreto de una propiedad. Si se define a
    %     una propiedad como dependent(solo con escribir dependent).Matlab
    %     no muestra por el prompt el nombre y valor de la variable, si
    %     Hidden es falso, hasta que no tenga un método get.
    %   Si está definido el constructor al inicializar primero pasa por el mismo y luego
    %   sigue con el resto... al definir las propiedades también se pasa por
    %   el método get de las mismas. --
    
    %%
    properties(Access = private, Hidden = true) %variables internas controladas por variables dependientes
        %La variable mComment(itaMeta), sirve para identificar cada     VER
        %instancia en particular. Por ej. a la hora de graficar.
        mComment = '';
        mDimensions = 0;
        mData   = [];              % alternative syntax, equals .timeData.'
        mDomain = 'time';          % 'time' / 'freq'
        mSamplingRate = 44100;
        mSignalType = 'power';     % 'power' / 'energy'
        %El tipo de señal es importante a la hora de calcular la fft.
        %Obtendremos una señal de potencia (potencia finita, energia infinita, señales periodicas) por ej. para el habla, el ruido
        %y una señal de energia (potencia = 0) por ej. para la respuesta al impulso. 
        mEvenSamples = true; %*
        %Si la señal es par o impar. Es necesaria para calcular la fft.
   
        %---------------------------------------------------------
        % También son de itaSuper                           VER
        mDataType = 'double';           % Type for internal data
        mDataTypeOutput = 'double';     % Type used for output
        mDataTypeEqual = true;          % On/Off Switch for data type casts (speed reason)
        mDataFactor = 1;                % Factor for scaling if using int
     
    
    end
    
    properties(Constant, Hidden = true)
    
        %El constant refiere a que en todas las instancias de la clase
        %samnsAudio esta variable va a tener un solo valor.
        %Para hacer referencia a la misma se usa el nombre de la clase + el
        %operador de acceso: samnsAudio.VALID_SIGNAL_TYPES
        VALID_SIGNAL_TYPES = {'power', 'energy'};
    
    end
	
	properties(Dependent = true, Hidden = false)
	%--------------------------------------------------------------------
    % Variables definidas en itaAudio                   VER
    % Estas variables son de tipo dependent por lo tanto para ser vista necesitan tener definido por lo menos
    % el método get. Para estas están definidos los métodos get/set.
    % Si se usan estas propiedades al nombrarla se llama al método get.
    % Es decir si en un método cualquiera uso this.samplingRate cuando se
    % pasa por esa linea se llama al método get.samplingRate.
    
        samplingRate        % frecuencia de muestreo en Hz
        signalType          % energy (filter) or power (signal) normalization for FFT/IFFTsignalType
        fftDegree           % 2^fftDegree samples en el dominio del tiempo
        trackLength         % duracion en segundos
        comment             % comentario que describe el objeto (string)
    %--------------------------------------------------------------------    
    % Variables definidas en itaSuper    VER
        nBins               % número de samples en el dominio de la frecuencia (bins)
        nSamples            % número de samples en el dominio del tiempo
        
        time                % time domain data (get/set) - full dimensions   VER
        timeData            % time domain data in 2D. Señal Original         VER
        
        freq                % frequency domain data (get/set) - full dimensions
        freqData            % frequency domain data in 2D
        
        domain              % Agrego properties of itaSuper %domain of data ('time'/'freq')
        freqAmp
       
        dimensions          % dimensiones del campo "data"
        dataFactor
        dataType            % raw data type, data is stored in... (single/double)       VER
        dataTypeOutput      % data type when you access data (single/double), conversion
    end
    
    properties(Dependent = true, Hidden = true)
        %En esta variable van a estar los datos en crudo, y se puede
        %acceder por medio del set y get de las variables frecData y
        %timeData. Para obtenerla en la frecuencia usa la FFT y para
        %obtenerla en el tiempo la IFFT. Ver bien cual es la funcion fft
        %que se utiliza en este caso.
        data                %raw data, could be time or frequency domain (CAREFUL!)
    end
    
    
    %% Los métodos usan por dentro cuatro identificadores respecto a lo que son variables de entrada y variables de salida.
	% varargin significa que es una estructura que contiene parametros que se le pasa a la función si son varios para acceder
	% a los mismos se usa varargin{index}, nargin indica el numero de argumentos que la funcion recibió.
	% varargout significa las variables de salida que va a sacar la función y nargout indica el numero de objetos de salida.
	% Por ejemplo si llamamos a una función >> ita_portaudio_run() sin recibir en una variable la salida de la funcion va 
	% a realizar la función de play pero si escribimos >> result = ita_portaudio_run() realizará la función record and play.
	% esto se puede observar en las lineas de codigo de la función ita_portaudio_run():
	% 				if nargout > 0
	%					record = true;
	% 				else
	% 					record = false;
	% 				end
   methods
       function this = samnsAudio(varargin)
       end
       
     %% Geters
        function result =   get.time(this)
            % output n-dimensions     VER
            result = reshape(this.timeData, [this.nSamples this.dimensions]);
        end
        function result =   get.freq(this)
            % output n-dimensions
            result = reshape(this.freqData, [this.nBins this.dimensions]);
        end
        function result =   get.timeData(this)
            this = cal_ifft(this);
            result = this.data;
        end
        function result =   get.freqData(this)
            this = cal_fft(this);
            result = this.data;
        end
        function result = 	get.freqAmp(this)
            aux = fft(this.timeData,[],1);
            result = aux(1:floor(size(aux,1)/2)+1,:);
        end
        function result =   get.data(this)
            result = get_data(this);
        end
        function result =   get.domain(this)
            result = this.mDomain;
        end
        function result =   get.samplingRate(this)
            result = this.mSamplingRate;
        end       
        function result =   get.signalType(this)
            result = this.mSignalType;
        end        
        function result =   get.dimensions(this)
            result = this.mDimensions;
        end
        function result =   get.dataType(this)
            result = class(this.mData);
        end
        function result =   get.dataTypeOutput(this)
            result = this.mDataTypeOutput;
        end
        function result =   get.dataFactor(this)
            result = this.mDataFactor;
        end       
        function result =   get.comment(this)
            result = this.mComment;
        end
        function result =   get.trackLength(this)             % Obtiene la duración en segundos
           
            result = this.nSamples ./ this.samplingRate;    % Divide samples/fs
            % mpo: changed the output back to double, simpler to work with
        end         
        function result =   get.nBins(this)
            result = get_nBins(this);
        end
        function result =   get.nSamples(this)
            result = get_nSamples(this);
        end       
     
     %% Seters  
        function this =     set.time(this,value)
            dimensionsValue = size(value);
            n_Samples = dimensionsValue(1);
            this.timeData = reshape(value, n_Samples, []);
            this.dimensions = dimensionsValue(2:end);
        end
        function this =     set.freq(this,value)
            dimensionsValue = size(value);
            n_Bins = dimensionsValue(1);
            this.freqData = reshape(value, n_Bins, []);
            this.dimensions = dimensionsValue(2:end);
        end
        function this =     set.timeData(this,value)
            this.domain = 'time';
            this.data = value;
        end       
        function this =     set.freqData(this,value)
            this.domain = 'freq';
            this.data = value;
        end
        function this =     set.freqAmp(this,value)
            this.timeData = ifft([value; value(end-1:-1:2,:)],[],1,'symmetric');
        end       
        function this =     set.data(this,value)
            sizeValue = size(value);

            if numel(sizeValue) > 2
                error([upper(mfilename) '.set.data  only 2D-data is allowed, use .freq or .time for higher dimensions']);
            end

            % BMA: Vector can be given as columns or rows.
            %if sizeValue(1) == 1
            %    value = value(:); % RSC - there is a bug here a = itaResult; a.freq = zeros(1,3); leads to a result with 3 bins and 3 channels
            %end

            this = set_data(this, value);

            if prod(this.dimensions) ~= sizeValue(2)
                % only set the dimensions if there is inconsistent data
                this.dimensions = sizeValue(2);
            end

        end
        function this =     set.domain(this,value)
            % only do something if there is a change
            if strcmpi(this.domain, value)
                return;
            end
            
            % the domain will be switched, data set to NaNs
            %             nChannels = this.nChannels;
            switch lower(value)
                case 'time'
                    %                   this.data = nan(this.nSamples, nChannels);
                    this.mDomain = 'time';
                case 'freq'
                    %                     nBins = this.nBins;
                    this.mDomain = 'freq';
                    %                    this.data = nan(nBins, nChannels) + 1i * nan(nBins, nChannels);
                otherwise
                    error('%s:I don''t know this domain.',upper(mfilename))
            end
        end    
        function this =     set.samplingRate(this,value)
            if isscalar(value)
                this.mSamplingRate = value;
            else
                error('%s.set.samplingRate  samplingRate debe ser un valor escalar',mfilename);
            end
        end   
        function this =     set.signalType(this,value)
            if ismember(value, this.VALID_SIGNAL_TYPES)
                this.mSignalType = value;
            else
                warning([upper(mfilename) '.set.signalType  ignoring unknown input'])
            end
        end      
        function this =     set_data(this,value)
            % this functions is needed for class itaAudioDevNull
            % and for the check of even number of samples
            if ~isa(value, this.dataType)
                if any(strcmp('int',this.dataType)) && ~any(strcmp('int',this.dataTypeOutput))
                    this.dataFactor = double(max(max(abs(value)))) ./ (double(intmax(this.dataType))-1);
                    value = value ./ this.mDataFactor;
                end
                wstate = [warning('off','MATLAB:intConvertNonIntVal') warning('off','MATLAB:intConvertNaN')];
                this.mData = cast(value,this.dataType);
                warning(wstate);
                disp('Changing data-type. Some information may be lost')
            else
                this.mData = value;
            end
        end        
        function this =     set.dimensions(this,value)
            if isnumeric(value)

                this.mDimensions = value;
            else
                error('Samdir Audio: La dimension debe ser numerica!')
            end
        end      
        function this =     set.dataType(this,value)
            this = cast(this,value);
        end       
        function this =     set.dataTypeOutput(this,value)
            this.mDataTypeOutput = value;
            if strcmp (this.dataType, value)
                this.mDataTypeEqual = true;
            else
                this.mDataTypeEqual = false;
            end
            if strcmp('int',value)
                ita_verbose_info('Sorry, but ''int'' is really dangerous for dataTypeOutput, please use double or single.',1)
            end
        end       
        function this =     set.dataFactor(this,value)
            this.mDataFactor = value;
            if value ~= 1
                ita_verbose_info('Please be carefull setting dataFactor!');
            end
        end      
        function this =     set.comment(this,value)
            this.mComment = value;
        end
        function this =     set.trackLength(this, value)
            n_Samples = this.samplingRate * double(value);
            if isfinite(n_Samples)
                this = set_nSamples(this, n_Samples);
            else
                disp('Cannot set trackLength, nSamples are not finite. Check the samplingRate.');  %VER
            end
        end       
        function this =     set.nSamples(this,value)
            this = set_nSamples(this,value);
        end        
        
        %% is* Stuff
        function result = isFreq(this)
            result = zeros(size(this));
            for ind = 1:numel(result)
                result(ind) = strcmp(this(ind).domain,'freq');
            end
        end
        function result = isEvenSamples(this)
            %isEvenSamples - return 1 if sample number is even
            result = this.mEvenSamples;
        end        
        function result = isPower(this)
            %isPower - returns 1 if power signal
            result = nan(size(this));
            for ind = 1:numel(result)
                result(ind) = strcmp(this(ind).signalType,'power');
            end
        end
        function result = isEnergy(this)
            %isEnergy - returns 1 if energy signal
            result = nan(size(this));
            for ind = 1:numel(result)
                result(ind) = strcmp(this(ind).signalType,'energy');
            end
        end
        function result = isempty(this)
            result = false(size(this));
            for idx = 1:numel(this)
                result(idx) = isempty(this(idx).data);
            end
        end
        function result = isTime(this)
            result = zeros(size(this));
            for ind = 1:numel(result)
                result(ind) = strcmp(this(ind).domain,'time');
            end
        end
          
          %% Vector
        function result = timeVector(this,idx)
            %timeVector - get the time vector (x-axis) in seconds starting at 0
            %seconds till trackLength
            if numel(this) ~= 1
                error('just works on single instances');
            end
            result = linspace(0,double(this.trackLength),this.nSamples+1).';
            result(end) = [];
            if nargin == 2
                result = result(idx);
            end
        end
        function result = freqVector(this, index)
            %freqVector - returns the frequency vector (x-axis) in Hz
            
            if numel(this) ~= 1
                error('just works on single instances');
            end
            SR = this.samplingRate;
            if isnan(SR) || isinf(SR) || ~isscalar(SR)
                error([upper(mfilename) '.freqVector  wrong samplingRate set']);
            end
            if nargin < 2
                
                if this.isEvenSamples
                    
                    result = linspace(0,this.samplingRate/2,this.nBins).';
                else
                    result = linspace(0,this.samplingRate/2*(1-1/(2*this.nBins-1)),this.nBins).';
                end   
            else
                if this.isEvenSamples
                    result = (index-1)/(this.nBins-1) * this.samplingRate/2;
                else
                    result = (index-1)/(this.nBins-0.5) * this.samplingRate/2;
                end
            end
            
        end
        
        %% get DATA in dB
        function result = freqData_dB(this,varargin)        %Devuelve los datos en frecuencia en dB
            
            refValues = max (abs(this.freqData));      %Realiza 20*log10(abs(Obj.freq)/referenceValue)
            log_prefix = 20;
            
            % changed from log10(x) to log(x)/log(10) because it is faster
            result = bsxfun(@times, log_prefix(:).'./log(10), log(abs(this.freqData + realmin))); %plus eps to avoid -Inf
            result = bsxfun(@plus,result, log_prefix(:).'./log(10).*log(1./refValues(:).'));
        end
         %% funciones auxiliares
        function result     = get_nBins(this)
            if this.isFreq
                result = size(this.data,1);
            else
                result = this.nSamples2nBins;
            end
        end 
        function result     = get_data(this)
            if ~this.mDataTypeEqual || any(this.mDataFactor ~= 1)
                if strcmp('int',this.dataTypeOutput)
                    result = cast(this.mData,this.dataTypeOutput);
                else
                    result = cast(this.mData,this.dataTypeOutput)  .* this.mDataFactor;
                end
            else
                result = this.mData;
            end
        end        
        function nBins      = nSamples2nBins(this)       
             %nSamples2nBins - converts between sample and bin number
            n_Samples = this.nSamples;
            % check for empty data
            if n_Samples == 0, nBins = 0; return, end
            % check if odd number of samples
            if this.isEvenSamples
                nBins = (n_Samples/2) + 1;
                %                 error([upper(mfilename) '.nSamples2nBins odd number of samples not allowed']);
            else
                nBins = (n_Samples+1) / 2;
            end
        end       
        function result     = get_nSamples(this)
            if this.isTime
                result = size(this.data,1);
            else
                result = this.nBins2nSamples;
            end
        end      
        function nSamples   = nBins2nSamples(this)
            %nSamples2nBins - converts between sample and bin number
            
            % check for empty data
            n_Bins = this.nBins;
            if n_Bins == 0, nSamples = 0; return, end
            if this.isEvenSamples
                nSamples = 2 * (n_Bins - 1);
            else
                nSamples = (n_Bins * 2) - 1;
            end
        end

   end 
end