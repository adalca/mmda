#!/usr/bin/env bash

GITOUT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
echo GITOUT_PATH $GITOUT_PATH
REG_PATH=${GITOUT_PATH}/registration
TOOLS_PATH=${GITOUT_PATH}/tools
EVAL_PATH=${GITOUT_PATH}/evaluation
DATAPROC_PATH=${GITOUT_PATH}/dataProcessing

export PATH="${GITOUT_PATH}:${REG_PATH}:${TOOLS_PATH}:$PATH"
curdir=`pwd -P`

#./mccBuild.sh ${REG_PATH}/runAlgo3D.m ${GITOUT_PATH} /path/to/bin/MCC/MCC_partialRegistration
#./mccBuild.sh ${EVAL_PATH}/prepareLabels.m ${GITOUT_PATH} /path/to/bin/MCC/MCC_prepareLabels
#./mccBuild.sh ${EVAL_PATH}/hausdorffPlots.m ${GITOUT_PATH} /path/to/bin/MCC/MCC_hausdorff

#./mccBuild.sh ${DATAPROC_PATH}/preprocessStrokeImages.m ${GITOUT_PATH} /data/vision/polina/projects/stroke/bin/MCC/MCC_preprocessStrokeImages

./mccBuild.sh ${TOOLS_PATH}/padNii.m ${GITOUT_PATH} /data/vision/polina/projects/stroke/bin/MCC/MCC_padNii

#./mccBuild.sh ${TOOLS_PATH}/doHistogramEqualization.m ${GITOUT_PATH} /data/vision/polina/projects/stroke/bin/MCC/MCC_doHistogramEqualization

#./mccBuild.sh ${DATAPROC_PATH}/prepareT1File.m ${GITOUT_PATH} /data/vision/polina/projects/stroke/bin/MCC/MCC_prepareT1File

#./mccBuild.sh ${DATAPROC_PATH}/prepareAxialFile.m ${GITOUT_PATH} /data/vision/polina/projects/stroke/bin/MCC/MCC_prepareAxialFile

#./mccBuild.sh ${TOOLS_PATH}/matchWM_cl.m ${GITOUT_PATH} /data/vision/polina/projects/stroke/bin/MCC/MCC_matchWM
