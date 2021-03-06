#' Shrinking the Sample Covariance Matrix Towards a Diagonal Matrix with Equal
#' Diagonal Elements
#' 
#' Provides a nonparametric Stein-type shrinkage estimator of the covariance
#' matrix that is a linear combination of the sample covariance matrix and of a
#' diagonal matrix with the average of the sample variances on the diagonal and
#' zeros elsewhere.
#' 
#' The rows of the data matrix \code{data} correspond to variables and the
#' columns to subjects.
#' 
#' @param data a numeric matrix containing the data.
#' @param centered a logical indicating if the mean vector is the zero vector.
#' @return Returns an object of the class "shrinkcovmathat" that has
#' components: \item{Sigmahat}{The Stein-type shrinkage estimator of the
#' covariance matrix.} \item{lambdahat}{The estimated optimal shrinkage
#' intensity.} \item{Sigmasample}{The sample covariance matrix.}
#' \item{Target}{The target covariance matrix.} \item{centered}{If the data are
#' centered around their mean vector.}
#' @author Anestis Touloumis
#' @seealso \code{\link{shrinkcovmat.unequal}} and
#' \code{\link{shrinkcovmat.identity}}.
#' @references Touloumis, A. (2015) Nonparametric Stein-type Shrinkage
#' Covariance Matrix Estimators in High-Dimensional Settings.
#' \emph{Computational Statistics & Data Analysis} \bold{83}, 251--261.
#' @examples
#' data(colon)
#' NormalGroup <- colon[, 1:40]
#' TumorGroup <- colon[, 41:62]
#' Sigmahat.NormalGroup <- shrinkcovmat.equal(NormalGroup)
#' Sigmahat.NormalGroup
#' Sigmahat.TumorGroup <- shrinkcovmat.equal(TumorGroup)
#' Sigmahat.TumorGroup
#' @export
shrinkcovmat.equal <- function(data, centered = FALSE) {
    if (!is.matrix(data)) 
        data <- as.matrix(data)
    p <- nrow(data)
    N <- ncol(data)
    centered <- as.logical(centered)
    if (centered != TRUE && centered != FALSE) 
        stop("'centered' must be either 'TRUE' or 'FALSE'")
    if (!centered) {
        if (N < 4) 
            stop("The number of columns should be greater than 3")
        DataCentered <- data - rowMeans(data)
        SigmaSample <- tcrossprod(DataCentered)/(N - 1)
        TraceSigmaHat <- sum(diag(SigmaSample))
        NuHat <- TraceSigmaHat/p
        Q <- sum(colSums(DataCentered^2)^2)/(N - 1)
        TraceSigmaSquaredHat <- (N - 1)/(N * (N - 2) * (N - 3)) * ((N - 
            1) * (N - 2) * sum(SigmaSample^2) + (TraceSigmaHat)^2 - N * 
            Q)
        LambdaHat <- (TraceSigmaHat^2 + TraceSigmaSquaredHat)/
          (N * TraceSigmaSquaredHat + (p - N + 1)/p * TraceSigmaHat^2)
        LambdaHat <- min(LambdaHat, 1)
    } else {
        if (N < 2) 
            stop("The number of columns should be greater than 1")
        SigmaSample <- tcrossprod(data)/N
        TraceSigmaHat <- sum(diag(SigmaSample))
        NuHat <- TraceSigmaHat/p
        TraceSigmaSquaredHat <- 0
        for (i in 1:(N - 1)) TraceSigmaSquaredHat <- sum(crossprod(data[, 
            i], data[, (i + 1):N])^2) + TraceSigmaSquaredHat
        TraceSigmaSquaredHat <- 2 * TraceSigmaSquaredHat/N/(N - 1)
        LambdaHat <- (TraceSigmaHat^2 + TraceSigmaSquaredHat)/((N + 1) * 
            TraceSigmaSquaredHat + (p - N)/p * TraceSigmaHat^2)
        LambdaHat <- min(LambdaHat, 1)
    }
    if (LambdaHat < 1) {
        SigmaHat <- (1 - LambdaHat) * SigmaSample
        diag(SigmaHat) <- NuHat * LambdaHat + diag(SigmaHat)
    } else SigmaHat <- diag(LambdaHat * NuHat, p)
    Target <- diag(NuHat, p)
    ans <- list(Sigmahat = SigmaHat, lambdahat = LambdaHat, 
                Sigmasample = SigmaSample, Target = Target, centered = centered)
    class(ans) <- "shrinkcovmathat"
    ans
}
