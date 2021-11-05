"""
This file is simply to experiment with functions I am adding so I don't have to put a 
bunch of random code in function files. 

"""
#my packages being used
include("./cannyEdgeDetector.jl")
include("./harrisCorner.jl")

#external packages 
using Images, ImageView, FileIO

RGBImage = load("images/waffle.jpg") #load image

# edgeImage = canny_edge_detection(RGBImage; lowThresholdRatio=0.07, highThresholdRatio=0.18, gaussianDim=15, gaussianSigma=5)

# edgeImage = colorview(Gray, edgeImage)

# imshow(edgeImage)
# save("imageEdges.jpg", edgeImage)

imshow(harris_corner_detection(RGBImage))

sleep(30)