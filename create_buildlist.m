function create_buildlist

buildlist = {'chase', 
    'dem',            
    'dim',
    'greg',
    'hamsmith',
    'hewitt',
    'hort',
    'hud',
    'james',
    'ken',
    'kings',
    'mcc',
    'morrill',
    'morse',
    'mub',
    'murk',
    'nes',
    'nhh',
    'pars',
    'paul',
    'pcac',
    'pet',
    'rud',
    'spauld'};

buildlist_pos{1} = {'chase'};
buildlist_pos{2} = {'dem','demerit'};
buildlist_pos{3} = {'dimond','diamond'};
buildlist_pos{4} = {'greg'};
buildlist_pos{5} = {'ham smith','hsmith','gam','hs','hamsmith'};
buildlist_pos{6} = {'hewitt'};
buildlist_pos{7} = {'hort','horton'};
buildlist_pos{8} = {'hud'};
buildlist_pos{9} = {'james','jms'};
buildlist_pos{10} = {'ken'};
buildlist_pos{11} = {'kings','kingsbury'}; %do not use king because anything like making, walking, talking will be recorded as buildnum = 11
buildlist_pos{12} = {'mub'};
buildlist_pos{13} = {'mcc','mcconnell'};
buildlist_pos{14} = {'morrill','morill','morril','moril','morrel',...
    'morrell','morell','morel','morrle'};
buildlist_pos{15} = {'morse'};
buildlist_pos{16} = {'murk','murkland'};
buildlist_pos{17} = {'nes','nessmith','nesmith'};
buildlist_pos{18} = {'new hampshire hall','nh hall','nhh'};
buildlist_pos{19} = {'pars','parsons'};
buildlist_pos{20} = {'paul'};
buildlist_pos{21} = {'pcac'};
buildlist_pos{22} = {'pet','pettee','petee','pette'};
buildlist_pos{23} = {'rud','rudman'};
buildlist_pos{24} = {'spauld','sls','spaulding'};



save buildlist.mat

end

