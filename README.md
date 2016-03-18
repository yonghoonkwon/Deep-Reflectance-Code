# Deep Reflectance Codes (DRC), A Hashing Approach for Material Recognition and Surface Friction Prediction

Created by Hang Zhang, Kristin Dana and Ko Nishino

###   Introduction

This repository contains the code for reproducing the results in the paper (coming soon)

Link to the [project](http://www.hangzh.com/Friction.html)

### Get Started

* The code relies on [vlfeat](http://www.vlfeat.org/), and [matconvnet](http://www.vlfeat.org/matconvnet), which should be downloaded and built before running the experiments. 

* Download the models (VGG-M) in `data/models`. It is slightly faster to download them manually from here: [http://www.vlfeat.org/matconvnet/pretrained](http://www.vlfeat.org/matconvnet/pretrained).

* Download the following dataset to data folder
    * Reflectance Disks (coming soon)  
    * Flickr Material Database [FMD](http://people.csail.mit.edu/celiu/CVPR2010/FMD/) 
    * Describable Textures Dataset [DTD](http://www.robots.ox.ac.uk/~vgg/data/dtd)
    * Textures under varying Illumination[KTH](http://www.nada.kth.se/cvap/databases/kth-tips/)

* 'run_Experiments.m' reproducing general material recogniton results

*  'HashForFriction_Demo.m' reproducting friction prediction results

###   General Material Recogniton Results

dataset         | FV-SIFt-Hash | CNN-ITQ | VLAD-CNN-KBE | FV-CNN-KBE |   DRC    |  DRC-opt  
--------------- |:-----------:|:--- ---:|:------------:|:----------:|:--------:|:---------:
reflectance     | 64.5%       | 51.9%   | 60.1%        | 58.8%      |   59.9%  | 60.2%     
FMD             | 48.3%       | 65.0%   | 59.4%        | 57.7%      |   64.8%  | 65.5%     
DTD             | 43.6%       | 52.6%   | 52.3%        | 53.1%      |   55.4%  | 55.8%     
KTH             | 72.0%       | 73.7%   | 75.6%        | 54.4%      |   76.6%  | 77.2%     



### Acknowldgements

We thank MatConvNet(http://www.vlfeat.org/matconvnet) and VLFEAT teams for creating and maintaining these excellent packages. We would like to thank Felix Yu for [hashing methods](https://github.com/felixyu) and Cimpoi for [FV-CNN encoders](https://github.com/mcimpoi). The copyrights of original codes reserve. 
