classdef myAccuracy < dagnn.Loss
    
  properties (Transient)
    rel_error = 0
    log_error = 0
    rm_error = 0
  end
    
  methods
     function outputs = forward(obj, inputs, params)
        est_d_values = gather(inputs{1});
        est_d_values_pow = power(10,est_d_values);
        gt_d_values_pow = inputs{2};
        temp_m = inputs{2}==1000;
        est_d_values_pow(temp_m) = gt_d_values_pow(temp_m);
        marks = ones(size(inputs{2}));
        marks(temp_m) = 0;
        pixelnum = sum(sum(sum(marks,1),2));
%         pixelnum = size(inputs{1},1)*size(inputs{1},2);
        
        rel_error_tmp = sum(sum(sum((abs(est_d_values_pow-gt_d_values_pow)./gt_d_values_pow),1),2));
        log_error_tmp = sum(sum(sum((abs(log10(est_d_values_pow)-log10(inputs{2}))),1),2));
        rm_error_tmp = sum(sum(sum((est_d_values_pow-gt_d_values_pow).^2,1),2));
              
        obj.rel_error = obj.rel_error + rel_error_tmp;
        obj.log_error = obj.log_error + log_error_tmp;
        obj.rm_error = obj.rm_error + rm_error_tmp;
        
        obj.numAveraged = obj.numAveraged + pixelnum ;
        outputs{1} = obj.average ;
        
     end
     
     function [derInputs, derParams] = backward(obj, inputs, params, derOutputs)
        derInputs{1} = [] ;
        derInputs{2} = [] ;
        derParams = {} ;
     end
     
     function reset(obj)
        obj.rel_error = 0 ;
        obj.log_error = 0 ;
        obj.rm_error = 0 ;
        obj.average = [0;0;0] ;
        obj.numAveraged = 0 ;
     end
     
     function recalerror(obj)
        obj.rel_error = obj.rel_error/obj.numAveraged;
        obj.log_error = obj.log_error/obj.numAveraged;
        obj.rm_error = sqrt(obj.rm_error/obj.numAveraged);
        obj.average = [obj.rel_error; obj.log_error; obj.rm_error] ;
     end
     
     function str = toString(obj)
        str = sprintf('rel_error:%.3f, log_error:%.3f, rm_error:%.3f', ...
                    obj.rel_error, obj.log_error, obj.rm_error) ;
     end
      
     function obj = myAccuracy(varargin)
        obj.load(varargin) ;
     end
   end
    
    
end

