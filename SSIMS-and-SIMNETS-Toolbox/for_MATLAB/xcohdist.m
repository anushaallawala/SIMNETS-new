

function d = xcohdist(x,y,movingwin,params)

d = zeros(1,size(y,1));
for n = 1: size(y,1)

[ C ] = cohgramc(reshape(x,[],1) ,reshape(y(n,:),[],1)  , movingwin, params);
%[ C ,phase, S12, S1, S2, time, fq] = cohgramc(reshape(x,[],1) ,reshape(y,[],1)  , params.movingwin, params);
d(n) = 1-mean(C);

end




%     A distance function must be of the form
%  
%           function D2 = DISTFUN(XI, XJ),
%  
%     taking as arguments a 1-by-N vector XI containing a single row of X, an
%     M2-by-N matrix XJ containing multiple rows of X, and returning an
%     M2-by-1 vector of distances D2, whose Jth element is the distance
%     between the observations XI and XJ(J,:).