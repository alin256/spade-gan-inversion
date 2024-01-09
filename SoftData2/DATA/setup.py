__author__ = 'kfo005'
import datetime as dt
import pickle

from misc import ecl,grdecl
import csv, os
import numpy as np
from mako.lookup import TemplateLookup
from mako.runtime import Context
from subprocess import call,Popen,PIPE,DEVNULL
from simulator.rockphysics.standardrp import elasticproperties
from copy import deepcopy
from pipt.geostat import gaussian_sim
import mat73,shutil,glob
import mpslib as mps


# define the test case
case_name = 'GAN'
start = dt.datetime(1967, 1, 1)

# define the data
prod_wells = ['PRO1','PRO2']
inj_wells = ['INJ1', 'INJ2']
prod_data = ['WOPR', 'WWPR']
inj_data = ['WWIR']

O = mps.mpslib();
# O = mps.mpslib(method='mps_snesim_tree', simulation_grid_size=[64,64,1])
O = mps.mpslib(method='mps_snesim_tree', simulation_grid_size=[128,128,1])
O.par['n_real']=1
TI, TI_filename = mps.trainingimages.strebelle()
#TI, TI_filename = mps.trainingimages.rot90()
O.par['ti_fnam']=TI_filename
O.par['rseed'] = 17 #11 er ok. 13 får fire kanaler mot slutten.

def main():
    O.run()
    #O.plot_reals()
    #build the data file
    # Look for the mako file
    lkup = TemplateLookup(directories=os.getcwd(),
                          input_encoding='utf-8')
    tmpl = lkup.get_template(f'{case_name}.mako')
    os.mkdir('TRUE_RUN') # folder for run
    true = O.sim[0][:64,:64,0].T
    true[:32,:] = 0 # only single channel
    np.savez('true_model',**{'true':true})
    # use a context and render onto a file
    with open(f'TRUE_RUN/{case_name}.DATA','w') as f:
        ctx = Context(f, **{'multnum':true.flatten()})
        tmpl.render_context(ctx)

    # Run file
    com = ['flow','--output-dir=TRUE_RUN', f'TRUE_RUN/{case_name}.DATA']
    call(com, stdout=DEVNULL)

    case = ecl.EclipseCase(f'TRUE_RUN/{case_name}')

    rpt = case.report_dates()
    assim_time = [(el - start).days for el in rpt][1:]

    #N=100
    #for i in range(len(pem_input['vintage'])):
    #    tmp_error = [gaussian_sim.fast_gaussian(np.array(list(dim_field)), np.array([800]),np.array([20])) for _ in range(N)]
    #    np.savez(f'var_bulk_imp_vintage_{i}.npz',error=np.array(tmp_error).T)

    rel_var = ['REL', 10]
    abs_var = {'WOPR':['ABS', 8**2],
               'WWPR':['ABS', 8**2],
               'WWIR':['ABS', 8**2],
               }


    f = open('true_data.csv', 'w', newline='')
    g = open('var.csv', 'w', newline='')
    h = open('true_data_index.csv','w',newline='')
    k = open('assim_index.csv','w',newline='')
    l = open('datatyp.csv','w',newline='')

    writer1 = csv.writer(f)
    writer2 = csv.writer(g)
    writer3 = csv.writer(h)
    writer4 = csv.writer(k)
    writer5 = csv.writer(l)


    for time in assim_time:
        tmp_data = []
        tmp_var = []
        list_datatyp = []
        for data in prod_data:
            for well in prod_wells:
                # same std for all data
                single_data = case.summary_data(data + ' ' + well, start + dt.timedelta(days=time))
                #all_data = [case.summary_data(data + ' ' + well, start + dt.timedelta(days=timeidx)) for timeidx in assim_time if case.summary_data(data + ' ' + well, start + dt.timedelta(days=timeidx)) > 0]
                list_datatyp.extend([data + ' ' + well])
                # if the data has value below 10 we must make the variance absolute!!
                if single_data > 0:
                    tmp_var.extend(abs_var[data])
                    tmp_data.extend(single_data)
                else:
                    tmp_var.extend(['ABS','100'])
                    tmp_data.extend(['0.0'])

        for data in inj_data:
            for well in inj_wells:
                single_data = case.summary_data(data + ' ' + well, start + dt.timedelta(days=time))
                #all_data = [case.summary_data(data + ' ' + well, start + dt.timedelta(days=timeidx)) for timeidx in assim_time if case.summary_data(data + ' ' + well, start + dt.timedelta(days=timeidx)) > 0]
                list_datatyp.extend([data + ' ' + well])
                # if the data has value 10 we must make the variance absolute!!
                if single_data > 0:
                    tmp_data.extend(single_data)
                    tmp_var.extend(abs_var[data])
                else:
                    tmp_var.extend(['ABS','100'])
                    tmp_data.extend(['0.0'])
        if time == assim_time[1]:
            for el in list_datatyp:
                writer5.writerow([el])
            writer3.writerow(assim_time)
            for i in range(len(assim_time)):
                writer4.writerow([i])
        writer1.writerow(tmp_data)
        writer2.writerow(tmp_var)


    f.close()
    g.close()
    h.close()
    l.close()
    k.close()


if __name__ == '__main__':
    main()
