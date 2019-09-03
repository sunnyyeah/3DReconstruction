function [yy,blur]=Gray_centroidFunction(img)
%%激光线条细化之灰度重心函数
%输入：
%img   待求的图片
%输出：
%yy  灰度质心坐标（列坐标质心值）
%blur 细化后的激光线条

% I=rgb2gray(img); 
I = img;
% I=rgb2gray(imread(img));  
[rows,cols]=size(I);
for i = 1:rows
    for j = 1:cols
        if I(i,j,1) < 90
            I(i,j,1) = 0;
        end
    end
end
blur = I;
% gussFilter=fspecial('gaussian',3,1.5);
% blur=imfilter(I,gussFilter,'replicate');  %高斯滤波
% figure;imshow(blur);

for i=1:1:rows                            %取阈值
    for j=1:1:cols
        if blur(i,j)<22
            blur(i,j)=0;
        end
    end
end
[M,N]=max(blur,[],2);%求最大值
hold on;
% b=1:rows;
% figure;plot(N,b);title('极大值');
% axis([1 rows 1 1000]);
% set(gca,'xtick',[1:100:rows]);
% set(gca,'ytick',[1:100:1000]);
yy=zeros(1,rows);
for ii=1:rows            %灰度质心法版本1（以每个像素灰度值为加权）
    double x;double y;
    x=0.0;y=0.0;
    for jj=1:cols
        x=x+double(blur(ii,jj));
        y=y+double(blur(ii,jj))*double(jj);
    end
    yy(1,ii)=round(y/x);
%     yy(1,ii)=y/x;
    
end

% for ii=1:rows           %灰度质心法版本2（以灰度值平方为加权）
%     double x;double y;
%     x=0.0;y=0.0;
%     for jj=100:cols
%         x=x+double(blur(ii,jj)^2);
%         y=y+double(blur(ii,jj)^2)*double(jj);
%     end
%     yy(1,ii)=round(y/x);
% end

% iii=1:rows;                 %画出所求的灰度重心
% figure(2);imshow(blur);
% figure;plot(fliplr(yy),iii);title('灰度重心');
% axis([1 rows 1 1000]);
% set(gca,'xtick',[1:100:rows]);
% set(gca,'ytick',[1:100:1000]);
% for iiii=1:rows            %把所求的灰度质心代入blur，并只显示所符合的坐标的灰度
%     for jjj=1:cols
%         if jjj==fliplr(yy(1,iiii))
%             img(iiii,jjj,1)=0;
%             img(iiii,jjj,2) = 0;
%             img(iiii,jjj,3) = 0;
%         end
%     end
% end
% figure,imshow(img);
% figure(4);imshow(blur);
% imwrite(blur,'newblur.jpg');