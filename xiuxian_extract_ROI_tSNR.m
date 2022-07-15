%%%% this script is finnally standardized and will be used in the future calculation for all subjects
function [ROI_data,mean_ROI_tSNR] = xiuxian_extract_ROI_tSNR(settings, maskID, subjID, maskname, smoothlevel)

    nbruns = dir(fullfile(settings.EPIfolder,'3D_run*')); % just an indirect way to get how many run there are

%% gets mask index
Y = spm_read_vols(spm_vol(maskID),1);
indx = find(Y>0);
[x,y,z] = ind2sub(size(Y),indx);
XYZ = [x y z]';
ROI_data = [];

%% Extract tSNR maps for each run
%tSNR_runs_cntnr = cell(1, length(nbruns));
for cRun = 1:length(nbruns)
     output_pth = fullfile(settings.OutputFolder,[subjID], nbruns(cRun).name);
        tSNR_vol = dir(fullfile(output_pth,...
            sprintf('3D_run_%d_tSNR.nii',...
            cRun)))
        ROI_data(cRun) = nanmean(spm_get_data(fullfile(tSNR_vol.folder,tSNR_vol.name), XYZ),2);  %locate the tSNR 
  
%% warning if the mask and the map do not have the same dimension
maskinfo = niftiinfo(maskID);
mapinfo = niftiinfo(fullfile(tSNR_vol.folder,tSNR_vol.name));

if sum(maskinfo.ImageSize==mapinfo.ImageSize)~=3 || sum(maskinfo.PixelDimensions==mapinfo.PixelDimensions)~=3
    disp('WARNING!!! tSNR: maps and masks do not have the same dimensions, tSNR is wrong')
end
%%     % Average all runs' tSNR volumes
%     if length(nbruns) == 3
%         runAvg = nanmean(cat(4, tSNR_runs_cntnr{1},...
%                                 tSNR_runs_cntnr{2},...
%                                 tSNR_runs_cntnr{3}), 4);
%     else
%         runAvg = nanmean(cat(4, tSNR_runs_cntnr{1},...
%                                 tSNR_runs_cntnr{2},...
%                                 tSNR_runs_cntnr{3},...
%                                 tSNR_runs_cntnr{4}), 4);
%     end



% Extract voxels included in the ROI
% tSNR_roi_vxls = runAvg(mask_idx);

if isempty(smoothlevel)
    savingname ='tSNR';
else savingname =['tSNR',smoothlevel,'mm'];
end

% save tSNR value in diagnostics structure 
if exist(fullfile(settings.diagnosticspath,['QA_', subjID,'.mat']))==0
    dataQA.(savingname).(maskname) = ROI_data;
    save(fullfile(settings.diagnosticspath,['QA_', subjID,'.mat']), 'dataQA')
else
    load(fullfile(settings.diagnosticspath,['QA_', subjID,'.mat']));
    dataQA.(savingname).(maskname) = [];
    dataQA.(savingname).(maskname) = ROI_data;
    save(fullfile(settings.diagnosticspath,['QA_', subjID,'.mat']), 'dataQA')
end
% find ROI tSNR mean value
mean_ROI_tSNR = mean(ROI_data)
end