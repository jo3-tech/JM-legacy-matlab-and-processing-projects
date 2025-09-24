%% Clear Workspace
%%
close all;
imtool close all;
closepreview;
clear all;
clc;

%% Explore Image Acquisition Hardware
%%
%UNCOMMENT ANY OF THE REQUIRED CODE BELOW TO EXPLORE IMAGE ACQUISITION HARDWARE
%query hardware - installed adaptors?
%info = imaqhwinfo                      %shows installed adaptor is winvideo

%query adaptor - available devices?
%adaptor_info = imaqhwinfo('winvideo')  %returns two device Id's; 1 = the inbuilt one & 2 = the external one
                                        %the external one is the required one hence we continue with '2'

%query device - default constructor? 
%device_info = imaqhwinfo('winvideo',2)

%device info - supported formats?
%device_info.SupportedFormats'

%% Explore Video/Image Acquisition & Configuration Tools & Options
%%
%UNCOMMENT ANY OF THE REQUIRED CODE BELOW TO EXPLORE IMAGE ACQUISITION TOOLS & OPTIONS
%connect device (default constructor)
%vid = eval(device_info.ObjectConstructor)

%configure device using property inpsector
%inspect(vid)

%examine device properties programmatically
%frames_per_trigger=get(vid,'FramesPerTrigger')     %answer was 10 i.e it will return 10frames everytime getdata() is used

%configure device properties programmatically    
%set(vid,'FramesPerTrigger',4)  %use to change the number of frames returned by getdata()

%configure source properties                    
%src = getselectedsource(vid)
%inspect(src)

%preview video (set up camera focus, lighting, etc)
%preview(vid)
%disp('press "enter" key to continue');
%pause;

%set brightness etc
%set(obj_src,'Brightness',128);
%set(obj_src,'saturation',200);

%get snapshot
%frame = getsnapshot(vid);  %get a single image frame (independent of framespertrigger property)
%figure, imshow(frame)
%disp('press "enter" key to continue');
%pause;

%close all           % close all figure windows

%start acquisition, get data & display frames
%start(vid)  %this command captures the no. of frames indicated in framespertrigger and stores them in memory
%frames = getdata(vid);  %get the number of frames indicated by framesPerTrigger
%imaqmontage(frames)     %display the grabbed images as a montage (in sequence in one image)

%skip first frames
%set(vid,'TriggerFrameDelay',2)  %skip 2 frames.... type SET(vid) to see property names and their possible values
%start(vid)
%frames = getdata(vid);
%imaqmontage(frames)

%save image to file
%imwrite(frames(:,:,:,end),'last_frame.png','png') %save the last frame

%start acquisition, get only a number of frames from the data
%start(vid)
%frames = getdata(vid,2);   %get the 1st 2 frames

%% Clean Up
%%
%stop(vid);
%delete(vid);   %clear(vid);        % remove video object
close all;
imtool close all;
closepreview;
clear all;
clc;

%% Acquire Video/Image Data
%%

%perform image acquisition depending on what is required;
%images grabbed as per user request or images grabbed continuously

%define video object
vid = videoinput('winvideo',2); % OR device_info = imaqhwinfo('winvideo',2);
                                %    vid =
                                %    eval(device_info.ObjectConstructor);

%images grabbed as per user request using getsnapshot
%%

%preview video
preview(vid)
disp('press "enter" key to continue when video has started properly');
pause;

n=1;

while(1)
    image_name=strcat('image acquisition',num2str(n),'.jpg');
    disp('press "enter" key to grab the next frame OR');
    disp('type "D" or "d" to use the default image OR');
    disp('type the name of an image "file_name.jpg" OR');
    disp('type "999" to stop image acquisition')
    k=input('','s');
    
    
    if strcmp(k,'999')
        break;                  %exit the while loop
    elseif isempty(k)
        I=getsnapshot(vid);     %grab image here from webcam
    elseif((k=='D')|(k=='d'))
        I=imread(image_name);   %use default image
    else
        I=imread(k);            %use image indicated by the type input
    end
    
    imwrite(I,image_name,'jpg') %save current image to file
    imshow(I)
   
    
    %now perform any operations you want on the image I
    
    
    n=n+1;
end



break;


% images grabbed continuously using trigger 
% i think it is better to just use getsnapshot since only a single image is required but 
%a single image can also be acquired using trigger like so
%%

triggerconfig(vid,'manual');    %set the vid object to manual triggering
set(vid,'FramesPerTrigger',1 ); %capture only a single image when triggered
set(vid,'TriggerRepeat', Inf);  %can use trigger command an infinite number of times
                                %if set to a finite number, you have to start the 
                                %video again one trigger is used beyond that number

%start video capture
start(vid);                                
                                
%preview video
preview(vid)
disp('press "enter" key to continue when video has started properly');
pause;

while(1)
    
    trigger(vid); 
    I=getdata(vid,1);           %grab image here from webcam
        
        
    %now perform any operations you want on the image I
    
end


%% Clean Up
%%
%stop(vid); delete(vid); clear vid;        % remove video object