include("./convolutionFilter.jl")
include("./filters.jl")
using Images
using ImageView
using Statistics

RGBImage = load("images/image.jpg") #load image

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

function double_threshold(image, lowThresholdRatio=0.05, highThresholdRatio=0.09)
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

function hysteresis(image, weak, strong)
    """
    Performs hysteresis on image. Turns weak edges into strong edges if the weak edge
    is boardered by a strong one. 

    Parameters
    ----------

    image : array 
        Array representing image edges up to double thresholding

    weak : int 
        Value of weak edges

    strong : int 
        Value of strong edges
    
    Returns
    -------

    image : array
        Array for image with hysteresis ran on it

    """

    xDim, yDim = size(image) #save image dimensions 

    paddedImage = padarray(image, Pad(1,1)) #pad image by 1 one on each side to remove out of index errors

    #loop through all pixels in image
    for x in 1:xDim 
        for y in 1:yDim
            if image[x,y] == weak #if it is a weak edge 
                #if any of the boarding pixels are strong, set pixel to strong as well
                if (( paddedImage[x+1,y+1] == strong ) || ( paddedImage[x+1,y] == strong ) || ( paddedImage[x+1,y-1] == strong ) ||
                    ( paddedImage[x,y+1] == strong ) || ( paddedImage[x,y-1] == strong ) || 
                    ( paddedImage[x-1,y+1] == strong ) || ( paddedImage[x-1,y] == strong ) || ( paddedImage[x-1,y-1] == strong ))
                    image[x,y] = strong 
                else #otherwise it isn't an edge
                    image[x,y] = 0
                end
            end
        end
    end

    image
end

function compression(image; n=3)
    """
    Compresses image by n^2 by compacting every nxn area in image into 1 pixel. 

    Parameters
    ----------

    image : array
        Array for image 
    
    n : int, optional
        Default: 3. Size of area that will be collapsed into a single pixel. The size of the 
        image will be reduced by a factor of 1/n^2. Only currently works for odd n

    """

    xDim, yDim = size(image) #save x and y dimensions of image

    filterOverlap = Int(floor(n/2)) #calculate amount compression filter will overlap outside image

    centerCoord = 1 + filterOverlap #set value x,y (both equal) that will be taken as "center." On odd sized filters, this is actually just the center. On even it will be offset one right and one down

    minusAmount = filterOverlap #amount "filter" will go up or left. For a 3x3 this is just 1, for a 2x2 same. Odd has same as plus amount where even is 1 extra. 
    plusAmount = n - centerCoord #amount to the right or down "filter" extends from center. This will be same as above for odd and 1 less for even. 

    #amount extra needed to be added as padding in either direction to account for even divisability 
    xExtra = n-(xDim % n)
    yExtra = n-(yDim % n)

    padWidth = Pad((minusAmount, plusAmount+xExtra), (minusAmount, plusAmount+yExtra)) #set pad amount to padding for overflow from filter and excess to account for having to divide dimensions by compression amount
    image = padarray(image, padWidth) #pad array

    out = zeros(( Int((xDim+xExtra)/n), Int((yDim+yExtra)/n) )) #set empty output image array in size of new, compressed image

    #variables to keep track of "location" in output image
    xOut = 1
    yOut = 1
            
    #Loop through every n pixels in image, meaning each square nxn around index looped through coorisponds to one pixel in output image
    for x in 1:n:(xDim+xExtra) 
        for y in 1:n:(yDim+yExtra) 
            #set output pixel to average of coorisponding pixels in original image
            out[xOut, yOut] = mean(image[ x-minusAmount:x+plusAmount, y-minusAmount:y+plusAmount ])

            yOut += 1 #increment y index
        end
        xOut += 1 #increment x index
        yOut = 1 #reset y index
    end

    out
end


function canny_edge_detection(RGBimage; lowThresholdRatio=0.05, highThresholdRatio=0.09, gaussianDim=9, gaussianSigma=1, compress=false)
    """
    Performs canny edge detection on Julia image. Returns new image currently with 255 as an edge and 0
    as no edge. (updating this to be convertable back to Julia image, between 0 and 1, would be ideal)

    Parameters
    ----------

    RGBimage : Julia Image
        Julia image from load(image_path)
    
    lowThresholdRatio : Float, optional
        Default: 0.05. Ratio of high threshold which counts for weak edge 

    highThresholdRatio : Float, optional 
        Default: 0.09. Ratio of maximum edge value for strong edge 

    gaussianDim : Int
        Odd Integer representing dimension of Gaussian blur filter

    gaussianSigma : Float 
        Sigma value for Gaussian 

    compress : Bool, optional
        Default: false. true if image should be compressed before processing... Changes dimensions of image currently 

    Returns
    -------

    outImage : Array 
        Array representing image edges. 

    """

    greyImage = Gray.(RGBimage) #convert to greyscale

    image = channelview(greyImage) #convert image to channel view of image

    xDim, yDim = size(image) #save dimensions of image

    if compress && ((xDim/1000 > 2) || (yDim/1000 > 2)) #if the image resolution is sufficiently large, compress it. This is for better edge detection (hopefully) and processing times
        #take the largest of x or y to determine the compression amount (to get largest dimension closest to 1500 pixels)
        if xDim > yDim 
            n = Int(floor(xDim/1000))
        else 
            n = Int(floor(yDim/1000))
        end

        image = compression(image; n=n) 
    end

    gaussianFilter = gaussian(gaussianDim, gaussianSigma) #create gaussian filter

    image = convolution_filter(image, gaussianFilter) #apply gaussian to image

    sobelImage = sobel_filter(image) #run sobel filters on image to get edge intensity and direction

    nonMaxSupprImg = non_max_suppression(sobelImage[1], sobelImage[2]) #run non maximum suppression on image

    doubleThreshold = double_threshold(nonMaxSupprImg) #run double thresholding on image 

    outImage = hysteresis(doubleThreshold[1], doubleThreshold[2], doubleThreshold[3]) #run hysteresis on image to turn weak edges into strong edges

    outImage #maybe add "uncompressor" at the end here to go back to original dimensions of image. 

end

imshow(canny_edge_detection(RGBImage; lowThresholdRatio=0.05, highThresholdRatio=0.08, gaussianDim=21, gaussianSigma=4))
sleep(30)
