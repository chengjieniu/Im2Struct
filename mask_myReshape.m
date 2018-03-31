classdef mask_myReshape < dagnn.ElementWise
%one layer in net_mask
  
  properties
    dmap = [56; 56; 3]
  end

  properties (Transient)
    inputSizes = {}
  end

  methods
    function outputs = forward(obj, inputs, params)
      obj.inputSizes = cellfun(@size, inputs, 'UniformOutput', false) ;
      outputs{1} = reshape(inputs{1}, [obj.dmap(1) obj.dmap(2) obj.dmap(3) size(inputs{1},4)]) ;
    end

    function [derInputs, derParams] = backward(obj, inputs, params, derOutputs)
      derInputs{1} = reshape(derOutputs{1}, [1 1 obj.dmap(1)*obj.dmap(2)*obj.dmap(3) size(inputs{1},4)]) ;
      derParams = {} ;
    end

    function outputSizes = getOutputSizes(obj, inputSizes)     
      outputSizes{1} = inputSizes{1} ;
      outputSizes{1}(1) = obj.dmap(1);
      outputSizes{1}(2) = obj.dmap(2);
      outputSizes{1}(3) = obj.dmap(3);
    end

    function obj = myReshape(varargin)
      obj.load(varargin) ;
    end
  end
end
