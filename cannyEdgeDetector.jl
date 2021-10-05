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
    Sx = [
        -1 0 1;
        -2 0 2;
        -1 0 1; 
    ]

    Sy = [
        1 2 1;
        0 0 0;
        -1 -2 -1;
    ]

    #run convolution with above filters on image
    imageX = convolution_filter(image, Sx)
    imageY = convolution_filter(image, Sy)

    intensity = hypot.(imageX, imageY) #find the "hypotonuse" of each of the edge intensities (sqrt(x^2 + y^2)). This will result in the "intensity" of the edge in its direction as we are looking at x direction edges and y direction edges
    intensity = intensity .* (255 / maximum(intensity)) #cap each of the pixel edge intensities at 255

    edgeAngle = atan.(imageY, imageX) #use arctan to find the angle at which each edge is. 

    (intensity, edgeAngle)
end



function canny_edge_detection(RGBimage, gaussianDim=9, gaussianSigma=1)
    """

    """

    greyImage = Gray.(RGBimage) #convert to greyscale

    image = channelview(greyImage) #convert image to channel view of image

    gaussianFilter = gaussian(gaussianDim, gaussianSigma) #create gaussian filter

    image = convolution_filter(image, gaussianFilter) #apply gaussian to image

    sobelImage = sobel_filter(image) #run sobel filters on image to get edge intensity and direction

    sobelImage
end

imshow(canny_edge_detection(RGBimage)[1])
sleep(20)
