% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/batches.R
\name{infiniteSum_batches}
\alias{infiniteSum_batches}
\alias{infiniteSum_batches_C}
\title{Approximates the sum of a positive discrete infinite series with a single
maximum using the batches algorithm}
\usage{
infiniteSum_batches(
  logFunction,
  parameters = numeric(),
  batch_size = 40,
  epsilon = 1e-15,
  maxIter = 1e+05,
  n0 = 0
)

infiniteSum_batches_C(
  logFunction,
  parameters = numeric(),
  batch_size = 40,
  epsilon = 1e-15,
  maxIter = 1e+05,
  n0 = 0
)
}
\arguments{
\item{logFunction}{The function that returns the series value
\ifelse{html}{\out{a<sub>n</sub>}}{\eqn{a_n}} in
the log scale. Can either be an \code{R} function or a string indicating one
of the pre-coded functions. See \code{\link[=precompiled]{precompiled()}} for a list of
available functions. If defined in \code{R}, the function's definition must
have two arguments. The first argument must be the integer argument
equivalent to \eqn{n} in \ifelse{html}{\out{a<sub>n</sub>}}{\eqn{a_n}} and
the second must be a vector of numeric parameters.}

\item{parameters}{A numeric vector with parameters used in logFunction.
Vectorized summation over various parameter values sets is not implemented.
Use \code{\link[=apply]{apply()}} or their variants to achieve this.}

\item{batch_size}{The batch size at which point convergence checking is
performed. The algorithm perform at least twice this number of function
evaluations. See 'details'.}

\item{epsilon}{The desired error margin for the approximation. See 'details'.}

\item{maxIter}{The maximum number of iterations for the approximation. In
most cases, this number will not be reached unless it is very small.}

\item{n0}{The sum will be approximated for the series starting at this value.}
}
\value{
A \code{\link[=summed-objects]{summed-objects()}} object.
}
\description{
A simple method to perform the summation. It adds the values in batches and
stops when the accumulated batch is smaller than the desired threshold. There
is an implementation purely in \code{R} and one in \code{C}. The one in R is
usually slightly faster due to vectorized computing.
}
\details{
The series \ifelse{html}{\out{a<sub>n</sub>}}{\eqn{a_n}} must pass
the ratio convergence test, meaning that the ratio
\ifelse{html}{\out{a<sub>n+1</sub>/a<sub>n</sub>}}{\eqn{a_{n+1}/a_n}} must
converge to a number \eqn{L < 1} when \eqn{n} goes to infinity.

The batches algorithm consists of evaluating the function a fixed number of
times for two checkpoints. If the difference between the sum at these
checkpoints is smaller than \code{epsilon}, the code stops and the later
checkpoint sum is returned. Else, continue summing until the next checkpoint.
All checkpoints are \code{batch_size} long.

This function's efficiency is reliant on the choice of \code{batch_size}.
If it is set too large, the algorithm overshoots the necessary
number of function evaluations too much. If it is set too small, the
algorithm will need to process too many partial summations which slows it
down. However, if they are well calibrated for the series, they can
potentially be very efficient.

Since the batch sizes are known before the calculations are made,
function evaluations can be vectorized. This is why there are two functions
available. \code{infiniteSum_batches} does the calculations at the \code{R}
level, while \code{infiniteSum_batches_C} interfaces the low level \code{C}
code. However, the \code{C} code does not use vectorization since it isn't
available on long double precision type, and therefore the \code{R} level
function should be faster in most cases.

Another difference is that the low level code uses double precision for the
calculations. This means that it is less prone to rounding errors. But this
also means that the two functions can sometimes require a different number
of iterations and function evaluations to reach the stop criteria. This
is shown in the examples.

Another requirement in the current installment of this function is that the
series must have only a single maximum. This is the case for most discrete
probability distributions and marginalization problems. This limitation
will be addressed in the future.
}
\examples{
## Define some function that is known to pass the ratio test.
param = 0.1
funfun <- function(k, p) return(k * log1p(-p[1]))
result <- infiniteSum_batches(funfun, parameters = param)

## This series is easy to verify analytically
TrueSum = -log(param)
TrueSum - result$sum
# Notice that it required 400 function evaluations for the approximation.
result$n

# If we use the C function, it reaches a lower error, but requires more
# iterations
result_C <- infiniteSum_batches_C(funfun, parameters = param)
TrueSum - result_C$sum
result_C$n

## A common problem is finding the normalizing constant for the
## Conway-Maxwell-Poisson distribution. It has already been included
## in the precompiled list of functions.
comp_params = c(lambda = 5, nu = 3)
result <- infiniteSum_batches("COMP", comp_params)
# With a specifically chosen argument value, the summation can be done with
# fewer iterations. But it is usually hard to know the ideal choice for
# applications beforehand
result$n
infiniteSum_batches("COMP", comp_params, batch_size = 11)$n
# A small batch_size ensures a small number of iterations, but slows the
# method due to multiple checking.
infiniteSum_batches("COMP", comp_params, batch_size = 2)$n
}
\seealso{
\code{\link[=precompiled]{precompiled()}} provides a list with precompiled functions
that can be used for the summation. \code{\link[=infiniteSum]{infiniteSum()}} is a more
efficient algorithm.
}
