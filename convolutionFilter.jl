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

    if length(size(image)) == 3 && size(image)[1] == 3 #if the image array has three dimensions and the first dimension is 3, interpret it as a RGB image


        out = zeros(size(image)) #create blank image array with same dimentions as input array 

        #save row and column dimensions of image for use later
        rowImageSize = size(image)[2]
        columnImageSize = size(image)[3]

        #find the row and column filter overlap
        rowFilterOverlap = Int(floor(size(filter)[1]/2)) 
        columnFilterOverlap = Int(floor(size(filter)[2]/2))

        padWidth = Pad(0, rowFilterOverlap, columnFilterOverlap) #set pad amount for image to be the floor of half the kernel size. This should be equal to the amount of overlap of the kernel when looking at the edge of the image

        #citation for image padding: https://discourse.julialang.org/t/is-there-any-padding-function-available-to-pad-a-matrix-or-array/8521/3
        image = padarray(image, padWidth) #pad input array using closest in bound pixel (yes this does differ from the python implementation, but I doubt this significantly affects performance?)

        for i in 1:rowImageSize 
            for j in 1:columnImageSize 
                #take the dot product of the kernel and the section of the image the kernel overlaps (for each channel) and set it to the corresponding pixel in the output image
                out[1, i, j] = dot(image[1, i-rowFilterOverlap:i+columnFilterOverlap, j-rowFilterOverlap:j+columnFilterOverlap], filter)
                out[2, i, j] = dot(image[2, i-rowFilterOverlap:i+columnFilterOverlap, j-rowFilterOverlap:j+columnFilterOverlap], filter)
                out[3, i, j] = dot(image[3, i-rowFilterOverlap:i+columnFilterOverlap, j-rowFilterOverlap:j+columnFilterOverlap], filter)

            end

        end
    
    elseif length(size(image)) == 2 #if the image only has two dimensions, assume greyscale... Almost same as RGB, however only 1 channel
        out = zeros(size(image)) #create blank image array with same dimentions as input array 

        #save row and column dimensions of image for use later
        rowImageSize = size(image)[1]
        columnImageSize = size(image)[2]

        #find the row and column filter overlap
        rowFilterOverlap = Int(floor(size(filter)[1]/2)) 
        columnFilterOverlap = Int(floor(size(filter)[2]/2))

        padWidth = Pad(rowFilterOverlap, columnFilterOverlap) #set pad amount for image to be the floor of half the kernel size. This should be equal to the amount of overlap of the kernel when looking at the edge of the image

        #citation for image padding: https://discourse.julialang.org/t/is-there-any-padding-function-available-to-pad-a-matrix-or-array/8521/3
        image = padarray(image, padWidth) #pad input array using closest in bound pixel (yes this does differ from the python implementation, but I doubt this significantly affects performance?)

        for i in 1:rowImageSize 
            for j in 1:columnImageSize 
                #take the dot product of the filter and corisponding area in image
                out[i, j] = dot(image[i-rowFilterOverlap:i+columnFilterOverlap, j-rowFilterOverlap:j+columnFilterOverlap], filter)

            end

        end

    end

    totalTime = now() - startTime #take different between current time and start time to get time function took to run
    println("Filter ran on image in $totalTime") #display runtime in print statement

    return out

end
