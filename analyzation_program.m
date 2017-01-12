function analyzation_program(start_date,end_date,building)


%load_data takes the excel sheets, buildlist, roomlist, and coordlist and
%matches each tweet to its respective time, building, comfort score,
%coordinate, and user.  Each of these areas are in their own column so
%there are six columns where each cell corresponds to all other cells in the
%same row which all correspond to the same tweet.  Additionally, load_data
%creates four columns corresponding to the maximum weather, minumum
%weather, average weather, and day that the weather occurred.  These will
%be used later to relate all of the data for each day coming in with the
%respective outside temperatures.  This data corresponds to all of the
%archived tweets
load_data;


%truncate_data takes the stamps and weather data and shortens the columns
%so that they only correspond to the requested building and time.
[weathmax,weathmin,weathavg,weathtime,roomstmp,coordstmp,timestmp,userstmp,buildstmp,comfstmp,buildnum] = truncate_data(start_date,end_date,building);


%analyzes the data for the given building and the given time period:
%       tweet vs. time
%       avg. room comfort w/ # of tweets
%       weather vs number of tweets (hot/cold bar graph) along with the average
%           temperature each day
%       floor plans
%       standard deviation
analyze_building(weathmax,weathmin,weathavg,weathtime,roomstmp,coordstmp,timestmp,userstmp,buildstmp,comfstmp,buildnum,start_date,end_date);


end