# Image Processing Project

This project is a collection of various implementations I have made for a handful of image processing algorithms. 

## Convolution Filter

This was the first algorithm I worked on, coming about from optimizing a convolutional algorithm I was given which was purposefully slow. I worked to optimize it and eventually settled on this algorithm as it is very fast in comparison with the initial algorithm I was given (up to 200x faster, which speaks more to how slow the original function was). 

Through developing this function, I had to use a handful of optimization techniques, which was good practice for me. I eliminated half the loops of the previous solution and then utilized linear algebra to further improve speed. I am extremely happy with this product and have used it as my convolutional filter for the rest of my projects. This was a fundemental building block in all of these implementations due to how integral filters are to image processing. 

## Canny Edge Detection

Following my convolutional filter, I learned about edge detection. I wanted to develop my own implementation of canny edge detection for a bit of fun, but also to solidify my understanding of edge detection. This was a much more difficult implementation, though I felt like I learned a lot going through all the necessary steps of building it up. I had to make use of my convolutional filter for sobel filters, which provided a useful application of the convolution algorithm I worked on. I did follow a tutorial to develop this implementation; however, I still feel like I learned a ton about canny edge detection through working on it and generally improved my understanding of image processing. This particular implementation was extremely fun, both for its novelty, but for its complexity and the fun of finding the edges in many different photos. 

## Harris Corner Detector 

This implementation I struggled with a bit more than the edge detector. I found it much harder to find a concrete tutorial on the subject and it seemed like many sources simply left out the important details. The math was also somewhat novel to me, which wasn't helping. I eventually came to mostly understand how everything was working and was able to get an implementation in place for the algorithm.

It was definitely interesting to work on this implementation; however, I think I got more out of the Canny Edge Detection implementation. As far as I can tell, my implementation works to some extent (it marks most corner-like locations), but it isn't the most accurate. I haven't compared my algorithm to a "professional" implementation, but from what I have seen it isn't that far off/that different. The tutorial I was following suggested some other corner detection methods (and some improvements), which I really want to try out when I have the time to see the improvement. 
