
clc;
clear all;
close all;

%Before running this code, please point the MATLAB directory to the twitty
%folder.

creds = struct('ConsumerKey','RV4RL8KWAKPqeQyFOZGiQ',...
    'ConsumerSecret','G2CAXw34p3P2uVRq5EecIhL2dXq0O5wxx8J66UL0M0g',...
    'AccessToken','431331378-JI2Aeg4UZlavrbOh9rayHMdVrTJqvAv7OKhlA3Uw',...
    'AccessTokenSecret','rb2IeuKTbPJjgfRIS7zKVWtwMe2bt3r42JbkbwXQU');

% set up a Twitty object
addpath 'C:\ClimateControl\ShounakTwitter\Twitter\Codes\twitty_1.1.1\twitty.m'; % Twitty
addpath 'C:\ClimateControl\ShounakTwitter\Twitter\Codes\twitty_1.1.1\parse_json.m'; % Twitty's default json parser
addpath 'C:\ClimateControl\ShounakTwitter\Twitter\Codes\twitty_1.1.1\loadjson.m'; % I prefer JSONlab, however.
%load('creds.mat') % load my real credentials
tw = twitty(creds); % instantiate a Twitty object
tw.jsonParser = @loadjson; % specify JSONlab as json parser
X = tw.mentionsTimeline('count','200'); % Find the tweets in the timeline having #UNHBuildings as addressee. 
                                        % The variable X now has all the
                                        % needed information


%S = tw.search('matlab','lang','en');
%count = length(S{1 }.statuses);
% while isfield(S{1}.search_metadata,'next_results')
%     S = tw.search(S{1}.search_metadata.next_results);
%     count = count + length(S{1}.statuses);
% end
% fprintf('Tweets retrieved: %d\n\n',count)

%Instantiating Variables
month = {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
FID = {'fid1','fid2','fid3','fid4','fid5','fid6','fid7','fid8','fid9','fid10','fid11','fid12'};
fid_month = '';
index_month = '';
index_month = [];
index_month_arr = {};
screen_user_name = {};
user_name = 'KaylaMaslauskas';
loop_user_name = '';
match = 0;
match_count = 0;
 
for ii=length(X):-1:1 %Running Reverse for loop in order to chronologically add the tweets in the notepad
   
   % X{ii}.created_at(5:7) gives output as 'Feb'. In order to perform
   % numerical operations on the date, we have to use num2str, after
   % matching the dates with our array on line 35.
   index_month_arr{ii} = num2str(strmatch(X{ii}.created_at(5:7),month)); 
    
    if length(index_month_arr{ii}) == 1
       index_month_arr{ii} = strcat('0',index_month_arr{ii}); % concatenating zeros for the months 1-9 for consistency.
    end
    
    fprintf('\n index day %s & month %s & year %s ', X{ii}.created_at(9:10),index_month_arr{ii},X{ii}.created_at(27:30))
    
    fileID = sprintf('\n F:/Work/Twitter/%s%s.txt',X{ii}.created_at(27:30),index_month_arr{ii}); %Path to store the tweets monthwise
    fid = fopen(fileID, 'a');
    %fprintf(fid,' Month   Name \r\n \r\n');
    fprintf(fid,'\r\n %s',index_month_arr{ii});
    
    %There is an issue of timezone as of 1/28/2016. In that the obtained time
    %from twitter is 5 hours ahead of the actual time. Hence, fixing the
    %issue crudely for the time being X{ii}.created_at(12:19) this contains
    %the entire time of which only 12 and 13 are needed.
    inttime_hr = 0;
    time_hr = X{ii}.created_at(12:13);
    inttime_hr = int32(str2num(time_hr));
    inttime_hr = inttime_hr - 5;
  
    
    
    fprintf(fid,'%s %s %s %d%s', X{ii}.created_at(5:7),X{ii}.created_at(9:10), X{ii}.created_at(27:30),inttime_hr, X{ii}.created_at(14:19));
    fprintf(fid,' %s ',X{ii}.user.screen_name);
    fprintf(fid,' %s ',X{ii}.text);
    fclose(fid);
    
    loop_user_name = (X{ii}.user.screen_name);
    screen_user_name{ii} = loop_user_name;
   
end

%Below is the ongoing code of 'welcome' message for a new user and 'Welcome back message for a year old user.'



% Sorting user names Start
[a b c] = unique(screen_user_name); 
d = hist(c,length(a));
% Sorting user names End
user_name_a = '';


sysdate_clock = fix(clock);

interested_year=2016;%sysdate_clock(1)
interested_month=3; %sysdate_clock(2)
interested_day=10;%sysdate_clock(3)
index_loc = [];


for ii=length(X):-1:1
    
    
    strcmp(user_name,loop_user_name);
    
    %fprintf('\n user_name %s ',X{ii}.user.screen_name);
    
    if ((str2num(index_month_arr{ii})== interested_month))
        % fprintf('month ');
        if(str2num((X{ii}.created_at(9:10)))== interested_day)
            if(str2num((X{ii}.created_at(27:30))) == interested_year)
                % Below line is to find the number of people who tweeted on
                % the interested day, year and month. Once we get that, we
                % can compare the same with the available database.
                fprintf('\n date of tweet %s %s %s.... user name & message %s %s',index_month_arr{ii}, X{ii}.created_at(9:10),X{ii}.created_at(27:30),(X{ii}.user.screen_name),X{ii}.text)
                index_loc(end+1) = ii; % capturing the index_location
                
                
            end
        end
    end
    
    %     if (strcmp(user_name,loop_user_name)== 1)
    %
    %         match_count = match_count+1;
    %         fprintf('match name %s match count ');
    %         fprintf('Hi %s Welcome Back! Your last text was on %s %s %s %s %s ',X{ii}.user.screen_name,X{ii}.created_at(5:7),X{ii}.created_at(9:10), X{ii}.created_at(27:30),inttime_hr, X{ii}.created_at(14:19))
    %     end
end

today = 0;
count_name = 0;


for jjj = 1:length(index_loc)
   
    count_name = 0;
    for iii=length(X):-1:1
       % fprintf('\n iii %d',iii);
        if(strcmp(X{index_loc(jjj)}.user.screen_name, X{iii}.user.screen_name)==1)
            
            
            fprintf('jjj %d   iii %d',jjj,iii);
              fprintf('\n match name Day Month year %s %s %s %s ' ,X{iii}.user.screen_name, (X{iii}.created_at(9:10)), index_month_arr{iii}, (X{iii}.created_at(27:30)));
        end
    end
end

double_index = [];

for jjjj = 1:length(index_match_loc)
   % fprintf('\n TOP jjjj %d ',jjjj);
    if((str2num((X{index_match_loc(jjjj)}.created_at(9:10)))== interested_day)...
            && (str2num(X{index_match_loc(jjjj)}.created_at(27:30))) == interested_year ...
            && str2num(index_month_arr{index_match_loc(jjjj)})== interested_month)
        
        fprintf('\n double jjjj %d ',jjjj);
    
        
    end
end