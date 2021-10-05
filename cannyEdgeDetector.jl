include("./convolutionFilter.jl")
include("./filters.jl")
using Images
using ImageView

RGBimage = load("images/image.jpg") #load image

function sobel_filter(image)
    """
    This function is meant to be the "part 2" of canny edge detection, applying sobel edge
    detectors ("derivative finders") to the image. For this, because the slide didn't offer 
    specificity, I am using: https://towardsdatascience.com/canny-edge-detection-step-by-step-in-python-computer-vision-b49c3a2d8123
    as a guide. (yes python tutorial, I want to implement everything myself so I only need
    equations and direction)

    Parameters
    ----------

    image : array
        Array representing image.

    Returns
    -------

    intensity : array 
        Array of same size of image with each pixel value being the "intensity" of the 
        edge at that point. 
    
    edgeAngle : array 
        Array of same size of image with each pixel being the angle at which the edge
        is normal to, in radians.

    """


    #define sobel filters in x and y direction (derivative finders). Used filters from: https://towardsdatascience.com/canny-edge-detection-step-by-step-in-python-computer-vision-b49c3a2d8123
    Sy = [
        -1 0 1;
        -2 0 2;
        -1 0 1; 
    ]

    Sx = [
        1 2 1;
        0 0 0;
        -1 -2 -1;
    ]

    #run convolution with above filters on image
    imageX = convolution_filter(image, Sx)
    imageY = convolution_filter(image, Sy)

    intensity = hypot.(imageY, imageX) #find the "hypotonuse" of each of the edge intensities (sqrt(x^2 + y^2)). This will result in the "intensity" of the edge in its direction as we are looking at x direction edges and y direction edges
    intensity = intensity .* (255 / maximum(intensity)) #cap each of the pixel edge intensities at 255

    edgeAngle = atan.(imageX, imageY) #use arctan to find the angle at which each edge is. 

    (intensity, edgeAngle)
end

function non_max_suppression(edgeIntensity, angle)
    """
    Perform non-maximum suppression on the edges found with sobel filer. 

    Parameters
    ----------

    edgeIntensity : array 
        Array with each x,y element in array representing the intensity of the edge
        in the image at the point x,y
    
    angle : array 
        Array with each element x,y representing the angle at which the edge is in the
        image at that point

    Returns
    -------

    out : array
        Array representing edges of image now with non-maximum suppression run on it

    """

    xDim, yDim = size(edgeIntensity) #save shape of image

    out = zeros((xDim, yDim)) #create empty array for output

    angle[angle .< 0] .+= pi #for angles below zero, set them to angles in opposite direction (same "direction" just negative of it)

    #loop over every pixel
    for x in 1:xDim
        for y in 1:yDim 
            #variables used to hold values for pixel "in front of" and "behind" pixel we are looking at. Default to 255 if program doesn't properly handle all angle cases
            q = 255
            r = 255

            #for each if statement below: which pixels angle coorisponds to, records two values of edge intensity at the two coorisponding pixels
            #looking at angles within pi/4 cone of straight up or down. 
            if (0 <= angle[x,y] < pi/8) || ( (7*pi)/8 <= angle[x,y] <= pi )
                if x+1 <= xDim #make sure x+1 isn't greater than image dimensions
                    q = edgeIntensity[x+1,y]
                end

                if x-1 >= 1 #make sure x-1 is in image dimensions, ie not below 1
                    r = edgeIntensity[x-1, y]
                end
            
            #looking at angles within pi/4 cone of pi/4, diagonal following line y=x
            elseif (pi/8 <= angle[x,y] < (3*pi)/8)
                if (x+1 <= xDim) && (y+1 <= yDim) #make sure new pixel is in image dimensions 
                    q = edgeIntensity[x+1, y+1]
                end

                if (x-1 >= 1) && (y-1 >= 1) #make sure in image dimensions 
                    r = edgeIntensity[x-1,y-1]
                end
            
            #looing at pi/4 cone around directly left or right
            elseif ((3*pi)/8 <= angle[x,y] < (5*pi)/8)
                if (y+1 <= yDim) #make sure in image dimensions
                    q = edgeIntensity[x, y+1]
                end

                if (y-1 >= 1) #make sure in image dimensions 
                    r = edgeIntensity[x,y-1]
                end 

            #looking at pi/4 cone around direction coorisponding to line in y=-x direction
            elseif ((5*pi)/8 <= angle[x,y] < (7*pi)/8)
                if (x+1 <= xDim) && (y-1 >= 1) #make sure in image dimensions 
                    q = edgeIntensity[x+1, y-1]
                end

                if (x-1 >= 1) && (y+1 <= yDim) #make sure in image dimensions 
                    r = edgeIntensity[x-1,y+1]
                end 
            end

            if (edgeIntensity[x,y] >= q) && (edgeIntensity[x,y] >= r) #if the edge intensity at the center pixel is the same or higher than those on either side in the direction of the edge, keep the edge
                out[x,y] = edgeIntensity[x,y]
            else #otherwise, remove edge intensity at that point
                out[x,y] = 0
            end
        end
    end

    out

end

function double_threshold(image, lowThresholdRatio=0.05, highThresholdRatio=0.5)
    """
    Applies double threshold to image, removing "wet garbage," and classifying weak
    and strong edges. 

    Parameters
    ----------

    image : array
        Array representing image (having sobel filters and non-max suppression run on 
        it)
        
    lowThresholdRatio : float 
        Sets edge low threshold to this ratio multiplied by high threshold 

    highThresholdRation: float 
        Sets edge high threshold to this ratio multiplied by maximum edge intensity
        in image. 

    Returns
    -------

    image : array 
        Array representing image with thresholds ran on it 
    
    weak : int 
        Value of a weak edge in image

    strong : int 
        Value of strong edge in image

    """

    #set high and low threshold values
    highThreshold = maximum(image) * highThresholdRatio
    lowThreshold = highThreshold * lowThresholdRatio

    #save image dimensions
    xDim, yDim = size(image)

    #set constant values for strong and weak edges
    weak = 25
    strong = 255

    image = ifelse.(image .>= highThreshold, strong, image) #if pixel value is above high threshold, set to strong value 
    image = ifelse.(image .< lowThreshold, 0, image) #if pixel value is below low threshold, set to 0
    image = ifelse.((lowThreshold .<= image .< highThreshold), weak, image) #if pixel value is inbetween high and low threshold, set to weak value

    (image, weak, strong)

end

function canny_edge_detection(RGBimage, gaussianDim=9, gaussianSigma=1)
    """

    """

    greyImage = Gray.(RGBimage) #convert to greyscale

    image = channelview(greyImage) #convert image to channel view of image

    gaussianFilter = gaussian(gaussianDim, gaussianSigma) #create gaussian filter

    image = convolution_filter(image, gaussianFilter) #apply gaussian to image

    sobelImage = sobel_filter(image) #run sobel filters on image to get edge intensity and direction

    nonMaxSupprImg = non_max_suppression(sobelImage[1], sobelImage[2]) #run non maximum suppression on image

    doubleThreshold = double_threshold(nonMaxSupprImg) #run double thresholding on image 

end

imshow(canny_edge_detection(RGBimage)[1])
sleep(20)
