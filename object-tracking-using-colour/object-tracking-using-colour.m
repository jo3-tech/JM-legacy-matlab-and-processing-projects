%% Clear Workspace
%%
close all;
imtool close all;
closepreview;
%COM_CloseNXT('all','bluetooth.ini');   %only closes all open serial ports
                                        %matching the COM-port from the ini-file
COM_CloseNXT('all');
clear all;
clc;

%% Ensure Connection to the NXT (note: only John Hansens enhanced firmware ver 1.27 is supported!)
%%
%connect via usb
%joe_nxt=COM_OpenNXT();             %look for usb devices
%NXT_PlayTone(440, 500, joe_nxt);   %play a tone on joe-nxt
%COM_SetDefaultNXT(joe_nxt);        %sets joe_nxt as the global default handle so we don't have to pass 
%disp('usb connected');             %the name to functions each time as we did above

%connect via bluetooth.... if it doesnt work, restart the nxt and try again
joe_nxt=COM_OpenNXT('bluetooth.ini');   %look for usb devices, then for bluetooth
COM_SetDefaultNXT(joe_nxt);             %sets joe_nxt as the global default handle
%NXT_PlayTone(440, 500);                 %play a tone on joe-nxt
disp('bluetooth connected');
%nxt=COM_GetDefaultNXT;                 %get the handle for the default nxt

%% Check Found Colour
%%
%load results from found colour file
fid=fopen('tracking_colour.txt','r');   %open file for reading
if fid==-1
    colour_num='1';             %follow the default colour (red) if the file could not open
    disp('couldnt determine colour to follow; following red');
else
    colour_num=fgetl(fid);
end
fclose(fid);                    %close file

res_filename=strcat('definition_',colour_num,'_result.mat');

load(res_filename,'rgb_ave','T');   %obtain the mean colour vector stored in variable; rgb_ave &
                                    %obtain the ideal threshold value stored in variable; T

%% Set Parameters, Flags & Initialise Counters
%%
% General
no=1;            %image number
count=0;         %counts how many iterations have passed while no object is found
countmax=500;   %number of iterations before the robot stops looking for the object
Amin=1000;       %minimum area the object must be before the robot recognises it as 'properly in view'
xR=140;          %upper x limit below which the object should be in order be recognised as 'properly in view'
xL=100;          %lower x limit above which the object should be in order be recognised as 'properly in view'   

% NXT Motor objects & parameters (don't need objects if using direct motor commands)
%mC=NXTMotor('C','Power',25);
%mA=NXTMotor('A');   mA.Power=25;
%mAC=NXTMotor('AC','Power',25);
powerC=25;
powerA=25;

%% Image Input Choice
%%
% Configure Image Acquisition Settings
adaptor='winvideo';
device=2;

%define video object
vid = videoinput(adaptor,device);   %OR query device
                                    %   DVinfo = imaqhwinfo(adaptor,device);
                                    %   vid = eval(DVinfo.ObjectConstructor);
%preview video
preview(vid)
pause(2);                           %wait for video to start properly first
disp('starting...');
    
while(1)
    
%% Image Acquisition/Input
%%  
    iRGB=getsnapshot(vid);      %grab image from webcam continuously
    iRGB=imrotate(iRGB,-90);    %rotate image clockwise ONLY BECAUSE OF WOWEBCAM
    
%% Colour Segmentation using Euclidean Distance Measure
%%
    %reshape the input image matrix so that it can be used in the calculation of euclidean distance
    [rows,cols,n] = size(iRGB); %rows=no. of rows, cols= no. of columns of the RGB image matrix
    MASK=true(rows,cols);       %create a unity matrix with same 2D dimensions as the RGB image

    M=rows*cols;
    X=reshape(iRGB,M,n);        %returns an M by n matrix whos elements are taken column-wise from iRGB
    MASK=reshape(MASK,M,1);     %returns an M by 1 matrix whos elements are taken column-wise from MASK
    iRGB2=X(MASK,:);            %reshape iRGB so that we have R1,G1,B1
                                %                             R2,G2,B2...etc
    iRGB2=double(iRGB2);        %convert the input image values to double so they can be used with mathematical operations

    %reshape the average colour vector so that it can be used in the calculation of euclidean distance
    iL=length(iRGB2);
    rgb_ave2=repmat(rgb_ave,iL,1);%shape rgb_ave in the same form as iRGB2; note that this is just repeated values 
                                 %of rgb_ave so we have r_ave,g_ave,b_ave
                                 %                      r_ave,g_ave,b_ave...etc                                                                                                        

    %calculate the euclidean distance between the averaged rgb defined colour values & the RGB image
    D=sqrt(sum(abs(iRGB2-rgb_ave2).^2,2)); %D is a vector which holds the distance between each point in the RGB image & the defined colour
    
    %apply threshold
    J=find(D<=T);           %return the coordinates of the values contained in D that satisfy the threshold condition
    I=zeros(rows,cols);     %create a zero matrix same size as original image
    I(J)=1;                 %create a binary vector with the required segmented region defined by the coordinates in J.
    SIo=I;                  %segmented image output
    
    %noise removal 1; starts
    %SIo=imfill(SIo,'holes');   %fill holes
    %SIo=medfilt2(SIo);         %median filter; remove noise by giving each pixel the value of
                                %the median of the area around it
    %noise removal 1; end
    
%% Localisation
%%
    %labelling
    [labeled,numObjects] = bwlabel(SIo,4);      %obtain the labelled image & the number of objects

    %noise removal 2; start
    if numObjects>1
        stats=regionprops(labeled,'Area');                        
        idx = find([stats.Area] > 500);
        SIo = ismember(labeled, idx);           %select only objects with reasonably large area
        %re-labelling
        [labeled,numObjects] = bwlabel(SIo,4);  %obtain the labelled image & the number of objects
    end
    %noise removal 2; end

    %check if an object is in the scene & follow it if only it's properly in view; start
    if numObjects==0
        %no object hasn't been found
        disp('object not found');           
        StopMotor(MOTOR_A,'off');           %stop the robot since it cant find any objects
        StopMotor(MOTOR_B,'off');            
        disp('stopping');        
        count=count+1;                  
        if count>=countmax;                  %if no object is found after max no. of iterations
            %***********decide what sensor to set or whatever for the controller*******************
            break;                      %exit while loop
        end
        
    else
        %at least one object has been found
        count=0;
        stats=regionprops(labeled,'Area','Centroid'); %obtain properties of objects
        
        if numObjects>1                   %if there is STILL more than 1 object i.e. our object + noise
            pos=find(max([stats.Area]));  %find the position of the object in the stats struct which has the largest area
            stats=stats(pos);
        end
        
        %now for sure we have only one object to follow; fingers crossed it's the right object! as there is no way of knowing
        
        xobj=stats.Centroid(1);         %obtain object location
        Aobj=stats.Area;                %obtain object pixel area
        
        if xobj>xR             %object has moved to the right
            StopMotor(MOTOR_A,'off');
            DirectMotorCommand(MOTOR_C,powerC,0,'off','off',0,'off');
            disp('turning right');
        elseif xobj<xL         %object has moved to the left
            StopMotor(MOTOR_C,'off');
            DirectMotorCommand(MOTOR_A,powerA,0,'off','off',0,'off');
            disp('turning left');
        else                   %object is neither too far to the right nor left
            StopMotor(MOTOR_A,'off');
            StopMotor(MOTOR_C,'off');   
            disp('stopping');
        end
            
        if Aobj<Amin           %object has moved away from robot 
            DirectMotorCommand(MOTOR_C,powerC,0,'off','off',0,'off');
            DirectMotorCommand(MOTOR_A,powerA,0,'off','off',0,'off');
            disp('forward');
        elseif xobj>xR         %object was already to the right so let the robot continue moving right
            StopMotor(MOTOR_A,'off');
        elseif xobj<xL         %object was already to the left so let the robot continue moving left
            StopMotor(MOTOR_C,'off');
        else
            StopMotor(MOTOR_A,'off');
            StopMotor(MOTOR_C,'off');
            disp('stopping');
        end
            
    end
    %check if an object is in the scene & follow it if only it's properly in view; end

    %repeat the while loop at this point
end
            

%% Clean Up
%%
delete(vid); clear vid;        % remove video object
COM_CloseNXT('all');