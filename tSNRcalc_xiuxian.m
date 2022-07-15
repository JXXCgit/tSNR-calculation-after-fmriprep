%%%% this script is finnally standardized and will be used in the future calculation for all subjects
clc; clear
addpath('E:/xiuxian/program/spm12');
folderpath = 'X:\xiuxian\fmriprep\fmriprep output\New folder\tSNR' 
subjlist = dir(fullfile(folderpath, 'sub*')) %list of the subjects in the main folder

for s = 1:length(subjlist)
    subjpath=[folderpath, filesep, subjlist(s).name] %directory of different subjects
    EPI = dir(fullfile(subjpath,'*preproc_bold.nii.gz*')); %directory of the original unzippied 4D files
    nVolRS = 1; % number of volume after which it starts averaging snr
    for ep = 1 : length(EPI)
        runfoldername = ['3D_',EPI(ep).name(27:31)] %create the run folder based on the position of the letter 
        mkdir (subjpath, runfoldername) %create the run folder based on the position of the letter 
        gunzip(fullfile(subjpath, EPI(ep).name))   %unzip 4D nfti to zipped 4D nfti file
        if exist(fullfile(subjpath, runfoldername)) 
           spm_file_split(fullfile(subjpath, EPI(ep).name(1:end-3)),fullfile(subjpath, runfoldername)); %loate the 4D zipped file and convert it to 3D and tranfer them into the corresponding run folder
        else
            disp( '4D already splitted');
        end

        EPI_files = dir(fullfile(subjpath, runfoldername)); %list of the 3D files after conversion in different run folders
        EPI_files = EPI_files(3:end); %position of the 3D files after conversion in different run folders
         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%the aboove steps are to convert the 4D nfiti file to 3D file
%the followed steps are to calculate the tSNR with .nii files 
        hdr = spm_vol(fullfile({EPI_files.folder}',...
            {EPI_files.name}'));
        allVols = NaN([hdr{1}.dim, numel(EPI_files)-(nVolRS-1)]);
        for currFile = nVolRS:numel(EPI_files)
            allVols(:,:,:,currFile) = spm_read_vols(hdr{currFile});
        end

        % compute tSNR
        tSNR_vol = nanmean(allVols,4)./nanstd(allVols,[], 4);

        % save tSNR to NIfTI file type
        Vo = hdr{1};
        Vo.fname = fullfile(subjpath, [runfoldername,'_tSNR.nii'] );
        Vo = rmfield(Vo, 'pinfo');
        spm_write_vol(Vo, tSNR_vol);
    end
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% remove unnecessary files after tSNR caclculation and move .tSNR.nii file to different run folder 
tSNRfile = dir(fullfile(subjpath,'*tSNR.nii*'));
for iSNR= 1:length(tSNRfile)
    movefile(fullfile(subjpath, tSNRfile(iSNR).name), fullfile(subjpath, runfoldername))
end
delete '*.nii.gz*' ;
delete '*desc-preproc_bold*';   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% extract tSNR values over the whole brain and ROI level
%%%%% to extract the tSNR values from the whole brain and ROI
%%%%% the whole brain is somehow ROI, so to extract the values from the whole brain, we match the mask after resliced with the whole brain file (*_desc-preproc_bold)
%% to reslice the mask for whole brain, select the template from the folder of DPABI, based on the voxel size of our data (1.5 * 1.5 * 1.5)
maskID='X:\xiuxian\fmriprep\fmriprep output\New folder\tSNR\Reslice_Templates\WhiteMask_09_91x109x91.img'; % equal the resolution of mask and image by resampling 
folderpath = 'X:\xiuxian\fmriprep\fmriprep output\New folder\tSNR' 
subjlist = dir(fullfile(folderpath, 'sub*')) %list of the subjects in the main folder
settings.OutputFolder='X:\xiuxian\fmriprep\fmriprep output\New folder\tSNR'
settings.diagnosticspath='X:\xiuxian\fmriprep\fmriprep output\New folder\tSNR'
maskname='Brain'
smoothlevel=[]
for i=1:length(subjlist)
    subjID = subjlist(i).name
    settings.EPIfolder=[subjpath];
    [ROI_data,mean_ROI_tSNR] = xiuxian_extract_ROI_tSNR(settings, maskID, subjID, maskname, smoothlevel)
    tsnr(i,:)=ROI_data;
end










