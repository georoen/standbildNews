library(jpeg)

mth_imageAlgebra <- function(path, sendung, res){
  # select corresponding reference frame
  # TODO check if tagesthemen and heute journal need separate frames
  if(sendung %in% c("h19", "hjo")){
    frameIMG <- readJPEG("extra/zdf_frame.jpg")
  } else {
    frameIMG <- readJPEG("extra/ard_frame.jpg")
  }
  
  # list all downloaded frames
  fls <- list.files(path = path, full.names = TRUE)
  
  # calculate array difference between reference and all frames
  diffs <- sapply(fls, function(x, y = frameIMG){
    diff <- readJPEG(x) - y
    return(mean(abs(diff)))
  })
  # hist(diffs)
  
  # identify freeze frames
  diffs[diffs< 0.05]
  
}



