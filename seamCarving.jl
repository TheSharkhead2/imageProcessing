#import my packages
include("./convolutionFilter.jl")
include("./filters.jl")

#import external libraries
using Images, ImageView 

function calculate_energy(img)
    """
    Calculate energy of each pixel using E = abs(d/dx) + abs(d/dy). Return
    as seperate image

    Parameters
    ----------

    img : array
        Array representing grayscale image. 

    Returns
    -------

    out : array
        Array of same size as input, each pixel value is the energy of that pixel

    """

    #calculate sobel in x and y direction for image
    xSobel = sobelX(img)
    ySobel = sobelY(img)

    #add absolute values of each derivative in each direction of each pixel and return it
    out = abs.(xSobel) .+ abs.(ySobel)

end

function seam_carving(image)
    """
    Description to be written
    
    I used this to get an idea of what I have to do: https://karthikkaranth.me/blog/implementing-seam-carving-with-python/

    """

    #save grayscale version of image for running through sobel filters
    grayImage = Gray.(image)

    #get images as arrays
    grayImage = channelview(grayImage)
    image = channelview(image)

    (calculate_energy(grayImage))

end
