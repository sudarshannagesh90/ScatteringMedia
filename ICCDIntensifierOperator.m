classdef ICCDIntensifierOperator < matlab.mixin.Copyable
% CLASS INTENSIFIEROPERATOR -  Implements intensification of the
%                              input-photons when incident on the ICCD
%                              sensor.
%                                  .
%              
% Constructor:
%   obj = ICCDIntensifierOperator(objectSizePixels,quantumEfficiency,darkCurrent,multiChannelPlateAmplification,phosphorScreenEfficiency,exposureDuration)
%
% Inputs:
%    objectSizePixels          : Size of the object in pixels given as [rows,cols,numberOfImages]. 
%    quantumEfficiency         : Qunatum-efficiency of the photo-cathode in
%                                electrons per photon.
%    darkCurrent               : Dark-current emitted in
%                                electrons/pixel/second. 
%multiChannelPlateAmplification: Amplification of the electrons by multi-channel plate.
%phosphorScreenEfficiencyPSF   : Efficiency of the phosphor-screen photons/electron.
%    exposureDuration          : Exposure-duration in seconds.


% Output:
%    obj                       : ICCDIntensifierOperator type object with 
%                              overloaded functions.
%
% Overloaded Methods:
%    conj(obj)      : Returns a copy of the object.
%    transpose(obj) : Returns a copy of the operator.
%    ctranspose(obj): Returns a copy of the operator.
%    mtimes(obj,x)  : Called when used as (obj*x). Applies the specified 
%                     ICCDIntensifierOperator on an image x after reshaping it to
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
    multiChannelPlateAmplification
    phosphorScreenEfficiency
    exposureDuration
    
end

methods
    % Function detectorSamplingOperator - Constructor.
    function obj = ICCDIntensifierOperator(objectSizePixels,quantumEfficiency,darkCurrent,multiChannelPlateAmplification,phosphorScreenEfficiency,exposureDuration)

        obj.objectSizePixels                       = objectSizePixels;
        obj.quantumEfficiency                      = quantumEfficiency;
        obj.darkCurrent                            = darkCurrent;
        obj.multiChannelPlateAmplification         = multiChannelPlateAmplification;
        obj.phosphorScreenEfficiency               = phosphorScreenEfficiency;
        obj.exposureDuration                       = exposureDuration;
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
        imageInElectrons = imageInElectrons*obj.multiChannelPlateAmplification;
        imageInElectrons = imageInElectrons*obj.phosphorScreenEfficiency;
        res              = floor(imageInElectrons);
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

    function set.multiChannelPlateAmplification(obj,multiChannelPlateAmplification)
        validateattributes(multiChannelPlateAmplification,...
                           {'double','single'},...
                           {'nonsparse','scalar','real','nonnan','finite','positive',},...
                           mfilename,'multiChannelPlateAmplification');
        if ~isa(multiChannelPlateAmplification,'double')
            multiChannelPlateAmplification = double(multiChannelPlateAmplification);
        end
        obj.multiChannelPlateAmplification = multiChannelPlateAmplification;
    end 
    function set.phosphorScreenEfficiency(obj,phosphorScreenEfficiency)
        validateattributes(phosphorScreenEfficiency,...
                           {'double','single'},...
                           {'nonsparse','scalar','real','nonnan','finite','positive',},...
                           mfilename,'phosphorScreenEfficiency');
        if ~isa(phosphorScreenEfficiency,'double')
            phosphorScreenEfficiency = double(phosphorScreenEfficiency);
        end
        obj.phosphorScreenEfficiency = phosphorScreenEfficiency;
    end
    function set.exposureDuration(obj,exposureDuration)
        validateattributes(exposureDuration,...
                           {'double','single'},...
                           {'nonsparse','scalar','real','nonnan','finite','positive',},...
                           mfilename,'exposureDuration');
        if ~isa(exposureDuration,'double')
            exposureDuration = double(exposureDuration);
        end
        obj.exposureDuration = exposureDuration;
    end
    
end

end