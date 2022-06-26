
function CreateVideoPythonScript(videoFolder, videoName, trainingSetName)
[~,name,~] = fileparts(videoName);

tempID = fopen([name, '.py'],'w');

outline = sprintf('import os\n');
fwrite(tempID,outline);

outline = sprintf('os.environ["DLClight"] = "True"\n');
fwrite(tempID,outline);

outline = sprintf('import deeplabcut\n');
fwrite(tempID,outline);

outline = sprintf('from deeplabcut.utils import auxfun_multianimal, auxiliaryfunctions\n');
fwrite(tempID,outline);

outline = sprintf(['path_config_file = ''/dartfs-hpc/rc/home/0/f0036y0/' trainingSetName '/config.yaml''\n']);
fwrite(tempID,outline);

outline = sprintf('os.system(''echo config_pathd'')\n');
fwrite(tempID,outline);

outline = sprintf(['videofile_path = os.path.join(os.getcwd(), ''' videoName ''')\n']);

fwrite(tempID,outline);

outline = sprintf('deeplabcut.analyze_videos(path_config_file,[videofile_path], save_as_csv=True)\n');
fwrite(tempID,outline);
end

