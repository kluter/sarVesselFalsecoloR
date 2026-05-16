#=======================================#
# functions
#=======================================#

#=== check for needed R packages + activate ===#
packageChecker <- function(requiredPacks){
  check <- requiredPacks %in% installed.packages()[,"Package"]
  for(i in 1:length(check)){
    if(!check[i]){
      install.packages(requiredPacks[i])
    }
  }
  sapply(requiredPacks, require, character.only = TRUE)
}

#=== convert "//" -> "/" (R path artefact from read.table) ===#
backslashConverter <- function(x){
  gsub("////", "/", x)
}

#=== input/output directories and threshold from cache.txt ===#
getBatchIn <- function(){
  path <- read.table(here("cache.txt"), header = FALSE, sep = ",")
  backslashConverter(as.character(path[1,1]))
}
getBatchOut <- function(){
  path <- read.table(here("cache.txt"), header = FALSE, sep = ",")
  backslashConverter(as.character(path[1,2]))
}
getThreshold <- function(){
  path <- read.table(here("cache.txt"), header = FALSE, sep = ",")
  as.numeric(as.character(path[1,3]))
}

#=== list .jpg files in inputDir, excluding BROWSE files ===#
getInput <- function(inputDir){
  list <- list.files(inputDir)
  list[grep("^(?=.*jpg)(?!.*BROWSE)", list, perl=TRUE)]
}

#=== perceptually optimized false-color palette (blue -> cyan -> yellow -> red) ===#
oceanFireRamp <- c("#2b83ba", "#3087b9", "#358ab8", "#3a8eb8", "#4092b7",
            "#4595b6", "#4a99b5", "#4f9db4", "#55a1b3", "#55a1b3",
            "#5fa8b1", "#64acb0", "#6aafaf", "#6fb3af", "#74b7ae",
            "#79baad", "#7fbeac", "#84c2ab", "#89c5aa", "#8ec9a9",
            "#94cda8", "#99d0a7", "#9ed4a6", "#a3d8a5", "#a9dca5",
            "#addea5", "#b0dfa6", "#b4e1a7", "#b7e2a8", "#bbe4a9",
            "#bee5aa", "#c2e6ab", "#c5e8ac", "#c8e9ae", "#ccebaf",
            "#cfecb0", "#d3edb1", "#d6efb2", "#daf0b3", "#ddf2b4",
            "#e1f3b5", "#e4f4b6", "#e7f6b8", "#ebf7b9", "#eef9ba",
            "#f2fabb", "#f5fbbc", "#f9fdbd", "#fcfebe", "#ffffbf",
            "#fffcbb", "#fff9b8", "#fff6b4", "#fff2b0", "#ffefac",
            "#ffeca8", "#ffe8a4", "#ffe5a0", "#ffe29d", "#ffde99",
            "#ffdb95", "#ffd891", "#fed48d", "#fed189", "#fece85",
            "#feca82", "#fec77e", "#fec47a", "#fec076", "#febd72",
            "#feba6e", "#feb66b", "#feb367", "#feb063", "#fdab5f",
            "#fba55d", "#fa9f5a", "#f89957", "#f69354", "#f58d51",
            "#f3864f", "#f2804c", "#f07a49", "#ef7446", "#ed6e43",
            "#ec6840", "#ea623e", "#e85c3b", "#e75638", "#e55035",
            "#e44932", "#e2432f", "#e13d2d", "#df372a", "#de3127",
            "#dc2b24", "#da2521", "#d91f1e", "#d7191c", "#d7191c"
)

#=== position of histogram peak (bins 1-235; upper range excluded, see README) ===#
maxPoint <- function(input){
  histo <- input
  maxhist <- max(histo$counts[1:235])
  for (i in 1:length(histo$counts)){
    if(histo$counts[i] == maxhist){
      maxpoint <- i
    }
  }
  return(maxpoint)
}

#=== position of histogram minimum after maxPoint (fallback separation point) ===#
minPoint <- function(input){
  histo <- input
  maxpoint <- maxPoint(histo)
  minhist <- min(histo$counts[maxpoint:length(histo$counts)])
  for (i in maxpoint:length(histo$counts)){
    if(histo$counts[i] == minhist){
      minpoint <- i
    }
  }
  return(minpoint)
}

#=== adaptive moving-window thresholding: masks sea clutter, returns vessel pixels ===#
movingWindow <- function(input, threshold){
  jpg <- input
  histo <- hist(jpg, breaks = 255, plot=FALSE)
  maxpoint <- maxPoint(histo)
  minpoint <- minPoint(histo)
  windowSize <- 20
  result <- NA
  while (is.na(result)){
    if(windowSize < 10){
      jpg[jpg < minpoint] <- NA
      result <- jpg
      print(paste("minPoint fallback:", minpoint))
      return(result)
    }
    for (i in seq(maxpoint, length(histo$counts), by=5)){
      if((i + windowSize) <= length(histo$counts)){
        windowSum <- sum(histo$counts[i:(i + windowSize)])
        if(windowSum <= (max(histo$counts) * threshold)){
          jpg[jpg < i] <- NA
          result <- jpg
          print(paste(i, "final windowSize:", windowSize))
          return(result)
        }
      }
    }
    windowSize <- windowSize - 1
  }
}

#=== batch process all chips: threshold, false-color overlay, write PNG ===#
processingJPG <- function(){
  inputDir  <- getBatchIn()
  outputDir <- getBatchOut()
  threshold <- getThreshold()
  list <- getInput(inputDir)
  for (i in 1:length(list)){
    jpg <- raster(paste0(inputDir, "/", list[i]))
    new <- movingWindow(jpg, threshold)
    stacked <- c(jpg, new)
    result <- stack(stacked)
    w <- as.numeric(bbox(jpg)[,2][1])
    h <- as.numeric(bbox(jpg)[,2][2])
    outname <- sub("\\.[jJ][pP][eE]?[gG]$", ".png", list[i])
    png(filename=paste0(outputDir, "/", outname), width = w, height = h)
    plotRGB(result, r=1, g=1, b=1, ext=NULL)
    plot(new, col=oceanFireRamp, add=TRUE, bty="n", box=FALSE, axes=FALSE, legend=FALSE)
    dev.off()
  }
}

#=======================================#
# main
#=======================================#
requiredPacks <- c("here", "raster", "sp")
packageChecker(requiredPacks)

start_time <- Sys.time()
processingJPG()
end_time <- Sys.time()
end_time - start_time

#=======================================#
# debugging
#=======================================#
# inputDir <- getBatchIn()
# list <- getInput(inputDir)
# jpg1 <- raster(paste0(inputDir, "/", list[1]))
# plot(jpg1, col=oceanFireRamp)
#
# histogram1 <- hist(jpg1,
#                    breaks = 255,
#                    main = "image chip histogram",
#                    xlab = "[8bit] grey levels", ylab = "frequency",
#                    col = "darkred")
# minPoint(histogram1)
#
# res1 <- movingWindow(jpg1, 0.1)
# histogram2 <- hist(res1,
#                    breaks = 255,
#                    main = "histogram after thresholding",
#                    xlab = "greyscale", ylab = "frequency",
#                    col = "darkred")
# plot(res1)
#
# stacked <- c(jpg1, res1)
# result <- stack(stacked)
#
# png(filename=paste0(getBatchOut(), "/debug_test.png"), width=151, height=151)
# plotRGB(result, r=1, g=1, b=1, ext=NULL)
# plot(result[[2]], col=oceanFireRamp, add=TRUE, bty="n", box=FALSE, axes=FALSE, legend=FALSE)
# dev.off()
