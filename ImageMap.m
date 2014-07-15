classdef ImageMap
    properties
        S       % States as each node on the map
        Size    % Size of the map
    end
    
    methods
        function obj = ImageMap(imgfilename)
            % Generate a map from an image
            % NOTE: the map won't have diagonal states
            img = imread(imgfilename);
            imshow(img);
            obj.Size = length(img) + 1;
%             num_elements = (obj.Size+1)^2;
            % Use only up to 3 letter variables in the struct
            obj.S = repmat(struct('con',[], 'obs', false, 'san', false, 'wat', false), obj.Size, obj.Size);
            
            % find the blocked cells in the image and set its corner nodes as obstacles
            for i=1:obj.Size-1
                for j=1:obj.Size-1
                    % if the image has color 223 then it's sand
                    if img(i,j) == 223
                        obj.S(i,j).san = true;
                        obj.S(i+1,j).san = true;
                        obj.S(i,j+1).san = true;
                        obj.S(i+1,j+1).san = true;
                    % if the image has color 101 then it's water
                    elseif img(i,j) == 101
                        obj.S(i,j).wat = true;
                        obj.S(i+1,j).wat = true;
                        obj.S(i,j+1).wat = true;
                        obj.S(i+1,j+1).wat = true;
                    % if the image has color 0 then it's blocked
                    elseif img(i,j) == 0
                        obj.S(i,j).obs = true;
                        obj.S(i+1,j).obs = true;
                        obj.S(i,j+1).obs = true;
                        obj.S(i+1,j+1).obs = true;
                    end
                end
            end
            
            
            % Construct connectivity
            for i=1:obj.Size-1
                for j=1:obj.Size-1
                    % skip obstacle nodes
                    if obj.S(i,j).obs; continue; end
                    % checking Up
                    if i>1 && ~obj.S(i-1,j).obs
                        obj.S(i,j).con = [obj.S(i,j).con; i-1 j];
                    end
                    % checking Down
                    if i<=obj.Size && ~obj.S(i+1,j).obs
                        obj.S(i,j).con = [obj.S(i,j).con; i+1 j];
                    end
                    % checking Left
                    if j>1 && ~obj.S(i,j-1).obs
                        obj.S(i,j).con = [obj.S(i,j).con; i j-1];
                    end
                    % checking Right
                    if j<=obj.Size && ~obj.S(i,j+1).obs
                        obj.S(i,j).con = [obj.S(i,j).con; i j+1];
                    end
                end
            end
            
        end
        
        
        function F = features(obj, i, j, direction)
            F = zeros(1,16);
            
            % facing direction
            F(direction) = 1;
            offset = 4;
            
            if obj.S(i,j).obs
                F(1+offset) = 1;
            end
            if obj.S(i,j).wat
                F(2+offset) = 1;
            end
            if obj.S(i,j).san
                F(3+offset) = 1;
            end
            offset = offset+3;
            
            % obstacles in neighboring nodes
            if i>1 && obj.S(i-1,j).obs
                F(1+offset) = 1;
            end
            if j<obj.Size && obj.S(i,j+1).obs
                F(2+offset) = 1;
            end
            if i<obj.Size && obj.S(i+1,j).obs
                F(3+offset) = 1;
            end
            if j>1 && obj.S(i,j-1).obs
                F(4+offset) = 1;
            end
            % anything outside of the main area is considered as obstacle
            if i==1; F(1+offset) = 1; end
            if j==obj.Size; F(2+offset) = 1; end
            if i==obj.Size; F(3+offset) = 1; end
            if j==1; F(4+offset) = 1; end
            offset = offset+4;
            
            % water in neighboring nodes
            if i>1 && obj.S(i-1,j).wat
                F(1+offset) = 1;
            end
            if j<obj.Size && obj.S(i,j+1).wat
                F(2+offset) = 1;
            end
            if i<obj.Size && obj.S(i+1,j).wat
                F(3+offset) = 1;
            end
            if j>1 && obj.S(i,j-1).wat
                F(4+offset) = 1;
            end
            offset = offset+4;
            
            % sand in neighboring nodes
            if i>1 && obj.S(i-1,j).san
                F(1+offset) = 1;
            end
            if j<obj.Size && obj.S(i,j+1).san
                F(2+offset) = 1;
            end
            if i<obj.Size && obj.S(i+1,j).san
                F(3+offset) = 1;
            end
            if j>1 && obj.S(i,j-1).san
                F(4+offset) = 1;
            end
            offset = offset+4;
            
            % distance to closest obstacle
            % apply BFS to get the closest obstacle
            marked = zeros(obj.Size, obj.Size);
            marked(i,j) = 1;
            queue = [i j]; %coordinates
            found_obstacle = 0;
            found_water = 0;
            found_sand = 0;

            while ~isempty(queue)
                ci = queue(1,1);
                cj = queue(1,2);
                queue(1,:) = []; %remove head
                
                % collect obstacle related features
                if (~found_obstacle && obj.S(ci,cj).obs)
                    if abs(ci-i) > abs(cj-j)
                        if ci<i
                            F(1+offset) = 1;
                        else
                            F(3+offset) = 1;
                        end
                    else
                        if cj<j
                            F(4+offset) = 1;
                        else
                            F(2+offset) = 1;
                        end
                    end
                    dst = sqrt((ci-i)^2 + (cj-j)^2);
                    F(5+offset) = dst;
                    found_obstacle = 1;
                end
                
                % collect water related features
                if (~found_water && obj.S(ci,cj).wat)
                    if abs(ci-i) > abs(cj-j)
                        if ci<i
                            F(6+offset) = 1;
                        else
                            F(8+offset) = 1;
                        end
                    else
                        if cj<j
                            F(9+offset) = 1;
                        else
                            F(7+offset) = 1;
                        end
                    end
                    dst = sqrt((ci-i)^2 + (cj-j)^2);
                    F(10+offset) = dst;
                    found_water = 1;
                end
                
                % collect sand related features
                if (~found_sand && obj.S(ci,cj).san)
                    if abs(ci-i) > abs(cj-j)
                        if ci<i
                            F(11+offset) = 1;
                        else
                            F(13+offset) = 1;
                        end
                    else
                        if cj<j
                            F(14+offset) = 1;
                        else
                            F(12+offset) = 1;
                        end
                    end
                    dst = sqrt((ci-i)^2 + (cj-j)^2);
                    F(15+offset) = dst;
                    found_sand = 1;
                end
                
                % when all the wanted features are collected, exit the loop
                if found_obstacle && found_water && found_sand
                    break;
                end
                
                
                %%%%%%
                %add neighbors that aren't marked yet to the queue
                if ci>1 && ~marked(ci-1,cj)
                    queue(end+1,:) = [ci-1, cj];
                    marked(ci-1,cj) = 1;
                end
                if cj<obj.Size && ~marked(ci,cj+1)
                    queue(end+1,:) = [ci, cj+1];
                    marked(ci,cj+1) = 1;
                end
                if ci<obj.Size && ~marked(ci+1,cj)
                    queue(end+1,:) = [ci+1, cj];
                    marked(ci+1,cj) = 1;
                end
                if cj>1 && ~marked(ci,cj-1)
                    queue(end+1,:) = [ci, cj-1];
                    marked(ci,cj-1) = 1;
                end
            end
            offset = offset + 15;
            
            
            % get n_th neighbor features
            for dst=1:10
                neigh_list = [];
                % find the neighboring states
                for ni=-dst:0
                    neigh_list(end+1,:) = [ni dst+ni];
                end
                for ni=1:dst-1
                    neigh_list(end+1,:) = [ni dst-ni];
                end
                for ni=dst:-1:0
                    neigh_list(end+1,:) = [ni ni-dst];
                end
                for ni=-1:-1:1-dst
                    neigh_list(end+1,:) = [ni -(dst+ni)];
                end
                
                % set these features if neighbors are obstacle
                list_size = size(neigh_list,1);
                for ind=1:list_size
                    ni = i + neigh_list(ind,1);
                    nj = j + neigh_list(ind,2);
                    %if this neighbor falls in the map
                    if ni>0 && ni<=obj.Size && nj>0 && nj<=obj.Size
                        if obj.S(ni,nj).obs
                            F(ind+offset) = 1;
                        else
                            F(ind+offset) = 0;
                        end
                        if obj.S(ni,nj).wat
                            F(ind+list_size+offset) = 1;
                        else
                            F(ind+list_size+offset) = 0;
                        end
                        if obj.S(ni,nj).san
                            F(ind+(2*list_size)+offset) = 1;
                        else
                            F(ind+(2*list_size)+offset) = 0;
                        end
                    end
                end
                offset = offset + 3*list_size;
            end
            
            % distance to the closest obstacle in the current direction
            ci = i;
            cj = j;
            dst = 0;
            while ci>0 && ci<=obj.Size && cj>0 && cj<=obj.Size
                F(1+offset) = dst; %this allows walls to be counted
                if obj.S(ci,cj).obs; break; end
                if direction == 1
                    ci = ci-1;
                elseif direction == 2
                    cj = cj+1;
                elseif direction == 3
                    ci = ci+1;
                elseif direction == 4
                    cj = cj-1;
                end
                dst = dst + 1;
            end
            offset = offset+1;
            
            % closest distance to the wall
            F(1+offset) = min(min(ci, obj.Size-ci), min(cj, obj.Size-cj));
            offset = offset+1;
            
            % can see the wall in either direction
            F(1+offset) = 1;
            F(2+offset) = 1;
            F(3+offset) = 1;
            F(4+offset) = 1;
            for ci=i:-1:1
                if obj.S(ci,j).obs
                    F(1+offset) = 0;
                    break;
                end
            end
            for cj=j:obj.Size
                if obj.S(i,cj).obs
                    F(2+offset) = 0;
                    break;
                end
            end
            for ci=i:obj.Size
                if obj.S(ci,j).obs
                    F(3+offset) = 0;
                    break;
                end
            end
            for cj=j:-1:1
                if obj.S(i,cj).obs
                    F(4+offset) = 0;
                    break;
                end
            end
            offset = offset+4;
                    
        end
        
        
        function display(obj)
            hold on; axis equal; width = 800; height = 800;
            set(gcf, 'Position', [1914-width 998-height width height]);
            set(gca,'Position',[.02 .02 .96 .96]);
            xlim([.5 obj.Size-.5]);
            ylim([.5 obj.Size-.5]);
            % ylabel('i');
            % view(-90, -90);
            
            for i=.5:obj.Size-.5
               plot([.5 obj.Size-.5], [i i]);
               plot([i i], [.5 obj.Size-.5]);
            end
            
            for i=1:obj.Size
                for j=1:obj.Size
                    if obj.S(i,j).obs
                        plot(j-.5,i-.5, 'r.');
                    elseif obj.S(i,j).wat
                        plot(j-.5,i-.5, 'b.');
                    elseif obj.S(i,j).san
                        plot(j-.5,i-.5, 'y.');
                    end
                end
            end
%             % display using state connection
%             for i=1:obj.Size
%                 for j=1:obj.Size
%                     for row=1:size(obj.S(i,j).con,1)
%                         plot(j-.5,i-.5,'.');
%                         next_i = obj.S(i,j).con(row,1);
%                         next_j = obj.S(i,j).con(row,2);
%                         plot([j-.5 next_j-.5], [i-.5 next_i-.5]);
%                     end
%                 end
%                 drawnow;
%             end
        end
       
    end
    
end

