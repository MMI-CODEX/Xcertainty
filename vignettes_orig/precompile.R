# Pre-compiled vignettes 
getwd()
knitr::knit(input = "vignettes_orig/Xcertainty.Rmd", output = "vignettes/Xcertainty.Rmd")
knitr::knit(input = "vignettes_orig/Xcertainty_informative_priors.Rmd", output = "vignettes/Xcertainty_informative_priors.Rmd")
knitr::knit(input = "vignettes_orig/Xcertainty_growth_curves.Rmd", output = "vignettes/Xcertainty_growth_curves.Rmd")

# Must manually move image files from Xcertainty/ to Xcertainty/vignettes/ after knit