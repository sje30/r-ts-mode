## Examples for testing r-ts-mode

# test message

function1 = function(x) {
  ## hello world
  x * 2
}

function2 <- function(x, y) {
  ## Return the maximum of the two arguments X and Y.
  if (x > y) {
    return(x)
  } else {
    return(y)
  }
}


function3 <- function(x) {
  ## simple threshold
  if (x > 10)
  1				# TODO: how to indent this?
  else
  0
}

c = NA

silly <- "hello"

plan <- NA

worse <- Inf
hello <- NaN
jumper <- 9.0

risky <- FALSE
safe  <- TRUE

pdf_file = "test1.pdf"
pdf(file=pdf_file)
plot(1:10)
dev.off()

# 


## anonymous functions might be tricky in this context...
## can we ignore them for point of view of imenu and navigation?
doubles = sapply(1:10, function(x) {x*2})

## To help with debugging the indentation code.
## (setq treesit--indent-verbose t)


## beg and end of defun work okay, but highlighted as string rather
## than as name.  Maybe need overwrite function or to reorder rules?

"threshold<-" <- function(x, value) {
  ## X is the object to update
  ## VALUE is the value on the RHS.
  y <- ifelse(x > value, 1, 0)
  return(y)
}
x <- c(0.3, 0.1, 0.6, 0.7, 0.9, 0.2)
threshold(x) <- 0.4
x


## Example of a function within a function
## imenu behaves a bit oddly here.
fn5 <- function(a, b) {

  add <- function(x, y) {
    x+y
  }

  add(a, b) + 1
}


fn5(3, 5)

## Things to do:
## I like the ESS way of commenting, with #, ##, and ###.
## (Like the elisp convention.)  How can we add this?
