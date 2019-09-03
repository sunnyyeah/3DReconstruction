% ˫Ŀ+���⣬����ɨ��ʵ����ά�ؽ�
%% ˵��
% Ϊ�˵õ��������ϵ�µ�x��y��z����Ҫ���������������������ֵ����ˣ�
%     ����������ͼ���������䣬����װ�������䣨��ʵƫ����ر�󡣣�

%%
close all;
clear all;
clc;


% ����cameraParams_left����
load('cameraParamsL_3th.mat');
load('cameraParamsR_3th.mat');
load('stereoParams3th.mat');

T_ = stereoParams_3th.TranslationOfCamera2(1,1);
fl = stereoParams_3th.CameraParameters1.FocalLength(1,1);

uvL = zeros(4,2,8);          % ÿ��ͼ��δ�������ĸ��ǵ������
uvR = zeros(4,2,8);
% 4���ĸ��㣻   2��u��v    8������ͼ
xyz = zeros(4,3,8);
RT = zeros(3,4,7);   % 3��4�У�7��RT�����ǵþͿ�ipad

uvv = zeros(96,3,8);   % �������������ꡣ8��ͼ��ÿ��ͼ���110���㣬ÿ���������Ϊx,y,z

% ��ȡ32�����������Ϣ��������ͼ��ÿ��ͼ4���㡿
for i = 1:8
    % ��ͼ��u
    uvL(1,1,i) = floor(cameraParams_L3th.ReprojectedPoints(1,2,i));
    uvL(2,1,i) = floor(cameraParams_L3th.ReprojectedPoints(9,2,i));
    uvL(3,1,i) = floor(cameraParams_L3th.ReprojectedPoints(19,2,i));
    uvL(4,1,i) = floor(cameraParams_L3th.ReprojectedPoints(27,2,i));
    
    % ��ͼ��v
    uvL(1,2,i) = floor(cameraParams_L3th.ReprojectedPoints(1,1,i));
    uvL(2,2,i) = floor(cameraParams_L3th.ReprojectedPoints(9,1,i));
    uvL(3,2,i) = floor(cameraParams_L3th.ReprojectedPoints(19,1,i));
    uvL(4,2,i) = floor(cameraParams_L3th.ReprojectedPoints(27,1,i));
    
    % ��ͼ��u = ��ͼ��u
    uvR(1,1,i) = floor(cameraParams_L3th.ReprojectedPoints(1,2,i));
    uvR(2,1,i) = floor(cameraParams_L3th.ReprojectedPoints(9,2,i));
    uvR(3,1,i) = floor(cameraParams_L3th.ReprojectedPoints(19,2,i));
    uvR(4,1,i) = floor(cameraParams_L3th.ReprojectedPoints(27,2,i));
    
    % ��ͼ��v
    uvR(1,2,i) = floor(cameraParams_R3th.ReprojectedPoints(1,2,i));
    uvR(2,2,i) = floor(cameraParams_R3th.ReprojectedPoints(9,2,i));
    uvR(3,2,i) = floor(cameraParams_R3th.ReprojectedPoints(23,2,i));
    uvR(4,2,i) = floor(cameraParams_R3th.ReprojectedPoints(31,2,i));
end

%% ���ÿ��ͼ���ڸ��Ե���������µ�x,y,z
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

%% ���ÿ��ͼ��
CameraBase_xyz = xyz(:,:,1);      % ����ͼ���Ե�һ��ͼΪ��׼��Camera1_xyz:3*4
for i = 2:8         % ����2~8��ͼ������Щͼ�ϵĵ�ת����һ��ͼ������ϵ��
    Camera_xyz = [xyz(:,:,i),ones(4,1)];            % 4*4
    % RT = CameraBase_xyz\Camera_xyz;  RT*Camera_xyz=CameraBase_xyz
    RT(:,:,i-1) = (Camera_xyz\CameraBase_xyz)';
end

%% ���ÿ��ͼ�ϵĹ�������
for i =1:2:15
    path1_l = ['qinshih111_left/' num2str(i) '.png'];           % ��������ͼ
    path1_r = ['qinshih111_right/' num2str(i) '.png'];          % ��������ͼ
    path2_l = ['qinshih111_left/' num2str(i+1) '.png'];         % ����������ͼ
    path2_r = ['qinshih111_right/' num2str(i+1) '.png'];        % ����������ͼ
    
    I1_l = imread(path1_l);%��ȡ����ͼƬ
    I2_l = imread(path2_l);
    
    I1_r = imread(path1_r);%��ȡ����ͼƬ
    I2_r = imread(path2_r);
    
    % ������������ͼ
    [J1_l, J1_r] = rectifyStereoImages(I1_l, I1_r, stereoParams_3th);
    [J2_l, J2_r] = rectifyStereoImages(I2_l, I2_r, stereoParams_3th);
    
    %% ��ȡ��ͼ����Ȥ����
    [rows cols] = size(rgb2gray(J1_l));
    
    if i == 1           % ͼƬ1�������ã���Ϊ������
        for n = 1:rows      % ��
            for m = 1:cols  % ��
                if n < 190 || n > 300 || m < 470 || m > 520
                    J1_l(n, m, :) = 0;                                       
                    J2_l(n, m, :) = 0;                  
                end
            end
        end
        
        %         figure,imshow(J1_l);
        % ��ͼ��ȡ����
        for n = 1:rows      % ��
            for m = 1:cols  % ��
                if n < 180 || n > 290 || m < 190 || m > 260
                    J1_r(n, m, :) = 0;
                    J2_r(n, m, :) = 0;
                end
            end
        end
    end
    
    if i ~= 1
        for n = 1:rows      % ��
            for m = 1:cols  % ��
                if n < 280 || n > 360 || m < 442 || m > 521
                    J1_l(n, m, :) = 0;
                    J2_l(n, m, :) = 0;
                end
            end
        end
        
        %         figure,imshow(J1_l);
        % ��ͼ��ȡ����
        for n = 1:rows      % ��
            for m = 1:cols  % ��
                if n < 280 || n > 380 || m < 210 || m > 288
                    J1_r(n, m, :) = 0;
                    J2_r(n, m, :) = 0;
                end
            end
        end
        %         figure,imshow(J1_r);
    end
    %% ������ֻ�ȡ������
    Line_l = J1_l - J2_l;
    Line_r = J1_r - J2_r;
    
    %     figure,
    %     subplot(121),imshow(Line_l);
    %     subplot(122),imshow(Line_r);
    % ϸ��
    [yy_l,blur_l] = Gray_centroidFunction(Line_l(:,:,1))    % yy��ʾ�����ߵ��е���Ϣ
    [yy_r,blur_r] = Gray_centroidFunction(Line_r(:,:,1))    % yy��ʾ�����ߵ��е���Ϣ
    
    % ���и�ͼ����ʾ��ɢ����Ϣ
%     figure
%     imshow(J1_l);
%     hold on
%     for n=1:rows                     %������ĻҶ����Ĵ���blur����ֻ��ʾ�����ϵ�����ĻҶ�
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
%     for n=1:rows                     %������ĻҶ����Ĵ���blur����ֻ��ʾ�����ϵ�����ĻҶ�
%         for m=1:cols                  %
%             if m==yy_r(1,n)          %m==fliplr(yy(1,n))
%                 plot(m,n,'b.');
%             end
%         end
%     end
%     hold off
    
       %% Ѱ�Ҷ�Ӧ�㡪������ɨ������ͼ���еĵ㡣
    count = 1;
    for u = 1:rows                   % ��
        if (isempty(find(isnan(yy_l(1,u)))) && isempty(find(isnan(yy_r(1,u)))))
            uvv(count,1,(i+1)/2) = u;
            uvv(count,2,(i+1)/2) = yy_l(1,u);;
            uvv(count,3,(i+1)/2) = yy_r(1,u);
            count = count +1;     
        end
    end
end

%% �ؽ�

% ���ÿ��ͼ���xyz
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

XYZ_Total = zeros(544,3);           % �洢����ͼ���ϵ�XYZ��ע������XYZ�����ڵ�һ��ͼ�е�����ϵ�±�ʾ�ģ�
% ��2~8ͼ���е�����XYZת������һ��ͼ������ϵ��
    % [X_base;Y_base;Z_base]=[R T][X;Y;Z;1]
temp = 1;
for i = 2:8
   PicNum = max(find(XYZ(:,1,1)));
   XYZ_Total(temp:(temp+PicNum-1),:) = (RT(:,:,i-1)*[XYZ(1:PicNum,:,i)';ones(1,PicNum)])';
   temp = temp+PicNum;
end


plot3(XYZ_Total(:,1),XYZ_Total(:,2),XYZ_Total(:,3),'r.');
