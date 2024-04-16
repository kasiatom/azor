setwd("C:/Users/mremb/OneDrive/Desktop/stuff/STUDIA KURWA/MGR/depth")

library(dplyr)
library(ggplot2)
library(stringr)
require(readr)


## wczytanie plików
dfnames <- list.files(path = ".", pattern = "*regions.bed$")
print(dfnames)

## petla po nazwach plików csv
for (x in dfnames) {
  data <- read_tsv(x, col_names = FALSE, show_col_types = FALSE)
  colnames(data) <- c("CHROM", "START", "END", "DEPTH")
  sample <- str_match(x, "depth_p[0-9]*")
  data <- data %>%
    mutate("POS" = (END + START) / 2) %>%
    filter(CHROM != "Mito") %>%
    mutate(CHROM = factor(
      CHROM,
      levels = c(
        "I",
        "II",
        "III",
        "IV",
        "V",
        "VI",
        "VII",
        "VIII",
        "IX",
        "X",
        "XI",
        "XII",
        "XIII",
        "XIV",
        "XV",
        "XVI"
      )
    )) %>%
    as.data.frame()
  
  median_depth <- median(data$DEPTH, na.rm = FALSE)
  
  
  file_name <- paste("plot_", sample, "_coverage", ".png", sep = "")
  png(file = file_name, width = 1275, height = 1700)
  plot_cov <- data %>%
    ggplot(aes(POS, DEPTH)) +
    geom_point(size = 0.1,
               color = "#cc0066",
               alpha = 0.5) +
    xlab("Position in the chromosome") +
    ylab("Median sequencing depth (500 bp windows)") +
    facet_grid(scales = "fixed", rows = vars(CHROM)) +
    scale_x_continuous() +
    scale_y_continuous(limits = c(0, 4 * median_depth)) +
    theme_bw()
  
  ## u mnie ten print musi być, może to kwestia systemu operacyjnego
  print(plot_cov)
  dev.off()
  
}