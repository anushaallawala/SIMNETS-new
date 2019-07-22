function [ SNETS ] = SSIMNETS(dmat, dim, perp, crange,varargin)

%  SPIKE TRAIN SIMILARITY SPACE TOOLBOX% 
%
% [ SNETS ] = SSIMNETS(dmat, dim, perp, crange,varargin)
%
%  OVERVIEW:
%  This function identifies 'functional sub-ensembles' (sub-nets)
%  This is done by clustering neurons / channels according to the 
%  correlation between single unit / channel similarity maps
%  Neurons / channels are clustered using K-means, the number of 
%  clusters is selected  using silhouette values 
%  (high values ~ higer between/within cluster distances)
%
% INPUTS: 
% dmat: cell array of distance matrices for each neurons 
% (each one of size events x events)
% NOTE: the distance matrices can be obtained using 
% SSIMS (for single unit spiking data) or 
% lfpSIMS (for continous data)
% dim  = # of dimensions used to cluster neurons / channels
% perp = perplexity used to cluster neurons / channels
% crange = # of clusters to check using k means
% displayopt = the last (optional) argument will plot results if set to 1
%
% Code requires SSIMS toolbox + helper functions:
%   - autokmeanscluster
%
% OUTPUTS: 
% SNETS.NSPACE: each point represents a neuron
% SNETS.clusterindex: index denoting membership in a cluster
% SNETS.centroids: cluster centroids
% SNETS.silhouette: silhouette values for different # of clusters identified using k-means (Higher = more cluster separation)
% SNETS.numclus: # of clusters identified (NOTE: this version will only detect > 1 cluster!!!)
% SNETS.NNcorr: Correlations between single unit SSIMS relational maps ( neuron x neuron )
% SNETS.distmat: full distance matrix ( neuron x events )
%
% @author Carlos Vargas-Irwin & Jaqueline Hynes
% Copyright (c) Carlos Vargas-Irwin, Brown University. All rightsreserved. Resistance is futile.



  
  SIMmat = zeros(numel(dmat));
  for x = [ 1:numel(dmat) ]
     
     for y = [1:x]
         
         SIMmat(x,y) = corr( dmat{x}(:), dmat{y}(:) , 'type' , 'pearson');   
   
     end 
     
  end
  
 SIMmat = tril(SIMmat)+tril(SIMmat,-1)'; 


% Use t-SNE to project the matrix of neuron-neuron correlations into
% a low dimensional space
%NSPACE = tsne_PCA(ncmat,[],neurondim,[],perp);
NSPACE =  runtSNE(SIMmat, dim, perp);
 
% varimax rotation
LPC = pca(NSPACE);
NSPACE = NSPACE*LPC;

% Cluster using K-means, selecting the number of clusters
[s cindex centroids nclus ] = autokmeanscluster(crange,NSPACE);

% put results in a nice data structure
SNETS.NSPACE = NSPACE;
SNETS.clusterindex = cindex;
SNETS.centroids = centroids;
SNETS.silhouette = s;
SNETS.numclus = nclus;
SNETS.NNcorr = SIMmat;


% to plot... or not
if nargin>4
    plotfig = varargin{1};
else
    plotfig = 0;
end


if plotfig
    
figure
plot(2:max(crange),s(2:max(crange)),'ko-')
set(gca,'fontsize',20)
xlabel('cluster #')
ylabel('mean sil. values')
    
figure
plotNT(NSPACE  ,cindex','symbol','o','msize',15);
view(2)

hold on
for n = 1:nclus
    h = text(centroids(n,1),centroids(n,2),num2str(n)); set(h,'color','m','fontsize',30)
    hold on  
end

end






