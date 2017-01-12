function create_kml_file(filename,twstmp,timestmp,userstmp,buildstmp,...
    comfstmp,lat_long,time_flag,hot_flag,cold_flag,other_flag)


% %flags to switch on/off placemarkers/properties 
% time_flag  = 0; %setting time stamps in KML (1: yes; 0: no)
% hot_flag   = 1; %setting hot   placemarkers in KML (1: yes; 0: no)
% cold_flag  = 1; %setting cold  placemarkers in KML (1: yes; 0: no)
% other_flag = 1; %setting other placemarkers in KML (1: yes; 0: no)
comf_flag = [hot_flag cold_flag other_flag other_flag]; %hot cold comfort undefined


%write kml file
file_1 = fopen(filename,'w');

fprintf(file_1,'<?xml version="1.0" encoding="UTF-8"?>\n');
fprintf(file_1,'<kml xmlns="http://earth.google.com/kml/2.2">\n\n');
fprintf(file_1,'<Document>\n');
fprintf(file_1,sprintf('  <name>@UNHbuildings Tweets (%s)</name>\n',filename));

%set up location pin styles
if hot_flag==1,
fprintf(file_1,'    <Style id="hot">\n');  %too hot style
fprintf(file_1,'     <IconStyle>\n');
fprintf(file_1,'      <Icon>\n');
fprintf(file_1,'       <href>http://maps.google.com/mapfiles/kml/paddle/red-blank.png</href>\n');
fprintf(file_1,'      </Icon>\n');
fprintf(file_1,'      <hotSpot x="32" y="1" xunits="pixels" yunits="pixels"/>\n');
fprintf(file_1,'     </IconStyle>\n');
fprintf(file_1,'    </Style>\n');
end;
if cold_flag==1,
fprintf(file_1,'    <Style id="cold">\n');  %too cold style
fprintf(file_1,'     <IconStyle>\n');
fprintf(file_1,'      <Icon>\n');
fprintf(file_1,'       <href>http://maps.google.com/mapfiles/kml/paddle/blu-blank.png</href>\n');
fprintf(file_1,'      </Icon>\n');
fprintf(file_1,'      <hotSpot x="32" y="1" xunits="pixels" yunits="pixels"/>\n');
fprintf(file_1,'     </IconStyle>\n');
fprintf(file_1,'    </Style>\n');
end;
if other_flag==1,
fprintf(file_1,'    <Style id="comfortable">\n');  %comfortable style
fprintf(file_1,'     <IconStyle>\n');
fprintf(file_1,'      <Icon>\n');
fprintf(file_1,'       <href>http://maps.google.com/mapfiles/kml/paddle/grn-blank.png</href>\n');
fprintf(file_1,'      </Icon>\n');
fprintf(file_1,'      <hotSpot x="32" y="1" xunits="pixels" yunits="pixels"/>\n');
fprintf(file_1,'     </IconStyle>\n');
fprintf(file_1,'    </Style>\n');
fprintf(file_1,'    <Style id="undefined">\n');  %undefined style
fprintf(file_1,'     <IconStyle>\n');
fprintf(file_1,'      <Icon>\n');
fprintf(file_1,'       <href>http://maps.google.com/mapfiles/kml/paddle/wht-blank.png</href>\n');
fprintf(file_1,'      </Icon>\n');
fprintf(file_1,'      <hotSpot x="32" y="1" xunits="pixels" yunits="pixels"/>\n');
fprintf(file_1,'     </IconStyle>\n');
fprintf(file_1,'    </Style>\n');
end;


str_folder ={'too hot','too cold','comfortable','undefined'};
str_folder = str_folder(find(comf_flag));
ind_folder = ones(size(comfstmp));
ind_folder(comfstmp>0)      = 1; %find all tweet index = too hot
ind_folder(comfstmp<0)      = 2; %find all tweet index = too cold
ind_folder(comfstmp==0)     = 3; %find all tweet index = too hot
ind_folder(isnan(comfstmp)) = 4; %find all tweet index = too cold
list_folder = [1 2 3 4];
list_folder = list_folder(find(comf_flag));
for nn=1:length(list_folder), %four folders/styles - hot, cold, comfortable, undefined
    fprintf(file_1,'<Folder>\n');
    fprintf(file_1,'<name>%s</name>\n',str_folder{nn});
    for ii=1:length(timestmp),
        if ind_folder(ii)==list_folder(nn),
            fprintf(file_1,'<Placemark>\n');
            
            %time stamps in KML
            if time_flag==1,
            fprintf(file_1,'    <TimeStamp><when>%sT00:00:00Z</when></TimeStamp>\n',...
                datestr(timestmp(ii),'yyyy-mm-dd'));
            end;
            
            %clean tweet text
            str_temp = double(twstmp{ii});
            str_temp(str_temp<32 | str_temp>127) = 32; %replace any character (weird character) large than 127 to space ('32'); see ASCII Character Code/Map- http://www.danshort.com/ASCIImap/
            bad_words   = {'fuck','shit','damn'};
            clean_words = {'f**k','sh*t','darn'};
            for jj=1:length(bad_words),
                ind = findstr(str_temp,double(bad_words{jj}));
                for kk=1:length(ind),
                    str_temp(ind(kk):length(bad_words{jj})+ind(kk)-1) = double(clean_words{jj});
                end;
            end;
            str_temp = char(str_temp);
            %     fprintf(file_1,'      <description><![CDATA[<img src="https://pbs.twimg.com/profile_images/421475857870630912/c6FwktT__bigger.jpeg" alt="" width="104" height="142"><br><h2>@%s</h2><p><i><font color="grey">%s</font></i><br>%s</p>]]></description>\n',...
            %         userstmp{ii},datestr(timestmp(ii),'mmm.dd,yyyy HH:MM PM'),str_temp);
            fprintf(file_1,'      <description><![CDATA[<h2>@%s</h2><p><i><font color="grey">%s</font></i><br>%s</p>]]></description>\n',...
                userstmp{ii},datestr(timestmp(ii),'mmm.dd,yyyy HH:MM PM'),str_temp);
            if comfstmp(ii)>0,  %too hot
                fprintf(file_1,'    <styleUrl>#hot</styleUrl>\n');
            elseif comfstmp(ii)<0,  %too cold
                fprintf(file_1,'    <styleUrl>#cold</styleUrl>\n');
            elseif comfstmp(ii)==0,  %just right (comfortable)
                fprintf(file_1,'    <styleUrl>#comfortable</styleUrl>\n');
            else, %undefined comfort level
                fprintf(file_1,'    <styleUrl>#undefined</styleUrl>\n');
            end;
            %lat and longitudes
            temp = [lat_long(buildstmp(ii),2),lat_long(buildstmp(ii),1)]; %coordinates
            temp = temp + randn(size(temp))*0.00015 ; %add noise to coordinates to show multiple dots
            fprintf(file_1,...
                '    <Point><coordinates>%3.15f,%3.15f,%3.15f</coordinates></Point>\n',...
                [temp,0]); %[long,lat,elevation]
            fprintf(file_1,'</Placemark>\n');
        end;
    end;
    
    fprintf(file_1,'</Folder>\n');
end;

fprintf(file_1,'</Document>\n</kml>\n');

fclose(file_1);


function aftermath

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

%load tweet data
[twstmp,roomstmp,coordstmp,timestmp,userstmp,buildstmp,comfstmp] = load_data;
%detele tweet with unidentified building (ie, buildstmp=0)
ind = find(buildstmp==0);
buildstmp(ind) = []; comfstmp(ind) = [];
userstmp(ind) = []; timestmp(ind) =[]; twstmp(ind) =[];

%create kml files (12 files)
%All tweets - Hot, cold, others 
%Lass 100 tweets - hot, cold, others
%Last Fall - hot, cold, others
%Last Spring = hot, cold, others
clear file_names
file_names{1,1} = 'All_hot.kml';
file_names{1,2} = 'All_cold.kml';
file_names{1,3} = 'All_others.kml';
file_names{2,1} = 'Last100_hot.kml';
file_names{2,2} = 'Last100_cold.kml';
file_names{2,3} = 'Last100_others.kml';
file_names{3,1} = 'LastFall_hot.kml';
file_names{3,2} = 'LastFall_cold.kml';
file_names{3,3} = 'LastFall_others.kml';
file_names{4,1} = 'LastSpring_hot.kml';
file_names{4,2} = 'LastSpring_cold.kml';
file_names{4,3} = 'LastSpring_others.kml';

% %server file directory
% file_loc = 'C:\inetpub\wwwroot\wordpress\WebFiles\KML';
% for ii=1:size(file_names,1), %all, last100, LastFall, LastSpring
%     for jj=1:size(file_names,2), %hot, cold, others
%         file_names{ii,jj} = sprintf('%s\\%s',file_loc,file_names{ii,jj});
%     end; end;


%set function input parameters
time_flag  = 0; %setting time stamps in KML (1: yes; 0: no)
hot_flag   = [1 0 0]; %setting hot   placemarkers in KML (1: yes; 0: no)
cold_flag  = [0 1 0]; %setting cold  placemarkers in KML (1: yes; 0: no)
other_flag = [0 0 1]; %setting other placemarkers in KML (1: yes; 0: no)

%find 
clear ind
ind{1} = 1:length(timestmp);
ind{2} = length(timestmp)-99:length(timestmp);
ind{3} = find(timestmp>=datenum('1/1/2013') & timestmp<=datenum('5/31/2013'));
ind{4} = find(timestmp>=datenum('8/23/2013') & timestmp<=datenum('12/31/2013'));


for ii=1:size(file_names,1), %all, last100, LastFall, LastSpring
    for jj=1:size(file_names,2), %hot, cold, others
        create_kml_file(file_names{ii,jj},twstmp(ind{ii}),timestmp(ind{ii}),...
            userstmp(ind{ii}),buildstmp(ind{ii}),comfstmp(ind{ii}),lat_long,....
            time_flag,hot_flag(jj),cold_flag(jj),other_flag(jj));
    end;
end;
    
    
filename = 'All.kml';
create_kml_file(filename,twstmp,timestmp,userstmp,buildstmp,comfstmp,...
    lat_long,0,1,1,1);
%last 100 tweets
filename = 'Last100_cold.kml';
ind = length(timestmp)-99:length(timestmp);
create_kml_file(filename,twstmp(ind),timestmp(ind),userstmp(ind),...
    buildstmp(ind),comfstmp(ind),lat_long);
%Spring 2014
filename = 'Spring2014_cold.kml';
ind = find(timestmp>=datenum('1/1/2014') & timestmp<=datenum('5/31/2014'));
create_kml_file(filename,twstmp(ind),timestmp(ind),userstmp(ind),...
    buildstmp(ind),comfstmp(ind),lat_long);
%Spring 2013
filename = 'Spring2013_cold.kml';
ind = find(timestmp>=datenum('1/1/2013') & timestmp<=datenum('5/31/2013'));
create_kml_file(filename,twstmp(ind),timestmp(ind),userstmp(ind),...
    buildstmp(ind),comfstmp(ind),lat_long);
%Fall 2013
filename = 'Fall2013_cold.kml';
ind = find(timestmp>=datenum('8/23/2013') & timestmp<=datenum('12/31/2013'));
reate_kml_file(filename,twstmp(ind),timestmp(ind),userstmp(ind),...
    buildstmp(ind),comfstmp(ind),lat_long);

