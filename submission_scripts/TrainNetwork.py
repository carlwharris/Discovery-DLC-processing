import os
os.environ["DLClight"] = "True"

import deeplabcut
#from deeplabcut.utils import auxfun_multianimal, auxiliaryfunctions
os.system('echo imported')

# Change this to match the path and filename of your account and project
#path_config_file = '/dartfs-hpc/rc/home/0/f0036y0/Training_Set_V2--2020-09-13/config.yaml'
path_config_file = '/dartfs-hpc/rc/home/0/f0036y0/Nov_1-Annaliese-2020-11-01/config.yaml'

os.system('echo config_pathd')

# TO TRAIN THE NETWORK, UNCOMMENT (remove the # at the beginning of the line) THE FOLLOWING TWO LINES AND ADJUST PARAMETERS
deeplabcut.train_network(path_config_file, shuffle=1, displayiters=25, saveiters = 5000, maxiters= 250000)

os.system('echo done')
