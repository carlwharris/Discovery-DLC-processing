
allMP4Files = dir('*.mp4');
allMP4Files = struct2table(allMP4Files);

for i = 1:size(allMP4Files,1)
    currFileName = allMP4Files.name{i};
    
    if contains(currFileName, 'Trim_')
        movefile(currFileName, currFileName(6:end));
    end
end