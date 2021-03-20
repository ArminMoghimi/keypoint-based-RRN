# Keypoint based Relative Radiometric Normalization (RRN) method (codes and dataset)

This repository includes a MATLAB codes and datasets used in our manuscript "[A. Moghimi, T. Celik, A. Mohammadzadeh, H. Kusetogullari, "A Comparative Analysis of Feature Point Detection and Matching Methods in Relative Radiometric Normalization"] for relative radiometric normalization (RRN) of unregistered bi-temporal multi-spectral images.  

## Overview
The MATLAB code implements the fully automatic relative radiometric normalization methods for unregistered satellite image pairs based on the different feature detector-descriptors, presented in our manuscript. 

![Test Image 1](https://github.com/ArminMoghimi/Keypoint-based-Relative-Radiometric-Normalization-RRN-method/blob/main/keypoint_based_rrn.png)
For code and datasets, see supplementary material.

## Dependencies and Environment
The codes are developed and tested in MATLAB R2020a, with both OpenCV.3.4.1 and the VLFeat open-source libraries on a desktop computer with Intel(R) Core (TM) i7-3770 CPU @ 3.40 GHz, 12.00GB RAM, running the Windows 8.1. In order to use the codes, you need some prerequisite as follow: 
- 	MATLAB 2020a
- 	OpenCV (3.4.1)
- 	VLFeat 0.9.21 

you also need the required build tools for windows which is Visual Studio. Please see https://github.com/kyamagu/mexopencv to how to download and install OpenCV on your MATLAB software. Also, please see the https://www.vlfeat.org/ to how to download and install VLFeat 0.9.21.
