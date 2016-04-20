#Idea Queue
For recording, organizing, sharing, and developing ideas
about Scott's text-to-image synthesis project, especially
in its application to bird-processing.

##Reading CUB and Writing to Torch

###Handling Missing MTurk Data

 - Ignore MTurk altogether.
 - Impute.
 - Fill with a default value such as -1's.

##Estimation of Bounding Boxes

 - Scale down bounding box by fixed factor, centering at each keypoint.
 - Compute Voronoi cells of set of keypoints, and round to rectangles.
 - Find maximal disks around each keypoint containing no other keypoint,
   and circumscribe squares around them.

## Generation of Bounding Box Data

 -

##Demo
(Want as generic as possible)

 - Gradient Descent on Descriminant.
 - Graphical Models (backprop rnn)


TODO:

 - install Ubuntu
 - try running training script (minus gpu)
 - convert py bbox stuff to lua
 - write script for 50/100
 - try GAN for posture generation
 - cool read: SPatial Transformer Networks
