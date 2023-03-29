#!/bin/bash

#SBATCH --job-name=fMRIprep
#SBATCH --time=01:00:00 # hh:mm:ss

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=9
#SBATCH --mem-per-cpu=10000 # megabytes
#SBATCH --partition=batch,debug

#SBATCH --mail-user=jeanne.caron-guyon@uclouvain.be
#SBATCH --mail-type=ALL
#sbatch --output=fmriprep_job-%j.txt

#SBATCH --comment=cpp_cluster_hackaton

#export OMP_NUM_THREADS=9
#export MKL_NUM_THREADS=9

# Submission script for Lemaitre3
# 
# USAGE on cluster:
#
#   sbatch fmriprep.sh <subjID> <TaskName>
# 
# USAGE locally:
#
#   bash fmriprep.sh <subjID> <TaskName>
#

# fail whenever something is fishy
# -e exit immediately
# -x to get verbose logfiles
# -u to fail when using undefined variables
# https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html
set -e -x -u -o pipefail

# set to true to run locally
LOCAL=false

subjID=$1
TaskName=$2

FMRIPREP_VERSION="22.0.2"

if [ ${LOCAL} == false ]; then
    module purge
    path_to_singularity_image="$HOME/singularity_images/containers/images/bids/bids-fmriprep--${FMRIPREP_VERSION}.sing"
    bids_dir="../inputs/raw"
    output_dir="../outputs"
    freesurfer_license_folder="$HOME/freesurfer_license"
    tmp_dir="../tmp"
fi

# change values below to test locally
if [ ${LOCAL} == true ]; then
    : Running locally
    path_to_singularity_image="$HOME/my_images/bids-fmriprep--${FMRIPREP_VERSION}.sing"
    bids_dir="$HOME/github/bidspm/demos/MoAE/inputs/raw"
    output_dir="$HOME/outputs"
    freesurfer_license_folder="$HOME/Dropbox/Softwares/Freesurfer/License"
    tmp_dir="$HOME/tmp"
fi

# create output and tmp folders in case they don't exist
mkdir -p "${tmp_dir}"
mkdir -p "${output_dir}"

singularity run --cleanenv \
    -B "${bids_dir}":/bids_dir \
    -B "${tmp_dir}":/tmp \
    -B "${output_dir}":/output \
    -B "${freesurfer_license_folder}":/freesurfer_license \
        "${path_to_singularity_image}" \
            /bids_dir \
            /output \
            participant \
            --participant-label "${subjID}" \
            --task "${TaskName}" \
            --work-dir /tmp \
            --fs-license-file /freesurfer_license/license.txt \
            --output-spaces MNI152NLin2009cAsym T1w \
            --notrack \
            --skip_bids_validation \
            --stop-on-first-crash
