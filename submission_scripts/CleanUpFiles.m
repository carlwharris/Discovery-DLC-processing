
function CleanUpFiles(videoName)
[~,name,~] = fileparts(videoName);

delete(videoName);
delete([name, '.pbs']);
end
