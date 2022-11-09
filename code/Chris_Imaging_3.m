%% Video Frame Extraction

%takes string file name of video, gives row vector of features
function features = Chris_Imaging_3(file)

%go into file with videos
cd 'mp4videos\'
vidObj = VideoReader(file);
starttime = 1;
vid = read(vidObj);
frames = vidObj.NumFrames;
ST = '.jpg';
cd ..

%only change these lines to change the number of frames skipped
if(frames>=121)
    numskips=10;
else
    numskips = 6;
end

for x = starttime : numskips : frames
    Sx = num2str(x);
    Strc = strcat(Sx, ST);
    Vid = vid(:, :, :, x);
    cd 'trial'
  
    imwrite(Vid, Strc);
    cd ..  
end

%change this line to where you want the pictures
path = 'C:\Users\acbon\OneDrive\Documents\3411 Systems\project\trial\';

i=1;
imds1 = imageDatastore(strcat([path num2str(i) '.jpg']));
i = i + numskips;
imds2 = imageDatastore(strcat([path num2str(i) '.jpg']));
i =i + numskips;
imds3 = imageDatastore(strcat([path num2str(i) '.jpg']));
i =i+numskips;
imds4 = imageDatastore(strcat([path num2str(i) '.jpg']));
i =i+numskips;
imds5 = imageDatastore(strcat([path num2str(i) '.jpg']));
i =i+numskips;
imds6 = imageDatastore(strcat([path num2str(i) '.jpg']));
i =i+numskips;
imds7 = imageDatastore(strcat([path num2str(i) '.jpg']));
i =i+numskips;
imds8 = imageDatastore(strcat([path num2str(i) '.jpg']));
i =i+numskips;
imds9 = imageDatastore(strcat([path num2str(i) '.jpg']));
i =i+numskips;
imds10 = imageDatastore(strcat([path num2str(i) '.jpg']));
i =i+numskips;
imds11 = imageDatastore(strcat([path num2str(i) '.jpg']));
i =i+numskips;
imds12 = imageDatastore(strcat([path num2str(i) '.jpg']));
% i =i+numskips;
% imds13 = imageDatastore(strcat([path num2str(i) '.jpg']));
% i =i+numskips;
% imds14 = imageDatastore(strcat([path num2str(i) '.jpg']));
% i =i+numskips;
% imds15 = imageDatastore(strcat([path num2str(i) '.jpg']));
imgs(1,1) = readall(imds1);
imgs(2,1) = readall(imds2);
imgs(3,1) = readall(imds3);
imgs(4,1) = readall(imds4);
imgs(5,1) = readall(imds5);
imgs(6,1) = readall(imds6);
imgs(7,1) = readall(imds7);
imgs(8,1) = readall(imds8);
imgs(9,1) = readall(imds9);
imgs(10,1) = readall(imds10);
imgs(11,1) = readall(imds11);
imgs(12,1) = readall(imds12);
% imgs(13,1) = readall(imds13);
% imgs(14,1) = readall(imds14);
% imgs(15,1) = readall(imds15);
clear imds1
clear imds2
clear imds3
clear imds4
clear imds5
clear imds6
clear imds7
clear imds8
clear imds9
clear imds10
clear imds11
clear imds12
clear imds13
clear imds14
clear imds15

features = zeros();
n  = 0;

%make features using each frame
for o = 1:numskips:12*numskips+1
features(12*n+1:12+12*n,1) = imaging(strcat(['trial\' num2str(o) '.jpg']));
n = n+1;
end

%format so it it 1xn row vector
features = transpose(features);

%delete picture frames (save my computer from exploding)
theFiles = dir('trial');
for k = 1 : length(theFiles)
  baseFileName = theFiles(k).name;
  fullFileName = fullfile('trial\', baseFileName);
  fprintf(1, 'Now deleting %s\n', fullFileName);
  delete(fullFileName);
end

