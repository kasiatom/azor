## załozyłam sobie projekt i wtedy nie musiałam sie martwić ścieżkami
## jak Pani nie chce robic projektu, to musi ściezki dopasować
## używałam plików takich, jak są na githubie, a wiec bez nagłówka => dodaję nazwy zmiennych
## tam tez były jakies nadmiarowe taby, żeby sie ich pozbyć potrzebowałam dodatkowego pakietu "stringr"
#setwd("C:/Users/mremb/OneDrive/Desktop/stuff/STUDIA KURWA/MGR/tabelki")
#getwd()

library (dplyr)
library(ggplot2)
library(stringr)

#fpath = "C:/Users/mremb/OneDrive/Desktop/stuff/STUDIA/MGR/tabelki"
dfnames = list.files(path = ".", pattern = "*.csv")

#zczytywanie wszystkich plików
## petla po nazwach plików csv
for (x in dfnames) {
	data = read.csv(x, header = FALSE)
	colnames(data) = c("CHROM", "POS", "REF", "ALT", "FORM.DP", "FORM.A0")
	#print(head(data))
	## numer próbki biorę z nazwy => to bezpieczniejsze, 
	## wtedy nie musze się martiwić w jakiej kolejnosci petla się wykonuje i czy obrazki odpowiadaja próbkom
	## no i mogę robic dla dowolnej liczby plików => tylko nazwy muszą zawierać wzorzec p[0-9]*
	sample = str_match(x, "p[0-9]*")
	data = data %>%
		rowwise() %>%
		mutate("MAF" = min(FORM.A0, FORM.DP - FORM.A0)) %>%
		ungroup() %>%
		mutate(across(c(CHROM, REF, ALT), str_squish)) %>%
		as.data.frame()
	
	#print(head(data))
	#wwarunki do stworzenia kolejnych subsets
	## zostawiłam to, uznałam, że nic to nie wnosi i w nazwach plików może byc numeracja rzymska
	#spis = list("chr1","chr2","chr3","chr4","chr5","chr6","chr7","chr8","chr9","chr10","chr11","chr12","chr13","chr14","chr15","chr16","mito")
	chromosomy = list(
		"I",
		"II",
		"III",
		"IV",
		"V",
		"VI",
		"VII",
		"VIII",
		"XI",
		"X",
		"XI",
		"XII",
		"XIII",
		"XIV",
		"XV",
		"XVI",
		"Mito"
	)
	
	for (j in chromosomy) {
		#recursive zmienna naming
		g = subset(data, CHROM == j)
		MAF = g$MAF
		value = MAF / g$FORM.DP
		pos = g$POS
		## jednak to jest lepsze, bo mozna przesledzić którego allele którego szczepu zostały w przypadku LOH 
		## (a dla próbek 10 i 11 cos tam widać - na nich sprawdzałam skrypt)
		value_alt = g$FORM.A0 / g$FORM.DP
		
		#recursive plot files naming
		#mypath = file.path("C:/Users/mremb/OneDrive/Desktop/stuff/STUDIA/MGR/ploty",paste("plot_p",a[x],"_chr",b[x],".png",sep = ""))
		## minor allele
		#file_name = paste("plot_", sample, "_", j, "_minor_allele", ".png", sep = "")
		#png(file = file_name)
		#plot_minor<- ggplot(g, aes(pos, value)) +
		#	geom_point() +
		#	xlab("Position in the chromosome") +
		#	ylab("Minor allele fractions") +
		#	scale_x_continuous() +
		#	scale_y_continuous(expand = c(0, 0), limits = c(-0.5, 1.0)) +
		#	theme_minimal()
		
		#print(plot_minor)
		#dev.off()
		
		## alt allele
		file_name = paste("plot_", sample, "_", j, "_alt_allele", ".png", sep = "")
		png(file = file_name)
		plot_alt <- ggplot(g, aes(pos, value_alt)) +
			geom_point() +
			xlab("Position in the chromosome") +
			ylab("ALT (mainly non s288c strain) allele fractions") +
			scale_x_continuous() +
			scale_y_continuous(expand = c(0, 0), limits = c(-0.5, 1.0)) +
			theme_minimal()
		
		## u mnie ten print musi być, może to kwestia systemu operacyjnego
		print(plot_alt)
		dev.off()
		
		
		
	}
}

## problem - wiem, że jest coś nie tak z pętlą/pętlami i zczytywaniem wartości, ale nie mam pomysłu jak to naprawić
## wewnętrzna pętla zastępuje dane w subsetcie przez co wartości są 0 i ploty powstają puste
## w efekcie są puste grafy o nazwie "plot_p8_chr1", "plot_p9_chr2" itd
