# Xcertainty

# Getting started

You can use the [devtools](https://cran.r-project.org/package=devtools) package for R to install Xcertainty directly from Github.  Run the following command from an R session:

```
devtools::install_github('MMI-CODEX/Xcertainty')
```

Then, take a look at some vignettes that review example uses of the package in the [inst/doc](inst/doc) folder. Start with the [Xcertainty](inst/doc/Xcertainty.html) vignette, as this will give a proper introduction to using `Xcertainty` and overview of how to use the `independent_length_sampler()` and `body_condition` functions. 

Xcertainty is currently in beta testing. If interested in providing feedback please use this form: https://forms.gle/LdEmfzhGaUVHcG6s6 


# Developer notes

The following notes form a living document that describes development approach the `R` package `Xcertainty` uses.

## Package overview

The `Xcertainty` package uses a Bayesian framework to implement hierarchical models that estimate physical lengths and relationships from photogrammetric data taken with unoccupied aerial systems (UAS).  The hierarchical models use a common "data, process, prior" structure to relate observations, such as pixel counts, altimeter readings, and age estimates, to unknown quantities and relationships, such as lengths, widths, and growth curves.

- Typical data are the lengths of animal features reported as the number of pixels in an image, such as maximum width or total length.  Data also include image information, such as the camera's focal length, sensor width, and height above the focal animal (i.e., altitude as reported by a barometer or laser rangefinder).  Data may also include estimates of an animal's age, sex, and other variables.  Non-length variables are important inputs to growth curve models and other scientific models of population characteristics.

- The process model relates observations to unknown lengths.  `Xcertainty` assumes a thin lens optical system forms images.  The process model uses thin lens formulas to compute the true size of an object from its apparent size in the image, information about the UAS camera, and its altitude.  The process model also assumes 1) UAS report altitudes with error, and 2) pixel lengths may have some error from limitations of image quality and resolution, and (generally small) variations in how different users label animal features in images.  The process model uses measurement error components for altitudes and pixel measurements to incorporate the additional assumptions.

- The prior primarily serves to impose relationships between true, unobserved widths.  Fitting the model to data estimates the relationships.  Growth curves and other scientific relationships are generally considered to be part of the prior.  The prior can also constrain and parameterize the process model.

The `Xcertainty` package provides different `xxx_sampler()` functions that build MCMC samplers which, when run, fit hierarchical models to the data provided.  The `xxx_sampler()` functions primarily differ in the prior distribution's assumptions and structure.  For example, the `independent_length_sampler()` function does not assume image measurements share any relationships.  By comparison, the `growth_curve_sampler()` function assumes the subjects in images grow over time.  The prior distribution associates subject and timepoint metadata with all measurements, then uses a growth curve formula (with parameters estimated from data) to impose an assumption that measurements from the same animal over time are related.

## Adding new prior distributions via `xxx_sampler()` functions

`Xcertainty`'s design goal is to provide tools that prepare, process, and summarize data and model output for photogrammetric observations.  Each `xxx_sampler()` function represents a different analysis that could potentially be run on data.  In general, developers should consider building new `xxx_sampler()` functions to add new types of analyses.  New analyses may, for example, add different types of growth curve models or other scientific models of population characteristics. The existing `xxx_sampler()` functions serve as examples for how to do link data to models.  The `Xcertainty` package uses the [nimble](https://cran.r-project.org/package=nimble) package to build MCMC samplers.  Developers will need to know how to use the `nimble` package.   New `xxx_sampler()` functions require the following development tasks:

1) Add a new "subject/length models" section to the `template_model` nimble model, found in [template_model.R](R/template_model.R).  The "measurement error" model section of `template_model` processes altimeter and pixel measurements.  The "subject/length models" section of `template_model` uses `if` statements as "include guards" to determine which prior distribution should be used for unobserved measurements.  

    The `template_model` nimble model stores all unobserved length measurements in a single `object_length` vector.  Developers must specify a prior distribution for each element of the `object_length` vector they wish to estimate.  Prior distributions may require one or more model-specific index vectors to implement, to formally link model parameters to subjects and measurements.
    
    For example, `object_length[15] ~ dunif(min = 0, max = 15)` will model the 15th `object_length` element as an object independent of all others, with a true length between 0 and 15 units (generally meters).  Instead, specifying `object_length[15] <- min_length + growth_rate * subject_age[object_subject[15]]` is one way to link the 15th `object_length` element to an unbounded linear growth model.  Typically, growth models are more complicated and have asymptotic limits.  In this simplified example, `min_length` and `growth_rate` would be additional parameters with prior distribution entries.  The `subject_age` vector would contain ages for all animals, and the `object_subject` vector would be used to help associate the right age with the unobserved measurement `object_length[15]`. 

2. Create a new `xxx_sampler()` function in a corresponding `xxx_sampler.R` file in the `R/` package subdirectory.  Use [roxygen](https://cran.r-project.org/package=roxygen2) to make sure the function is installed with `Xcertainty`.  The roxygen [getting started](https://cran.r-project.org/web/packages/roxygen2/vignettes/roxygen2.html) vignette and [project website](https://roxygen2.r-lib.org) give brief overviews of the roxygen system.  Plenty of [other tutorials](https://kbroman.org/pkg_primer/pages/docs.html) can be found online too.

    Importantly, `Xcertainty` requires photogrammetric data to be pre-formatted using the `parse_observations()` function.  The `xxx_sampler()` function needs to link the formatted data to the code in the new `template_model` section.  Developers can run the example script in `help(parse_observations)` to see how pre-formatted data are organized.  In general, `dplyr`'s `join` function can be a helpful tool for linking pre-formatted data to `template_model` variables.
    
3. As part of [R package requirements](https://cran.r-project.org/doc/manuals/r-release/R-exts.html), make sure you create a brief demonstration script that can run the new `xxx_sampler()` function.  Since CRAN requires demonstration scripts to take less than five seconds to run and MCMC samplers can take longer than 5 seconds to build, you may find it helpful to add a `package_only` argument to the `xxx_sampler()` function that will only partially build the MCMC sampler.  The `package_only` argument can also be helpful for debugging user issues.  See the `growth_curve_sampler()` function code to see an example of the `package_only` strategy.

4. Advertise the new capabilities!  Also, record that the new `xxx_sampler()` function was added to the `Xcertainty` package in the release notes within the [NEWS.md](NEWS.md) file.


### Code of conduct

This project is released with a Contributor Code of Conduct in [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms

### Branching practices

The Xcertainty repository uses several branches to separate development code from published production code, and to aid in managing development processes.  The branching model uses the main ideas of Vincent Driessen's [git-flow](https://nvie.com/posts/a-successful-git-branching-model/) workflow.  The branches Xcertainty uses are:

- **main:** Contains most recent stable, published version of package.  Suitable for installation from an `R` session by running `devtools::install_github('jmhewitt/Xcertainty')`
- **development:** Contains code for new features, enhancements, etc. to be released in the next version of the package.  Ideally, should always be able to pass CRAN checks, as described in the [Testing the package](#testing-the-package) section.
- **feature-XXX:** Optional practice, in which a large feature can be developed before merging in to the **development** branch.  Can be useful to use when the **development** branch is stable (i.e., passes CRAN checks), and/or when new code in **feature-XXX** may interfere with existing functionality in **development**.  Should be a safe place to commit code that is not fully written and may not run, or run reliably.


### Testing the package

The package should be regularly checked for warnings and errors that will prevent the package from being published on [CRAN](https://cran.r-project.org).  Developers can run checks from their local command line by setting their working directory to the package's root directory, building the package via `R CMD BUILD .`, and then running `R CMD CHECK` via
```
R CMD CHECK R CMD CHECK PhotogrammetriX_XXX.tar.gz --as-cran --as-cran
```
where `XXX` is the package version (i.e., `1.0.0`).  Additional information can be found in the [Writing R Extensions manual](https://cran.r-project.org/doc/manuals/R-exts.html) published by CRAN.
