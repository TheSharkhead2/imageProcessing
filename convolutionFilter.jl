#import packages 
using Images
using ImageView
using LinearAlgebra
using Dates

function convolution_filter(image, filter)
    """
    Applies a filter, filter, to the inputed image, image, using convolution. 

    Parameters
    ----------

    image : array (3, i, j)
        An array representing the image of shape (3, i, j) where i is the number of rows,
        j is the number of pixels, and the first dimention contains color information. 

    filter : array
        A nxn array (where n is an odd number) that represents the filter that will be
        applied to the above image. 
    
    Returns
    -------

    out : array (3, i, j)
        An array representing the output image with the same dimensions as the input image

    """

    startTime = now() #get exact time on function start to later calculate time it took to run

    out = zeros(size(image)) #create blank image array with same dimentions as input array 

    #save row and column dimensions of image for use later
    rowImageSize = size(image)[2]
    columnImageSize = size(image)[3]

    filterOverlap = Int(floor(size(filter)[1]/2)) #save the value of the "overlap" of the filter for later use

    padWidth = Pad(0, filterOverlap, filterOverlap) #set pad amount for image to be the floor of half the kernel size. This should be equal to the amount of overlap of the kernel when looking at the edge of the image

    #citation for image padding: https://discourse.julialang.org/t/is-there-any-padding-function-available-to-pad-a-matrix-or-array/8521/3
    image = padarray(image, padWidth) #pad input array using closest in bound pixel (yes this does differ from the python implementation, but I doubt this significantly affects performance?)

    for i in 1:rowImageSize 
        for j in 1:columnImageSize 
            #take the dot product of the kernel and the section of the image the kernel overlaps (for each channel) and set it to the corresponding pixel in the output image
            out[1, i, j] = dot(image[1, i-filterOverlap:i+filterOverlap, j-filterOverlap:j+filterOverlap], filter)
            out[2, i, j] = dot(image[2, i-filterOverlap:i+filterOverlap, j-filterOverlap:j+filterOverlap], filter)
            out[3, i, j] = dot(image[3, i-filterOverlap:i+filterOverlap, j-filterOverlap:j+filterOverlap], filter)

        end

    end

    totalTime = now() - startTime #take different between current time and start time to get time function took to run
    prinln("Filter ran on image in $totalTime") #display runtime in print statement

    return out

end
