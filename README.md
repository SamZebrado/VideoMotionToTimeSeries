# VideoMotionToTimeSeries
Detect vibrating/luminance changing object in video within specified area and transform the motion into time series.

Compute the onset of each changing.

[For future implementation, ]compute the motion traces for center of the vibrating objects.

# A Step-by-Step Guide
1. Use your phone to record a video with some objects that vibrate or change luminance once in a while.
**The current solution only supports objects without large place changes across the video, flickering stars, vibrating coffee machine, etc.** (sorry for my limited imagination while giving examples lol)

You can check your video using **sc_CheckVideoFrameByFrame.m** and find a good frame to define areas of interest (AOIs).

2. Modify variable fname in function **fc_ReadVideo.m** to make it load your video

3. Run script **sc_DefineAOI** and click to define AOIs that include the objects of interest on the figure showing up. 
The guideline has been printed as the figure title. 

You can modify variable **index_frame_AOI** to use different frame of the video as the background.

4. One file name "AOI-rects-{Date-Time}" will be saved when you complete AOI defining.

5. Modify the file name variable fname_AOI in script **sc_GetTimeSeries.m** as the one in Step 4.

6. Manually save variable "sd_tS" in another mat file (let's call it testTimeSeriesSD.mat). This variable contains the SD across all pixels for each frame (Details have been written in section "For each area of interes" below).

7. Modify the file name in line "D = load('testTimeSeriesSD');" of scripts **sc_GetOnsets**. You will get the onset times computed by function **fc_find_start_point_wtc**.
In this script I compare the earliest onset in AOI 1-8 relative to each onset of luminance changing in AOI 9.




# Specify a range on one frame
Read in video. 
Display one frame. 
Collect mouse clicks: 
* left-click two points to define a rectangular area of interest (AOI)
    * display the clicked points with a cross on the figure
    * display the rectangular areas with bolded lines
* right-click to cancel
    * redraw remaining points with crosses
* Click a same point twice to stop defining and save the data into temp.mat in case of forgetting to save
Save the defined data into AOI-{date-time}.mat

# For each area of interest
* get time series for the intensity of each pixel
* normalize each time series to its median
* compute cross-pixel standard deviation to make onset more salient
* the output could be used by onset detection tools

# Alternative solution which has not been implemented
* filter the data to exclude unwanted variations, e.g. slowly changing luminance due to the projector/screen/light's refreshing
* select pixels whose standard deviation is large as "motion-indicating" pixels
* combine information from multiple motion-indication pixels and get the earliest onset time
