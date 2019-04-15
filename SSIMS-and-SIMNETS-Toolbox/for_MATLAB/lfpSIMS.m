 function [CSIMS, tSNE_transform, dmat] = lfpSIMS(frmat, dim, perplexity, movingwin, param)
% [CSIMS_coordinates, tSNE_transform, basedmat] = getCSIMS(frmat, metric, dim, perplexity, paramstruc)
%
% INPUTS:
% FRmat: continous data ( #events x #bins x #neurons)
% dim: number of desired dimensions for the new space (optional, default = 3)
% perplexity: perplexity value for t-SNE (optional, default = 30)
% movingwin (in the form [window winstep] -- required from Chronux
% The funciton expects an additional parameter structure for spectral 
% analysis (using the Chronux toolbox cohgramc function)
% paramstruc: structure with fields tapers, pad, Fs, fpass, err, trialave
%         - optional
%             tapers : precalculated tapers from dpss or in the one of the following
%                      forms: 
%                      (1) A numeric vector [TW K] where TW is the
%                          time-bandwidth product and K is the number of
%                          tapers to be used (less than or equal to
%                          2TW-1). 
%                      (2) A numeric vector [W T p] where W is the
%                          bandwidth, T is the duration of the data and p 
%                          is an integer such that 2TW-p tapers are used. In
%                          this form there is no default i.e. to specify
%                          the bandwidth, you have to specify T and p as
%                          well. Note that the units of W and T have to be
%                          consistent: if W is in Hz, T must be in seconds
%                          and vice versa. Note that these units must also
%                          be consistent with the units of params.Fs: W can
%                          be in Hz if and only if params.Fs is in Hz.
%                          The default is to use form 1 with TW=3 and K=5
%                       Note that T has to be equal to movingwin(1).
%  
%  	        pad		    (padding factor for the FFT) - optional (can take values -1,0,1,2...). 
%                      -1 corresponds to no padding, 0 corresponds to padding
%                      to the next highest power of 2 etc.
%  			      	 e.g. For N = 500, if PAD = -1, we do not pad; if PAD = 0, we pad the FFT
%  			      	 to 512 points, if pad=1, we pad to 1024 points etc.
%  			      	 Defaults to 0.
%             Fs   (sampling frequency) - optional. Default 1.
%             fpass    (frequency band to be used in the calculation in the form
%                                     [fmin fmax])- optional. 
%                                     Default all frequencies between 0 and Fs/2
%             err  (error calculation [1 p] - Theoretical error bars; [2 p] - Jackknife error bars
%                                     [0 p] or 0 - no error bars) - optional. Default 0.
%             trialave (average over trials when 1, don't average when 0) - optional. Default 0
%
% OUTPUT:
% CSIMS_coordinates: dim-dimenstional coordinates of the points associated
% with each firing rate vector
% tSNE_transform: matrix that replicates the transform optimized by tSNE
% 	(multiply new data by this matrix to project onto the same coordinate space)
% basedmat: distance matrix of spike trains. Its size is
% 		[numel(ev), size(frmat,1) * size(frmat,3)]
% 	It consists of the [size(frmat,1), size(frmat,1)] distance matrices for each unit concatenated along the second dimension.

% @author Carlos Vargas-Irwin, Jonas Zimmermann
% Copyright (c) Carlos Vargas-Irwin, Brown University. All rights reserved.


dim
perplexity
movingwin
param




tic;
dmat{1} = [];
% calculate and concatenate distance matrices
ix = 1;
parfor n = 1:size(frmat,3) 
    
    dmat{n}= squareform(pdist(frmat(:,:,n), @(Xi,Xj) xcohdist(Xi,Xj,movingwin,param)  ));  

end
telapsed = toc;
fprintf('Calculated the base distances for %i channels in %4.1f seconds.\n', size(frmat,3), telapsed )

alldmat = horzcat(dmat{:});

% apply t-SNE
[CSIMS, tSNE_transform, kld] = runtSNE(alldmat, dim, perplexity);

%     A distance function must be of the form
%  
%           function D2 = DISTFUN(XI, XJ),
%  
%     taking as arguments a 1-by-N vector XI containing a single row of X, an
%     M2-by-N matrix XJ containing multiple rows of X, and returning an
%     M2-by-1 vector of distances D2, whose Jth element is the distance
%     between the observations XI and XJ(J,:).

