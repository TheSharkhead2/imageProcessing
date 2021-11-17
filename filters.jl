"""
This file contains some functions and definitions of useful filters... IE Gaussian

"""

#include convolutional filter package I made
include("./convolutionFilter.jl")

function gaussian(n, sigma=1)
    """
    Returns nxn gaussian matrix. 

    Parameters
    ----------

    n : Integer
        Size of Gaussian filter. Will be nxn. Must be odd integer. 

    sigma : Float, optional 
        Default = 1. Sigma value (standard deviation) for generating Gaussian. 

    Returns
    -------

    Gaussian : nxn matrix 
        Matrix of Gaussian filter

    """

    if sigma == 0 #as a standard deviation of 0 makes no sense, assume 1 when sigma=0
        sigma = 1
    end

    out = zeros((n,n)) #create nxn output matrix 

    halfWidth = floor(n/2) #get floor of half the matrix dimension for use with offsets 

    #loop through all x and y of matrix, with (x,y) = (0,0) is center of filter
    for x in -halfWidth:halfWidth
        for y in -halfWidth:halfWidth
            out[convert(Int, x+halfWidth+1),convert(Int, y+halfWidth+1)] = (1/(2*pi*sigma^2)) * exp(-(x^2 + y^2)/(2*sigma^2)) #I am using formula for gaussian from: https://medium.com/@akumar5/computer-vision-gaussian-filter-from-scratch-b485837b6e09
        end
    end

    out 

end

function sobelX(image)
    """
    Take in greyscale image and return sobelX filter run on the image. 

    Parameters
    ----------

    image : array   
        2d array representing the image
    
    Returns
    -------

    out : array 
        Array representing input image run through a sobel filter in the x direction 

    """

    #define x direction sobel filter
    Sx = [
        -1 0 1;
        -2 0 2;
        -1 0 1;
    ]

    convolution_filter(image, Sx) #run filter on image and return it

end

function sobelY(image)
    """
    Take in greyscale image and return sobelY filter run on the image. 

    Parameters
    ----------

    image : array   
        2d array representing the image
    
    Returns
    -------

    out : array 
        Array representing input image run through a sobel filter in the y direction 

    """

    #define y direction sobel filter
    Sy = [
        1 2 1;
        0 0 0;
        -1 -2 -1;
    ]

    convolution_filter(image, Sy) #run filter on image and return it

end