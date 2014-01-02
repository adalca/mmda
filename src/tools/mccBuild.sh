#!/bin/bash
curdir=`pwd -P`

mccRunDir=/path/to/2012a/bin/mcc
toolboxpath=/path/to/MIA/NIFTI_20100106

#mainMFile=${REG_PATH}/runAlgo3D.m
mainMFile=$1

#projPath=${GITOUT_PATH}
projPath=$2

#mccDir=/data/vision/polina/projects/stroke/bin/MCC/MCC_partialRegistration
mccDir=$3


mkdir -p $mccDir
cd $mccDir

cmd="${mccRunDir} -C -m ${mainMFile} -a $toolboxpath -a $projPath"
echo $cmd
$cmd

chmod +x *
chmod +r *
cd $curdir
