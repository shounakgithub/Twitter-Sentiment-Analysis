function analyze_building(weathmax,weathmin,weathavg,weathtime,roomstmp,coordstmp,timestmp,userstmp,buildstmp,comfstmp,buildnum,start_date,end_date)

%shorten data to between start_date and end_date
start_date = datenum(start_date);
end_date = datenum(end_date);
%weather data
ind = find(weathtime>=start_date & weathtime<=end_date);
weathmax  = weathmax(ind);
weathmin  = weathmin(ind);
weathavg  = weathavg(ind);
weathtime = weathtime(ind);
%tweet data
ind = find(timestmp>=start_date & timestmp<=end_date);
roomstmp  = roomstmp(ind);
coordstmp = coordstmp(ind);
timestmp  = timestmp(ind);
userstmp  = userstmp(ind);
comfstmp  = comfstmp(ind);
buildstmp = buildstmp(ind);
%how many days between start_date and end_date
period = end_date - start_date + 1;


if 1,
%plot_timeofday plots the time of day that tweets were recieved.
%buildhitlist_timeofday is the number of hits the building recieves in each
%hour of the day.
plot_timeofday(timestmp,period);


%plot_hits_avg plots the number of tweets (hits) and the average
%comfort level.
plot_hits_avg(roomstmp,comfstmp,period,buildnum);
end;

%plot_comfvsweath plots the number of tweets received each day in the given 
%period against the weather and gives the number of hot,very hot, cold, and
%very cold tweets. It also gives the average comfort level for each of 
%those days in a subplot.  The output buildhit_day gives the number of hits
%recieved during each day in the given period.
[buildhit_day,comfavg_day] = plot_comfvsweath(weathmin,weathmax,...
    weathavg,weathtime,timestmp,buildstmp,roomstmp,comfstmp,buildnum,...
    period,start_date,end_date);


if 0,
%plot_floorplans plots the comfort levels of each tweeted room on the
%floorplans of the building.
plot_floorplans(buildnum,roomstmp,comfstmp)



%dt_string = input('what interval would you like to analyze the data?  15min/30min/1hour/1day/1week         ');
dt_string = '1 day';
%standard deviation of the tweets for either the whole campus or one of 
%buildings.  Unlike the other functions within analyze_building, this
%is not a subfunction.
tw_timeline_plot(start_date,end_date,buildnum,dt_string);
end;




function plot_timeofday(timestmp,period)

timestmp_timeofday = timestmp - floor(timestmp);
timestmp_timeofday = floor(24*timestmp_timeofday);


buildhit_timeofday = zeros(1,24);

for ii = 1:length(timestmp_timeofday)
    for jj = 1:length(buildhit_timeofday)
        if timestmp_timeofday(ii) == jj
            buildhit_timeofday(jj) = buildhit_timeofday(jj) + 1;
        end
    end
end

%number of hits per day, per week
if 1 > floor(timestmp(end)) - floor(timestmp(1))
    buildhit_timeofday = buildhit_timeofday/7;
else
    buildhit_timeofday = buildhit_timeofday/(period/7);
end


figure;
tt = 1:24;
bar(tt,buildhit_timeofday(tt));
set(gca,'ylim',[0 max(buildhit_timeofday)*1.15],'xtick',0:3:24,...
    'xticklabel',{'12:00 AM','3:00','6:00','9:00','12:00 PM',...
    '3:00','6:00','9:00','12:00 AM'});
title('Average Number of Tweets per Hour');
set(gca,'ygrid','on');




function [roomhitlist,comfavg] = plot_hits_avg(roomstmp,comfstmp,period,buildnum)

load roomlist

%make rmat
rmat = zeros(length(roomstmp),length(roomlist{buildnum}));

for ii = 1:length(roomstmp)
    for jj = 1:length(roomlist{buildnum})
        if strcmp(roomstmp(ii),roomlist{buildnum}{jj}(1)) == 1
            rmat(ii,jj) = comfstmp(ii);
        end
    end
end


%score for each room
comfscore = sum(rmat);
if 1 == length(comfscore)   %meaning that there is only one line of data to sum
    comfscore = rmat;       %this is so that the comfscore will match up with the
end                         %roomhitlist for the purpose of finding the comfavg


%roomhitlist is the number of tweets recived in each room during the given
%period
roomhitlist = zeros(1,length(roomlist{buildnum}));

for ii = 1:length(roomstmp)
    for jj = 1:length(roomlist{buildnum})
        if rmat(ii,jj) ~= 0
            roomhitlist(jj) = roomhitlist(jj) + 1;
        end
    end
end

comfavg = zeros(1,length(comfscore));

for ii = 1:length(comfavg)
    if 0 == sum(roomhitlist)
        figure;
        hold on
        text(.5,1.4,'No Matching Rooms')
        text(.5,1.2,'Incongruent Tweets:')
        text(.5,1,roomstmp)
        axis([0 2 0 2])
        hold off
        return
    else
        comfavg(ii) = comfscore(ii)/roomhitlist(ii);
    end
end

%abreviate the roomlist,comfavg,roomhitlist so that they are easier to plot
roomhitlist_abr = roomhitlist;
comfavg_abr = comfavg;
roomlist_abr = roomlist{buildnum};

for rr = 1:length(roomhitlist_abr)
    if roomhitlist_abr(rr) == 0
        roomhitlist_abr(rr) = nan;
    end
end

ind = find(isnan(roomhitlist_abr));
roomhitlist_abr(ind) = [];
comfavg_abr(ind) = [];
roomlist_abr(ind) = [];

%if none of the data matches up with a correct room number post the tweets
%and exit the program
if isempty(roomlist_abr)
    figure;
    hold on
    text(.5,1.4,'No Matching Rooms')
    text(.5,1.2,'Incongruent Tweets:')
    text(.5,1,builddata)
    axis([0 2 0 2])
    hold off
    return
end

for ii = 1:length(roomlist_abr)
    roomlist_abr(ii) = roomlist_abr{ii}(1);
end

our_markersize = 7;

figure;
ii = 0:length(comfavg_abr);
subplot(2,1,1)
plot([ii(1) ii(end)],[0 0],'k-')
hold on


for ii = 1:length(roomlist_abr)
    if comfavg_abr(ii) <= -1.25
        plot(ii,comfavg_abr(ii),'ko','MarkerFaceColor','c','MarkerSize',our_markersize)
    elseif comfavg_abr(ii) < 0
        plot(ii,comfavg_abr(ii),'ko','MarkerFaceColor','b','MarkerSize',our_markersize)
    elseif comfavg_abr(ii) == 0
        plot(ii,comfavg_abr(ii),'ko','MarkerFaceColor','g','MarkerSize',our_markersize)
    elseif comfavg_abr(ii) >= 1.25
        plot(ii,comfavg_abr(ii),'ko','MarkerFaceColor','y','MarkerSize',our_markersize)
    elseif comfavg_abr(ii) > 0
        plot(ii,comfavg_abr(ii),'ko','MarkerFaceColor','r','MarkerSize',our_markersize)
    end
end


set(gca,'xtick',1:1:length(roomlist_abr),'xticklabel',roomlist_abr)
set(gcf,'position',[300 170 740 490])
axis([0 length(roomlist_abr) -3 3])
grid on
title('Averge Comfort Level in Each Room')
xlabel('Room')

hold off


rr = 1:length(roomhitlist_abr);
subplot(2,1,2)

plot([0 rr(end)],[0 0],'k-')
hold on

for ii = 1:length(roomlist_abr)
    if comfavg_abr(ii) <= -1.25
        bar(ii,roomhitlist_abr(ii),'c')
    elseif comfavg_abr(ii) < 0
        bar(ii,roomhitlist_abr(ii),'b')
    elseif comfavg_abr(ii) == 0
        bar(ii,roomhitlist_abr(ii),'g')
    elseif comfavg_abr(ii) >= 1.25
        bar(ii,roomhitlist_abr(ii),'y')
    elseif comfavg_abr(ii) > 0
        bar(ii,roomhitlist_abr(ii),'r')
    end
end


axis([0 length(roomhitlist_abr) 0 (max(roomhitlist_abr) + 1)])
set(gca,'xtick',1:1:length(roomhitlist_abr),'xticklabel',roomlist_abr)
set(gcf,'position',[300 170 740 490])
grid on
title('Number of Tweets in Each Room')
xlabel('Room')

hold off





function [buildhit_day,comfavg_day] = plot_comfvsweath(weathmin,weathmax,weathavg,weathtime,timestmp,buildstmp,roomstmp,comfstmp,buildnum,period,start_date,end_date)





%plot campus map or building floor plans first
fig = figure;
set(gcf,'position',[130 100 1605 676]);  
buildnum=0;
if buildnum==0, %all buildings --> campus map
    plot_campus(timestmp,buildstmp,comfstmp);
else,
    plot_floorplans(buildnum,roomstmp,comfstmp);
end;




%The first step is to determine the number of tweets recieved each day.
%The variable "period" is the number of days between the given dates.

timestmp_day = floor(timestmp);  %the day on which each tweet occurs
timestmp_day = timestmp_day - weathtime(1);   %the first day in the 
                                              %seris is zero (0 to period)

buildhit_day = zeros(1,(period));
buildscore_day = zeros(1,(period));
comfavg_day = zeros(1,(period));

for ii = 1:length(buildhit_day)
    for jj = 1:length(timestmp_day)
        if timestmp_day(jj) == ii-1
            buildscore_day(ii) = buildscore_day(ii) + comfstmp(jj);
            buildhit_day(ii) = buildhit_day(ii) +1;
            comfavg_day(ii) = buildscore_day(ii)/buildhit_day(ii);
        end
    end
    if buildhit_day(ii) == 0
        comfavg_day(ii) = nan;
    end
end




%barhot and barcold represent the values to be plotted as a bar graph
barhot = zeros(length(buildhit_day),2);
barcold = zeros(length(buildhit_day),2);

for ii = 1:length(barhot)
    for jj = 1:length(timestmp_day)
        if timestmp_day(jj) == ii - 1      %this is because length(barhot) = period +1
            if comfstmp(jj)== 1            
                barhot(ii,1) = barhot(ii,1) + 1;
            elseif comfstmp(jj)== 2
                barhot(ii,2) = barhot(ii,2) + 1;
            elseif comfstmp(jj)== -1
                barcold(ii,1) = barcold(ii,1) - 1;
            elseif comfstmp(jj)== -2
                barcold(ii,2) = barcold(ii,2) - 1;
            end
        end
    end
end


%To label the x-axis I will also want to know a certain number of dates to
%give as reference points (tick marks).


if period < 10
    xlabels = zeros(1,period);
    for ii = 1:period
        xlabels(ii) = weathtime(1) + ii - 1;
    end
else
    xlabels = zeros(1,10);
    for ii = 1:10
        xlabels(ii) = floor(period/10*ii + weathtime(1) - 1);
    end
end

xlabels = datestr(xlabels,'mm/dd');
xlabels = cellstr(xlabels);


%plot comfvsweath
tt = 1:length(buildhit_day);

% figure;
% set(gcf,'position',[130 100 1605 676]);  
%plot temp data
subplot('position',[.1 .67 .55 .27]);
plot(tt,weathavg,'k-','linewidth',2);
hold on;
fill([tt tt(end:-1:1)],[weathmax' weathmin(end:-1:1)'],[221 221 221]/255,'EdgeColor','none')
plot(tt,weathavg,'k-','linewidth',2);
plot([tt(1) tt(end)],[0 0],'k-','linewidth',1);
axis([1 length(weathtime) -15 100]);
ylabel('Tempurature (^oF)');
set(gca,'xtick',(period/length(xlabels)):(period/length(xlabels)):period,...
    'xticklabel',xlabels,'ytick',-30:15:150,...
    'ylim',[min(weathmin) max(weathmax)*1.1]);
legend('Avg. Temperature','Temp. Range');
title(sprintf('%s to %s',datestr(start_date),datestr(end_date)));
set(legend,'FontSize',10,'position',[.488 .903 .174 .068]);
grid on;
hold off;

%plot tweet count
subplot('position',[.1 .1 .55 .50])
plot(tt,buildhit_day,'k-','linewidth',1);
hold on;
hbar = bar(tt,barhot,'stacked','y');
cbar = bar(tt,barcold,'stacked','c');
set(hbar,{'FaceColor'},{'r';[255 153 102]/255});
set(cbar,{'FaceColor'},{'b';[166 222 244]/255});
plot(tt,buildhit_day,'k-');
axis([1 length(weathtime) min(min(barcold))*1.15 max(buildhit_day)*1.15]);
ylabel('Number of Tweets');
temp = floor(min(barcold(:))/2)*2:2:max(buildhit_day); %find ylim
set(gca,'ytick',temp,'xtick',(period/length(xlabels)):(period/length(xlabels)):period,'xticklabel',xlabels);
set(gca,'yticklabel',abs(str2num(get(gca,'yticklabel'))));
%set(gca,'ytick',-40:10:70,'xlim',[(period/length(xlabels)-1) (period+1)],'xticklabel','');
grid on
legend('Number of Tweets','Number of Hot Tweets','Number of Very Hot Tweets','Number of Cold Tweets','Number of Very Cold Tweets')
%set(legend,'FontSize',10,'position',[.733 .59 .145 .0981])
hold off;

% %comfavg
% tt = 1:length(comfavg_day);
% subplot('position',[.1 .1 .85 .15])
% hold on
% plot(tt,comfavg_day,'ko','MarkerFaceColor','k','MarkerSize',4,'linewidth',2);
% plot(tt([1 end]),[0 0],'g--','linewidth',2)
% axis([1 length(comfavg_day) -3 3])
% set(gca,'ytick',-2:1:2,'yticklabel',{'very cold','cold','comfortable','hot','very hot'},...
%     'xtick',(period/length(xlabels)):(period/length(xlabels)):period,'xticklabel',xlabels);
% xlabel('Date')
% ylabel('Average Comfort Level')
% grid on
% hold off






function plot_floorplans(buildnum,roomstmp,comfstmp)


load buildlist
load roomlist
load coordlist
load floorlist

%the first thing that needs to be done is create a list of rooms that need
%to be plotted in.  The rmat can be condensed (or summed) into one row so 
%that the the number in each cell corresponds to the sum of the comfort 
%levels (i.e 2+(-1)+1+0...).  Then the number of times the room has been 
%tweeted can be counted.  When plotting we want the average comfort level 
%so the sum (comfscore) can be divided by the number of mentions 
%(roomhitlist).  Then, because there is exactly one coordlist cell for 
%every roomlist cell, I am going to remove the rooms from the %summed rmat, 
%roomlist, and coordlist so that only the rooms with tweets in them remain. 

rmat = zeros(length(roomstmp),length(roomlist{buildnum}));

for ii = 1:length(roomstmp)
    for jj = 1:length(roomlist{buildnum})
        if strcmp(roomstmp(ii),roomlist{buildnum}{jj}(1)) == 1
            rmat(ii,jj) = comfstmp(ii);
        end
    end
end


%score for each room
comfscore = sum(rmat);
if 1 == length(comfscore)   %meaning that there is only one line of data to sum
    comfscore = rmat;       %this is so that the comfscore will match up with the
end  

roomhitlist = zeros(1,length(roomlist{buildnum}));

for ii = 1:length(roomstmp)
    for jj = 1:length(roomlist{buildnum})
        if rmat(ii,jj) ~= 0
            roomhitlist(jj) = roomhitlist(jj) + 1;
        end
    end
end

comfavg = zeros(1,length(comfscore));

for ii = 1:length(comfavg)
    if 0 == sum(roomhitlist)
        figure;
        hold on
        text(.5,1.4,'No Matching Rooms')
        text(.5,1.2,'Incongruent Tweets:')
        text(.5,1,roomstmp)
        axis([0 2 0 2])
        hold off
        return
    else
        comfavg(ii) = comfscore(ii)/roomhitlist(ii);
    end
end

for ii = 1:length(comfscore)
    if comfscore(ii) == 0
        comfscore(ii) = nan;
    end
end

ind = find(isnan(comfscore));
comfscore(ind) = [];
roomhitlist(ind) = [];
comfavg(ind) = [];
roomlist{buildnum}(ind) = [];
coordlist{buildnum}(ind) = [];


%load image
for ii = 1:length(floorlist{buildnum})
    str_temp = sprintf('img{%d} = imread(''Floorplans180\\%s%d.jpg'');',ii,buildlist{buildnum},ii);
    eval(str_temp);
end


% %plot
% figure;
% set(gcf,'position',[155 9 624 671]); 
% hold on

xx = 0:1:200;
yy = 150:-1:0;

%buildings (such as kingsbury) whose room number also contains a letter
%(for instance w or n) denoting the wing of the building, are put into the
%vector wingbuild
wingbuild = [11];

%to access a specific cell within a cell use
%coordlist{variable for which list}{variable for which room}(xx yy).
for ii = 1:length(floorlist{buildnum})
    subplot(length(floorlist{buildnum}),3,ii*3);
    image(xx,yy,flipdim(img{ii},1))
    hold on
    for jj = 1:length(comfavg)
        if ismember(buildnum,wingbuild) == 1
            if comfavg(jj) > 1.25
                try
                    junk = strfind(roomlist{buildnum}{jj},sprintf('%d',ii));
                    junk = cell2mat(junk);
                    if junk(1) == 2,
                        temp = [coordlist{buildnum}{jj}(1),coordlist{buildnum}{jj}(2)]; %get room coordinates
                        temp = temp + randn(size(temp)) * 1; %add some randomness to display
                        plot(temp(1),temp(2),'ko','MarkerFaceColor','y','MarkerSize',6);
                    end
                end
            elseif comfavg(jj) > 0
                try
                    junk = strfind(roomlist{buildnum}{jj},sprintf('%d',ii));
                    junk = cell2mat(junk);
                    if junk(1) == 2
                        plot(coordlist{buildnum}{jj}(1),coordlist{buildnum}{jj}(2),'ko','MarkerFaceColor','r','MarkerSize',6)
                    end
                end
            elseif comfavg(jj) < -1.25
                try
                    junk = strfind(roomlist{buildnum}{jj},sprintf('%d',ii));
                    junk = cell2mat(junk);
                    if junk(1) == 2
                        plot(coordlist{buildnum}{jj}(1),coordlist{buildnum}{jj}(2),'ko','MarkerFaceColor','c','MarkerSize',6)
                    end
                end
            elseif comfavg(jj) < 0
                try
                    junk = strfind(roomlist{buildnum}{jj},sprintf('%d',ii));
                    junk = cell2mat(junk);
                    if junk(1) == 2
                        plot(coordlist{buildnum}{jj}(1),coordlist{buildnum}{jj}(2),'ko','MarkerFaceColor','b','MarkerSize',6)
                    end
                end    
            end
        else
            if comfavg(jj) > 1.25
                try
                    junk = strfind(roomlist{buildnum}{jj},sprintf('%d',ii));
                    junk = cell2mat(junk);
                    if junk(1) == 2
                        plot(coordlist{buildnum}{jj}(1),coordlist{buildnum}{jj}(2),'ko','MarkerFaceColor','y','MarkerSize',6)
                    end
                end
            elseif comfavg(jj) > 0
                try
                    junk = strfind(roomlist{buildnum}{jj},sprintf('%d',ii));
                    junk = cell2mat(junk);
                    if junk(1) == 2
                        plot(coordlist{buildnum}{jj}(1),coordlist{buildnum}{jj}(2),'ko','MarkerFaceColor','r','MarkerSize',6)
                    end
                end
            elseif comfavg(jj) < -1.25
                try
                    junk = strfind(roomlist{buildnum}{jj},sprintf('%d',ii));
                    junk = cell2mat(junk);
                    if junk(1) == 2
                        plot(coordlist{buildnum}{jj}(1),coordlist{buildnum}{jj}(2),'ko','MarkerFaceColor','c','MarkerSize',6)
                    end
                end
            elseif comfavg(jj) < 0
                try
                    junk = strfind(roomlist{buildnum}{jj},sprintf('%d',ii));
                    junk = cell2mat(junk);
                    if junk(1) == 2
                        plot(coordlist{buildnum}{jj}(1),coordlist{buildnum}{jj}(2),'ko','MarkerFaceColor','b','MarkerSize',6)
                    end
                end    
            end
        end
    end
    hold off;
    ylabel(sprintf('Floor %d',ii));
    set(gca,'xtick',[],'ytick',[],'xticklabel','','yticklabel','');
    if ii==1, 
        temp = upper(buildlist_pos{buildnum}(1));
        title(sprintf('Building: %s',temp{1}));
        
        %draw legend for dots
        hold on;
        tempx = get(gca,'xlim');
        tempy = get(gca,'ylim');
        jj=1;  %red dot
        plot(tempx(2)-diff(tempx)*.2,tempy(2)-diff(tempx)*jj*0.07,...
            'ko','markerfacecolor','r','markersize',6);
        text(tempx(2)-diff(tempx)*.18,tempy(2)-diff(tempx)*jj*0.07,...
            'too hot','color','r','FontWeight','bold');
        jj=2;  %green dot
        plot(tempx(2)-diff(tempx)*.2,tempy(2)-diff(tempx)*jj*0.07,...
            'ko','markerfacecolor','g','markersize',6);
        text(tempx(2)-diff(tempx)*.18,tempy(2)-diff(tempx)*jj*0.07,...
           'just right','color',[102 204 0]/255,'FontWeight','bold');
        jj=3;  %blue dot
        plot(tempx(2)-diff(tempx)*.2,tempy(2)-diff(tempx)*jj*0.07,...
            'ko','markerfacecolor','b','markersize',6);
        text(tempx(2)-diff(tempx)*.18,tempy(2)-diff(tempx)*jj*0.07,...
            'too cold','color','b','FontWeight','bold');
        hold off;
    end;
end;







function [temp] = floorplanlookup(buildnum)

if buildnum == 1
    temp = dir('C:\Users\Andrew\Documents\MATLAB\Final Program\Floorplans180\chase*');
elseif buildnum == 2
    temp = dir('C:\Users\Andrew\Documents\MATLAB\Final program\Floorplans180\dem*');
elseif buildnum == 3
    temp = dir('C:\Users\Andrew\Documents\MATLAB\Final program\Floorplans180\dim*');
elseif buildnum == 4
    temp = dir('C:\Users\Andrew\Documents\MATLAB\Final program\Floorplans180\greg*');
elseif buildnum == 5
    temp = dir('C:\Users\Andrew\Documents\MATLAB\Final program\Floorplans180\hsmith*');
elseif buildnum == 6
    temp = dir('C:\Users\Andrew\Documents\MATLAB\Final program\Floorplans180\hewitt*');
elseif buildnum == 7
    temp = dir('C:\Users\Andrew\Documents\MATLAB\Final program\Floorplans180\hort*');
elseif buildnum == 8
    temp = dir('C:\Users\Andrew\Documents\MATLAB\Final program\Floorplans180\hud*');
elseif buildnum == 9
    temp = dir('C:\Users\Andrew\Documents\MATLAB\Final program\Floorplans180\james*');
elseif buildnum == 10
    temp = dir('C:\Users\Andrew\Documents\MATLAB\Final program\Floorplans180\ken*');
elseif buildnum == 11
    temp = dir('C:\Users\Andrew\Documents\MATLAB\Final program\Floorplans180\kings*');
elseif buildnum == 12
    temp = dir('C:\Users\Andrew\Documents\MATLAB\Final program\Floorplans180\mub*');
elseif buildnum == 13
    temp = dir('C:\Users\Andrew\Documents\MATLAB\Final program\Floorplans180\mcc*');
elseif buildnum == 14
    temp = dir('C:\Users\Andrew\Documents\MATLAB\Final program\Floorplans180\morrill*');
elseif buildnum == 15
    temp = dir('C:\Users\Andrew\Documents\MATLAB\Final program\Floorplans180\morse*');
elseif buildnum == 16
    temp = dir('C:\Users\Andrew\Documents\MATLAB\Final program\Floorplans180\murk*');
elseif buildnum == 17
    temp = dir('C:\Users\Andrew\Documents\MATLAB\Final program\Floorplans180\nes*');
elseif buildnum == 18
    temp = dir('C:\Users\Andrew\Documents\MATLAB\Final program\Floorplans180\nhh*');
elseif buildnum == 19
    temp = dir('C:\Users\Andrew\Documents\MATLAB\Final program\Floorplans180\pars*');
elseif buildnum == 20
    temp = dir('C:\Users\Andrew\Documents\MATLAB\Final program\Floorplans180\pcac*');
elseif buildnum == 21
    temp = dir('C:\Users\Andrew\Documents\MATLAB\Final program\Floorplans180\pet*');
elseif buildnum == 22
    temp = dir('C:\Users\Andrew\Documents\MATLAB\Final program\Floorplans180\rud*');
elseif buildnum == 23
    temp = dir('C:\Users\Andrew\Documents\MATLAB\Final program\Floorplans180\spauld*');
end



function plot_campus(timestmp,buildstmp,comfstmp)

%plot tweet data on maps (campus now)


%lat_long is a matrix which stores the coordinates for each of the UNH
%buildings on the campus map.  Each row corresponds to a building around
%campus.
lat_long = [43.135692   -70.939343;
43.136334   -70.933957;
43.135504   -70.933249;
43.134893   -70.938592;
43.1357     -70.931135;
43.136271   -70.934858;
43.133641   -70.93209;
43.134776   -70.928625;
43.136811   -70.934783;
43.137430   -70.935738;
43.134095   -70.934955;
43.132771   -70.932176;
43.137344   -70.934397;
43.134823   -70.935813;
43.134377   -70.929955;
43.136146   -70.933163;
43.137884   -70.935727;
43.138158   -70.933861;
43.133398   -70.933796;
43.136819   -70.928839;
43.134557   -70.933303;
43.137023   -70.935438;
43.135598   -70.935405;
43.135293   -70.934494];

rand('seed',0);

%read map image
img = imread('Campus_Map_Full.jpg');
img = flipdim(img,1);
xx=linspace(-70.943034,-70.92207,size(img,2));
yy=linspace(43.130524,43.139873,size(img,2));


%plot
subplot('position',[.67 .22 .31 .55])
image(xx,yy,img);
set(gca,'YDir','normal','xtick',[],'ytick',[]);
set(gca,'xlim',[-70.94  -70.928]);
title('UNH Campus: Tweets for All Buildings','fontsize',12);
hold on;
%detele tweet with unidentified building (ie, buildstmp=0)
ind = find(buildstmp==0);
buildstmp(ind) = []; comfstmp(ind) = []; timestmp(ind) =[];
%plot each tweet
for ii=1:length(buildstmp),
    temp = [lat_long(buildstmp(ii),2),lat_long(buildstmp(ii),1)]; %coordinates
    temp = temp + randn(size(temp))*0.00015 ; %add noise to coordinates to show multiple dots
    if comfstmp(ii)>0, %too warm --> red dots
        plot(temp(1),temp(2),'ko','markerfacecolor','r','markersize',7);
    elseif comfstmp(ii)<0, %too cold--> blue dots
        plot(temp(1),temp(2),'ko','markerfacecolor','b','markersize',7);
    elseif comfstmp(ii)==0,,%comfortable --> green dots
        plot(temp(1),temp(2),'ko','markerfacecolor','g','markersize',7);
    else, %unknown comfort --> black dots
        plot(temp(1),temp(2),'ko','markerfacecolor','k','markersize',7);
    end;
end;

%draw legend for dots
ii=1;  %red dot
plot(-70.9303,43.139873-ii*0.0005,'ko','markerfacecolor','r','markersize',9);
text(-70.93,43.139873-ii*0.0005,'too hot','color','r','FontWeight','bold');
ii=2;  %green dot
plot(-70.9303,43.139873-ii*0.0005,'ko','markerfacecolor','g','markersize',9);
text(-70.93,43.139873-ii*0.0005,'just right','color',[102 204 0]/255,'FontWeight','bold');
ii=3;  %blue dot
plot(-70.9303,43.139873-ii*0.0005,'ko','markerfacecolor','b','markersize',9);
text(-70.93,43.139873-ii*0.0005,'too cold','color','b','FontWeight','bold');
hold off;





function aftermath

%load tweet data
[twstmp,roomstmp,coordstmp,timestmp,userstmp,buildstmp,comfstmp] = load_data;
%load weather data
[weathmax,weathmin,weathavg,weathtime] = weatherdata(datestr(floor(timestmp(1))),...
    datestr(floor(timestmp(end))));

buildnum = 11; %kingsbury
start_date = datestr(floor(timestmp(1)));
end_date = datestr(floor(timestmp(end)));

analyze_building(weathmax,weathmin,weathavg,weathtime,roomstmp,coordstmp,timestmp,userstmp,buildstmp,comfstmp,buildnum,start_date,end_date)




