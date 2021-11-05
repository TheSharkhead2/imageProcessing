#import my packages
include("./convolutionFilter.jl")
include("./filters.jl")

#import external libraries
using Images, ImageView, FileIO, Statistics

function harris_operator(image; gaussianDim=9, gaussianSigma=1)
    """
    Return harris operator run on image 

    Parameters
    ----------

    image : Julia Image
        Julia RGB image from load(image_path) 

    Returns
    -------

    harris : array  
        Harris opperator value on each pixel in input image


    """

    image = Gray.(image) #convert image to grayscale 

    image = channelview(image) #covert image to 2d array

    gaussianFilter = gaussian(gaussianDim, gaussianSigma) #create gaussian filter

    image = convolution_filter(image, gaussianFilter) #apply gaussian to image

    #define x and y sobel filters
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

    Ixx = convolution_filter(convolution_filter(image, Sx), Sx) #get Ixx, second derivative in x direction

    Iyy = convolution_filter(convolution_filter(image, Sy), Sy) #get Iyy, second derivative in y direction

    Ixy = convolution_filter(convolution_filter(image, Sx), Sy) #get Ixy, mixed partial in x than y direction 

    #we can use the above to create a hessian matrix, the determinant and trace of which gives us the information we want for harris corner detection at each point 
    det = Ixx .* Iyy .- Ixy.^2
    trace = Ixx .+ Iyy


    #calculate the Harris opperator at each pixel. 
    harris = det .- (0.2 .* trace)

    abs.(harris) #compute and return the absolute value of this harris opperator

end
    
function max_harris_values(harris; threshold=0.7)
    """
    Returns the maximum harris opperator values according to threshold. 

    Parameters
    ----------

    harris : array
        Harris opperator of image 

    threshold : Float, optional 
        Default 0.7. Threshold for porportion of max harris operator value for classifying 
        pixel as "corner"

    """

    cornerValueThreshold = maximum(harris) * threshold #get the pixel value threshold for pixel by finding the maximum value and multiplying by the threshold

    out = zeros(size(harris)) #create empty output image for taking thresholds 
    
    #loop through all indicies in harris opperator matrix
    for x in 1:size(harris)[1]
        for y in 1:size(harris)[2]
            #if the harris opperator value is above threshold, save as corner (give value of 1), else ignore it (set to 0)
            if harris[x, y] >= cornerValueThreshold
                out[x, y] = 1
            else
                out[x, y] = 0
            end
        end
    end

    out
end

function harris_corner_detection(image; threshold=0.2, gaussianSigma=1)
    """
    Runs harris corner detection on an image. 

    Parameters
    ----------

    image : Julia RGB image
        Image you want to get corners of 
    
    threshold : Float, optional 
        Default = 0.7. Threshold for classifying the difference between a corner and an unimportant pixel 

    gaussianSigma : Float, optional
        Defualt = 1. Sigma for gaussian blur run on image. 

    Returns 
    -------

    out : Array image
        Image with red overlayed on detected corners. 
    
    """

    harris = harris_operator(image; gaussianSigma=gaussianSigma) #calculate harris opperator of image

    cornerPixels = max_harris_values(harris; threshold=threshold) #get only harris pixel values over threshold 

    image = channelview(image) #convert Julia image to array for easier manipulation 

    c, xDim, yDim = size(image) #get dimensions of image

    #loop through all pixels in image
    for x in 1:xDim 
        for y in 1:yDim
            #if the cornerPixels array identifies this as a corner, overlay red on image
            if cornerPixels[x,y] == 1
                image[1, x, y] = 1.0 
                image[2, x, y] = 0.0
                image[3, x, y] = 0.0
            end 
        end
    end

    colorview(RGB, image)
    
end

