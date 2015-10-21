function C = contrastvector(str,conditions)

%% Examples:
% str = 'stim[3:10]'
% str='stim_channel1[8:20]-stim_channel1[1:3]+stim_channel1[1:2]'

if(iscellstr(str) | iscell(str))
    for idx=1:length(str)
        C(idx,:) = nirs.design.contrastvector(str{idx},conditions);
    end
    return;
end


%Parse the str
lst=sort([1 strfind(str,'-') strfind(str,'+') length(str)+1]);
for i=2:length(lst)
    S{i-1}=str(lst(i-1):lst(i)-1);
end

for i=1:length(S)
    slocal=S{i};
    if(isempty([strfind(slocal,'-') strfind(slocal,'+')]))
        multiplier{i}=1;
    elseif(~isempty(strfind(slocal,'*')))
        multiplier{i}=str2num(slocal(1:strfind(slocal,'*')-1));
    elseif(~isempty(strfind(slocal,'+')))
        multiplier{i}=1;
    else
        multiplier{i}=-1;
    end
    cond{i}=slocal(max([0 strfind(slocal,'-') strfind(slocal,'+') ...
        strfind(slocal,'*')])+1:end);
    cond{i}=cond{i}(1:min([strfind(cond{i},'[')-1 length(cond{i})]));
    if(isempty(strfind(slocal,'[')))
        indices{i}=[];
    else
        indices{i}=str2num(slocal(strfind(slocal,'['):end));
    end
end


% Remove the numbering off of the stim condition names
for i=1:length(conditions)
    if(double(conditions{i}(end))>=48 & ...
            double(conditions{i}(end))<=57) %  between 0-9
            names{i}=conditions{i}(1:max(strfind(conditions{i},'_'))-1);
    else
        names{i}=conditions{i};
    end
end
names=unique(names);


C = zeros(1,length(conditions));
cond{1}(strfind(cond{1},' '))=[];

for idx=1:length(cond)
    if(isempty(indices{idx}))
        lst=find(ismember(conditions,cond{idx}));
        if(length(lst)==0)
            warning(['unable to find name: ' cond{idx}]);
        end
    else
        lst=[];
        for i=1:length(indices{idx})
            s=['00' num2str(indices{idx}(i))];
            lst=[lst find(ismember(conditions,[cond{idx}...
                '_' s(end-1:end)]))];
        end
        if(length(lst)~=length(indices{idx}) || length(lst)==0)
            warning(['unable to find name: ' cond{idx}]);
        end
    end
   
    
    C(1,lst)=C(1,lst)+ones(1,length(lst))*multiplier{idx};
end