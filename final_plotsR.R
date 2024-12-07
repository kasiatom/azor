## załozyłam sobie projekt i wtedy nie musiałam sie martwić ścieżkami
## jak Pani nie chce robic projektu, to musi ściezki dopasować
## używałam plików takich, jak są na githubie, a wiec bez nagłówka => dodaję nazwy zmiennych
## tam tez były jakies nadmiarowe taby, żeby sie ich pozbyć potrzebowałam dodatkowego pakietu "stringr"

setwd("C:/Users/mremb/OneDrive/Desktop/stuff/STUDIA/MGR/tabelki")
getwd()

library(dplyr)
library(ggplot2)
library(stringr)

dfnames = list.files(path = ".", pattern = "*.csv")

#zczytywanie wszystkich plików
## petla po nazwach plików csv
for (x in dfnames) {
  
  data = read.csv(x, header = FALSE)
  colnames(data) = c("CHROM", "POS", "REF", "ALT", "FORM.DP", "FORM.AO")
  
  ## numer próbki biorę z nazwy => to bezpieczniejsze, 
  ## wtedy nie musze się martiwić w jakiej kolejnosci petla się wykonuje i czy obrazki odpowiadaja próbkom
  ## no i mogę robic dla dowolnej liczby plików => tylko nazwy muszą zawierać wzorzec p[0-9]*
  sample = str_match(x, "p[0-9]*")
  data = data %>%
    rowwise() %>%
    mutate("MAF" = min(FORM.AO, FORM.DP-FORM.AO)) %>%
    ungroup() %>%
    mutate(across(c(CHROM, REF, ALT), str_squish)) %>%
    as.data.frame()
  
  # warunki do stworzenia kolejnych subsets
  ## zostawiłam to, uznałam, że nic to nie wnosi i w nazwach plików może byc numeracja rzymska
  chromosomy = list(
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
    "XVI",
    "Mito"
  )
  
 ## for (j in chromosomy) {
    
    #recursive zmienna naming
    g = subset(data, CHROM == chromosomy[1:17])
    MAF = g$MAF
    value = MAF / g$FORM.DP
    pos = g$POS
    
    ## value_alt tak, bo mozna przesledzić którego allele którego szczepu zostały w przypadku LOH 
    value_alt = g$FORM.AO / g$FORM.DP
    
    ## alt allele
    file_name = paste("plot_", sample, "_alt_allele", ".png", sep = "")
    png(file = file_name, height = 1700, width = 1275)
    plot = ggplot(g, aes(pos, value_alt))
    plot_alt = plot + facet_grid(CHROM ~.) +
      geom_point() +
      xlab("Position in the chromosome") +
      ylab("ALT (mainly non s288c strain) allele fractions") +
      scale_x_continuous() +
      scale_y_continuous(limits = c(0.0, 1.0)) +
      theme_bw()
    
    print(plot_alt)
    dev.off()
    
##  }
  
}
