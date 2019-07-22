function [ x,y,z ] = SIMNETS_movie( NSmap,neuronID,nID, newShift, timeaxis, alignment )

% Neuronal Funcitonal Dynamics
% Detailed explanation goes here

% Author JHYNES
% Date: 2019-14-04

    close all;
    load('neuronID')
    prepLables = {'Baseline' 'Obj', 'Grip', 'Go'};
    cols= [ 0 .2 1 ; 0.4 1 1; 1.0 .6 .2 ];
    colsN = cols(neuronID(nID),:);
  % Set up Figures
    figure(1);set(gcf, 'OuterPosition', [2052  1016  100 100])
    figure(2);set(gcf, 'OuterPosition', [447 355 1189 1054])
    set(gcf,'Color',[1 1 1]); box off; grid off; 
    ax1 = subplot(4,1,1);set(gca,'FontSize',16); set(gca,'linewidth',3); set(gca, 'YColor', 'none');  box off; hold (ax1,'on');
    ax2 = subplot(4,1,[2:4]); axis off; 
    
%% Parameters & Pre-allocate

fade = 5;
speed = .001; 
timeaxisN = timeaxis(1):newShift:timeaxis(end); 
  
%% Set up Data, Figures, Timeaxis

% Interpolate Data
    permNS = permute(NSmap,[3 1 2]);  
    B = interp1(timeaxis,permNS,timeaxisN);
    NSmap = permute(B,[2 3 1]);
   
% Pre-allocate   
    temp = cell(1,size(NSmap,3));
    c = zeros(1,size(NSmap,3)); 
    tP = zeros(1,size(NSmap,3));  
%% Set up Time Plots: AX1

  
   line(ax1,[ timeaxisN(1) timeaxisN(end)] , [0 0 ], 'linewidth',5 , 'Color', [ .9 .9 .9]); 
   xlabel(ax1,'Time (S)'); ylim([ -.01 .01]); xlim([  timeaxisN(1) timeaxisN(end) ]);hold on;   
   
   
 % Color labels for timepooints
   
    if alignment == 2

      base =  repmat({'k'} , [ 1 numel(find(timeaxisN <-1))]);
      obj  =  repmat({'r'} , [ 1 numel( find(timeaxisN >=-1 & timeaxisN < 0))]);
      grip =  repmat({'c'} , [ 1 numel( find(timeaxisN >=0 & timeaxisN<2))]); 
      go =  repmat({'g'} ,   [ 1 numel(find(timeaxisN >= 2))]); 
      colStr = [ base obj grip go]; 

      tP(1)= plot(ax1,timeaxisN(1),0, '^','MarkerFaceColor', 'k' ,'MarkerEdgeColor',[ .8 .8 .8],'markersize',15);hold on; 
      mark(1)=plot(ax1,-1, 0, '^' , 'MarkerFaceColor' , 'r' ,'MarkerEdgeColor' ,[ .8 .8 .8],'markersize',15);
      mark(2)=plot(ax1,0, 0, '^' , 'MarkerFaceColor', 'c' , 'MarkerEdgeColor',[ .8 .8 .8],'markersize',15);
      mark(3)=plot(ax1,2, 0, '^' , 'MarkerFaceColor', 'g' , 'MarkerEdgeColor',[ .8 .8 .8],'markersize',15);
      legend(ax1,[tP(1) mark], prepLables, 'location', 'bestoutside','Orientation','horizontal','AutoUpdate','off'); 

    elseif alignement == 4

      premove  =  repmat({'c'} , [ 1 numel(find(timeaxisN< 0))]);
      move =  repmat({'b'} , [ 1 numel(find(timeaxisN>=0))]); 
      colStr = [ obj , grip, go]; 

    end 

%% Create Trajectories: Figure 2 

   figure(1)
 % Interpolate along time
   p = plotNT(NSmap(nID,:,:),ones(1,numel(nID)), 'color',[1 1 1], 'msize', 10, 'symbol', '-','lwidth',1 ,'avg_trajectories',0,'smooth_trajectories',1, 'smooth_steps',200);hold off; 
 
   if numel(nID)==1
       x = p(:).XData;
       y = p(:).YData;    
       z = p(:).ZData;    

   else

       x =  cell2mat({p(:).XData}');
       y = cell2mat({p(:).YData}');    
       z = cell2mat({p(:).ZData}');    

   end
   
  xx = x*1;
  yy = y*1;
  zz = z*1;
   
%% Plotting Neuronal Trajectories
figure(2)
 
xlim(ax2,[min(xx(:)) max(xx(:))]); ylim(ax2, [ min(yy(:))  max(yy(:))]);  zlim(ax2,[min(zz(:))  max(zz(:)) ]); hold on;
axis(ax2,'manual');
%view(253,11);
  
   
for ii = 1:size(x,2)
    
  %   camorbit(ax2, 5,0,'camera')
    
    tP(ii+1)= plot(ax1,timeaxisN(ii), 0, '.', 'Color',colStr{ii} , 'MarkerFaceColor',[ .3 .3 .3], 'markersize',50);
     delete(tP(ii)); 
           % If timepoint > 2, detete the last point and plot another
           % Otherwise plot the first point. 
           if ii>= 2

                delete(c(ii-1)); 
                c(ii) = scatter3(ax2, x(:,ii), y(:,ii),z(:,ii),50, colsN,'filled');hold on;
                xlim(ax2,[min(xx(:)) max(xx(:))]); ylim(ax2, [ min(yy(:))  max(yy(:))]);  zlim(ax2,[min(zz(:))  max(zz(:)) ]); hold on;
 
                      
                
                % If timepoint > fadeing lag and we are past the first
                % timepoint, plot the transparent neuron tail.
                % Otherwise plot the transparent neuron tail and delete
                % old tail.
                if (ii<=fade && ii>=2)

                    
                        
                        if numel(nID)==1
                             tMat = [x(:,1:ii)', y(:,1:ii)',z(:,1:ii)'];
                             tMat = reshape(tMat', [numel(nID) size(NSmap,2) size(tMat,1)]);
                        else 

                            xR = [ reshape( x(:,1:ii), [ numel(nID),1, numel(1:ii)])];
                            yR = [ reshape( y(:,1:ii), [ numel(nID),1, numel(1:ii)])];
                            zR = [ reshape( z(:,1:ii), [ numel(nID),1, numel(1:ii)])];
                            tMat = cat(2, xR, yR, zR);
                        end 
                         temp{ii} = plotNTmovie( tMat,nID, 'color', colsN, 'msize', 10, 'symbol', '-','lwidth',3 ,'avg_trajectories',0,'smooth_trajectories',0, 'smooth_steps',1, 'use_patchline', 1, 'alpha',.2);
                        xlim(ax2,[min(xx(:)) max(xx(:))]); ylim(ax2, [ min(yy(:))  max(yy(:))]);  zlim(ax2,[min(zz(:))  max(zz(:)) ]); hold on;

                elseif ii>=fade
                            

                        if numel(nID)==1

                          tMat = [x(ii-fade+1:ii)', y(ii-fade+1:ii)',z(ii-fade+1:ii)'];
                          tMat = reshape(tMat', [numel(nID) size(NSmap,2) size(tMat,1)]);

                        else 

                            xR = [ reshape( x(:,ii-fade+1:ii), [ numel(nID),1, numel(ii-fade+1:ii)])];
                            yR = [ reshape( y(:,ii-fade+1:ii), [ numel(nID),1, numel(ii-fade+1:ii)])];
                            zR = [ reshape( z(:,ii-fade+1:ii), [ numel(nID),1, numel(ii-fade+1:ii)])];
                            tMat = cat(2, xR, yR, zR);
                        end 

                        temp{ii} = plotNTmovie(tMat,nID, 'color',colsN, 'msize', 10, 'symbol', '-','lwidth',3 ,'avg_trajectories',0,'smooth_trajectories',0, 'smooth_steps',1, 'use_patchline', 1, 'alpha',.2);
                        xlim(ax2,[min(xx(:)) max(xx(:))]); ylim(ax2, [ min(yy(:))  max(yy(:))]);  zlim(ax2,[min(zz(:))  max(zz(:)) ]); hold on;
                        delete(temp{ii-fade+1}(:))
                end

            else

                        c(ii) =scatter3(ax2, x(:,ii), y(:,ii),z(:,ii),50, colsN,'filled');
                        xlim(ax2,[min(xx(:)) max(xx(:))]); ylim(ax2, [ min(yy(:))  max(yy(:))]);  zlim(ax2,[min(zz(:))  max(zz(:)) ]); hold on;
                        temp{ii} = 0;
                       

           end
            pause(speed)
            
            
end

tP(ii+1)=plot(ax1,timeaxisN(end), 0, '.', 'MarkerEdgeColor',colStr{end}, 'MarkerFaceColor', [ .8 .8 .8], 'markersize',50);





end

