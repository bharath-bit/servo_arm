clc
close all
clear all



a = imaqhwinfo('winvideo');

% Capture the video frames using the videoinput function
% You have to replace the resolution & your installed adaptor name.
vid = videoinput('winvideo',1,'YUY2_320x240');%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%11

% Set the properties of the video object
set(vid, 'FramesPerTrigger', Inf);
set(vid, 'ReturnedColorspace', 'rgb')
vid.FrameGrabInterval = 3;
 port = 'COM3';
board = 'Uno';
% creating arduino object with servo library
arduino_board = arduino(port, board, 'Libraries', 'Servo');
         servo_motor1 = servo(arduino_board, 'D8');
         servo_motor2= servo(arduino_board, 'D9');
         servo_motor3 = servo(arduino_board, 'D10');
         servo_motor4 = servo(arduino_board, 'D11');
          writePosition(servo_motor1, 0.5);
     writePosition(servo_motor2, 0.5);
     writePosition(servo_motor3, 1);
     writePosition(servo_motor4, 0.2);
  
%start the video aquisition here
start(vid)
preview(vid)
% disp('press any key to continue..')
% pause


% Set a loop that stop after 500 frames of aquisition
while(vid.FramesAcquired<=2000)
    pause(2)
    % Get the snapshot of the current frame
    data = getsnapshot(vid);
    
    % Now to track RED objects in real time
    % we have to subtract the RED component 
    % from the grayscale image to extract the red components in the image.
    diff_im1 = imsubtract(data(:,:,1), rgb2gray(data));
    %figure(3)
    %imshow(data(:,:,1))
%     figure(1)
%     subplot(2,2,1)
%     imshow(diff_im1)
%     title('Difference Image for RED')
     % Now to track GREEN objects in real time
    % we have to subtract the GREEN component 
    % from the grayscale image to extract the GREEN components in the image.
    diff_im2 = imsubtract(data(:,:,2), rgb2gray(data));    
%     subplot(2,2,2)
%     imshow(diff_im2)
%     title('Difference Image for GREEN')
     % Now to track BLUE objects in real time
    % we have to subtract the BLUE component 
    % from the grayscale image to extract the BLUE components in the image.
    diff_im3 = imsubtract(data(:,:,3), rgb2gray(data));
%     subplot(2,2,3)
%     imshow(diff_im3)
%     title('Difference Image for BLUE')
    %Use a median filter to filter out noise
    diff_im1 = medfilt2(diff_im1, [3 3]);
    diff_im2 = medfilt2(diff_im2, [3 3]);
    diff_im3 = medfilt2(diff_im3, [3 3]);
    % Convert the resulting grayscale image into a binary image.
    diff_im1 = im2bw(diff_im1,0.24);
    diff_im2 = im2bw(diff_im2,0.12);
    diff_im3 = im2bw(diff_im3,0.08); 
    % Remove all those pixels less than 300px
    diff_im1 = bwareaopen(diff_im1,300);
    diff_im2 = bwareaopen(diff_im2,300);
    diff_im3 = bwareaopen(diff_im3,300);
    % Label all the connected components in the image.
    bw1 = bwlabel(diff_im1, 8);
    bw2 = bwlabel(diff_im2, 8);
    bw3 = bwlabel(diff_im3, 8);
    
    % Here we do the image blob analysis.
    % We get a set of properties for each labeled region.
    stats1 = regionprops(bw1, 'BoundingBox', 'Centroid');
    stats2 = regionprops(bw2, 'BoundingBox', 'Centroid');
    stats3 = regionprops(bw3, 'BoundingBox', 'Centroid');
    
    % Display the image
    figure(1)
    imshow(data)    
    title('RGB objects')
    hold on
    %This is a loop to bound the red objects in a rectangular box.
    for object = 1:length(stats1)
        bb = stats1(object).BoundingBox;
        bc = stats1(object).Centroid;
        rectangle('Position',bb,'EdgeColor','r','LineWidth',2)
        plot(bc(1),bc(2), '-r+')
        a1=text(bc(1)+15,bc(2), strcat('RED: X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
        set(a1, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
%         disp('Stop signal Ahead')       
        %s = serial('COM7');
%         fopen(s);
%         fwrite(s,'A');
%         fclose(s);
    end
    for object = 1:length(stats2)
        bb = stats2(object).BoundingBox;
        bc = stats2(object).Centroid;
        rectangle('Position',bb,'EdgeColor','g','LineWidth',2)
        plot(bc(1),bc(2), '-g+')
        a2=text(bc(1)+15,bc(2), strcat('GREEN: X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
        set(a2, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
       % disp('Green Signal ahead')
%         s = serial('COM7');
%         fopen(s);
%         fwrite(s,66);
%         fclose(s);
    end
    for object = 1:length(stats3)
         bb = stats3(object).BoundingBox;
         bc = stats3(object).Centroid;
         rectangle('Position',bb,'EdgeColor','b','LineWidth',2)
         plot(bc(1),bc(2), '-b+')
         a3=text(bc(1)+15,bc(2), strcat('BLUE: X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
         set(a3, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
    end
         disp('Blue signal Ahead')       
        % s = serial('COM7');
%         fopen(s);
%         fwrite(s,'B');
%         fclose(s);
%         
%    end
    
   redcount=length(stats1)
greencount=length(stats2)
bluecount=length(stats3)










  switch redcount
      
      case 1
         writePosition(servo_motor1, 0.5);
     writePosition(servo_motor2, 0.5);
     writePosition(servo_motor3, 0.5);
     writePosition(servo_motor4, 0);
    current_position = readPosition(servo_motor2);
    writePosition(servo_motor4, 0.2);
writePosition(servo_motor2, 0.1);
pause(0.3)
writePosition(servo_motor3, 0.25);
pause(0.3)

    
    

%fprintf(ser,'%s',a);
%fclose(ser);
       
      case 2
  
       
    % case 3
        %  disp('C');
      %     fopen(s);
       % fwrite(s,'C');
       % fclose(s);  
      % case 4
         % disp('D');
        %   fopen(s);
       % fwrite(s,'D');
       % fclose(s);
      % case 5
      %    disp('E');
       %    fopen(s);
      %  fwrite(s,'E');
      %  fclose(s);
  end
  
  switch greencount
      
      case 1
        
           
    current_position = readPosition(servo_motor1);
     current_position1 = readPosition(servo_motor2);
     
    if current_position==0.5
writePosition(servo_motor1, 0);
pause(0.3)
writePosition(servo_motor2, 0);
pause(0.3)
writePosition(servo_motor3, 0.25);
pause(0.3)
 writePosition(servo_motor4, 0);

elseif current_position1==0
    writePosition(servo_motor2, 0.5);
   
end
   
  end
switch bluecount
    case 1
          current_position4 = readPosition(servo_motor4);
     
    if current_position4==0
writePosition(servo_motor4, 0);
    else
writePosition(servo_motor4, 0.2);
    end
end
    
    end
    
 % matmal('prasannaav0101@gmail.com', 'Attentance', 'command complete');
    hold off

% Both the loops end here.

% Stop the video aquisition.
%closepreview(vid);
stop(vid);
delete(vid)

% Flush all the image data stored in the memory buffer.
%release(vid);

% Clear all variables
% clear all
% stop(vid);