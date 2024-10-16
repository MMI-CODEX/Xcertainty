# Pre-compiled vignettes 
getwd()
knitr::knit(input = "vignettes_orig/Xcertainty.Rmd", output = "vignettes/Xcertainty.Rmd")
knitr::knit(input = "vignettes_orig/Xcertainty_informative_priors.Rmd", output = "vignettes/Xcertainty_informative_priors.Rmd")
knitr::knit(input = "vignettes_orig/Xcertainty_growth_curves.Rmd", output = "vignettes/Xcertainty_growth_curves.Rmd")

# Make sure image files end up in Xcertainty/vignettes/img after knit. May need to manually drag and drop.