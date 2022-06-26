
%%
function UploadPickleFiles(videoName)
dropboxAccessToken = 'YOURTOKENHERE';

videoName = ['Trim_', videoName];
uploadToDropbox(dropboxAccessToken,videoName)
delete(videoName)
end
