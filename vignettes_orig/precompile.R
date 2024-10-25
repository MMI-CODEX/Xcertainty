# Pre-compiled vignettes 
getwd()
knitr::knit(input = "vignettes_orig/Xcertainty.Rmd", output = "vignettes/Xcertainty.Rmd")
knitr::knit(input = "vignettes_orig/Xcertainty_informative_priors.Rmd", output = "vignettes/Xcertainty_informative_priors.Rmd")
knitr::knit(input = "vignettes_orig/Xcertainty_growth_curves.Rmd", output = "vignettes/Xcertainty_growth_curves.Rmd")

# {!} Make sure image files end up in Xcertainty/vignettes/img after knit. 
# May need to manually drag and drop from 'Xcertainty/figure/' to 'Xcertainty/vignette/img/'

# {!} Then, need to manually change the pathway for each vignette in the 'vignettes/' folder, by changing "figure" to "img".
# for example, change: 
# "![plot of chunk Xc_Fig8_bai_dist](figure/Xc_Fig8_bai_dist-1.png)" 
# to 
# "![plot of chunk Xc_Fig8_bai_dist](img/Xc_Fig8_bai_dist-1.png)"


# To create local copies of html, ex:
rmarkdown::render(input = "vignettes/Xcertainty.Rmd", output_format = "html_document")
rmarkdown::render(input = "vignettes/Xcertainty_informative_priors.Rmd", output_format = "html_document")
rmarkdown::render(input = "vignettes/Xcertainty_growth_curves.Rmd", output_format = "html_document")