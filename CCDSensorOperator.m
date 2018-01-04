classdef CCDSensorOperator < matlab.mixin.Copyable
% CLASS CCDSENSOROPERATOR -  Converts electrons incident on sensor to
%                            gray-level image. This class also adds
%                            poisson, dark-current and read-noise. 
%                             
%                                  .
%              
% Constructor:
%   obj = CCDSensorOperator(objectSizePixels,quantumEfficiency,darkCurrent,readNoise,exposureDuration,fullWellCapacity,saturationImageIndex,numberOfBits)
%
% Inputs:
%    objectSizePixels          : Size of the object in pixels given as [rows,cols,numberOfImages]. 
%    quantumEfficiency         : Qunatum-efficiency of the sensor in
%                                electrons per photon.
%    darkCurrent               : Dark-current emitted in
%                                electrons/pixel/second. 
%    readNoise                 : Read-noise emitted in
%                                electrons/pixel. 
%    exposureDuration          : Exposure-duration in seconds.
%    fullWellCapacity          : Full-well capacity of sensor in electrons/pixel.
%    saturationImageIndex      : Index of the image that saturates.
%    numberOfBits              : Number of bits on the digital-sensor.
%
% Output:
%    obj                       : ICCDIntensifierOperator type object with 
%                              overloaded functions.
%
% Overloaded Methods:
%    conj(obj)      : Returns a copy of the object.
%    transpose(obj) : Returns a copy of the operator.
%    ctranspose(obj): Returns a copy of the operator.
%    mtimes(obj,x)  : Called when used as (obj*x). Applies the specified 
%                     CCDSENSOROPERATOR on an image x after reshaping it to
%                     objectSizePixels. The number of elements in x must be
%                     prod(objectSizePixels).
%

% Author   : Sudarshan Nagesh             
% Institute: NorthWestern University (NU) 

properties

    % Properties provided as input.
    objectSizePixels
    quantumEfficiency
    darkCurrent
    readNoise
    exposureDuration
    fullWellCapacity
    saturationImageIndex
    numberOfBits    
    
end

methods
    % Function detectorSamplingOperator - Constructor.
    function obj = CCDSensorOperator(objectSizePixels,quantumEfficiency,darkCurrent,readNoise,exposureDuration,fullWellCapacity,saturationImageIndex,numberOfBits)
        obj.objectSizePixels                       = objectSizePixels;
        obj.quantumEfficiency                      = quantumEfficiency;
        obj.darkCurrent                            = darkCurrent;
        obj.readNoise                              = readNoise;
        obj.exposureDuration                       = exposureDuration;
        obj.fullWellCapacity                       = fullWellCapacity;
        obj.exposureDuration                       = exposureDuration;
        obj.saturationImageIndex                   = saturationImageIndex;
        obj.numberOfBits                           = numberOfBits;
    end
    
    % Overloaded function for conj().
    function res = conj(obj)
        res = obj;
    end
    
    % Overloaded function for .' (transpose()).
    function res = transpose(obj)
         res = obj;
    end
    
    % Overloaded function for ' (ctranspose()).
    function res = ctranspose(obj)
        res = obj;
    end
    
    % Overloaded function for * (mtimes()).
    function res = mtimes(obj,x)
        x   = reshape(x,obj.objectSizePixels);
        x   = double(x);
        imageInElectrons = x*obj.quantumEfficiency+obj.darkCurrent*obj.exposureDuration;
        imageInElectrons = floor(imageInElectrons);
        imageInElectrons = poissrnd(imageInElectrons);
        for ind = 1:size(imageInElectrons,3)
            imageInElectrons(:,:,ind) = imageInElectrons(:,:,ind)+obj.readNoise*randn(size(imageInElectrons(:,:,ind)));
        end
        imageInElectrons = min(imageInElectrons,obj.fullWellCapacity);
        imageInElectrons(imageInElectrons<=0) = 0;
        maxVals            = squeeze(max(max(imageInElectrons)));
        [maxValue]= max(maxVals);  
        maxIndex  = find(maxVals == max(maxVals(:)));
        maxIndex  = min(maxIndex);
        disp(['Maximum-number of electrons: ',num2str(maxValue),' and index is ',num2str(maxIndex)])
        if maxVals(obj.saturationImageIndex-1)==obj.fullWellCapacity
           disp(['ImageIndex ',num2str(obj.saturationImageIndex-1),' is also saturated']);
           disp(['Reduce the saturation image index or reduce the number of photons in simulation or amplification gain']);
        end
        gain          =  (2^(obj.numberOfBits)-1)/maxVals(obj.saturationImageIndex);
        imageInVolts  =  gain*imageInElectrons;
        imageInVolts  =  floor(imageInVolts);
        res           =  dec2bin(imageInVolts,12);
    end
end

methods    
    % Check validity of properties provided as input.
    
    function set.objectSizePixels(obj,objectSizePixels)
        validateattributes(objectSizePixels,...
                           {'numeric'},...
                           {'nonsparse','vector','numel',3,'integer','positive'},...
                           mfilename,'objectSizePixels',1);
        if ~isa(objectSizePixels,'double')
            objectSizePixels = double(objectSizePixels);
        end
        if ~isrow(objectSizePixels)
            objectSizePixels = objectSizePixels(:)';
        end
        obj.objectSizePixels = objectSizePixels;
    end
    
    function set.quantumEfficiency(obj,quantumEfficiency)
        validateattributes(quantumEfficiency,...
                           {'double','single','<',1},...
                           {'nonsparse','scalar','real','nonnan','finite','positive'},...
                           mfilename,'quantumEfficiency');
        if ~isa(quantumEfficiency,'double')
            quantumEfficiency = double(quantumEfficiency);
        end
        obj.quantumEfficiency = quantumEfficiency;
    end
    function set.darkCurrent(obj,darkCurrent)
        validateattributes(darkCurrent,...
                           {'double','single'},...
                           {'nonsparse','scalar','real','nonnan','finite','positive',},...
                           mfilename,'darkCurrent');
        if ~isa(darkCurrent,'double')
            darkCurrent = double(darkCurrent);
        end
        obj.darkCurrent = darkCurrent;
    end
    function set.readNoise(obj,readNoise)
        validateattributes(readNoise,...
                           {'double','single'},...
                           {'nonsparse','scalar','real','nonnan','finite','positive',},...
                           mfilename,'readNoise');
        if ~isa(readNoise,'double')
            readNoise = double(readNoise);
        end
        obj.readNoise = readNoise;
    end

    function set.fullWellCapacity(obj,fullWellCapacity)
        validateattributes(fullWellCapacity,...
                           {'double','single'},...
                           {'nonsparse','scalar','integer','finite','positive',},...
                           mfilename,'fullWellCapacity');
        if ~isa(fullWellCapacity,'double')
            fullWellCapacity = double(fullWellCapacity);
        end
        obj.fullWellCapacity = fullWellCapacity;
    end 
    function set.saturationImageIndex(obj,saturationImageIndex)
        validateattributes(saturationImageIndex,...
                           {'double','single'},...
                           {'nonsparse','scalar','integer','finite','positive',},...
                           mfilename,'saturationImageIndex');
        if ~isa(saturationImageIndex,'double')
            saturationImageIndex = double(saturationImageIndex);
        end
        obj.saturationImageIndex = saturationImageIndex;
    end 
    function set.numberOfBits(obj,numberOfBits)
        validateattributes(numberOfBits,...
                           {'double','single'},...
                           {'nonsparse','scalar','integer','finite','positive',},...
                           mfilename,'numberOfBits');
        if ~isa(numberOfBits,'double')
            numberOfBits = double(numberOfBits);
        end
        obj.numberOfBits = numberOfBits;
    end 
end

end