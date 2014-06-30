clear; close all; clc;
tic;

% useful line of code for calculating angle
% mod(atan2(i-0,j-0) *180/pi + 90, 360);

m = ImageMap('maps/map1.png');
m.display();

% direction: N1, E2, S3, W4
i = 40; j = 40;
F = m.features(i,j,2);
plot(j-.5,i-.5,'g.');
F'
disp(['feature size: ' num2str(length(F))]);
 
% data = UserData(m);
% path = data.collect_data();




toc;

% start and finish same
% neighboring states are obstacle
% 2 steps ahead if obstacle
% closest obst
% presence of obstacles

% fixed number of iterations: 100

