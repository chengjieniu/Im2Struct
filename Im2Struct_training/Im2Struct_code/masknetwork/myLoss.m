classdef myLoss < dagnn.Loss
 
  properties (Transient)
    clip_d = 1
  end
    
  methods
    function outputs = forward(obj, inputs, params)
      d_errors = gather(inputs{1})-log10(inputs{2});
      marks = ones(size(inputs{2}));
      marks(inputs{2}==1000) = 0;
      d_errors = d_errors.*marks;
%       pixelnum = size(inputs{1},1)*size(inputs{1},2)*size(inputs{1},4);
      pixelnum = sum(sum(sum(marks,1),2));
      outputs{1} = sum(sum(sum(d_errors.^2,1),2));
      n = obj.numAveraged ;
      m = n + pixelnum ;
      obj.average = (n * obj.average + outputs{1}) / m ;
      obj.numAveraged = m ;      
    end

    function [derInputs, derParams] = backward(obj, inputs, params, derOutputs)
      d_errors = gather(inputs{1})-log10(inputs{2});
      marks = ones(size(inputs{2}));
      marks(inputs{2}==1000) = 0;
      d_errors = d_errors.*marks;
      
      dx = zeros(size(d_errors), 'single');
      
      bs = size(inputs{2},4);
      for ii = 1:bs
          dx(:,:,:,ii) = 2*d_errors(:,:,:,ii);
      end
   
      estd = gather(inputs{1});
      for ii = 1:3:bs
          d1 = estd(:,:,:,ii);
          d2 = estd(:,:,:,ii+1);
          d3 = estd(:,:,:,ii+2);
          refd1 = flip(d1,2);
          refd2 = flip(d2,2);
          refd3 = flip(d3,2);

          d12 = d1-d2;
          d21 = d2-d1;


          d1refd3 = d1-refd3;
          d2refd3 = d2-refd3;
          d3refd1 = d3-refd1;
          d3refd2 = d3-refd2;

          fd1 = d12+d1refd3;
          dx(:,:,:,ii) = dx(:,:,:,ii)+2*fd1;

          fd2 = d21+d2refd3;
          dx(:,:,:,ii+1) = dx(:,:,:,ii+1)+2*fd2;

          fd3 = d3refd1+d3refd2;
          dx(:,:,:,ii+2) = dx(:,:,:,ii+2)+2*fd3;        
      end

      dx(dx > obj.clip_d) = obj.clip_d;
      dx(dx < -obj.clip_d) = -obj.clip_d; 
      
      for jj = 1:bs
          dx(:,:,:,jj) = dx(:,:,:,jj)/16650;
      end
   
      dx = gpuArray(dx);
      derInputs{1} = dx;
      derInputs{2} = [] ;
      derParams = {} ;
    end
    
    function setClip(obj, rd)
        obj.clip_d = rd;
    end
    
    function obj = myLoss(varargin)
      obj.load(varargin) ;
    end
  end
end
