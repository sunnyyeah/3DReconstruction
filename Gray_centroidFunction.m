function [yy,blur]=Gray_centroidFunction(img)
%%��������ϸ��֮�Ҷ����ĺ���
%���룺
%img   �����ͼƬ
%�����
%yy  �Ҷ��������꣨����������ֵ��
%blur ϸ����ļ�������

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
% blur=imfilter(I,gussFilter,'replicate');  %��˹�˲�
% figure;imshow(blur);

for i=1:1:rows                            %ȡ��ֵ
    for j=1:1:cols
        if blur(i,j)<22
            blur(i,j)=0;
        end
    end
end
[M,N]=max(blur,[],2);%�����ֵ
hold on;
% b=1:rows;
% figure;plot(N,b);title('����ֵ');
% axis([1 rows 1 1000]);
% set(gca,'xtick',[1:100:rows]);
% set(gca,'ytick',[1:100:1000]);
yy=zeros(1,rows);
for ii=1:rows            %�Ҷ����ķ��汾1����ÿ�����ػҶ�ֵΪ��Ȩ��
    double x;double y;
    x=0.0;y=0.0;
    for jj=1:cols
        x=x+double(blur(ii,jj));
        y=y+double(blur(ii,jj))*double(jj);
    end
    yy(1,ii)=round(y/x);
%     yy(1,ii)=y/x;
    
end

% for ii=1:rows           %�Ҷ����ķ��汾2���ԻҶ�ֵƽ��Ϊ��Ȩ��
%     double x;double y;
%     x=0.0;y=0.0;
%     for jj=100:cols
%         x=x+double(blur(ii,jj)^2);
%         y=y+double(blur(ii,jj)^2)*double(jj);
%     end
%     yy(1,ii)=round(y/x);
% end

% iii=1:rows;                 %��������ĻҶ�����
% figure(2);imshow(blur);
% figure;plot(fliplr(yy),iii);title('�Ҷ�����');
% axis([1 rows 1 1000]);
% set(gca,'xtick',[1:100:rows]);
% set(gca,'ytick',[1:100:1000]);
% for iiii=1:rows            %������ĻҶ����Ĵ���blur����ֻ��ʾ�����ϵ�����ĻҶ�
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