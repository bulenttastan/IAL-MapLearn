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
%             num_elements = (obj.Size+1)^2;
            % Use only up to 3 letter variables in the struct
            obj.S = repmat(struct('con',[], 'obs', false), obj.Size+1, obj.Size+1);
            
            % find the blocked cells in the image and set its corner nodes as obstacles
            for i=1:obj.Size
                for j=1:obj.Size
                    % if the image has color 0 then it's blocked
                    if img(i,j) == 0
                        obj.S(i,j).obs = true;
                        obj.S(i+1,j).obs = true;
                        obj.S(i,j+1).obs = true;
                        obj.S(i+1,j+1).obs = true;
                    end
                end
            end
            
            

%             % Construct the states and connectivity (4-way)
%             for i=1:obj.Size+1
%                 for j=1:obj.Size+1
%                     % if the node is surounded by a block then it automatically
%                     % becomes an obstacle, so we skip any connection for it
%                     if i<=obj.Size && j<=obj.Size && img(i,j)==0; continue; end
%                     if i>0 && j<=obj.Size && img(i-1,j)==0; continue; end
%                     if i<=obj.Size && j>0 && img(i,j-1)==0; continue; end
%                     if i>0 && j>0 && img(i-1,j-1)==0; continue; end
%                     
%                     is_up_blocked = false;
%                     is_down_blocked = false;
%                     is_left_blocked = false;
%                     is_right_blocked = false;
%                     if i==1 || im(i-1,j)==0; is_up_blocked = true; end
%                     if i==obj.Size+1 || im(i,j)==0; is_down_blocked = true; end
%                     if j==1 || im(i,j-1)==0; is_left_blocked = true; end
%                     if j==obj.Size+1 || im(i,j)==0; is_right_blocked = true; end
%                         
%                     % Up
%                     neig_states = ones(1,4); %NW, NE, SE, SW clockwise neighboring states
%                     
%                     if is_up_blocked; neig_states([1 2]) = 0; end
%                     if is_down_blocked; neig_states([3 4]) = 0; end
%                     if is_left_blocked; neig_states([1 4]) = 0; end
%                     if is_right_blocked; neig_states([2 3]) = 0; end
%                     
%                     if neig_states(1)==1:
%                         obj.S(i,j).con = [obj.S(i,j).con [i-1,j]];
%                     end
%                     
%                     % Right
%                     if x+1<=obj.Size
%                         index = get_index(obj,x+1,y);
%                         obj.S(cur_index).con = [obj.S(cur_index).con index];
%                         obj.S(index).con = [obj.S(index).con cur_index];
%                     end
% 
%                     % Down
%                     if y-1>=0
%                         index = get_index(obj,x,y-1);
%                         obj.S(cur_index).con = [obj.S(cur_index).con index];
%                         obj.S(index).con = [obj.S(index).con cur_index];
%                     end
% 
%                     % Up
%                     if y+1<=obj.Size
%                         index = get_index(obj,x,y+1);
%                         obj.S(cur_index).con = [obj.S(cur_index).con index];
%                         obj.S(index).con = [obj.S(index).con cur_index];
%                     end
%                 end
%             end

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
            
            
            for i=1:obj.Size+1
                for j=1:obj.Size+1
                    if obj.S(i,j).obs
                        plot(j-.5,i-.5, 'r.');
                    end
                end
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

