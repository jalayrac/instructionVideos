# Unsupervised Learning from Narrated Instruction Videos

Created by Jean-Baptiste Alayrac at INRIA, Paris.

### Introduction

We address the problem of automatically learning the main steps to complete a certain task, such as changing a car tire, from a set of narrated instruction videos. The contributions of this paper are three-fold. First, we develop a new unsupervised learning approach that takes advantage of the complementary nature of the input video and the associated narration. The method solves two clustering problems, one in text and one in video, applied one after each other and linked by joint constraints to obtain a single coherent sequence of steps in both modalities. Second, we collect and annotate a new challenging dataset of real-world instruction videos from the Internet. The dataset contains about 800,000 frames for five different tasks (How to : change a car tire, perform CardioPulmonary resuscitation (CPR), jump cars, repot a plant and make coffee) that include complex interactions between people and objects, and are captured in a variety of indoor and outdoor settings. Third, we experimentally demonstrate that the proposed method can automatically discover, in an unsupervised manner , the main steps to achieve the task and locate the steps in the input videos.

The webpage for this project is available [here](http://www.di.ens.fr/willow/research/instructionvideos/). It contains link to the [paper](http://www.di.ens.fr/willow/research/instructionvideos/paper.pdf), and other utilities such as original data, poster or slides of the presentation.

### License

Our code is released under the MIT License (refer to the LICENSE file for details).

### Cite

If you find this code useful in your research, please, consider citing our paper:

> @InProceedings{Alayrac16unsupervised,
>    author      = "Alayrac, Jean-Baptiste and Bojanowski, Piotr and Agrawal, Nishant and Laptev, Ivan and Sivic, Josef and Lacoste-Julien, Simon",
>    title       = "Unsupervised learning from Narrated Instruction Videos",
>    booktitle   = "Computer Vision and Pattern Recognition (CVPR)",
>    year        = "2016"
>}

### Contents

  1. [Requirements](#requirements)
  2. [Method](#method)
  3. [Evaluation](#evaluation)
  4. [Features](#features)

### Requirements

To run the code, you need MATLAB installed.
The code was tested on Ubuntu 12.04 LTS with MATLAB-2014b.
In order to obtain the features used here, other dependencies are needed.
For that, see the corresponding [section](#features).

### Method

This repo contains the code for the method described in the CVPR paper.
This method aims at discovering the main steps to achieve a task and temporally localize them in narrated instruction videos.
The method is a 2-stage approach:

  1. Multiple Sequence Alignment of the text input sequences
  2. Discriminative clustering of videos under text constraints

Code is given for both with a separate script for each stage.You can run both stages with different parameter configurations (see comments in the code).

**Multiple Sequence Alignment:**

To run a demo of this code, you need to follow these steps:

1) Download the package and go to that folder
  ```Shell
  git clone https://github.com/jalayrac/instructionVideos.git
  cd instructionVideos
  ```

2) Download and unpack the preprocessed features
  ```Shell
  wget -P data http://www.di.ens.fr/willow/research/instructionvideos/release/NLP_data.zip
  unzip data/NLP_data.zip -d data
  ```

3) Go in the corresponding folder
  ```Shell
  cd nlp_utils
  ```

4) Open MATLAB and run
  ```Matlab
  compile.m
  launching_script.m
  ```

**Discriminative clustering under text constraints:**

Note, that you don't need to run the first stage to be able to launch this demo as we provide mat files of results for the first stage (see instructions below).
To run a demo of this code, you need to follow these steps:

1) Download the package and go to that folder
  ```Shell
  git clone https://github.com/jalayrac/instructionVideos.git
  cd instructionVideos
  ```

2) Download and unpack the preprocessed features (both for NLP and VISION)
  ```Shell
  wget -P data http://www.di.ens.fr/willow/research/instructionvideos/release/NLP_data.zip
  wget -P data http://www.di.ens.fr/willow/research/instructionvideos/release/VISION_data.zip
  unzip data/NLP_data.zip -d data
  unzip data/VISION_data.zip -d data
  ```

3) Download and unpack the preprocessed results of the first stage:
```Shell
wget -P results http://www.di.ens.fr/willow/research/instructionvideos/release/NLP_results.zip
unzip results/NLP_results.zip -d results
```

4) Go in the corresponding folder
  ```Shell
  cd cv_utils
  ```

5) Open MATLAB and run
  ```Matlab
  compile.m
  launching_script.m
  ```

### Evaluation

The authors provide the preprocessed results so that one can reproduce the results of the paper. To reproduce our result plots, please follow these steps:

1) Download the package and go to that folder
  ```Shell
  git clone https://github.com/jalayrac/instructionVideos.git
  cd instructionVideos
  ```
2) Download and unpack the preprocessed results, both for NLP and VISION
```Shell
wget -P results http://www.di.ens.fr/willow/research/instructionvideos/release/NLP_results.zip
unzip results/NLP_results.zip -d results
wget -P results http://www.di.ens.fr/willow/research/instructionvideos/release/VISION_results.zip
unzip results/VISION_results.zip -d results
```
3) Download and unpack the preprocessed data for NLP (for qualitative)
  ```Shell
  wget -P data http://www.di.ens.fr/willow/research/instructionvideos/release/NLP_data.zip
  unzip data/NLP_data.zip -d data
  ```

4) Go in the corresponding folder
```Shell
cd display_res
```

5) Open MATLAB and run (for NLP qual. results)
```Matlab
display_res_NLP.m
```

6) Open MATLAB and run (for temporal localization results)
```Matlab
display_res_VISION.m
```
### Features

If you want to run this code on new data, you will need to process the data as follows.
If you need more details on this don't hesitate to email the first author of the paper.

#### **NLP**

To obtain the direct object relations, we used the Stanford Parser 3.5.1 available [here](http://nlp.stanford.edu/software/stanford-parser-full-2015-01-29.zip).
We first construct a dictionary of direct object relations ranked by their number of apparitions in all our corpus.
The indexing is based on this ranking (see **count_files** folder for a given task.)

For each video, we created a *.trlst file.
For each dobj pronounced during the video, it has a new line containing:
- The index of the corresponding dobj in our dictionary
- The start time in the video (coming from subtitles)
- The end time in the video (coming from subtitles)


We then used the [nltk](http://www.nltk.org/howto/wordnet.html) python package to obtain the distance between dobj (WordNet interface). This allows us to obtain the **sim_mat** matrix.

#### **VISION**

The data for VISION contains two folders:

- **videos_info**: This folder contains video information for each video (FPS, number of frames...)
- **features**: This folder contains a mat file. This mat file is a struct containing all the features, ground truth, different information needed to be able to launch the second stage of the method. The features used here are a concatenation of a Bag-Of-Words of [Improved Dense Trajectories](http://lear.inrialpes.fr/~wang/improved_trajectories), and CNN representation obtained with [MatConvNet](http://www.vlfeat.org/matconvnet/). Please see the paper for detailed explanations.
