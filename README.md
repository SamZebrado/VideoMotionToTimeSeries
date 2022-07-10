# VideoMotionToTimeSeries
Detect vibrating/luminance changing object in video within specified area and transform the motion into time series.

Compute the onset of each changing.

[For future implementation, ]compute the motion traces for center of the vibrating objects.

# Specify a range on one frame
Read in video. 
Display one frame. 
Collect mouse clicks: 
* left-click two points to define a rectangular area of interest (AOI)
    * display the clicked points with a cross on the figure
    * display the rectangular areas with bolded lines
* right-click to cancel
    * redraw remaining points with crosses
* Escape key to stop defining and save the data into temp.mat in case of forgetting to save
Save the defined data into AOI-{date-time}.mat

# For each area of interest
* get time series for the intensity of each pixel
* filter the data to exclude unwanted variations, e.g. slowly changing luminance due to the projector/screen/light's refreshing
* select pixels whose standard deviation is large as "motion-indicating" pixels
* combine information from multiple motion-indication pixels and get the earliest onset time
