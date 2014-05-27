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
            obj.S = repmat(struct('con',[], 'obs', false), obj.Size, obj.Size);
            
            % find the blocked cells in the image and set its corner nodes as obstacles
            for i=1:obj.Size-1
                for j=1:obj.Size-1
                    % if the image has color 0 then it's blocked
                    if img(i,j) == 0
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
        
        
        function index = get_index(obj,x,y)
            % Returns the state index with a given x, y location on the map
            index = x*(obj.Size)+y+1;
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

