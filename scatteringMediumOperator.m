classdef scatteringMediumOperator < matlab.mixin.Copyable
% CLASS SCATTERINGMEDIUMOPERATOR - Implements scattering of an object by a
%                                  scattering medium as a function of time.
%                                  The temporal-response of the scattering 
%                                  medium is given by its N-D point-spread function.
%              
% Constructor:
%   obj = scatteringMediumOperator(PSF,objectSizePixels,boundaryCondition,outputSize)
%
% Inputs:
%    PSF                       : Temporal point-spread function (PSF) of the scattering medium [rows,cols,timeIndex].
%    objectSizePixels          : Size of the object in pixels. 
%    boundaryCondition         : Type of boundary-condition to be applied, one of
%              (Optional)      'Symmetric'   - Input-array values outside the image are assumed by mirror-reflecting the boundary.
%                              'Replicate'   - Input-array values outside the image are assumed by replicating the boundary.
%                              'Circular'    - Input-array values outside the image is assumed to be periodic. 
%                              Default is 'Symmetric'.
%    outputSize(Optional)      : Size of the output-array. Size of the output-array can be one of, 
%                              'Same'        - Output-array size is the same as that of the input-array. 
%                              'Full'        - Output-array size is the
%                              full filtered array size, larger than the
%                              input-array. 
%                              Default is 'Same'.
%
% Output:
%    obj                     : scatteringMediumOperator type object with 
%                              overloaded functions.
%
% Overloaded Methods:
%    conj(obj)      : Returns a copy of the adjoint object.
%    transpose(obj) : Returns a copy of the adjoint operator.
%    ctranspose(obj): Returns a copy of the adjoint operator.
%    mtimes(obj,x)  : Called when used as (obj*x). Applies the specified 
%                     scatteringMediumOperator on an image x after reshaping it to
%                     objectSizePixels. The number of elements in x must be
%                     prod(objectSizePixels).
%

% Author   : Sudarshan Nagesh             
% Institute: NorthWestern University (NU) 

properties(Constant)
    listOfSupportedBoundaryConditions = {'Symmetric','Replicate','Circular'};
    listOfSupportedOutputSize         = {'Same','Full'};
end

properties

    % Properties provided as input.
    PSF
    objectSizePixels
    boundaryCondition
    outputSize
    
    adjoint         = false;
end

methods
    % Function detectorSamplingOperator - Constructor.
    function obj = scatteringMediumOperator(PSF,objectSizePixels,boundaryCondition,outputSize)
        
        if nargin < 4
            outputSize = 'Same';
            if nargin < 3
                boundaryCondition = 'Symmetric';
            end
        end
        obj.PSF                 = PSF;
        obj.objectSizePixels    = objectSizePixels;
        obj.boundaryCondition   = boundaryCondition;
        obj.outputSize          = outputSize;
     end
    
    % Overloaded function for conj().
    function res = conj(obj)
        res = obj;
    end
    
    % Overloaded function for .' (transpose()).
    function res = transpose(obj)
%        res = obj.getAdjointOperator();
         res = obj;
    end
    
    % Overloaded function for ' (ctranspose()).
    function res = ctranspose(obj)
%        res = obj.getAdjointOperator();
        res = obj;
    end
    
    % Overloaded function for * (mtimes()).
    function res = mtimes(obj,x)
        
        if obj.adjoint
            res = x;
        else
            x   = reshape(x,obj.objectSizePixels);
            for ind = 1:size(obj.PSF,3)
                res(:,:,ind) = imfilter(x,obj.PSF(:,:,ind),obj.boundaryCondition,obj.outputSize);
            end
        end
        res = res(:);
    end
        
end

methods(Access = private)
    % Function getAdjoint - Returns the adjoint flag of the object.
    function adjoint = getAdjoint(obj)
        adjoint = obj.adjoint;
    end
    
    % Function setAdjoint - Sets the adjoint flag of the object.
    function setAdjoint(obj,adjoint)
        obj.adjoint = adjoint;
    end
    
    % Function getAdjointOperator - Copies and returns an object with its
    % adjoint flag reversed.
    function res = getAdjointOperator(obj)
        res = copy(obj);
        res.setAdjoint(xor(obj.getAdjoint(),true));
    end
end


methods    
    % Check validity of properties provided as input.
    
    function set.objectSizePixels(obj,objectSizePixels)
        validateattributes(objectSizePixels,...
                           {'numeric'},...
                           {'nonsparse','vector','numel',2,'integer','positive'},...
                           mfilename,'objectSizePixels',1);
        if ~isa(objectSizePixels,'double')
            objectSizePixels = double(objectSizePixels);
        end
        if ~isrow(objectSizePixels)
            objectSizePixels = objectSizePixels(:)';
        end
        obj.objectSizePixels = objectSizePixels;
    end
    
    function set.boundaryCondition(obj,boundaryCondition)
        if ~isempty(boundaryCondition)
            validateattributes(boundaryCondition,...
                               {'char'},{'nonempty'},...
                               mfilename,'boundaryCondition',1);
            if ~ismember(boundaryCondition,obj.listOfSupportedBoundaryConditions)
                error(strcat('Variable boundary conditions contains a method that is not supported.\n',...
                             'Supported interpolation methods are: ',obj.listOfSupportedBoundaryConditions));
            end
        else
            boundaryCondition = 'Symmetric';
        end
        obj.boundaryCondition = boundaryCondition;
    end
    
    function set.outputSize(obj,outputSize)
        if ~isempty(outputSize)
            validateattributes(outputSize,...
                               {'char'},{'nonempty'},...
                               mfilename,'outputSize',1);
            if ~ismember(outputSize,obj.listOfSupportedOutputSize)
                error(strcat('Variable output size contains a method that is not supported.\n',...
                             'Supported interpolation methods are: ',obj.listOfSupportedOutputSize));
            end
        else
            outputSize = 'Same';
        end
        obj.outputSize = outputSize;
    end
end

end