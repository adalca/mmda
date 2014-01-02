mmda
====

Matlab Medical Dataset Analysis

MATLAB Tools for quantization and analysis of large clinical datasets, with a focus on the NINDS SiGN Stroke Dataset. 
Some of the tools are used and briefly described in [1] together with [medical imaging pipelines](https://github.com/rameshvs/medical-imaging-pipelines). 

Depending on the analysis, the dataset will often need to be pre-processed via the [medical imaging pipelines package](https://github.com/rameshvs/medical-imaging-pipelines).
Following this pre-processing, please see the Quick Start section below.

[1] R. Sridharan*, A.V. Dalca*, K.M. Fitzpatrick, L. Cloonan, A. Kanakis, O. Wu, K.L. Furie, J. Rosand, N.S. Rost, P. Golland. 
Quantification and Analysis of Large Multimodal Clinical Image Studies: Application to Stroke. 
In Proc. MICCAI International Workshop on Multimodal Brain Image Analysis (MBIA), pp. 18-30, 2013. 



Example usecase // Quick Start:
-------------------------------
See `analyzeSiteMGH.m` for an example of running an analysis framework that performs cleanup and 
learns segmentation thresholds from MGH data. See `analyzeSite.m` as an example of analyzing a new
site from scratch, using the thresholds learned from MGH data.

see `initAnalysis.m` and @strokeDataset.predefinedSite.m for parameter documentation.


Details:
--------
The analysis hinges on the medicalDataset object, which allows for initiating a large dataset with various modalities for various subjects. 
A special case of a medicalDataset, called strokeDataset, is supplied, which allows for predefined modalities, such as 'DWI', and predefined 
datasets, such as 'Site18'. the medicalDataset and strokeDataset objects support several operations on the entire dataset, such as 
`clusterVolumes.m`, `linearEqualization.m` and `segmentModality.m`. Please see the documentation for `medicalDataset.m` and `strokeDataset.m`
for information on available operations, and see `analyzeSiteMGH.m` for an example analysis pipeline.

Dependencies:
-------------
- [NIFTI toolbox](http://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image)

Contacts:
---------
{adalca,rameshvs}@csail.mit.edu


License Info:
-------------
The tools are licensed under the MIT License:
http://www.opensource.org/licenses/mit-license.php
See LICENSE file for more information
