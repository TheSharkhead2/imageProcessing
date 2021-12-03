#import my packages
include("./convolutionFilter.jl")
include("./filters.jl")

#import external libraries
using Images, ImageView, ProgressMeter

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

    #loop through all x values to find the ideal y values for the seam (this may not be as efficient as storing the seams as they are calculated, however this is simpliler for the time)
    for x in (xDim-1):-1:1
        relativeMinIndex = argmin(pathEnergies[x,(last(yValues)-1):(last(yValues)+1)]) #create list of three pixels touching above last best y value (in row below) and find minimum index of said list
        
        relativeIndex = relativeMinIndex - 2 #this will be -1 for 1, 0 for 2, and 1 for 3 which is the offset from the last y value corisponding to the best path

        append!(yValues, last(yValues)+relativeIndex) #append the last y value added to this offset to get the next y value

    end

    reverse(yValues) #return the reverse of this y value list as it is in acending order and it makes more sense in decending order

end

function remove_seam_X(image, yValues; imageType="RGB", fileType="jpg")
    """


    """

    imageCopy = copy(image) #make copy of image

    #create output images for RGB or Gray images 
    if imageType == "RGB" 
        if fileType == "gif"
            out = Array{RGBA{N0f8}, 2}(undef, size(imageCopy)[1], size(imageCopy)[2]-1) #create empty output array for RGB image (transparency layer if gif)
        else
            out = Array{RGB{N0f8}, 2}(undef, size(imageCopy)[1], size(imageCopy)[2]-1) #create empty output array for RGB image
        end

    elseif imageType == "Gray"
        out = zeros( (size(imageCopy)[1], size(imageCopy)[2]-1) ) #create empty output array for Gray image
    end

    #loop through all y seam values and the corresponding index (which is the x value)
    for (index, y) in enumerate(yValues)
        if imageType == "RGB" #check to see if RGB image or Gray image
            
            out[index, :] = deleteat!(imageCopy[index, :], y) #remove pixel
            
        elseif imageType == "Gray"
            out[index, :] .= deleteat!(imageCopy[index, :], y) #remove information from the one pixel location for black/white images
        end
    end

    out

end

function seam_carving(image, xReduction; fileType="jpg")
    """
    Description to be written

    

    """

    xDim, yDim = size(image) #save size of image

    #get grayscale of image
    grayImage = Gray.(image) 
    grayImage = Float64.(grayImage) #convert to floats

    if fileType == "gif" #check if output file type is apng
        image = RGBA.(image) #add transparency layer to image
        outImage = copy(image) #initialize output image as copy of og image if saving as apng (animated image). 
    end

    #loop for each row y being removed
    @showprogress "Removing Seams... " for x in 1:xReduction

        imageEnergy = calculate_energy(grayImage) #calculate the energy of each pixel in the image

        bestSeam = calculate_seam_X(imageEnergy) #calculate the best seam to remove

        image = remove_seam_X(image, bestSeam; fileType=fileType) #remove seam from image

        if fileType == "gif"
            ### ERROR: this now doesn't properly save a gif ###

            outImage = cat(outImage, Array{RGBA{N0f8}}(padarray(image, Fill( RGBA{N0f8}(1.0,1.0,1.0,1.0), (0,0), (0, yDim-size(image)[2]) ))); dims=3) #if saving as animated gif, concatinate new image onto output. Extend new image to have empty transparent pixels on end
        end

        grayImage = Float64.(Gray.(image)) #convert image to grayscale

    end

    #return early apng file if that is output
    if fileType == "gif"
        return outImage
    end

    image
        

end


