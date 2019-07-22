
function [LFPmat, sampfreq] = getNSData(fname, chan, ev, dur)
%[LFPmat, sampfreq] = getNS5Data(fname, chan, event, duration)
% This function uses the NPMK toolbox (Blackrock)
% NOTE: data is formatted for use wich the Chronux toolbox
% (in form [ samples x (channels*trials) ], organized by channel  )
% toolbox available at http://chronux.org

out = openNSx(fname,'read','channels' ,chan, 'p:double',['t:' num2str(1) ':' num2str(2)],'sec');

sampfreq = out.MetaTags.SamplingFreq;

LFPmat = zeros(dur*sampfreq,numel(ev)*numel(chan));

count = 0; 
for c = 1:numel(chan)
for t =1:numel(ev)
    count = count+1;
    start = ev(t);
    fin = ev(t)+dur;
    out = openNSx(fname,'read','channels' ,chan(c), 'p:double', ['t:' num2str(start) ':' num2str(fin)],'sec');
    dif = dur*sampfreq - numel(out.Data);
    if dif > 0
        LFPmat(:,count) = [out.Data'; repmat(out.Data(end),1,dif) ];
    else
        LFPmat(:,count) = [out.Data(1:dur*sampfreq)' ];
    end
end
end