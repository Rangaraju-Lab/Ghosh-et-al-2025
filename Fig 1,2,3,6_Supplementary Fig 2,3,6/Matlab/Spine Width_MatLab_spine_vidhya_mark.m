function out = spine_mark(namepattern,pixelsize)
%function out = spine_mark(namepattern,pixelsize)
%mark spines to determine line profiles and spine size. 

%data are automatically saved to file
%input: namepattern: filenamepattern (wildcards allowed) of image files to
%       process
%output: filenames of new files with line profiles

files = filenamelist(namepattern);

nfiles = length(files);

for kf = 1:nfiles%for all files
    
    newname = extend_filename(files(kf).name,'_LP','ext','.mat');%for saving line profiles
    out{kf} = newname;
    
    for ki = 1:-1:1%read 10 frames (User-specific)
        data(:,:,ki) = imread(files(kf).name,ki);%use imread to be more universal
        
    end
    
    if nargin < 2 %pixel size not given by user
        
    try %try to get it from file, if it fails assume 1
        meta = imfinfo(files(kf).name);%just read 1st frame for resolution
        resolraw = meta(1).XResolution;
        resol = 1/ resolraw; %resolution is in pixels per cm, we want um
        unit = 'um';
    catch
        warning('Could not determine resolution and you did not set it. All distances will be in pixels')
        resol = 1;
        unit = 'pixel';%note for later that units are pixels and not um
    end
    else
        resol = pixelsize;%given by user
        unit = 'um';
    end
    meanimg = mean(data,3);
    meanimg = imfilter(meanimg,ones(3)/9);
    
    
    figure;imagesc(meanimg);
    axis equal
    colormap hot
    colorbar
      
    
    again = true; %initialize
    clear ha hb xc lc intens %delete values from old file, in case that we mark less spines here than in the previous file. Otherwise old values would remain but would not be correctly re-assigned
    loopcnt = 1;
    ks = loopcnt;
    while again && loopcnt <= 5000 %loop for multiple spines
        title(sprintf('%s, Spine %i',files(kf).name, ks),'interpreter','none')
        if loopcnt > 1;
            hold on
            plot(haraw{ks-1},hbraw{ks-1},'m','LineWidth',2)%plot previous marked spines
        end
        
        if kf > 1 %not the first file
            try
                oldpos = load(out{kf-1});%load data (expecially position) form previous file
                h = imline(gca,oldpos.p{loopcnt});%line but now wih inital values from previous file
                
            catch
                warning('could not load old line position. Draw a new line')
                h = imline(gca);
            end
        else
            h = imline(gca);
        end
        keyboard
        p{loopcnt} = h.getPosition;%position of line
        [haraw{ks},hbraw{ks},hc] = improfile(meanimg,p{loopcnt}(:,1),p{loopcnt}(:,2),'bilinear');%get line profile (Matlab fct)
        ha = haraw{ks} - haraw{ks}(1);%we will need the line without offset
        hb = hbraw{ks} - hbraw{ks}(1);
        xc{ks}= ha * resol;%scale with resolution
        yc{ks} = hb * resol;
        lc{ks} = sqrt(xc{ks}.^2 + yc{ks}.^2);%calculate lenght of (oblique) line Attention, this calculation fails for lines with first element not 0.
        lc{ks} = lc{ks} - min(lc{ks});%subtract min to start at 0
        intens{ks} = hc;
        
        again = input('Add another spine? 1 for yes, 0 for no, 9 to discard this ROI: ');
        if length(again) > 1
            warning('Not more than one character is allowed as answer. Please try again.')
            again = input('Add another spine? 1 for yes, 0 for no, 9 to discard this ROI: ');
            
        end
        if isempty(again)
            warning('For some reason I did not get your answer. Please try again.')
            again = input('Add another spine? 1 for yes, 0 for no, 9 to discard this ROI: ');

        end
        
        if again ~= 9 %user does not want to discard this roi
            %do nothing
            
        else %user wants to discart this roi, decrement loop counter
            disp('Discarding last ROI. Select a new one.')
            loopcnt = loopcnt -1;
            h.delete %delete old line to avoid any confusion
        end
        
        len=length(intens{ks});
        
        
        
        save(newname,'xc','yc','lc','intens','files','unit','p')%save relevant data (will be re-done in next loop, but in case of a crash we have already something)
        
        
        if loopcnt == 5000
            warning('stopping here, not more than 5000 ROIs allowed')
        end
        
        
        
        loopcnt = loopcnt + 1;
        ks = loopcnt;
        
    end        
        %show also last roi:
        if loopcnt > 1;
            hold on
           plot(haraw{ks-1},hbraw{ks-1},'m','LineWidth',2)
        end

        
    
end
