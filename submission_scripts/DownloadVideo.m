
function DownloadVideo(videoFolder, videoName)
dropboxAccessToken = 'YOURTOKENHERE';

relativePath = fullfile('iSpyData/video', videoFolder, videoName);
currFileFullPath = {relativePath};
downloadFromDropbox(dropboxAccessToken,currFileFullPath)

%scratchDirectory = '/dartfs-hpc/scratch/f0036y0';
%mkdir(scratchDirectory)
movefile(relativePath, pwd);
end
