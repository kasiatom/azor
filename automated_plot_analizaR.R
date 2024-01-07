setwd("C:/Users/mremb/OneDrive/Desktop/stuff/STUDIA KURWA/MGR/tabelki")
getwd()

library (dplyr)
library(ggplot2)

fpath = "C:/Users/mremb/OneDrive/Desktop/stuff/STUDIA KURWA/MGR/tabelki"
dfnames = list.files(fpath)

xlist = list(1:10)

#zczytywanie wszystkich plików
for (x in xlist) {
  data = read.csv(dfnames[x])
  data = data %>% rowwise() %>% mutate("MAF" = min(FORM.AO, FORM.DP-FORM.AO)) %>% ungroup
  
  #warunki do stworzenia kolejnych subsets
  spis = list("chr1","chr2","chr3","chr4","chr5","chr6","chr7","chr8","chr9","chr10","chr11","chr12","chr13","chr14","chr15","chr16","mito")
  chromosomy = list("I","II","III","IV","V","VI","VII","VIII","XI","X","XI","XII","XIII","XIV","XV","XVI","Mito")

  jlist = list(1:length(spis))
  
  for (j in jlist) {
    
    #recursive zmienna naming 
    g = paste0(spis[j])
    h = paste0(chromosomy[j])
    
    g = subset(data, CHR==h)
    MAF = g$MAF
    value = MAF/g$FORM.DP
    pos = g$POS
    
    #recursive plot files naming
    a=8:17
    b=1:17
    mypath = file.path("C:/Users/mremb/OneDrive/Desktop/stuff/STUDIA KURWA/MGR/ploty",paste("plot_p",a[x],"_chr",b[x],".png",sep = ""))
    
    png(file=mypath)
    ggplot(g, aes(pos, value)) +
      geom_point() +
      xlab("Position in the chromosome") +
      ylab("Mutant allele fractions") +
      scale_x_continuous() +
      scale_y_continuous(expand = c(0, 0), limits=c(-0.5, 1.0)) +
      theme_minimal()
    
    dev.off()
    
  }
}

## problem - wiem, że jest coś nie tak z pętlą/pętlami i zczytywaniem wartości, ale nie mam pomysłu jak to naprawić
## wewnętrzna pętla zastępuje dane w subsetcie przez co wartości są 0 i ploty powstają puste
## w efekcie są puste grafy o nazwie "plot_p8_chr1", "plot_p9_chr2" itd