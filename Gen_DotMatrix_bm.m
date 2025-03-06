function DotMatrix = Gen_DotMatrix_bm(MotionDir,MotionCoh,NumFrames,DotNum,InnerRadius,OuterRadius,StepPerMove)
    
    % by Ke Jia
    % 2021/10/27 21:24
    % generate dot matrix using bm methods (see Pilly_2009_VR for more details)
    % we have 400 dots, so please use (0:0.25:100)/100 for the coherence level
    
   
    %*************************************
    %*********Initialization**************
    %*************************************
    DotMatrix = cell(1,int16(NumFrames));
    %初始化运动点
    for dot_i = 1:DotNum      
        rr1 = rand();
        rr2 = rand();
        rand_r = max(rr1,rr2);                   %确保在圆内均匀分布
             
        Curr_Radius = InnerRadius + rand_r*(OuterRadius-InnerRadius); %产生随机半径，确保不遮挡注视点
        Curr_Angle  = rand()*2*pi;                  %产生随机角度       
        DotMatrix{1,1}(:,dot_i) = [Curr_Radius*cos(Curr_Angle);Curr_Radius*sin(Curr_Angle)]; %产生完整的随机点
    end
    
    
    %*************************************
    %*************Movement****************
    %*************************************
    Curr_Move = [StepPerMove*cos(MotionDir/180*pi);StepPerMove*sin(MotionDir/180*pi)];
    
    
    %*************************************
    %****Gen positions for each frame*****
    %*************************************
    for frame_i = 2:NumFrames 
      
        % select dots
        temp = randperm(DotNum);
        SignalDots = temp(1:(DotNum * MotionCoh));
      
        %gen movement for all the dos
        temp_angle = rand(1,DotNum)*2*pi;
        temp_move = [StepPerMove*cos(temp_angle);StepPerMove*sin(temp_angle)];  
        
%         if ~isempty(SignalDots)
%             temp_move(:,SignalDots)= repmat(Curr_Move,1,size(SignalDots));
%         end
        if ~isempty(SignalDots)
            temp_move(:,SignalDots)= repmat(Curr_Move,size(SignalDots));
        end
        
        DotMatrix{1,frame_i}(:,:) = DotMatrix{1,frame_i-1}(:,:) + temp_move;
        
        for dot_i = 1:DotNum 
            %out of bound
            r_now = sqrt(DotMatrix{1,frame_i}(1,dot_i)^2 + DotMatrix{1,frame_i}(2,dot_i)^2);
            r_dot = sqrt(DotMatrix{1,frame_i-1}(1,dot_i)^2 + DotMatrix{1,frame_i-1}(2,dot_i)^2);

            if r_now > (OuterRadius)||r_now<(InnerRadius)
                r_now = r_dot;
               
                if (DotMatrix{1,frame_i-1}(1,dot_i)>=0) && (DotMatrix{1,frame_i-1}(2,dot_i) >= 0)
                    ang_now = atan(DotMatrix{1,frame_i-1}(2,dot_i)/DotMatrix{1,frame_i-1}(1,dot_i)) + pi;
                elseif (DotMatrix{1,frame_i-1}(1,dot_i)<0) && (DotMatrix{1,frame_i-1}(2,dot_i) >= 0)
                    ang_now = atan(DotMatrix{1,frame_i-1}(2,dot_i)/DotMatrix{1,frame_i-1}(1,dot_i) ) ;             
                elseif (DotMatrix{1,frame_i-1}(1,dot_i)<0) && (DotMatrix{1,frame_i-1}(2,dot_i) < 0)
                    ang_now = atan(DotMatrix{1,frame_i-1}(2,dot_i)/DotMatrix{1,frame_i-1}(1,dot_i));              
                elseif (DotMatrix{1,frame_i-1}(1,dot_i)>0) && (DotMatrix{1,frame_i-1}(2,dot_i) <0)
                    ang_now = atan(DotMatrix{1,frame_i-1}(2,dot_i)/DotMatrix{1,frame_i-1}(1,dot_i)) + pi;              
                elseif (DotMatrix{1,frame_i-1}(1,dot_i)==0) && (DotMatrix{1,frame_i-1}(2,dot_i) < 0)
                    ang_now = atan(DotMatrix{1,frame_i-1}(2,dot_i)/DotMatrix{1,frame_i-1}(1,dot_i))+pi; 
                end
       
                DotMatrix{1,frame_i}(:,dot_i) = [r_now*cos(ang_now) ;r_now*sin(ang_now)];
            end
        end
    end  
end  