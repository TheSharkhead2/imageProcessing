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

function calculate_seam_X(imageEnergy)
    """
    Calculate lowest energy vertical seam in image 

    """

    xDim, yDim = size(imageEnergy) #store dimensions of image

    pathEnergies = zeros((xDim, yDim)) #create empty array same size as image to store energy for each path and use it to compute the best path

    pathEnergies[1, 1:yDim] = imageEnergy[1, 1:yDim] #set all energies from paths to first row of pixels as just those pixel's energy values as... that is just true

    pathEnergies = padarray(pathEnergies, Fill(Inf, (0,1), (0,1))) #pad path energy array with Inf on both left and right to invalidate paths goind through the side but allowing for checking the (0,0) pixel for example (which otherwise wouldn't exist)

    #loop through all pixels in energies image excluding  
    for x in 2:xDim 
        for y in 1:yDim 
            pathEnergies[x,y] = minimum(pathEnergies[x-1, (y-1):(y+1)]) + imageEnergy[x,y] #set least energy path to current pixel as the minimum value of the path to one of the three above pixels plus the energy of the current pixel
        end
    end


    endIndex = argmin(pathEnergies[xDim, 1:yDim]) #find the minimum value index of last row in pathEnergies array (this will be the final index of the lowest energy seam)

    yValues = [endIndex] #empty list (initially include last index) to store the path of y values for least energy

    for x in (xDim-1):-1:1
        relativeMinIndex = argmin(pathEnergies[x,(last(yValues)-1):(last(yValues)+1)]) #create list of three pixels touching above last best y value (in row below) and find minimum index of said list
        
        relativeIndex = relativeMinIndex - 2 #this will be -1 for 1, 0 for 2, and 1 for 3 which is the offset from the last y value corisponding to the best path

        append!(yValues, last(yValues)+relativeIndex) #append the last y value added to this offset to get the next y value

    end

    reverse(yValues) #return the reverse of this y value list as it is in acending order and it makes more sense in decending order

end

function seam_carving(image)
    """
    Description to be written
    
    I used this to get an idea of what I have to do: https://karthikkaranth.me/blog/implementing-seam-carving-with-python/

    """

    xDim, yDim = size(image) #save size of image

    grayImage = Gray.(image) #get grayscale of image

    #convert Julia image objects to just arrays (easier to work with)
    grayImage = channelview(grayImage)
    image = channelview(image)

    #calculate the energy of each pixel in the image
    imageEnergy = calculate_energy(grayImage)

    ### TEST CODE ###
    bestSeam = (calculate_seam_X(imageEnergy))

    for x in 1:xDim
        image[1, x, bestSeam[x]] = 1.0
        image[2, x, bestSeam[x]] = 0.0
        image[3, x, bestSeam[x]] = 0.0
    end

    image
        

end


"""
Dynamic approach to seam carving: 
- for each pixel in the second row, the least energy seam is the minimum of the least energies of the connected pixels above it (ie, if it bordered energies of 0.5, 0.7, 0.3 then the lowest energy is the 0.3 pixel path)
- use this to compute the energy of the lowest path to the second row, then the third row is the same, however with the added energy of the first and second row 
- do this for all rows until the bottom and take the lowest one, this is the path

"""