import os
import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import norm
import torch
import sys
sys.path.append('../../NonstationaryGANs/')
from models import generators

# load model achitectures

print('[1/5] Loading the GAN...')

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




def get_channel_probability_from_coarse_inputs(ms):
    # create GAN realizations from model parameters
    num_realizations = ms.shape[1]
    realizations = []
    for member in range(num_realizations):
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
    # print('shape', realizations_np.shape)
    channel_probability = np.mean(realizations_np, axis=(0,1,2))

    # print('shape', channel_probability.shape)
    # print(channel_probability)
    return channel_probability

# load model parameters from an .npz files

arguments = sys.argv
folder = '../HardData'
if len(arguments) > 1:
    folder = arguments[1]
    print('Plotting results from folder \"{}\"'.format(folder))
else:
    print('No arguments provided, falling back to plotting from folder \"{}\"'.format(folder))

# prior
print('[2/5] Preparing the prior...')
ms_prior = np.load('../HardData/prior.npz', allow_pickle=True)['m']
channel_prob_prior = get_channel_probability_from_coarse_inputs(ms_prior)

# synthetic truth
print('[3/5] Preparing the synthetic truth...')
has_truth = False


# posterior
print('[4/5] Preparing the posterior...')
ms_posterior = np.load('../HardData/posterior_state_estimate.npz', allow_pickle=True)['m']
channel_prob_posterior = get_channel_probability_from_coarse_inputs(ms_posterior)

# plotting
print('[5/5] Plotting and saving...')

if has_truth:
    fig, (sub_prior, sub_truth, sub_post) = plt.subplots(ncols=3,  
                                                         width_ratios=[3, 3, 4], 
                                                         figsize=(10, 4), sharey='all')
else:
    fig, (sub_prior, sub_post) = plt.subplots(ncols=2,  
                                              width_ratios=[3, 4], 
                                              figsize=(7, 3), sharey='all')
    #subplots[1].plot([1,2],[1,1])
    # subplots[1].text(0.5, 0.5, "Hard data", size=18, ha="center")

# plotting the channel probabilities
im1 = sub_prior.matshow(channel_prob_prior, cmap='tab20b', vmin=0, vmax=1, aspect='auto',
                        origin='lower')
sub_post.matshow(channel_prob_posterior, cmap='tab20b', vmin=0, vmax=1, aspect='auto')
fig.colorbar(mappable=im1, ax=sub_post)

fig.savefig('default.png', bbox_inches='tight', dpi=600)