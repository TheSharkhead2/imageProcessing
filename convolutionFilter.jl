#import packages 
using Images
using ImageView
using LinearAlgebra
using Dates

#Load monkeyImage 
image = load("image.jpg")

imageArray = channelview(image) #Julia uses a special storage for images that is different from arrays. It is easier to manipulate the image in array form. This is converting it to an array

#define the same filter as the python implementation uses
shiftingFilter = zeros((19,19)) #same size of filter in zeros
shiftingFilter[1,19] = 1 #set top right value to a 1

strongSharpenFilter = [
    -1 -1 -1 -1 -1 -1 -1 -1 -1;
    -1 -1 -1 -1 -1 -1 -1 -1 -1;
    -1 -1 -1 -1 -1 -1 -1 -1 -1;
    -1 -1 -1 -1 -1 -1 -1 -1 -1;
    -1 -1 -1 -1 80 -1 -1 -1 -1;
    -1 -1 -1 -1 -1 -1 -1 -1 -1;
    -1 -1 -1 -1 -1 -1 -1 -1 -1;
    -1 -1 -1 -1 -1 -1 -1 -1 -1;
    -1 -1 -1 -1 -1 -1 -1 -1 -1;
]

smallBlur = [
    1 1 1 1 1;
    1 1 1 1 1;
    1 1 1 1 1;
    1 1 1 1 1;
    1 1 1 1 1;
]
smallBlur = smallBlur * 1/sum(smallBlur)


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
    return out

end

startTime = now() #take the time before running the function
filteredImage = convolution_filter(imageArray, smallBlur)
totalTime = now() - startTime #subtract the start time from the time after running the function to get the time the function took to run
filteredImage = colorview(RGB, filteredImage) #convert image back to Julia image format (from array of shape (3,i,j))

println("The convolution function took $totalTime to run")

println("Displaying original image")
imshow(image) 

println("Displaying image with filter applied")
imshow(filteredImage)

sleep(20) #delay at end of file such that you can actually see displayed images (otherwise windows close)
