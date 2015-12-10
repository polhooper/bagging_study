import subprocess

print('#------------------------------------------------#\nTrainig predictive models and scoring test data...\n#------------------------------------------------#') 
cmd = 'python train_and_test.py'
subprocess.call(cmd, shell = True)

print('#--------------------#\nVisualizing results...\n#--------------------#') 
cmd = 'Rscript visuals.R'
subprocess.call(cmd, shell = True)
