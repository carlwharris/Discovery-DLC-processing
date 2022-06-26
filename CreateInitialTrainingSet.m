
%% GET VIDEO PATHS FROM 'APPS' FOLDER

videoFolder = '/Users/carlharris/Dropbox (Dartmouth College)/Apps/VideoStorage/iSpyData/video';
CSVFile = 'Video_Set_Oct26.xlsx';

videoFolders = dir(videoFolder);
videoFolders = struct2table(videoFolders);
videoFolders = videoFolders(4:end,:);

nFolders = size(videoFolders,1);

Files = struct;

for i = 1:nFolders
tankName = videoFolders.name{i};

currentFolder = fullfile(videoFolder, tankName);

    try
        T = GetVideoFiles(currentFolder);
        Files.(tankName) = T;
    end
end

cd('/Users/carlharris/Dropbox (Dartmouth College)/iSpy Analysis')

inTable = readtable(CSVFile);

folders = inTable{:,1};
startDateFile = inTable{:,2};
startDateFile = datetime(startDateFile,'InputFormat','dd-MMM-yyyy');

endDate = inTable{:,3};
endDateFile = datetime(endDate,'InputFormat','d-MMM-yyyy');

FileData = cell(size(folders,1),1);
for folderNo = 1:size(folders,1)
    currFolder = folders{folderNo};
    selFiles = Files.(currFolder);
    startDate = startDateFile(folderNo);
    endDate = endDateFile(folderNo);
    SelectedFiles = GetFilesInRange(selFiles, startDate, endDate);
    FileData{folderNo} = SelectedFiles;
end

%%
dropboxAccessToken = '';

cd('/Users/carlharris/Desktop');
initialTraininSetFolder = 'Initial Training Set Oct 26';
mkdir(initialTraininSetFolder);

nVideos =  250;
nFramesPerVid = 3;

for folderNo = 1:size(FileData,1)

    currFolder = FileData{folderNo};
    
    randInts = randperm(size(currFolder,1));
    
    if length(randInts) > nVideos
        randInts = randInts(1:nVideos);
    end
    
    for j = 1:length(randInts)
    
        try
            videoNo = randInts(j);

            currVideo = FileData{folderNo}{videoNo,2}{1};
            folderPaths = regexp(currVideo,'/','split');
            currParentFolder = folderPaths{end-1};
            currVideoName = folderPaths{end};

            currFileFullPath = {fullfile('iSpyData/video', currParentFolder, currVideoName)};
            downloadFromDropbox(dropboxAccessToken,currFileFullPath)

            vidReader = VideoReader(currFileFullPath{1});
            nFrames = vidReader.NumFrames;

            extractedImgFolder = fullfile(initialTraininSetFolder, currParentFolder, currVideoName(1:end-4));
            mkdir(extractedImgFolder)
            for k = 1:nFramesPerVid
                randFrame = randi(nFrames);
                outFrame = read(vidReader, randFrame);
                outFrameName = fullfile(extractedImgFolder, [num2str(k), '.png']);
                imwrite(outFrame, outFrameName);
            end
            
            delete(currFileFullPath{1})
            disp(['COPIED: ' num2str(folderNo) ' - ' num2str(j)])
        catch
            disp(['----- FAILED: -----   ' num2str(folderNo) ' - ' num2str(j)])
        end
    end
end

%%
initialSetFrames = initialTraininSetFolder;

extractedFrameFolders = dir(initialSetFrames);
extractedFrameFolders = struct2table(extractedFrameFolders);
extractedFrameFolders = extractedFrameFolders(3:end,:);

nTotEntries = size(extractedFrameFolders,1) * nVideos;
Folders = {};
NumAnimals = {};

cnt = 1;
figure('Position', [0 800 1800 400])

for folderNo = 1:size(extractedFrameFolders,1)
    parentFolder = extractedFrameFolders.folder{folderNo};
    currFolder = extractedFrameFolders.name{folderNo};
    
    extractedFrameSubFolders = dir(fullfile(parentFolder, currFolder));
    extractedFrameSubFolders = struct2table(extractedFrameSubFolders);
    extractedFrameSubFolders = extractedFrameSubFolders(3:end,:);
    
    for i = 1:size(extractedFrameSubFolders,1)
        
        currExtractedFrameFolder = extractedFrameSubFolders.name{i};
        
        imageFiles = dir(fullfile(extractedFrameSubFolders.folder{i}, currExtractedFrameFolder, '*.png'));
        imageFiles = struct2table(imageFiles);
        
        
        for j = 1:size(imageFiles,1)
            subplot(1,3,j)
            currImage = fullfile(imageFiles.folder{j}, imageFiles.name{j});
            imshow(currImage);
        end
        
        
        prompt = [num2str(cnt) ' - Total # animals in folder ', currExtractedFrameFolder, ': '];
        disp(prompt);
        k = waitforbuttonpress;
        button = double(get(gcf,'CurrentCharacter'));
        
        if button == 49
            currNumAnimals = 1;
        else
            currNumAnimals = 0;
        end
        
        Folders{cnt} = fullfile(currFolder, currExtractedFrameFolder);
        NumAnimals{cnt} = currNumAnimals;
        cnt = cnt + 1;
    end

end

%%
tempFolders = {};
tempNumAnimals = [];

for i = 1:length(Folders)
    currFolder = Folders{i};
    currNumAnimals = NumAnimals{i};
    
    if currNumAnimals == 1
        tempFolders = [tempFolders; currFolder];
        tempNumAnimals = [tempNumAnimals; currNumAnimals];
    end
end

%%
NumAnimals = tempNumAnimals;
Folders  = tempFolders;

AnimalsByFolder = table(Folders, NumAnimals);

save(fullfile(pwd, 'AnimalsByFolder'), 'AnimalsByFolder');

%%
zeroAnimalTot = sum(AnimalsByFolder.NumAnimals == 0);
oneAnimalTot = sum(AnimalsByFolder.NumAnimals == 1);
twoAnimalTot = sum(AnimalsByFolder.NumAnimals == 2);

toExtract = AnimalsByFolder.NumAnimals > 0;
extractNames = AnimalsByFolder.Folders(toExtract);

for i = 1:length(extractNames)
    currName = extractNames{i};
    extractNames{i} = [currName, '.mp4'];
end

currFileFullPath = fullfile('iSpyData/video', extractNames);

downloadFromDropbox(dropboxAccessToken,currFileFullPath(1:end))

%%
function T = GetVideoFiles(currentFolder)
videoFiles = dir(fullfile(currentFolder, '*.mp4'));
videoFiles = struct2table(videoFiles);

if ~isempty(videoFiles)
    names = videoFiles.name;
    repeat = contains(names, '(1)');

    videoFiles = videoFiles(~repeat, :);

    nFiles = length(videoFiles.name);

    FilePath = cell(nFiles, 1);
    DateNumber = cell(nFiles, 1);
    DateString = cell(nFiles, 1);

    for i = 1:nFiles
        currName = videoFiles.name{i};
        [~, currName, ~] = fileparts(currName);

        sep = strsplit(currName, '_');

        cat = [sep{2} '_' sep{3}];

        formatIn = 'yyyy-mm-dd_HH-MM-SS';
        dateNum = datenum(cat, formatIn);

        FilePath{i} = fullfile(videoFiles.folder{i}, videoFiles.name{i});
        DateNumber{i} = dateNum;
        DateString{i} = datestr(dateNum);
    end

    T = table(DateString, FilePath, DateNumber);
    T = sortrows(T, 'DateNumber');
else
    T = table();
end
end

function SelectedFiles = GetFilesInRange(fileList, startDate, endDate)

flooredDateNum = vertcat(fileList.DateNumber{:});

startDateNum = datenum(startDate);
toKeepLower = double(startDateNum < flooredDateNum);
[firstVidIdx, ~] = find(toKeepLower == 1);
if firstVidIdx > 1
    toKeepLower(firstVidIdx) = 1;
end

endDate = addtodate(datenum(endDate), 1, 'day');
endDate = datestr(endDate);

endDateNum = datenum(endDate);
toKeepUpper = double(flooredDateNum < endDateNum);
[lastVidIdx, ~] = find(toKeepUpper == 1);
if lastVidIdx < length(toKeepUpper)
    toKeepUpper(lastVidIdx) = 1;
end

toKeep = logical(toKeepLower .* toKeepUpper);
SelectedFiles = fileList(toKeep,:);
end

