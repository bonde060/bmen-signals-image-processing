function feats = imaging(x)
%% Read Original Image

xi = imread(x);
xi = imresize(xi,[960 444]);
% figure;
% imshow(xi);
%% Tracing left
xl = xi(240:349,95:349,:);
I = im2bw(xl,0.1217);
BW = bwareaopen(I,50);
se = strel('rectangle',[7 7]);
BW= imclose(BW,se);
BW= imfill(BW,'holes');
rows=size(BW,1);
columns=size(BW,2);
New=zeros(rows,columns,3);
for j=1:columns
    for o=1:rows
        if BW(o,j) == 0
            xl(o,j,:) = 0;
        end
    end
end
% figure;
% imshow(xl);
%% Tracing right
xr = xi(610:719,95:349,:);
I = im2bw(xr,0.1217);
BW = bwareaopen(I,50);
se = strel('rectangle',[7 7]);
BW= imclose(BW,se);
BW= imfill(BW,'holes');
rows=size(BW,1);
columns=size(BW,2);
New=zeros(rows,columns,3);
for j=1:columns
    for o=1:rows
        if BW(o,j) == 0
            xr(o,j,:) = 0;
        end
    end
end
% figure;
% imshow(xr);
%% Extract Pixel Color Matrix for Right Foot 
gray_x = rgb2gray(xr);
green_x = xr(:,:,2);
gsub_x = imsubtract(green_x,gray_x);
gbin_x = im2bw(gsub_x,0.01);
xrg = xr;
xrg(:,:,1) = 0;
xrg(:,:,3) = 0;
rows=size(xr,1);
columns=size(xr,2);
greentray = zeros(rows*columns,1);
i = 0;
holdg = im2double(xr);
for j=1:columns
     i = i+1;
    for o=1:rows
        if gbin_x(o,j) == 0
            xrg(o,j,2) = 0;
            greentray(o+240*i,1) = holdg(o,j,2);
        end
    end
end
% figure;
% imshow(xrg);

gray_x = rgb2gray(xr);
red_x = xr(:,:,1);
rsub_x = imsubtract(red_x,gray_x);
rbin_x = im2bw(rsub_x,0.01);
xrr = xr;
xrr(:,:,2) = 0;
xrr(:,:,3) = 0;
rows=size(xr,1);
columns=size(xr,2);
greentray = zeros(rows*columns,1);
i = -1;
holdr = im2double(xr);
for j=1:columns
    i = i+1;
    for o=1:rows
        if rbin_x(o,j) == 0
            xrr(o,j,1) = 0;
            greentray((o+240*i)+(240*510),1) = holdr(o,j,1);
        end
    end
end
% figure;
% imshow(xrr);
%% Extract Pixel Color Matrix for Left Foot 
gray_x = rgb2gray(xl);
green_x = xl(:,:,2);
gsub_x = imsubtract(green_x,gray_x);
gbin_x = im2bw(gsub_x,0.01);
xlg = xl;
xlg(:,:,1) = 0;
xlg(:,:,3) = 0;
rows=size(xl,1);
columns=size(xl,2);
greentray = zeros(rows*columns,1);
i = 0;
holdg = im2double(xl);
for j=1:columns
     i = i+1;
    for o=1:rows
        if gbin_x(o,j) == 0
            xlg(o,j,2) = 0;
            greentray(o+240*i,1) = holdg(o,j,2);
        end
    end
end
% figure;
% imshow(xlg);

gray_x = rgb2gray(xl);
red_x = xl(:,:,1);
rsub_x = imsubtract(red_x,gray_x);
rbin_x = im2bw(rsub_x,0.01);
xlr = xl;
xlr(:,:,2) = 0;
xlr(:,:,3) = 0;
rows=size(xl,1);
columns=size(xl,2);
greentray = zeros(rows*columns,1);
i = -1;
holdr = im2double(xl);
for j=1:columns
    i = i+1;
    for o=1:rows
        if rbin_x(o,j) == 0
            xlr(o,j,1) = 0;
            greentray((o+240*i)+(240*510),1) = holdr(o,j,1);
        end
    end
end
% figure;
% imshow(xlr);
%% Lets make another matrix baby x2!!!
outputmatrix = zeros(110*255*4,1,"double");
h = 0;
for i = 1:110
    for e = 1:255
        outputmatrix(e+255*h,1) = im2double(xl(i,e,2));
        outputmatrix(110*255+(e+225*h),1) = im2double(xr(i,e,2));
        outputmatrix(2*110*255+(e+225*h),1) = im2double(xl(i,e,1));
        outputmatrix(3*110*255+(e+225*h),1) = im2double(xr(i,e,1));
    end
    h = h+1;
end
%% Time to make sense of this mess
for u = 1:4
    feats(1,1) = var(outputmatrix(500:2500));
    feats(1,2) = mean(outputmatrix(500:2500));
    feats(1,3) = median(outputmatrix(500:2500));
    feats(1,4) = var(outputmatrix(3300:5000));
    feats(1,5) = mean(outputmatrix(3300:5000));
    feats(1,6) = median(outputmatrix(3300:5000));
    feats(1,7) = var(outputmatrix(6100:7900));
    feats(1,8) = mean(outputmatrix(6100:7900));
    feats(1,9) = median(outputmatrix(6100:7900));
    feats(1,10) = var(outputmatrix(8800:10300));
    feats(1,11) = mean(outputmatrix(8800:10300));
    feats(1,12) = median(outputmatrix(8800:10300));
end

%% Left foot outside sensor
% imshow(xlr(80:130,325:375,:)); %sensor outside of the left foot

%% Rigth foot outside sensor
% imshow(xrr(130:180,325:375,:)); %sensor outside of the rigth foot

%% Left Foot back sensor
% imshow(xlr(100:150,70:120,:));

%% Rigth Foot back sensor
% imshow(xrr(100:150,75:125,:));

%% Left Foot middle sensor
% imshow(xlr(130:180,325:375,:));

%% Right Foot middle sensor
% imshow(xrr(65:115,325:375,:));

%% Lets make this matrix baby
% outputmatrix = zeros(30000,1,"double");
% h = 0;
% for i = 1:50
%     for e = 1:50
%         outputmatrix(e+50*h,1) = im2double(xl(75+e,325+i,2));
%         outputmatrix(2500+(e+50*h),1) = im2double(xr(130+e,325+i,2));
%         outputmatrix(5000+(e+50*h),1) = im2double(xl(100+e,70+i,2));
%         outputmatrix(7500+(e+50*h),1) = im2double(xr(100+e,75+i,2));
%         outputmatrix(10000+(e+50*h),1) = im2double(xl(130+e,325+i,2));
%         outputmatrix(12500+(e+50*h),1) = im2double(xr(65+e,325+i,2));
%         outputmatrix(15000+(e+50*h),1) = im2double(xl(75+e,325+i,1));
%         outputmatrix(17500+(e+50*h),1) = im2double(xr(130+e,325+i,1));
%         outputmatrix(20000+(e+50*h),1) = im2double(xl(100+e,70+i,1));
%         outputmatrix(22500+(e+50*h),1) = im2double(xr(100+e,75+i,1));
%         outputmatrix(25000+(e+50*h),1) = im2double(xl(130+e,325+i,1));
%         outputmatrix(27500+(e+50*h),1) = im2double(xr(65+e,325+i,1));
%     end
%     h = h+1;
% end
end

