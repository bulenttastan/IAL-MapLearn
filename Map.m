classdef Map
    properties
        S       % States as each node on the map
        Size    % Size of the map
    end
    
    methods
        function obj = Map(size)
        % Constructor generates a map of given size
            obj.Size = size;
            num_elements = (size+1)^2+size^2;
            obj.S = repmat(struct('x',0,'y',0,'connection',[],'is_obstacle',false), num_elements, 1 );
            
            % Construct the states
            index = 1;
            for x=0:size
                for y=0:size
                    obj.S(index) = struct('x',x,'y',y,'connection',[],'is_obstacle',false);
                    index = index+1;
                end
            end

            for x=0:size-1
                for y=0:size-1
                    obj.S(index) = struct('x',x+0.5,'y',y+0.5,'connection',[],'is_obstacle',false);
                    index = index+1;
                end
            end

            % Construct connectivity (8-way)
            for x=0:size
                for y=0:size
                    cur_index = get_index(obj,x,y);
                    % Left
                    if x-1>=0
                        index = get_index(obj,x-1,y);
                        obj.S(cur_index).connection = [obj.S(cur_index).connection index];
                        obj.S(index).connection = [obj.S(index).connection cur_index];
                    end

                    % Right
                    if x+1<=size
                        index = get_index(obj,x+1,y);
                        obj.S(cur_index).connection = [obj.S(cur_index).connection index];
                        obj.S(index).connection = [obj.S(index).connection cur_index];
                    end

                    % Down
                    if y-1>=0
                        index = get_index(obj,x,y-1);
                        obj.S(cur_index).connection = [obj.S(cur_index).connection index];
                        obj.S(index).connection = [obj.S(index).connection cur_index];
                    end

                    % Up
                    if y+1<=size
                        index = get_index(obj,x,y+1);
                        obj.S(cur_index).connection = [obj.S(cur_index).connection index];
                        obj.S(index).connection = [obj.S(index).connection cur_index];
                    end

                    % Diagonals
                    % Left-Down
                    if x-0.5>=0 && y-0.5>=0
                        index = get_index(obj,x-0.5,y-0.5);
                        obj.S(cur_index).connection = [obj.S(cur_index).connection index];
                        obj.S(index).connection = [obj.S(index).connection cur_index];
                    end

                    % Left-Up
                    if x-0.5>=0 && y+0.5<=size
                        index = get_index(obj,x-0.5,y+0.5);
                        obj.S(cur_index).connection = [obj.S(cur_index).connection index];
                        obj.S(index).connection = [obj.S(index).connection cur_index];
                    end

                    % Right-Down
                    if x+0.5<=size && y-0.5>=0
                        index = get_index(obj,x+0.5,y-0.5);
                        obj.S(cur_index).connection = [obj.S(cur_index).connection index];
                        obj.S(index).connection = [obj.S(index).connection cur_index];
                    end

                    % Right-Up
                    if x+0.5<=size && y+0.5<=size
                        index = get_index(obj,x+0.5,y+0.5);
                        obj.S(cur_index).connection = [obj.S(cur_index).connection index];
                        obj.S(index).connection = [obj.S(index).connection cur_index];
                    end
                end
            end

            % Clear dupes in the connections
            for i=1:length(obj.S)
                obj.S(i).connection = sort(unique(obj.S(i).connection));
            end

%             % Generate obstacles
%             num_obstacles = 50;
%             for i=1:num_obstacles
%                 ind = randi(length(obj.S));
%                 obj.S(ind).is_obstacle = true;
%             end
        end
        
        
        function index = get_index(obj,x,y)
        % Returns the state index with a given x, y location on the map
            if rem(x,1)~=0 || rem(y,1)~=0
                index = (obj.Size+1)^2;
                nx = floor(x);
                ny = floor(y);
                index = index + nx*obj.Size+ny+1;
            else
                index = x*(obj.Size+1)+y+1;
            end
        end
        
        
        function display(obj)
            hold on; axis equal; width = 800; height = 800;
            set(gcf, 'Position', [1914-width 998-height width height]);
            set(gcf,'Units','normal');
            set(gca,'Position',[.02 .02 .96 .96]);
            xlim([0 obj.Size]);
            ylim([0 obj.Size]);
            % % display using 'connection'
            % for i=1:length(obj.S)
            %     for next_ind=obj.S(i).connection
            %         plot([obj.S(i).x obj.S(next_ind).x], [obj.S(i).y obj.S(next_ind).y]);
            %     end
            % end
            for i=0:obj.Size
               plot([0 obj.Size], [i i]);
               plot([i i], [0 obj.Size]);
               plot([i obj.Size], [0 obj.Size-i]);
               plot([0 i], [obj.Size-i obj.Size]);
               
               plot([i 0], [0 i]);
               plot([i obj.Size], [obj.Size i]);
            end
            for i=1:length(obj.S)
                if obj.S(i).is_obstacle
                    plot(obj.S(i).x, obj.S(i).y, '.y', 'linewidth',2);
                else
                    plot(obj.S(i).x, obj.S(i).y, '.');
                end
            end
        end
       
    end
    
end

