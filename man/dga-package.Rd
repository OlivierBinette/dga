% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dga-package.R
\docType{package}
\name{dga-package}
\alias{dga-package}
\alias{_PACKAGE}
\alias{dga}
\title{Capture-Recapture Estimation using Bayesian Model Averaging}
\description{
Performs Bayesian model averaging over all decomposable graphical models,
each representing a different list dependence structure, with the goal of
estimating the number of uncounted elements from the universe of elements
that could have been recorded or ``captured".  The code here is an
implementation of the model described in Madigan and York (1997).
}
\details{
\tabular{ll}{ Package: \tab dga\cr Type: \tab Package\cr Version: \tab
1.2\cr Date: \tab 2015-04-16\cr License: \tab GPL >=2 \cr }
}
\examples{

### This simulated example goes through the whole process for 3 lists.###
library(chron)
# Simulate some data
N <- 1000 # true population size
num.lists <- 3 # number of lists

# simulate 3 lists independently 'capturing'
l1 <- rbinom(N, 1, .2)
l2 <- rbinom(N, 1, .25)
l3 <- rbinom(N, 1, .3)

overlaps <- data.frame(l1, l2, l3)

# simulate dates of recording
dates <- paste(
  rep(2015, N), "-", sample(1:4, N, replace = TRUE), "-",
  sample(1:28, N, replace = TRUE)
)
dates <- chron(dates, format = c(dates = "y-m-d"))

# save true number in each stratum for comparison later
truth <- table((months(dates)))[1:4]

# remove dates of unrecorded elements
dates <- dates[apply(overlaps, 1, sum) > 0]

# remove individuals not recorded on any list
overlaps <- overlaps[apply(overlaps, 1, sum) > 0, ]

# stratify by date
strata <- make.strata(overlaps, dates = dates, date.defs = "monthly")

# check to make sure that all strata are OK
check <- check.strata(strata)

# look at strata, just to make sure
par(mfrow = c(2, 2), mar = rep(1, 4))
for (i in 1:nrow(strata$overlap.counts)) {
  venn3(strata$overlap.counts[i, ],
    main = rownames(strata$overlap.counts)[i],
    cex.main = 1
  )
}


# load the graphs to make the estimates
data(graphs3)

# select expansion factor defining the largest number of unrecorded elements.
# this makes Nmissing <- 0:(sum(Y)*fac)
fac <- 5

# set prior
delta <- 1 / 2^num.lists

# loop over strata to calculate posterior distributions of
# the total population size for each stratum
par(mfrow = c(2, 2), mar = rep(1.75, 4))
# if using Rstudio, make sure your plot window is pretty big here!
for (i in 1:nrow(strata$overlap.counts)) {
  Nmissing <- 0:(sum(strata$overlap.counts[i, ]) * fac)
  Y <- array(strata$overlap.counts[i, ], dim = rep(2, num.lists))
  weights <- bma.cr(Y, Nmissing, delta, graphs3)
  plotPosteriorN(weights, Nmissing + sum(strata$overlap.counts[i, ]),
    main = rownames(strata$overlap.counts)[i]
  )
  points(truth[i], .5 * max(weights), col = "red", pch = 16, cex = 2)
}
}
\references{
Madigan, David, and Jeremy C. York. "Bayesian methods for
estimation of the size of a closed population."  Biometrika 84.1 (1997):
19-31.
}
\author{
James Johndrow \email{james.johndrow@gmail.com}, Kristian Lum
\email{kl@hrdag.org}, and Patrick Ball \email{pball@hrdag.org}

Maintainer: Kristian Lum \email{kl@hrdag.org}
}
\keyword{Bayesian}
\keyword{averaging}
\keyword{capture-recapture}
\keyword{estimation}
\keyword{model}
\keyword{multiple}
\keyword{systems}
