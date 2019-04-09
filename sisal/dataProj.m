function [yp,Up,my,sing_val] = dataProj(y,p,varargin)
%%
% Usage:
% [yp,Up,my,sing_val] = dataProj(y,p,varargin)
%
% This function estimates the subspace and the afine space related with the
% observation model
%
%     y = M*x+noise
%
% where M is the mixing matrix containing the endmembers, x is the
% the fractions (sources) of each enmember at each pixel, and noise is a
% an  additive perturbation.
% 
%
% 
% Author: Jose Bioucas-Dias, January, 2009.
% 
% Please check for the latest version of the code and papers at
% www.lx.it.pt/~bioucas/SUNMIX
%
% 
%
%  =====================================================================
%  ===== Required inputs ===============================================
%
%  y [Lxn] = noisy data set generated by a [Lxp] endmember matrix
%     
%  p  = number of endmembers (defines the signal affine dimension)
%
%  ===== Optional inputs =============
% 
%  
%  'proj_type' =  ptojection type  {'ml', 'affine'}
%                'ml'      -> maximum likelihood  (ml)  identification of the signal p-dimensional subspace 
%                             (in the l2 sense): Infers an isometric
%                             matrix, Up, such that ||y-yp|, where yp=Up*Up'*y is
%                             minimized
%
%
%
%                'affine'  -> (best (p-1)-dimesional affine set in the l2
%                              sense <==> pca). Infers an isometric
%                             matrix, U(p-1), and a vector b such that ||y-yp|, where yp=U(p-1)*U(p-1)'*(y-b)+b is
%                             minimized. An isometric matrix, Up, that
%                             spans the p-dimensional  subspace  where
%                             vectors yp live is also computed.
%                             This projections leads to a better SNR.
%
%                             Default: 'affine'

%
%
% ===================================================  
% ============ Outputs ==============================
%
%   yp = [pxsamp_size] projected data set
%
%   Up =  [Lxp] isometric matrix:  yp-Up*Up'*yp = 0       
%   my =  data set mean value
%
%   sing_values = larger singular values 
%                 'ml' - p larger of Ry
%                 'affine' (p-1) larger of Cy
%
%  
%  Note: in the 'affine' case: yp = Up(:,1:p-1)*Up(:,1:p-1)'*(yp-my) + my;
%        i.e., the couple (Up(:,1:p-1)*Up(:,1:p-1)', my) defines the (p-1)
%        dimensional affine set in which the signal component of y lives.
%
% ========================================================
%    
% ===================================================  
% ============ Call examples ==============================
%
%  yp =dataProj(y,p)
%
%  [yp,Up,my,sing_val] =dataProj(y,p,'proj_type', 'ml')
%
%  [yp,Up,my,sing_val] =dataProj(y,p)
%
% 
%





%%
%--------------------------------------------------------------
% test for number of required parametres
%--------------------------------------------------------------
if (nargin-length(varargin)) ~= 2
     error('Wrong number of required parameters');
end

% endmember matrix size 
[L,samp_size] = size(y); %((L-> number of bands, samp_sise -> sample size)


%--------------------------------------------------------------
% Set the defaults for the optional parameters
%--------------------------------------------------------------

proj_type   = 'affine';



%--------------------------------------------------------------
% Read the optional parameters
%--------------------------------------------------------------
if (rem(length(varargin),2)==1)
  error('Optional parameters should always go by pairs');
else
  for i=1:2:(length(varargin)-1)
    switch upper(varargin{i})
     case 'PROJ_TYPE'
       proj_type = varargin{i+1};
     otherwise
      % Hmmm, something wrong with the parameter string
      error(['Unrecognized option: ''' varargin{i} '''']);
    end;
  end;
end
%%%%%%%%%%%%%%

%% projections 
 my = mean(y,2);
 switch  proj_type
    case 'ml'
        [Up,D] = svds(y*y'/samp_size,p);   % compute the p largest singular values and the
                                % corresponding singular vectors
        sing_val = diag(D);  
        yp = Up'*y;              % project onto the subspace span{E}
    case 'affine'
        yp = y-repmat(my,1,samp_size);
        [Up,D] = svds(yp*yp'/samp_size,p-1);         
        % represent yp in the subspace R^p 
        yp = Up*Up'*yp;
        % lift yp
        yp = yp + repmat(my,1,samp_size);   %
        % compute the orthogonal componeny of my
        my_ortho = my-Up*Up'*my;
        % define anothre orthonormal direction
        Up = [Up my_ortho/sqrt(sum(my_ortho.^2))];
        sing_val = diag(D);   
 end
        

return




