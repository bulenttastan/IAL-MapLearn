clear; close all; clc;
tic;
% m = Map(100);
m = ImageMap('maps/map1.png');
m.display(); 
% save m;
% load m;
% UserData.generate_trace(m);



toc;

% start and finish same
% neighboring states are obstacle
% 2 steps ahead if obstacle
% closest obst
% presence of obstacles

% fixed number of iterations: 100

