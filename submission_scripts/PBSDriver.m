
%% matlab -nodisplay -nosplash -r "PBSDriver"
Rows = 1:301;

useGPU = false;
NumProcessors = 2;
WallTimeHrs = 1;

load('VideosToDownsample', 'VideosToDownsample');

for i=Rows
VideoPaths = VideosToDownsample.VideoPaths(i,:);
    TrainingSetName = '';
    CreateMasterPBSFile({VideoPaths}, TrainingSetName, NumProcessors, WallTimeHrs, useGPU)
    [~, videoName,~] = fileparts(VideoPaths);
    SubmitScript(videoName)
    disp([i size(VideosToDownsample,1)])
end
%%
function SubmitScript(videoName)

[~,name,~] = fileparts(videoName);

submitScript = sprintf(['mksub ' name '.pbs']);
[status,~] = system(submitScript);
end
