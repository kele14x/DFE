function p = dfepath()
%DFEPATH is a helper function to return the path to this project's root folder

p = fullfile(fileparts(mfilename('fullpath')), '..');

end
