%% Clear Workspace
%%
close all;
imtool close all;
closepreview;
clear all;
clc;

%% Colour Name & Number Specification
%%
%roygbiv => r=1, o=2, y=3, g=4, b=5, i=v=p=6, any other colour = 7
disp('type the name of the colour you want to define.');
colour_name=input('it must be from the visible spectrum roygbiv: ','s');
fprintf('\n \n');

if strcmp(colour_name,'red')
    colour_num='1';
elseif strcmp(colour_name,'orange')
    colour_num='2';
elseif strcmp(colour_name,'yellow')
    colour_num='3';
elseif strcmp(colour_name,'green')
    colour_num='4';
elseif strcmp(colour_name,'blue')
    colour_num='5';
elseif (strcmp(colour_name,'indigo')||strcmp(colour_name,'voilet')||strcmp(colour_name,'purple'))
    colour_num='6';
else
    colour_num='7';
end
        
im_filename=strcat('definition_',colour_num,'_image.jpg');
mask_filename=strcat('definition_',colour_num,'_mask.mat');
res_filename=strcat('definition_',colour_num,'_result.mat');

%% Image Acquisition/Input
%%
disp('press "ENTER" key to use the webcam to grab a new image and define the');
disp('colour OR');
fprintf('\n')
disp('type "D" or "d" to use a default image and re-define a previously defined');
disp('colour (copy image & mask from "definition images & masks" folder).');
fprintf('\n')
disp('NOTE: acquiring a new image overwrites the default image and becomes');
disp('the new default image,and the mask created overwrites the default');
disp('mask and becomes the new default mask.');

option=input('\n \n select option: ','s');
fprintf('\n \n')
    
if isempty(option)
    % Configure Image Acquisition Settings
    disp('Press "ENTER" key to use default settings which selects the external');
    disp('webcam attached to pc/laptop with a built-in cam OR');
    fprintf('\n')
    disp('type "C" or "c" to configure settings using prompts from this program.');
    config=input('\n \n select option: ','s');
    fprintf('\n \n')

    if isempty(config)
        adaptor='winvideo';
        device=2;
    else
        %query hardware-adaptors, etc
        HWinfo=imaqhwinfo

        disp('select required adaptor; type "1" for 1st adaptor (coreco),');
        disp('"2" for 2nd (winvideo), etc. if unsure, use the winvideo adaptor');
        ADnum=input('\n \n select option: ');
        fprintf('\n \n')

        adaptor=char(HWinfo.InstalledAdaptors(ADnum));

        %query adaptor-available devices
        ADinfo=imaqhwinfo(adaptor)
        
        disp('select required device; type "1" for 1st device (built in cam),');
        disp('"2" for 2nd (external cam 1), etc.');
        DVnum=input('\n \n select option: ');
        fprintf('\n \n')

        device=cell2mat(ADinfo.DeviceIDs(DVnum));    
    end

    %define video object
    vid = videoinput(adaptor,device);   %OR query device
                                        %   DVinfo = imaqhwinfo(adaptor,device);
                                        %   vid = eval(DVinfo.ObjectConstructor);
    %preview video
    preview(vid)
    disp('press "ENTER" key to continue when video has started properly to');
    disp('grab an image');
    fprintf('\n \n');
    pause;    
        
    iRGB=getsnapshot(vid);                  %grab image from webcam
    iRGB=imrotate(iRGB,-90);                %rotate image clockwise ONLY BECAUSE OF WOWEBCAM
    imwrite(iRGB,im_filename,'jpg');        %save image to file
    iRGB = imfilter(iRGB,ones(3,3)/9);      %smoothing; reduce noise and color variation
    %imtool(iRGB)                           %explore color content of image using the image viewer
    disp('click the vertices of the polygon that enclose the ');
    disp('region containing the required colour, then right-');
    disp('click and select create mask.');
    fprintf('\n \n');
    mask=roipoly(iRGB);                     %create mask with 1's where the colours of interest are and 0's elsewhere
    save(mask_filename,'mask');             %save the mask matrix
    
elseif((option=='D')||(option=='d'))
    iRGB=imread(im_filename);               %use default image
    iRGB = imfilter(iRGB,ones(3,3)/9);      %smoothing; reduce noise and colour variation
    %imtool(iRGB)                           %explore colour content of image using the image viewer
    load(mask_filename);                    %load default mask
    
else
    error('invalid input');
    break;
end

%% Colour Definition in the HSV Colour Space
%%
disp(strcat('starting', colour_name,' definition...'));
fprintf('\n \n');
pause(2);

%convert RGB image to HSV & extract Hue(H),Saturation(S) & lightness Value(V) channels
iHSV = rgb2hsv(iRGB) ;
H = iHSV(:,:,1);            %extract the H channel
S = iHSV(:,:,2);            %extract the S channel
V = iHSV(:,:,3);            %extract the V channel for this particular image but we will not use them!

%extract the colour values of interest for the H & S channels using the
%mask & define a suitable range for the V channel. 
h = H(mask);
s = S(mask);
v = 0.6:0.002:1;            %chosen range for v. NOTE: dont use low v since v=0 is black

%now create a matrix containing all v values like so [v1 v2 v3..; 
%                                                     v1 v2 v3..;] etc with the same no. of rows of h rows
vv = repmat(v,[length(h),1]);

%now create a matrix containing all h values like so [h1 h1 h1...;
%                                                     h2 h2 h2...;] etc with same no. of columns of h
%this is also done for s
hh = repmat(h,[1,length(v)]);
ss = repmat(s,[1,length(v)]);

%combine the extracted values for each channel into one 3D matrix
hsvcolours(:,:,1) = hh;
hsvcolours(:,:,2) = ss;
hsvcolours(:,:,3) = vv;

%convert the extracted colours from the hsv space to the rgb space and let the values range from 1 to 256.
rgbcolours = hsv2rgb(hsvcolours);
rgbcolours = round(rgbcolours*255)+1 ;

%reshape each channel into a column matrix & arrange the values side by side 
%(column of r, column of g, column of b) in a matrix & convert to double so can be used in calculations
r=reshape(rgbcolours(:,:,1),prod(size(rgbcolours(:,:,1))),1);
g=reshape(rgbcolours(:,:,2),prod(size(rgbcolours(:,:,2))),1);
b=reshape(rgbcolours(:,:,3),prod(size(rgbcolours(:,:,3))),1);
rgb=double([r,g,b]);

%calculate the average/mean colour vector for use in colour segmentation
%using euclidean distance measure
[rows,cols]=size(rgb);      %rows=no. of rows, cols= no. of columns of the defined colours rgb matrix
rgb_ave=sum(rgb,1)/rows;    %mean vector; calculate the average value of each channel (r_ave,g_ave,b_ave)

save(res_filename,'rgb_ave');       %save the rgb matrix holding the colour definition information

disp(strcat(colour_name,' definition complete...'));
fprintf('\n \n');
pause(2);

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

%% Thresholding using Blob Analysis
%%
disp(strcat('determining', colour_name,' threshold...'));
fprintf('\n \n');
pause(2);

disp('type the initial threshold value or press "ENTER" to use the default value of 250;');
fprintf('\n')
disp('NOTE: this value will also be used if the program fails to obtain an appropriate threshold.');
To=input('\n \n initial threshold: ');  %define initial threshold value;
fprintf('\n \n')
if isempty(To)
    To=250;
end

disp('type the amount by which to decrement T with each iteration or press "ENTER" to use the default value of 0.1;');
decrement=input('\n \n decrement value: ');
fprintf('\n \n')
if isempty(decrement)
    decrement=0.1;
end

T=To;
n=1;

while(1)
    J=find(D<=T);           %return the coordinates of the values contained in D that satisfy the threshold condition
    I=zeros(rows,cols);     %creat a zero matrix same size as original image
    I(J)=1;                 %create a binary vector with the required segmented region defined by the coordinates in J.
    SIo=I;                  %segmentated image output    

    [labeled,numObjects] = bwlabel(SIo,4);   %obtain the labeled image & the number of objects
    
    if numObjects>1
        %display the label matrix as a pseudocolor indexed image
        pseudo_color = label2rgb(labeled, @spring, 'c', 'shuffle');
        imshow(pseudo_color);
        n=n+1;
        T=T-decrement;
        disp(strcat(num2str(numObjects),' objects detected; proceeding with iteration ', num2str(n),'.'));
        fprintf('\n')
        if n>=1000         %if too many iterations
            T=To;
            disp(strcat('could not determine appropriate', colour_name,' threshold. using default value; T='));
            disp(T);
            break;
        end
        
    else
        T=T-T*(5/100);  %include a safety margin to prevent colours close to the colour of the markers being detected 
        disp(strcat(num2str(numObjects),' object detected. ideal', colour_name,' threshold found; T= '));
        disp(T);
        break;
    end
end

fprintf('\n \n')
disp('copy the image and the mask into the "definition images & masks" folder');
disp('copy the results into the folder for the main program.');
disp('NOTE: if the threshold determination process finishes after only 1 or 2 iterations,')
disp('and the segmented image output shows only a white image, then you need to decrease');
disp('the initial threshold.');
figure, imshow(SIo), title('Segmented Image Output'); %display the segmented image output

save(res_filename,'rgb_ave','T');       %save the results

%% Clean Up
%%
if isempty(option)
    delete(vid); clear vid;        % remove video object
end