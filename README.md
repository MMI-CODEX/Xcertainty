# PhotogrammetriX

# Developer notes

The following notes form a living document that describes practices the `R` package `PhotogrammetriX` uses as development guidelines.

### Code of conduct

This project is released with a Contributor Code of Conduct in [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms

### Branching practices

The PhotogrammetriX repository uses several branches to separate development code from published production code, and to aid in managing development processes.  The branching model uses the main ideas of Vincent Driessen's [git-flow](https://nvie.com/posts/a-successful-git-branching-model/) workflow.  The branches PhotogrammetriX uses are:

- **main:** Contains most recent stable, published version of package.  Suitable for installation from an `R` session by running `devtools::install_github('jmhewitt/PhotogrammetriX')`
- **development:** Contains code for new features, enhancements, etc. to be released in the next version of the package.  Ideally, should always be able to pass CRAN checks, as described in the [Testing the package](#testing-the-package) section.
- **feature-XXX:** Optional practice, in which a large feature can be developed before merging in to the **development** branch.  Can be useful to use when the **development** branch is stable (i.e., passes CRAN checks), and/or when new code in **feature-XXX** may interfere with existing functionality in **development**.  Should be a safe place to commit code that is not fully written and may not run, or run reliably.


### Testing the package

The package should be regularly checked for warnings and errors that will prevent the package from being published on [CRAN](https://cran.r-project.org).  Developers can run checks from their local command line by setting their working directory to the package's root directory, building the package via `R CMD BUILD .`, and then running `R CMD CHECK` via
```
R CMD CHECK R CMD CHECK PhotogrammetriX_XXX.tar.gz --as-cran --as-cran
```
where `XXX` is the package version (i.e., `1.0.0`).  Additional information can be found in the [Writing R Extensions manual](https://cran.r-project.org/doc/manuals/R-exts.html) published by CRAN.
