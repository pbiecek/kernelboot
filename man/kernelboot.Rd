% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/kernelboot.R
\name{kernelboot}
\alias{kernelboot}
\title{Smoothed bootstrap}
\usage{
kernelboot(data, statistic, R = 500L, bw = "default", ...,
  kernel = c("gaussian", "epanechnikov", "rectangular", "triangular",
  "biweight", "cosine", "optcosine"), weights = NULL, adjust = 1,
  shrinked = TRUE, ignore = NULL, parallel = FALSE,
  mc.cores = getOption("mc.cores", 2L))
}
\arguments{
\item{data}{vector, matrix, or data.frame. For non-numeric values standard bootstrap
is applied (see below).}

\item{statistic}{a function that is applied to the \code{data}. The first argument of
the function will always be the original data. Any further arguments
can be passed to \code{statistic} through \dots argument.}

\item{R}{the number of bootstrap replicates.}

\item{bw}{the smoothing bandwidth to be used (see \code{\link[stats]{density}}).
The kernels are scaled such that this is the standard deviation,
or covariance matrix of the smoothing kernel. By default
\code{\link[stats]{bw.nrd0}} is used for univariate data,
and \code{\link{bw.silv}} is used for multivariate data.}

\item{\dots}{optional arguments passed to \code{statistic}.}

\item{kernel}{a character string giving the smoothing kernel to be used.
This must partially match one of "gaussian", "rectangular",
"triangular", "epanechnikov", "biweight", "cosine"
or "optcosine", with default "gaussian", and may be abbreviated.}

\item{weights}{vector of importance weights. It should have as many elements
as there are observations in \code{data}. It defaults to uniform
weights.}

\item{adjust}{scalar; the bandwidth used is actually \code{adjust*bw}. This makes
it easy to specify values like 'half the default' bandwidth.}

\item{shrinked}{logical; if \code{TRUE} random generation algorithm preserves
means and variances of the variables (see \code{\link{ruvk}} for details).
This parameter is used only for univariate and product kernels.}

\item{ignore}{vector of names of columns to be ignored during the smoothing phase of
bootstrap procedure (their values are not altered using random noise).}

\item{parallel}{if \code{TRUE} uses parallel processing (see \code{\link[parallel]{mclapply}}).}

\item{mc.cores}{number of cores used for parallel computing (see \code{\link[parallel]{mclapply}}).}
}
\description{
Smoothed bootstrap is an extension of standard bootstrap using kernel densities.
}
\details{
\emph{Smoothed bootstrap} is an extension of standard bootstrap procedure, where instead
of drawing samples with replacement from the empirical distribution, they are drawn
from kernel density estimate of the distribution.

For smoothed bootstrap, points (in univariate case), or rows (in multivariate case), are drawn with
replacement, to obtain samples of size \eqn{n} from the initial dataset of size \eqn{n}, as with
standard bootstrap. Next, random noise from kernel density \eqn{K} is added to each of the drawn
values. The proceure is repeated \eqn{R} times and \code{statistic} is evaluated on each of the
samples.

The noise is added \emph{only} to the numeric columns, while non-numeric columns (i.e.
\code{character}, \code{factor}, \code{logical}) are not altered. What follows, to the
non-numeric columns and columns listed in \code{ignore} standard bootstrap procedure
is applied.

With multivariate data, when using \code{kernel = "gaussian"} and \code{bw} is a non-diagonal
matrix, multivariate Gaussian kernel is applied. When \code{kernel = "gaussian"} and \code{bw}
is a diagonal matrix, or a vector, product kernel is used. In other cases, depending on the data,
univariate, or product kernels, are used.


\strong{Univariate kernels}

Univariate kernel density estimator is defined as

\deqn{
\hat{f_h}(x) = \sum_{i=1}^n w_i \, K_h\left(\frac{x-y_i}{h}\right)
}{
f(x) = sum[i](w[i] * Kh((x-y[i])/h))
}

where \eqn{w} is a vector of weights such that \eqn{\sum_i w_i = 1}{sum(w) = 1}
(by default \eqn{w_i=1/n}{w[i]=1/n} for all \eqn{i}), \eqn{K_h = K(x/h)/h}{Kh = K(x/h)/h} is
kernel \eqn{K} parametrized by bandwidth \eqn{h} and \eqn{y} is a vector of
data points used for estimating the kernel density.

To draw samples from univariate kernel density, the following procedure can be applied (Silverman, 1986):

\emph{Step 1} Sample \eqn{i} uniformly with replacement from \eqn{1,\dots,n}.

\emph{Step 2} Generate \eqn{\varepsilon}{\epsilon} to have probability density \eqn{K}.

\emph{Step 3} Set \eqn{x = y_i + h\varepsilon}{x = y[i] + h\epsilon}.

If samples are required to have the same variance as \code{data}
(i.e. \code{shrinked = TRUE}), then \emph{Step 3} is modified
as following:

\emph{Step 3'} \eqn{
x = \bar y + (y_i - \bar y + h\varepsilon)/(1 + h^2 \sigma^2_K/\sigma^2_Y)^{1/2}
}{
x = m + (y[i] - m + h\epsilon)/sqrt(1 + h^2 var(K)/var(y))
}

where \eqn{\sigma_K^2}{sK} is variance of the kernel (fixed to 1 for kernels used in this package).

When shrinkage described in \emph{Step 3'} is applied, the smoothed bootstrap density function changes it's form to

\deqn{
\hat{f}_{h,b}(x) = (1 + r) \hat{f_h}(x + r(x - \bar{y}))
}{
fb(x) = (1+r) f(x + r (x-mean(y)))
}

where \eqn{r = \left(1 + h^2 \sigma_K^2 / \sigma_y^2 \right)^{1/2}-1}{r = sqrt(1 + h^2 sK/var(y)) - 1}.

This package offers the following univariate kernels:

\emph{Gaussian}
\deqn{
K(u) = \frac{1}{\sqrt{2\pi}} e^{-{u^2}/2}
}{
K(u) = 1/sqrt(2\pi) exp(-(u^2)/2)
}

\emph{Rectangular}
\deqn{
K(u) = \frac{1}{2} \ \mathbf{1}_{(|u|\leq1)}
}{
K(u) = 1/2
}

\emph{Triangular}
\deqn{
K(u) = (1-|u|) \ \mathbf{1}_{(|u|\leq1)}
}{
K(u) = (1 - |u|)
}

\emph{Epanchenikov}
\deqn{
K(u) = \frac{3}{4}(1-u^2) \ \mathbf{1}_{(|u|\leq1)}
}{
K(u) = 3/4 (1 - u^2)
}

\emph{Biweight}
\deqn{
K(u) = \frac{15}{16}(1-u^2)^2 \ \mathbf{1}_{(|u|\leq1)}
}{
K(u) = 15/16 (1 - u^2)^2
}

\emph{Cosine}
\deqn{
K(u) = \frac{1}{2} \left(1 + \cos(\pi u)\right) \ \mathbf{1}_{(|u|\leq1)}
}{
K(u) = 1/2 (1 + cos(\pi u))
}

\emph{Optcosine}
\deqn{
K(u) = \frac{\pi}{4}\cos\left(\frac{\pi}{2}u\right) \ \mathbf{1}_{(|u|\leq1)}
}{
K(u) = \pi/4 cos(\pi/2 u)
}

All the kernels are re-scalled so that their standard deviations are equal to 1,
so that bandwidth parameter controls their standard deviations.

Random generation from Epachenikov kernel is done using algorithm
described by Devoye (1986). For optcosine kernel inverse transform
sampling is used. For biweight kernel random values are drawn from
\eqn{\mathrm{Beta}(3, 3)}{Beta(3, 3)} distribution and
\eqn{\mathrm{Beta}(3.3575, 3.3575)}{Beta(3.3575, 3.3575)}
distribution serves as a close approximation of cosine kernel.
Random generation for triangular kernel is done by taking difference
of two i.i.d. uniform random variates. To sample from rectangular
and Gaussian kernels standard random generation algorithms are used
(see \code{\link[stats]{runif}} and \code{\link[stats]{rnorm}}).


\strong{Product kernels}

Univariate kernels may easily be extended to multiple dimensions by
using product kernel

\deqn{
\hat{f_H}(x_1,\dots,x_n) = \sum_{i=1}^n w_i \prod_{j=1}^m
K_{h_j} \left( \frac{x_i - y_{ij}}{h_j} \right)
}{
f(x) = sum[i](w[i] * prod[j]( Kh[j]((x[i]-y[i,j])/h[j]) ))
}

where \eqn{w} is a vector of weights such that \eqn{\sum_i w_i = 1}{sum(w) = 1}
(by default \eqn{w_i=1/n}{w[i]=1/n} for all \eqn{i}), and \eqn{K_{h_j}}{Kh[j]}
are univariate kernels \eqn{K} parametrized by bandwidth \eqn{h_j}{h[j]}, where
\eqn{\boldsymbol{y}}{y} is a matrix of data points used for estimating the
kernel density.

Random generation from product kernel is done by drawing with replacement
rows of \eqn{y}, and then adding random noise from univariate kernel \eqn{K},
parametrized by corresponding bandwidth parameter \eqn{h}, to the sampled values.


\strong{Multivariate kernels}

Multivariate kernel density estimator may also be defined in terms of multivariate kernels
(e.g. multivariate normal distribution, as in this package)

\deqn{
\hat{f_H}(x_1,\dots,x_n) = \sum_{i=1}^n w_i \, K_H \left( \mathbf{x}-\boldsymbol{y}_i \right)
}{
f(x) = sum[i](w[i] * KH(x-y[i]))
}

where \eqn{w} is a vector of weights such that \eqn{\sum_i w_i = 1}{sum(w) = 1}
(by default \eqn{w_i=1/n}{w[i]=1/n} for all \eqn{i}), \eqn{K_H}{KH} is
kernel \eqn{K} parametrized by bandwidth matrix \eqn{H} and \eqn{\boldsymbol{y}}{y}
is a matrix of data points used for estimating the kernel density.

\emph{Notice:} When using multivariate normal (Gaussian) distribution as a kernel \eqn{K}, the
bandwidth parameter \eqn{H} is a \emph{covariance matrix} as compared to standard deviations
used in univariate and product kernels.

Random generation from multivariate kernel is done by drawing with replacement
rows of \eqn{y}, and then adding random noise from multivariate kernel \eqn{K},
parametrized by corresponding bandwidth matrix \eqn{H}, to the sampled values.
}
\examples{

kernelboot(mtcars, function(data) coef(lm(mpg ~ ., data = data)) , R = 250)
kernelboot(mtcars$mpg, function(data) median(data) , R = 250)


}
\references{
Silverman, B. W. (1986). Density estimation for statistics and data analysis.
Chapman and Hall/CRC.

Scott, D. W. (1992). Multivariate density estimation: theory, practice,
and visualization. John Wiley & Sons.

Efron, B. (1981). Nonparametric estimates of standard error: the jackknife,
the bootstrap and other methods. Biometrika, 589-599.

Hall, P., DiCiccio, T.J. and Romano, J.P. (1989). On smoothing and the bootstrap.
The Annals of Statistics, 692-704.

Silverman, B.W. and Young, G.A. (1987). The bootstrap: To smooth or not to smooth?
Biometrika, 469-479.

Scott, D.W. (1992). Multivariate density estimation: theory, practice,
and visualization. John Wiley & Sons.

Wang, S. (1995). Optimizing the smoothed bootstrap. Annals of the Institute of
Statistical Mathematics, 47(1), 65-80.

Young, G.A. (1990). Alternative smoothed bootstraps. Journal of the Royal
Statistical Society. Series B (Methodological), 477-484.

De Angelis, D. and Young, G.A. (1992). Smoothing the bootstrap.
International Statistical Review/Revue Internationale de Statistique, 45-56.

Polansky, A.M. and Schucany, W. (1997). Kernel smoothing to improve bootstrap
confidence intervals. Journal of the Royal Statistical Society: Series B
(Statistical Methodology), 59(4), 821-838.

Devroye, L. (1986). Non-uniform random variate generation. New York: Springer-Verlag.

Parzen, E. (1962). On estimation of a probability density function and mode.
The annals of mathematical statistics, 33(3), 1065-1076.

Silverman, B.W. and Young, G.A. (1987). The bootstrap: To smooth or not to smooth?
Biometrika, 469-479.

Jones, M.C. (1991). On correcting for variance inflation in kernel density estimation.
Computational Statistics & Data Analysis, 11, 3-15.
}
\seealso{
\code{\link{bandwidth}}, \code{\link[stats]{density}},
         \code{\link[stats]{bandwidth}}, \code{\link{kernelboot-class}}
}
