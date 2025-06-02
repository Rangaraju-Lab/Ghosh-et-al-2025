function newout = spine_vidhya_fit(namepattern)
%function out = spine_vidhya_fit(namepattern)
%assumes that spine-line-profiles have been generated with spine_vidhya_mark
%input: namepattern for ...LP.mat files from spine_vidhya_mark with line
%profiles of spines
%A gaussian + offset will be fittet. Figures of fits will be saved for each
%file and each spine
%a summary will be saved as FWHMoverTime.csv for each spine, but with data
%from all files

matfiles = filenamelist(namepattern);

nfiles = length(matfiles);
cnt = 0;

for kf = 1:nfiles
    load(matfiles(kf).name,'intens','lc','unit','xc','yc');

    nspines = length(intens);%intens is a cell array loaded from mat file, lenght of cell array gives number of spines
    
    for ks = 1:nspines 
        cnt = cnt + 1;%counter for output files
        newnameFit = extend_filename(matfiles(kf).name,sprintf('_spine%02i_fit',ks),'ext','.mat');%for saving fits
        newout{cnt} = newnameFit;

        appendix_img = sprintf('_spine%02i_plot',ks);%filename for plot
        newname_img = extend_filename(matfiles(kf).name,appendix_img,'ext','.png');
        
        figure;
        plot(lc{ks},intens{ks},'ob')%plot intens as fct of position
        title(sprintf('%s, Spine %02i',matfiles(kf).name, ks),'interpreter','none')
        xlabel(sprintf('Position [%s]',unit))
        ylabel('Intensity')
        [a0, indint] = max(intens{ks});%start value for fit: mean: assume that spine is centered on the line
        l0 = indint(1) * (lc{ks}(2) - lc{ks}(1));%index times difference of the first two line values for scaling.inint(1) to treat the case that we might have several equal  peakvalues
        s0 = (max(lc{ks}) - min(lc{ks}))/4;%width: assume about a fourth of the line length
        c0 = min(intens{ks});%offset
        
        beta0 = [a0,l0,s0,c0];%assemble start values
        [beta, R,J,CovB,MSE,ErrorModelInfo] = nlinfit(lc{ks}, intens{ks}, 'gauss_plus_c_for_fit', beta0);
        ci=nlparci(beta,R,J);%confidence interval for parameters
        beta(3) = abs(beta(3));%sigma can be negative from the fit routine, because only the square is in the function
        ci_sigma = ci(3,:) * sign(beta(3));%sigma can be negative from the fit routine, because only the square is in the function
        betafwhm = beta;
        
        hold on
        xfit{ks} = linspace(lc{ks}(1),lc{ks}(end),500);%for plotting the fit
        yfit{ks} = gauss_plus_c_for_fit(beta,xfit{ks});
        plot(xfit{ks},yfit{ks},'r-');
        betafwhm(3) = beta(3) * sqrt(8 * log(2));%convert sigma into fwhm
        ci_fwhm = ci_sigma * sqrt(8 * log(2));%convert sigma into fwhm
        ci_fwhm1(kf,ks) = ci_fwhm(1);%store confidence interval for all files, all spines
        ci_fwhm2(kf,ks) = ci_fwhm(2);
        fwhm(kf,ks) = betafwhm(3);%save for later
        msearray(kf,ks) = MSE;
        try
            time(kf) = vidhya_spine_get_time(matfiles(kf).name);
        catch
            time(kf) = 0;
            warning('Cannot read time from filename. Setting it to 0')
        end
        set(gcf,'Position',[   86         100        1063         420])
        legend('data',sprintf('Fit, FWHM %6.2f %s, CI %4.3f %4.3f',betafwhm(3),unit,ci_fwhm(1),ci_fwhm(2)))
        diss_set_figure_parameters01
        print_figure(newname_img,'fig',true,'dosave',true,'res',150);
        save(newnameFit,'beta','betafwhm','xfit','yfit','ci_fwhm','R','J','CovB','MSE','ErrorModelInfo','beta0','lc','intens','xc','yc','ci','ks')
    end
    
    
    
end

%% plot and saving for differnet time points (ie files)
aaa = 1;
for ks = 1:nspines %hopefully constant in all files
    
    clear spineevolution
    htmp = fwhm(:,ks);
    ci1tmp = ci_fwhm1(:,ks);
    ci2tmp = ci_fwhm2(:,ks);
    [sortedtime,tind] = sort(time);%sort time 
    sortedfwhm = htmp(tind);%use same sorting for fwhm and confidence intervals
    sortedci1 = ci1tmp(tind);
    sortedci2 = ci2tmp(tind);
    
    figure
    errorbar(sortedtime(:),sortedfwhm(:),abs(sortedfwhm(:)-sortedci1(:)),abs(sortedfwhm(:)-sortedci2(:)),'ob')%plot confidence interval as errorbars
    hold on
    plot(sortedtime,sortedfwhm,'-','LineWidth',2)
    xlabel('Time [min]')
    ylabel(sprintf('FWHM [%s]',unit))
    title(sprintf('Spine %i',ks))
    diss_set_figure_parameters01
    newname_fwhmimg = extend_filename(matfiles(1).name,sprintf('_spine%0i_fwhmplot',ks),'ext','.png')
    print_figure(newname_fwhmimg,'fig',true,'res',150,'dosave',true)
    
    spineevolution(1,:) = sortedtime; %assemble into array for saving as csv-file
    spineevolution(2,:) = sortedfwhm';
    spineevolution(3,:) = sortedci1;
    spineevolution(4,:) = sortedci2;
    
    newnamefwhmevolution = extend_filename(matfiles(1).name,sprintf('_spine%i_FWHMoverTime',ks),'ext','.csv');
    dlmwrite(newnamefwhmevolution,spineevolution);
    
end
