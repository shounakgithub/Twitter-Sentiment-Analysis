function [weathmax,weathmin,weathavg,weathtime] = weatherdata(start_date,end_date)

%read weather data from UNH's weather station website
% http://www.weather.unh.edu/data/
%this programs stores the weather data for each day being analyzed (max,min,avg).
%data is recorded between the hours of 7:00 AM and midnight because the
%temperature during the early morning hours is irrelevant to occupancy
%comfort.
%
%Input example:     start_date = '4/1/2013'     
%                   end_date = '4/30/2013'
%Output:            weathmax     max temperature
%                   weathmin     min temperature
%                   weathavg     avg temperature
%                   weathtime    time strings of the weather data 


%note: reading URL is very slow
%an excel file was created to save the weather data locally
% 1. look for data from excel file
% 2. If start/end dates outside excel file, then add data points to excel file
[data,txt,raw] = xlsread('weather.xls');
weathmax = data(1:end,1); %read max. temperature
weathavg = data(1:end,3); %read mean temperature
weathmin = data(1:end,2); %read min. temperature
weathtime_str = txt(2:end,1); %read temperature time vector
weathtime = datenum(weathtime_str); 

%turn dates into numbers
t = datenum(start_date):datenum(end_date); % a time vector
if length(t)==0, error('end_date earlier than start_date'); end;
%weathtime = datestr(t,'mm/dd/yyyy'); %only output date strings

[t_excel,ind_t,ind_t2] = intersect(weathtime,t); %check if excel time vector contains start/end dates
if isequal(t_excel,t), %all data in excel file
    weathmax  = weathmax(ind_t);
    weathmin  = weathmin(ind_t);
    weathavg  = weathavg(ind_t);
    weathtime = t;
else, %new data needed
    temp = zeros(length(t),1);
    temp(ind_t2) = weathmax(ind_t);  %populate excel data into the zero vector
    weathmax = temp;
    temp(ind_t2) = weathmin(ind_t); weathmin = temp;
    temp(ind_t2) = weathavg(ind_t); weathavg = temp;
    
    %read weather data for each day
    wb = waitbar(0,'Please wait...');
    t0 = cputime;
    for ii = 1:length(t),
        if weathmin(ii)==0 & weathmax(ii)==0, %no data
        %find Jan 1 of the year of the time vector elements
        jan1 = datenum(sprintf('1/1/%d',year(t(ii))));
        %web weather data is numbered from Jan 1 of a particular year
        wtext = urlread(sprintf('http://www.weather.unh.edu/data/%d/%d.txt',...
            year(t(ii)),t(ii)-jan1+1));
        ind=find(wtext==10);
        wtext2 = wtext;
        wtext2(ind)=',';
        
        wmat = str2num(wtext2);
        if length(wmat)/11~=round(length(wmat)/11),
            wmat = wmat(1:end-12); %the last 12 elements are junk
        end;
        wmat = reshape(wmat,11,length(wmat)/11);
        wmat = wmat.';
        wmat = wmat(:,6);
        %save data
        weathmax(ii) = max(wmat);
        weathmin(ii) = min(wmat);
        weathavg(ii) = mean(wmat);
        end;
        waitbar(ii/length(t),wb,...
            sprintf('%.1f sec passed',cputime-t0));
    end;
    close(wb);
    
    %save to excel
    clear data
    data{length(t)+1,4} = {''};
    data(1,1:4) = {'date','max temperature','min','avg'};
    data(2:end,1) = cellstr(datestr(t,'mm/dd/yyyy'));
    data(2:end,2) = num2cell(weathmax);
    data(2:end,3) = num2cell(weathmin);
    data(2:end,4) = num2cell(weathavg);
    xlswrite('weather.xls',data);
    
    %read data again for output
    [data,txt,raw] = xlsread('weather.xls');
    weathmax = data(1:end,1); %read max. temperature
    weathavg = data(1:end,3); %read mean temperature
    weathmin = data(1:end,2); %read min. temperature
    weathtime_str = txt(2:end,1); %read temperature time vector
    weathtime = datenum(weathtime_str);
    
end;


 

% %read weather data for each day
% weathmax = zeros(length(t),1);
% weathmin = weathmax;
% weathavg = weathmax;
% wb = waitbar(0,'Please wait...');
% t0 = cputime;
% for ii = 1:length(t),
%     %find Jan 1 of the year of the time vector elements
%     jan1 = datenum(sprintf('1/1/%d',year(t(ii))));
%     %web weather data is numbered from Jan 1 of a particular year
%     wtext = urlread(sprintf('http://www.weather.unh.edu/data/%d/%d.txt',...
%         year(t(ii)),t(ii)-jan1+1));
%     ind=find(wtext==10);
%     wtext2 = wtext;
%     wtext2(ind)=',';
%     
%     wmat = str2num(wtext2);
%     if length(wmat)/11~=round(length(wmat)/11),
%         wmat = wmat(1:end-12); %the last 12 elements are junk
%     end;
%     wmat = reshape(wmat,11,length(wmat)/11);
%     wmat = wmat.';
%     wmat = wmat(:,6);
%     %save data
%     weathmax(ii) = max(wmat);     
%     weathmin(ii) = min(wmat);
%     weathavg(ii) = mean(wmat);
%     waitbar(ii/length(t),wb,...
%         sprintf('%.1f sec passed',cputime-t0));
% end;
% close(wb);

