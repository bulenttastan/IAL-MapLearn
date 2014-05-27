clear; close all; clc;
tic;
m = ImageMap('maps/map1.png');
m.display(); 

data = UserData(m);
data.collect_data();


toc;

% start and finish same
% neighboring states are obstacle
% 2 steps ahead if obstacle
% closest obst
% presence of obstacles

% fixed number of iterations: 100

