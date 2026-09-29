## Written: 2026-09-28
## By: Carly Levitz
## Purpose: combine play-by-play data

rm(list=ls())

library(openxlsx)
library(tidyverse)

directory <- "/Users/carlylevitz/Documents/Data/baseball/baseball_reference/"
indir <- "/Users/carlylevitz/Documents/Data/baseball/rawdata/"

# What files are there?
files <- list.files(path=indir, pattern="*xlsx", full.names=TRUE, recursive=FALSE)

# Create a holding dataset
all <- data.frame(Inn="",Score="",Out="",RoB="",TotalPitches="",PitchCount=""
                  ,PitchDetails="",RO="",AB="",Batter="",Pitcher="",wWPA=""
                  ,wWE = "",Play="",game="",Pitching="",rowid="")

# Combine all play-by-plays
for (x in files) {
  temp <- read.xlsx(x,sheet=1)

  # rename variables something useful
  names(temp) <- c("Inn","Score","Out","RoB","Pit","RO","AB","Batter","Pitcher"
                   ,"wWPA","wWE","Play")

  # drop rows that are not needed
  temp <- temp %>%
    mutate(game=x)

  temp1 <- temp %>%
    filter(grepl("Bottom",Inn) == FALSE & grepl("Top",Inn) == FALSE &
             Inn != "Inn")

  # what teams are playing?
  teams <- tibble(AB = unique(temp1$AB),Pitching=rev(unique(temp1$AB)))

  tempcombine <- temp1 %>%
    # separate out pitch count and final pitch
    separate(Pit, c("TotalPitches", "pitchTemp"),sep="\\(", extra = "merge"
             , fill = "left") %>%
    separate(pitchTemp,c("PitchCount","PitchDetails"),sep="\\) ",extra="merge"
             ,fill = "left") %>%
    ## add on pitching team
    full_join(teams,by="AB")

  ## add on id for sorting the rows later on - want the at bats to be in order
  # not sure how to do it in tidyverse
  row.names(tempcombine) <- NULL
  tempcombine$rowid <- row.names(tempcombine)

  all <- rbind(all,tempcombine)

}











