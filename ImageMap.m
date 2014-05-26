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
            obj.Size = length(img);
            num_elements = (obj.Size+1)^2;
            obj.S = repmat(struct('x',0,'y',0,'con',[]), num_elements, 1);
            
            % Construct the states
            index = 1;
            for x=0:obj.Size
                for y=0:obj.Size
                    obj.S(index) = struct('x',x,'y',y,'con',[]);
                    index = index+1;
                end
            end

            % Construct connectivity (4-way)
            for x=0:obj.Size
                for y=0:obj.Size
                    cur_index = get_index(obj,x,y);
                    % Left
                    if x-1>=0
                        index = get_index(obj,x-1,y);
                        obj.S(cur_index).con = [obj.S(cur_index).con index];
                        obj.S(index).con = [obj.S(index).con cur_index];
                    end

                    % Right
                    if x+1<=obj.Size
                        index = get_index(obj,x+1,y);
                        obj.S(cur_index).con = [obj.S(cur_index).con index];
                        obj.S(index).con = [obj.S(index).con cur_index];
                    end

                    % Down
                    if y-1>=0
                        index = get_index(obj,x,y-1);
                        obj.S(cur_index).con = [obj.S(cur_index).con index];
                        obj.S(index).con = [obj.S(index).con cur_index];
                    end

                    % Up
                    if y+1<=obj.Size
                        index = get_index(obj,x,y+1);
                        obj.S(cur_index).con = [obj.S(cur_index).con index];
                        obj.S(index).con = [obj.S(index).con cur_index];
                    end
                end
            end

            % Clear dupes in the connections
            for i=1:length(obj.S)
                obj.S(i).con = sort(unique(obj.S(i).con));
            end
        end
        
        
        function index = get_index(obj,x,y)
            % Returns the state index with a given x, y location on the map
            index = x*(obj.Size+1)+y+1;
        end
        
        
        function display(obj)
            hold on; axis equal; width = 800; height = 800;
            set(gcf, 'Position', [1914-width 998-height width height]);
            set(gca,'Position',[.02 .02 .96 .96]);
            xlim([.5 obj.Size+.5]);
            ylim([.5 obj.Size+.5]);
            for i=.5:obj.Size+.5
               plot([.5 obj.Size+.5], [i i]);
               plot([i i], [.5 obj.Size+.5]);
            end
            
%             % display using 'connection'
%             for i=1:length(obj.S)
%                 for next_ind=obj.S(i).con
%                     plot([obj.S(i).x obj.S(next_ind).x], [obj.S(i).y obj.S(next_ind).y]);
%                 end
%             end
        end
       
    end
    
end

