function  spine_vidhya_show(filename)
%function spine_vidhya_show(filename)
%  load an ..._LP.mat and show the spines marked.



vv = load(filename);
nfiles = length(vv.files);    
for kf = 1
    for ki = 10:-1:1%read 10 frames (Vidhya-specific)
        data(:,:,ki) = imread(vv.files(kf).name,ki);%use imread to be more universal
        
    end
    meanimg = mean(data,3);
    meanimg = imfilter(meanimg,ones(3)/9);%Vidhya uses normally in imagej a 3x3 mean filter for smoothing, wo we implement it also here.
    
    
    figure;imagesc(meanimg);
    axis equal
    colormap hot
    colorbar
% 
%     img = imread(vv.files(kf).name);%read according image file
%     figure;
%     imagesc(img)
%     colormap gray
%     axis equal
    hold on
    for kp = 1:length(vv.p) 
        plot(vv.p{kp}(:,1),vv.p{kp}(:,2),'m','linewidth',2)%plot lines for all spines.
        text(vv.p{kp}(1,1)-20,vv.p{kp}(1,2),num2str(kp),'Color','m','FontSize',14)%number spines
    end
    
    
    
end
