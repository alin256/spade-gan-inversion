import os
import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import norm
import torch
import sys
sys.path.append('../../NonstationaryGANs/')
from models import generators

# load model achitectures

os.environ["CUDA_DEVICE_ORDER"] = "PCI_BUS_ID" 
os.environ["CUDA_VISIBLE_DEVICES"] = "0"
device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")


netG = generators.Res_Generator(z_dim = 128, n_classes = 4,base_ch = 52
                                ,att = True,img_ch = 1,leak = 0
                                ,cond_method='conv1x1',SN=False).to(device)

# load checkpoint for artificial dataset (provided by TotalEnergies)

checkpoint = torch.load('../../NonstationaryGANs/trained_models/AR_model.pth',map_location=device)
_ = netG.load_state_dict(checkpoint['netG_state_dict'])
_ = netG.eval()

# load model parameters from an .npz file

ms = np.load('../HardData/posterior_state_estimate.npz', allow_pickle=True)['m']

# create GAN realizations from model parameters

realizations = []
for member in range(100):
    scale_m = [np.exp(norm.cdf(elem)*(np.log(0.5) - np.log(0.01)) + np.log(0.01)) for elem in ms[:,member]]
    M = torch.tensor(np.array(scale_m)).reshape((4,4)).unsqueeze(0).unsqueeze(0)
    np.random.seed(member)
    with torch.no_grad():
        img = netG(torch.tensor(np.random.randn(128),dtype=torch.float32).unsqueeze(0).to(device=device),M.to(device=device)).cpu()
    multnum = img.numpy() # -1 stands for background
    merged_channel_realization = np.zeros(multnum.shape)
    merged_channel_realization[np.where(multnum!=-1)] = 1
    realizations.append(merged_channel_realization)

# converting to cahnnel probabilities

realizations_np = np.array(realizations)
print('shape', realizations_np.shape)
channel_probability = np.mean(realizations_np, axis=(0,1,2))

print('shape', channel_probability.shape)

print(channel_probability)

# plotting the channel probabilities

plt.matshow(channel_probability, cmap='tab20b', vmin=0, vmax=1)
plt.colorbar()
plt.savefig('default.png', bbox_inches='tight', dpi=600)
