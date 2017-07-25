% plot group-level all data
figure(110); clf; hold on
subplot(2,3,1); hold on

% figure colors
cols(:,:,1) = [ 0 210 255; 255 210 0; 0 0 0; 210 0 255]/256;
cols(:,:,2) = [ 0 155 255; 255 100 0; 0 0 0; 155 0 255]/256;
cols(:,:,3) = [0 100 255; 255 0 0; 0 0 0; 100 0 255]/256;

for c=1:3
    for i=1:24   
        data(i,c).exclude = isempty(data(i,c).RT);
    end
end

for c=1:3
    for p=1:3
    subplot(2,3,c); hold on
    allsw1 = [data(:,c).sliding_window];
    alld{c}(:,:) = reshape(allsw1(p,:),1200,size(allsw1,2)/1200)';
    %plot(alld(:,:,c)','color',.5*[1 1 1])
    plot(nanmean(alld{c}(:,:)),'color',cols(p,:,c),'linewidth',3)
    end
end

