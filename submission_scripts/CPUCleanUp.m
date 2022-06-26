
function CPUCleanUp(VideoPaths, TrainingSetName, NumProcessors, WallTimeHrs, useGPU)

[~, videoName,~] = fileparts(VideoPaths{1});

tempID = fopen([videoName, '.pbs'],'w');

outline = sprintf('#!/bin/bash -l\n');
fwrite(tempID,outline);

outline = sprintf('#PBS -N SOCIAL_BEHAVIOR\n');
fwrite(tempID,outline);

if useGPU
    outline = sprintf('#PBS -q gpuq\n');
    fwrite(tempID,outline);

    outline = sprintf(['#PBS -l nodes=1:ppn=' num2str(NumProcessors) '\n']);
    fwrite(tempID,outline);

    outline = sprintf('#PBS -l gpus=1\n');
    fwrite(tempID,outline);

    outline = sprintf('#PBS -l feature=gpu\n');
    fwrite(tempID,outline);
else
    outline = sprintf(['#PBS -l nodes=1:ppn=' num2str(NumProcessors) '\n']);
    fwrite(tempID,outline);
end

outline = sprintf('#PBS -A BrainSci\n');
fwrite(tempID,outline);

outline = sprintf(['#PBS -l walltime=' num2str(WallTimeHrs) ':00:00\n']);
fwrite(tempID,outline);
    
outline = sprintf('#PBS -j oe\n');
fwrite(tempID,outline);

outline = sprintf('cd $PBS_O_WORKDIR\n');
fwrite(tempID,outline);

if useGPU
    outline = sprintf('gpuNum=`cat $PBS_GPUFILE | sed -e ''s/.*-gpu//g''`\n');
    fwrite(tempID,outline);

    outline = sprintf('conda activate DLC-GPU\n');
    fwrite(tempID,outline);
else
    outline = sprintf('eval "$(conda shell.bash hook)"\n');
    fwrite(tempID,outline);
    
    outline = sprintf('conda activate DLC-CPU\n');
    fwrite(tempID,outline);
end

for i = 1:size(VideoPaths,1)
    [videoFolder, videoName, ext] = fileparts(VideoPaths{i});
    outline = ProcessVideoCommands(videoFolder, [videoName ext], TrainingSetName);
    fwrite(tempID,outline);
end

outline = sprintf('exit 0\n');
fwrite(tempID,outline);

end

function outline = ProcessVideoCommands(videoFolder, videoName, trainingSetName)
[~, name,~] = fileparts(videoName);
% outline = [];
% temp = sprintf(['matlab -nodisplay -nosplash -r "DownloadVideo(' '''' videoFolder '''' ',' '''' videoName '''' ')"\n']);
% outline = [outline temp];
% 
% temp = sprintf(['matlab -nodisplay -nosplash -r "CreateVideoPythonScript(' '''' videoFolder '''' ',' '''' videoName '''' ',' '''' trainingSetName '''' ')"\n']);
% outline = [outline temp];

% temp = sprintf(['python ' name '.py\n']);
% outline = [outline temp];

temp = sprintf(['matlab -nodisplay -nosplash -r "UploadPickleFiles(' '''' videoName '''' ')"\n']);
outline = [outline temp];

temp = sprintf(['matlab -nodisplay -nosplash -r "CleanUpFiles(' '''' videoName '''' ')"\n']);
outline = [outline temp];
end

