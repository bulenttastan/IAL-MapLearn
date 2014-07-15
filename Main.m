clear; close all; clc;


% useful line of code for calculating angle
% mod(atan2(i-0,j-0) *180/pi + 90, 360);
% direction: N1, E2, S3, W4

m = ImageMap('maps/map1.png');
m.display();


data = UserData(m);
path = data.collect_data();

data.display(path);
load paths;
paths{end+1} = path;

disp(['Path size: ' num2str(size(path,1))]);
disp(['Num items in paths: ' num2str(length(paths))]);

yes_to_save = input('Would you like to save paths (y/n)? ', 's');
if strcmpi(yes_to_save,'yes') || strcmpi(yes_to_save,'y')
    save paths paths;
end


% F = data.features(path,m);
% size(F)




