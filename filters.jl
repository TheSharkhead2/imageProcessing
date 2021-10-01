"""
This file contains some functions and definitions of useful filters... IE Gaussian

"""

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