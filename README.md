## Deep Reflectance Codes (DRC), A Hashing Approach for Material Retrieval 

Created by Hang Zhang, Kristin Dana and Ko Nishino

###   Introduction

This repository contains the code for reproducing the results in the [paper](http://arxiv.org/abs/1603.07998) (ECCV 2016):

      @article{zhang2016friction,
         Author = {Hang Zhang and Kristin Dana and Ko Nishino},
         Title = {Friction from Reflectance: Deep Reflectance Codes for Predicting Physical Surface Properties from One-Shot In-Field Reflectance},
         Booktitle = {Proceedings of the European Conference on Computer Vision ({ECCV})},
         Year = {2016}
      }

If you use the code for your research, please cite our paper. Link to the [project](http://eceweb1.rutgers.edu/vision/labweb/index.html)

### Get Started

* The code relies on [vlfeat](http://www.vlfeat.org/), and [matconvnet](http://www.vlfeat.org/matconvnet), which should be downloaded and built before running the experiments. (Supprting the version [matconvnet-1.0-beta18](http://www.vlfeat.org/matconvnet/download/).)
You can use the following commend to download them:

		git clone --recurse-submodules https://github.com/zhanghang1989/Deep-Reflectance-Code.git
	
* Download the model [VGG-M](http://www.vlfeat.org/matconvnet/pretrained) to `data/models` (older models can also be updated using the `vl_simplenn_tidy` function).

* Download the following dataset to `data/`
    * Reflectance Disks [(reflectance)](https://goo.gl/6Kwg13)  
    * Flickr Material Database [(fmd)](http://people.csail.mit.edu/celiu/CVPR2010/FMD/) 
    * Describable Textures Dataset [(dtd)](http://www.robots.ox.ac.uk/~vgg/data/dtd)
    * Textures under varying Illumination [(kth)](http://www.nada.kth.se/cvap/databases/kth-tips/)

* `run_Experiments.m` reproducing general material recogniton results

* `HashForFriction_Demo.m` reproducting friction prediction results

###   General Material Recogniton Results


Dataset         | FV-SIFT-Hash| CNN-ITQ | VLAD-CNN-KBE | FV-CNN-KBE |   DRC    |  DRC-opt
--------------- |:-----------:|:-------:|:------------:|:----------:|:--------:|:----------:
reflectance     | 64.5%       | 51.9%   | 60.1%        | 58.8%      |   59.9%  | 60.2%
FMD             | 48.3%       | 65.0%   | 59.4%        | 57.7%      |   64.8%  | 65.5%
DTD             | 43.6%       | 52.6%   | 52.3%        | 53.1%      |   55.4%  | 55.8%
KTH             | 72.0%       | 73.7%   | 75.6%        | 54.4%      |   76.6%  | 77.2%


### Acknowldgements
This work was supported by National Science Foundation award IIS-1421134 to KD
and KN and Office of Naval Research grant N00014-16-1-2158 (N00014-14-1-0316)
to KN.

We thank [vlfeat](http://www.vlfeat.org/) and [matconvnet](http://www.vlfeat.org/matconvnet) teams for creating and maintaining these excellent packages. We would like to thank Felix Yu for [hashing algorithms](https://github.com/felixyu) and Cimpoi for [FV-CNN encoders](https://github.com/mcimpoi). The copyrights of original code reserve. 
