

setNumbers = [1:3 5:58 60:64];

VideoPaths = [];
Set = [];

for i = 1:length(setNumbers)
    setNumber = setNumbers(i);

    matfilename = sprintf('Set_%0.0f Processed Data.mat', setNumber);
    load(matfilename, 'unprocessedData');

    folder = unprocessedData.Folder{1};
    videos = unique(unprocessedData.VideoSource);

    VideoPathsTemp = fullfile(folder, videos);
    VideoPaths = [VideoPaths; VideoPathsTemp];

    SetTemp = repmat(setNumber, size(VideoPathsTemp,1), 1);
    Set = [Set; SetTemp];
    
    disp([i setNumber length(setNumbers)]);
end

VideosToDownsample = table(Set, VideoPaths);

save('VideosToDownsample', 'VideosToDownsample');

%%
fileNames = [];
originalFiles = [];

for i = 1:size(VideosToDownsample,1)
    currFile = VideosToDownsample.VideoPaths{i};
    
    [~, name, ext] = fileparts(currFile);
    fileNames = [fileNames; [name ext]];
    originalFiles = [originalFiles; currFile];
end

filesInPWD = dir('*.mp4');
filesInPWD = struct2table(filesInPWD);

VideoPaths = [];

for i = 1:size(fileNames)
    inPWD = ismember(fileNames(i,:), filesInPWD.name);
    if ~inPWD
        VideoPaths = [VideoPaths; originalFiles(i,:)];
    end
end
Set = zeros(size(VideoPaths,1), 1);

VideosToDownsampleTemp = table(Set, VideoPaths);

disp(size(VideosToDownsampleTemp,1));

%%
VideosToDownsample = VideosToDownsampleTemp;
save('VideosToDownsample', 'VideosToDownsample');
