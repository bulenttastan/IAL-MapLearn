classdef UserData
    %USERDATA Creates and stores user data on the Map
 
    properties
        G           % Adjacency graph of the map
        Map         % Occupancy Map that's used for the shortest path
    end
    
    methods
        function obj = UserData(map)
            % Construct the occupancy map
            obj.Map = zeros(map.Size);
            for i=1:map.Size
                for j=1:map.Size
                    if map.S(i,j).obs
                        obj.Map(i,j) = 1;
                    end
                end
            end
        end
        
        
        function path = collect_data(obj)
            prev_pnt = [1 1];
            path = prev_pnt;

            % Construct the path from the previously clicked point to the clicked point
            while prev_pnt(1)~=size(obj.Map,1) || prev_pnt(2)~=size(obj.Map,2)
                [j, i] = ginput(1);
                cur_pnt = [round(i) round(j)];
                
                % if an obstacle is clicked, skip and warn the user
                if obj.Map(cur_pnt(1),cur_pnt(2))==1
                    disp('Please dont click on obstacles');
                    beep;
                    continue;
                end
                % if the clicked point is close to the end, set it to the end point
                % in order to finish the generation
                if sqrt((cur_pnt - [size(obj.Map,1) size(obj.Map,2)]).^2) < 4
                    cur_pnt = [size(obj.Map,1) size(obj.Map,2)];
                end

                % get the shortest path and extend the existing path
                new_path = obj.shortest_path(prev_pnt, cur_pnt);
                obj.display_path(new_path);

                path = [path; new_path(2:end,:)];
                prev_pnt = cur_pnt;
            end

            % display the path one last time with a different color
            for i=1:size(path,1)-1
                xarr = [path(i,2)-.5 path(i+1,2)-.5];
                yarr = [path(i,1)-.5 path(i+1,1)-.5];
                plot(xarr, yarr, 'y', 'linewidth',2);
            end
        end
        
        
        % Finds the shortest path between previous and current points on the map
        function path = shortest_path(obj, start, goal)
            % start with an empty occupancy map
            map = obj.Map;
            prev = start;
            map(prev(1),prev(2)) = 2;
            
            % Generate the graph for the shortest path
            q = java.util.LinkedList();
            while prev(1)~=goal(1) || prev(2)~=goal(2)
                % Up
                if prev(1)>1 && map(prev(1)-1,prev(2))==0
                    map(prev(1)-1,prev(2)) = map(prev(1),prev(2))+1;
                    q.add([prev(1)-1,prev(2)]);
                end
                % Down
                if prev(1)<size(map,1) && map(prev(1)+1,prev(2))==0
                    map(prev(1)+1,prev(2)) = map(prev(1),prev(2))+1;
                    q.add([prev(1)+1,prev(2)]);
                end
                % Left
                if prev(2)>1 && map(prev(1),prev(2)-1)==0
                    map(prev(1),prev(2)-1) = map(prev(1),prev(2))+1;
                    q.add([prev(1),prev(2)-1]);
                end
                % Right
                if prev(2)<size(map,2) && map(prev(1),prev(2)+1)==0
                    map(prev(1),prev(2)+1) = map(prev(1),prev(2))+1;
                    q.add([prev(1),prev(2)+1]);
                end
                
                prev = q.remove()';
            end
            
            % Trace back from goal to the start to build the shortest path
            path = goal;
            cur = goal;
            cur_value = map(goal(1),goal(2));
            
            while cur_value>2
                % create a list of possible directions then pick one randomly
                list = [];
                % check Up
                if cur(1)>1 && map(cur(1)-1,cur(2))==cur_value-1
                    list = [list; cur(1)-1 cur(2)];
                end
                % check Down
                if cur(1)<size(map,1) && map(cur(1)+1,cur(2))==cur_value-1
                    list = [list; cur(1)+1 cur(2)];
                end
                % check Left
                if cur(2)>1 && map(cur(1),cur(2)-1)==cur_value-1
                    list = [list; cur(1) cur(2)-1];
                end
                % check Up
                if cur(2)<size(map,2) && map(cur(1),cur(2)+1)==cur_value-1
                    list = [list; cur(1) cur(2)+1];
                end
                
                cur = list(randi(size(list,1)),:);
                cur_value = cur_value-1;
                path = [cur; path];
            end
            
%             disp(['Path between [' num2str(start(1)) ',' num2str(start(2)) '] and ['...
%                                    num2str(goal(1)) ',' num2str(goal(2)) ']']);
%             for i=1:size(path,1)
%                 disp(['[' num2str(path(i,1)) ',' num2str(path(i,2)) ']']);
%             end
%             for i=start(1):goal(1)
%                 str = '';
%                 for j=start(2):goal(2)
%                     str = [str ' ' num2str(map(i,j))];
%                 end
%                 disp(str);
%             end
        end
        
        
        function display_path(obj, path)
            for i=1:size(path,1)-1
                xarr = [path(i,2)-.5 path(i+1,2)-.5];
                yarr = [path(i,1)-.5 path(i+1,1)-.5];
                plot(xarr, yarr, 'r', 'linewidth',2);
            end
        end
    end
    
end

