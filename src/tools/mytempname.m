function temp_nam = mytempname(suffix)
% temp_name = mytempname(suffix)
%  Returns a temporarly file ending with suffix (example suffix: '.txt').
%  Like tempname, but "guarantees" that the file doesn't exist at the time
%  right before the string is returned.
%  The usual warnings about security, race conditions, etc. apply

%% temp
if(~exist('suffix','var'))
    full_suffix = '';
else
    full_suffix = suffix;
end
temp_nam = [tempname() full_suffix];
while(exist(temp_nam,'file'))
    temp_nam = [tempname() full_suffix];
end
