function tw_timeline_plot(start_date,end_date,buildnum,dt_string)
%
% plot timeline of tweets by dt
%    using mean, std error bars
%
%input:     start_date
%           end_date
%           dt           = time intervals (15min, 1 hour, 1 day, 1 week) 
%                     dt = 1 for per day
%           matrix       = comfmat or rmat
%           buildflag    = 0 (all buildings)
%                        = 11 (KING)
%



%tweetdata is a list of all the stmps(buildstmp, comfstmp, coordstmp,
%roomstmp, timestmp (dates in matlab time), userstmp, weathavg, weathmax,
%weathmin, weathtime).
load tweetdata

%turn the given dates into matlab time
start_date = datenum(start_date);
end_date = datenum(end_date);     %this is so that you can look at all of the data for the last day (datnum starts at midnight).

%getting the requested period
end_day = end_date - start_date;
start_day = 0;

period = end_day+1;

%truncate data
ind1 = find(timestmp<start_date);
ind2 = find(timestmp>(end_date + 1));
ind = horzcat(ind1,ind2);

timestmp(ind) = [];
buildstmp(ind) = [];
roomstmp(ind) = '';
comfstmp(ind) = [];


%dt_cell is a cell array which has all of the possible phrases that can be
%entered as analyzation periods.
dt_cell{1} = {'15min','15 min'};
dt_cell{2} = {'30min','30 min'};
dt_cell{3} = {'1hour','1 hour'};
dt_cell{4} = {'1day','1 day'};
dt_cell{5} = {'1week','1 week'};

%dt_vect is a vector of the possible dt's (or intervals) based on the
%response to the question.
dt_vect = [.0104 .0208 .0417 1 7];

for ii = 1:length(dt_cell)
    if 1 == cell2mat(strfind(dt_cell{ii},dt_string))
        dt = dt_vect(ii);
        break;
    end
end

%dt is now the length of time inbetween each standard deviation
%(i.e. if dt = .0104, the data is being analyzed in groups of 15 minutes).
%dt is in units of days.

if buildnum == 0,       %plot for all buildings in UNH
    timestmp_ceil = ceil(timestmp/dt)*dt;
    u = zeros(1,ceil(period/dt));
    s = zeros(1,ceil(period/dt));
    hits = zeros(1,ceil(period/dt));
    comf = cell(1,ceil(period/dt));
    for ii = 1:period/dt
        qq = find(timestmp_ceil == ceil(timestmp(1)/dt)*dt+ii*dt);
        u(ii) = mean(comfstmp(qq));
        s(ii) = std(comfstmp(qq));
        hits(ii) = length(qq);
        comf{ii} = num2cell(comfstmp(qq));
    end
       
else                    %plotting a certain building
    ind3 = find(buildstmp ~= buildnum);
    timestmp(ind3) = [];
    buildstmp(ind3) = [];
    roomstmp(ind3) = '';
    comfstmp(ind3) = [];
    timestmp_ceil = ceil(timestmp/dt)*dt;
    u = zeros(1,ceil(period/dt));
    s = zeros(1,ceil(period/dt));
    hits = zeros(1,ceil(period/dt));
    comf = cell(1,ceil(period/dt));
    for ii = 0:ceil(period/dt)-1
        qq = find(timestmp_ceil == ceil(timestmp(1)/dt)*dt+ii*dt);
        u(ii+1) = mean(comfstmp(qq));       %%(ii+1) is because ii = 0:#
        s(ii+1) = std(comfstmp(qq));
        hits(ii+1) = length(qq);
        comf{ii+1} = num2cell(comfstmp(qq));
    end
end

sumhits = sum(hits);
hits1 = zeros(1,length(hits));
%put hits into bins
bins = [2.5 9.5 20 30 60];
for ii = 1:length(hits)
    if hits(ii) == 0
        hits1(ii) = 0;
    elseif hits(ii) <= .02*sumhits && hits(ii) > 0
            hits1(ii) = 2.5;
    elseif hits(ii) <= .05*sumhits && hits(ii) > .02*sumhits 
            hits1(ii) = 9.5;
    elseif hits(ii) <= .1*sumhits && hits(ii) > .05*sumhits 
            hits1(ii) = 20;
    elseif hits(ii) <= .16*sumhits && hits(ii) > .1*sumhits 
            hits1(ii) = 30;
    else
            hits1(ii) = 60;
    end
end


%------plot mean, stdev, and comfortlevels on figure----%
figure;
hold on
x = 1:ceil(period/dt);

for ii = 1:ceil(period/dt)
    try
        hold on
        ylim([-3.8 3])
        plot([0 x],zeros(size(x)+1),'k')
        errorbar(x(ii),u(ii),s(ii),'b','linewidth',1)
        plot(x(ii),u(ii),'ro','markersize',ceil(hits1(ii))/2.7)
    end
    plot(x,u,'r','linewidth',1.5);
end

%xlabel('%d',dt_string{2:end})
ylabel('Comfort Level')
title('Standard Deviation of Tweet Comfort')


%--legend
[xrange] = get(gca,'xlim');
xmin = xrange(1);
xmax = xrange(2);


%mean
plot([.598*xmax .653*xmax],[-2.6 -2.6],'r-','linewidth',1.5)
text(.602*xmax,-3.2,'Mean','FontSize',6)

%std deviation
errorbar(.724*xmax,-2.6,.3,'b','linewidth',1)
text(.67*xmax,-3.205,'Std. Deviation','FontSize',6)


xcircle = xmax*[.8 .805 .828 .863 .92];
ycircle = [-2.5 -2.5 -2.5 -2.5 -2.5];
xscale = [xcircle .95*xmax];
yscale = [-3.1 -3.1 -3.1 -3.1 -3.1 -3.1];
scaletikx = [xscale(1) xscale(1) xscale(end) xscale(end)];
scaletiky = [-3 -3.25 -3 -3.25];

%circle scale
for ii = 1:5
    plot(xcircle(ii),ycircle(ii),'ro','MarkerSize',bins(ii)/2.7)
end
plot(xscale,yscale,'k-')
plot(scaletikx(1:2),scaletiky(1:2),'k-')
plot(scaletikx(3:4),scaletiky(3:4),'k-')
text(.785*xmax,-3.6,'0%','FontSize',7)
text(.825*xmax,-3.6,'Total Tweets','FontSize',6)
text(.935*xmax,-3.6,'25%+','FontSize',7)


xlabel = datestr(start_date:4:start_date+4*period/dt,'mm/dd');

set(gca,'xtick',1:4:length(xlabel),'xticklabel',xlabel)


end





function aftermath          %not sure what this is


%run the man program first
[comfmat,rmat] = AnalyzationProgram(start_date,end_date,building);       
close all;


dt = 1;
%plot tweet timeline for UNH campus
subplot(121);
tw_timeline_plot(start_date,end_date,dt,comfmat,0);
%plot tweet timeline for KING
subplot(122);
tw_timeline_plot(start_date,end_date,dt,rmat,buildnum);
end