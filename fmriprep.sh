#!/bin/bash
# Submission script for Lemaitre3
#SBATCH --job-name=fMRIprep
#SBATCH --time=42:00:00 # hh:mm:ss
#
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=9
#SBATCH --mem-per-cpu=10000 # megabytes
#SBATCH --partition=batch,debug
#
#SBATCH --mail-user=jeanne.caron-guyon@uclouvain.be
#SBATCH --mail-type=ALL
#sbatch --output=fmriprep_job-%j.txt
#
#SBATCH --comment=cpp_cluster_hackaton

module purge

#export OMP_NUM_THREADS=9
#export MKL_NUM_THREADS=9

subjID=$1
TaskName=$2

singularity run --cleanenv \
    -B ../inputs/raw:/bids_dir \ # where the inputs are to : temporary bids_dir directory
    -B ../tmp:/tmp \ # temporary directory in which analysis is ran (useful when crashs happen to retrieve analysis in process)
    -B ../outputs:/output \ # where the outputs are to : temporary output directory
    -B ~/freesurfer_license:/freesurfer_license \  # where the freesurfer license is 
    ~/singularity_images/containers/images/bids/bids-fmriprep--21.0.1.sing \
    /bids_dir /output \
    participant --participant-label ${subjID} \
    --work-dir /tmp \
    --fs-license-file /freesurfer_license/license.txt \
    --output-spaces MNI152NLin2009cAsym T1w \
    --notrack --stop-on-first-crash \
    --task ${TaskName} # task to be preprocessed 
