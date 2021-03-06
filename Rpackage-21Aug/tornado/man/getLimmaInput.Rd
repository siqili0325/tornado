\name{getLimmaInput}
\alias{getLimmaInput}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{ fit a linear model to each nucleotide
}
\description{
Fits the linear model log2(count+0.5) = beta0 + beta1*group + beta2*library.size + [optional confounders] to each nucleotide.  From these models, this function constructs an object which can be directly passed to \code{getTstats} to obtain \code{limma}'s moderated t statistics for each nucleotide, which we use as a measure of strength of association between group and count (expression). Reads coverage file from a SQLite database (see \code{makeDb}) and relies heavily on the \code{limma} package, using \code{lmFit} as the main workhorse.
}
\usage{
getLimmaInput(dbfile, tablename, group, chunksize = 1e+05, adjustvars = NULL, colsubset = NULL)
}
\arguments{
  \item{dbfile}{
Name/location (as character string) of database (usually ".db") file containing nucleotide by sample coverage.  
}
  \item{tablename}{
Name of the table the database contains
}
  \item{group}{
a 0/1 vector grouping the samples (columns) in the database. 
}
  \item{chunksize}{
How many rows of the database should be processed at a time? 
}
  \item{adjustvars}{
Optional matrix of adjustment variables (e.g. measured confounders, output from SVA, etc.) to use in fitting linear models to each nucleotide.
}

  \item{colsubset}{
Optional vector of column indices of the input file that denote samples you wish to include in analysis. Should NOT include 1 (pos).
}
}
\details{ It is assumed that the first column in the database is called \code{pos} and contains genomic position. \code{group} Must have the one fewer entries than the database denoted by \code{dbfile} has columns. Larger values of \code{chunksize} require more memory; smaller values of \code{chunksize} require more computation time. \code{adjustvars} must have the same number of rows as \code{group} has entries. ONLY EXPERIENCED USERS should provide \code{colsubset}.  This option should be used infrequently if at all, reason being that providing \code{colsubset} will load all of \code{dbfile} into memory.  Mainly used for debugging.
}
\value{
a list with elements
\item{ebobject }{A list of five vectors (\code{coefficients}, \code{stdev.unscaled}, \code{sigma}, \code{df.residual}, and \code{Amean}), mimicking the \code{MArrayLM} class in \code{limma}.  Here, \code{coefficients} and \code{stdev.unscaled} are only returned for beta1, the coefficient for \code{group}, as it is assumed this is the only covariate of interest.}
\item{pos }{A vector of the same length as those contained in \code{ebobject}, giving the genomic positions of each linear model.}
}
\references{
Smyth G (2004). "Linear models and empirical Bayes methods for assessing differential expression in microarray experiments." Statistical Applications in Genetics and Molecular Biology 3(1): Article 3.
}
\author{
Alyssa Frazee
}

\seealso{
\code{\link{getTstats}}, \code{\link{makeDb}}, \code{lmFit}, \code{MArrayLM-class}
}
\examples{
## add example here when we have a vignette
}