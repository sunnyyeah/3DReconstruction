% 双目+激光，随意扫描实现三维重建
%% 说明
% 为了得到相机坐标系下的x，y，z。需要求解出左右相机对齐后的坐标值。因此，
%     对左右两幅图进行消畸变，并假装它俩对其（其实偏差不是特别大。）

%%
close all;
clear all;
clc;


% 加载cameraParams_left对象。
load('cameraParamsL_3th.mat');
load('cameraParamsR_3th.mat');
load('stereoParams3th.mat');

T_ = stereoParams_3th.TranslationOfCamera2(1,1);
fl = stereoParams_3th.CameraParameters1.FocalLength(1,1);

uvL = zeros(4,2,8);          % 每幅图像未矫正的四个角点的坐标
uvR = zeros(4,2,8);
% 4：四个点；   2：u，v    8：八张图
xyz = zeros(4,3,8);
RT = zeros(3,4,7);   % 3行4列，7个RT。不记得就看ipad

uvv = zeros(96,3,8);   % 中心线像素坐标。8幅图，每幅图最多110个点，每个点的坐标为x,y,z

% 获取32个点的坐标信息【共八张图，每张图4个点】
for i = 1:8
    % 左图的u
    uvL(1,1,i) = floor(cameraParams_L3th.ReprojectedPoints(1,2,i));
    uvL(2,1,i) = floor(cameraParams_L3th.ReprojectedPoints(9,2,i));
    uvL(3,1,i) = floor(cameraParams_L3th.ReprojectedPoints(19,2,i));
    uvL(4,1,i) = floor(cameraParams_L3th.ReprojectedPoints(27,2,i));
    
    % 左图的v
    uvL(1,2,i) = floor(cameraParams_L3th.ReprojectedPoints(1,1,i));
    uvL(2,2,i) = floor(cameraParams_L3th.ReprojectedPoints(9,1,i));
    uvL(3,2,i) = floor(cameraParams_L3th.ReprojectedPoints(19,1,i));
    uvL(4,2,i) = floor(cameraParams_L3th.ReprojectedPoints(27,1,i));
    
    % 右图的u = 左图的u
    uvR(1,1,i) = floor(cameraParams_L3th.ReprojectedPoints(1,2,i));
    uvR(2,1,i) = floor(cameraParams_L3th.ReprojectedPoints(9,2,i));
    uvR(3,1,i) = floor(cameraParams_L3th.ReprojectedPoints(19,2,i));
    uvR(4,1,i) = floor(cameraParams_L3th.ReprojectedPoints(27,2,i));
    
    % 右图的v
    uvR(1,2,i) = floor(cameraParams_R3th.ReprojectedPoints(1,2,i));
    uvR(2,2,i) = floor(cameraParams_R3th.ReprojectedPoints(9,2,i));
    uvR(3,2,i) = floor(cameraParams_R3th.ReprojectedPoints(23,2,i));
    uvR(4,2,i) = floor(cameraParams_R3th.ReprojectedPoints(31,2,i));
end

%% 求解每幅图像在各自的相机坐标下的x,y,z
for i = 1:8
    for j = 1:4
        d = uvL(j,2,i)-uvR(j,2,i);
        Z = (fl*T_)/d;
        X = uvL(j,2,i)*Z/(Z-fl);
        Y = uvL(j,1,i)*Z/(Z-fl);
        xyz(j,1,i) = X;
        xyz(j,2,i) = Y;
        xyz(j,3,i) = Z;
    end
end

%% 求解每幅图像
CameraBase_xyz = xyz(:,:,1);      % 所有图像以第一幅图为基准，Camera1_xyz:3*4
for i = 2:8         % 遍历2~8幅图，将这些图上的点转到第一幅图的坐标系下
    Camera_xyz = [xyz(:,:,i),ones(4,1)];            % 4*4
    % RT = CameraBase_xyz\Camera_xyz;  RT*Camera_xyz=CameraBase_xyz
    RT(:,:,i-1) = (Camera_xyz\CameraBase_xyz)';
end

%% 求解每幅图上的光线坐标
for i =1:2:15
    path1_l = ['qinshih111_left/' num2str(i) '.png'];           % 含激光左图
    path1_r = ['qinshih111_right/' num2str(i) '.png'];          % 含激光右图
    path2_l = ['qinshih111_left/' num2str(i+1) '.png'];         % 不含激光左图
    path2_r = ['qinshih111_right/' num2str(i+1) '.png'];        % 不含激光右图
    
    I1_l = imread(path1_l);%读取左右图片
    I2_l = imread(path2_l);
    
    I1_r = imread(path1_r);%读取左右图片
    I2_r = imread(path2_r);
    
    % 矫正左右两幅图
    [J1_l, J1_r] = rectifyStereoImages(I1_l, I1_r, stereoParams_3th);
    [J2_l, J2_r] = rectifyStereoImages(I2_l, I2_r, stereoParams_3th);
    
    %% 提取左图感兴趣区域
    [rows cols] = size(rgb2gray(J1_l));
    
    if i == 1           % 图片1单独设置，因为它傲娇
        for n = 1:rows      % 行
            for m = 1:cols  % 列
                if n < 190 || n > 300 || m < 470 || m > 520
                    J1_l(n, m, :) = 0;                                       
                    J2_l(n, m, :) = 0;                  
                end
            end
        end
        
        %         figure,imshow(J1_l);
        % 右图提取区域
        for n = 1:rows      % 行
            for m = 1:cols  % 列
                if n < 180 || n > 290 || m < 190 || m > 260
                    J1_r(n, m, :) = 0;
                    J2_r(n, m, :) = 0;
                end
            end
        end
    end
    
    if i ~= 1
        for n = 1:rows      % 行
            for m = 1:cols  % 列
                if n < 280 || n > 360 || m < 442 || m > 521
                    J1_l(n, m, :) = 0;
                    J2_l(n, m, :) = 0;
                end
            end
        end
        
        %         figure,imshow(J1_l);
        % 右图提取区域
        for n = 1:rows      % 行
            for m = 1:cols  % 列
                if n < 280 || n > 380 || m < 210 || m > 288
                    J1_r(n, m, :) = 0;
                    J2_r(n, m, :) = 0;
                end
            end
        end
        %         figure,imshow(J1_r);
    end
    %% 背景差分获取激光线
    Line_l = J1_l - J2_l;
    Line_r = J1_r - J2_r;
    
    %     figure,
    %     subplot(121),imshow(Line_l);
    %     subplot(122),imshow(Line_r);
    % 细化
    [yy_l,blur_l] = Gray_centroidFunction(Line_l(:,:,1))    % yy表示中心线的列的信息
    [yy_r,blur_r] = Gray_centroidFunction(Line_r(:,:,1))    % yy表示中心线的列的信息
    
    % 在切割图想显示离散点信息
%     figure
%     imshow(J1_l);
%     hold on
%     for n=1:rows                     %把所求的灰度质心代入blur，并只显示所符合的坐标的灰度
%         for m=1:cols                  %
%             if m==yy_l(1,n)          %m==fliplr(yy(1,n))
%                 plot(m,n,'b.');
%             end
%         end
%     end
%     hold off
%     
%     figure
%     imshow(J1_r);
%     hold on
%     for n=1:rows                     %把所求的灰度质心代入blur，并只显示所符合的坐标的灰度
%         for m=1:cols                  %
%             if m==yy_r(1,n)          %m==fliplr(yy(1,n))
%                 plot(m,n,'b.');
%             end
%         end
%     end
%     hold off
    
       %% 寻找对应点——按行扫描两幅图像中的点。
    count = 1;
    for u = 1:rows                   % 行
        if (isempty(find(isnan(yy_l(1,u)))) && isempty(find(isnan(yy_r(1,u)))))
            uvv(count,1,(i+1)/2) = u;
            uvv(count,2,(i+1)/2) = yy_l(1,u);;
            uvv(count,3,(i+1)/2) = yy_r(1,u);
            count = count +1;     
        end
    end
end

%% 重建

% 求解每幅图像的xyz
XYZ=zeros(96,3,8);

for i = 1:8
    for j = 1:96
    d = uvv(j,2,i)-uvv(j,3,i);
    Z = (fl*T_)/d;
    X = uvv(j,2,i)*Z/(Z-fl);
    Y = uvv(j,1,i)*Z/(Z-fl);
    XYZ(j,1,i) = X;
    XYZ(j,2,i) = Y;
    XYZ(j,3,i) = Z;
    end
end

XYZ_Total = zeros(544,3);           % 存储所有图像上的XYZ（注：所有XYZ都是在第一幅图中的坐标系下表示的）
% 将2~8图像中的所有XYZ转换到第一幅图的坐标系中
    % [X_base;Y_base;Z_base]=[R T][X;Y;Z;1]
temp = 1;
for i = 2:8
   PicNum = max(find(XYZ(:,1,1)));
   XYZ_Total(temp:(temp+PicNum-1),:) = (RT(:,:,i-1)*[XYZ(1:PicNum,:,i)';ones(1,PicNum)])';
   temp = temp+PicNum;
end


plot3(XYZ_Total(:,1),XYZ_Total(:,2),XYZ_Total(:,3),'r.');
