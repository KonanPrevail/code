km <- function(X, K, max_iters) {
    m <- nrow(X)
    n <- ncol(X)
    centroids <- matrix(runif(K * n), K, n)
    idx <- matrix(0, m, 1)
    old_idx <- matrix(0, m, 1)

    for (j in seq_len(max_iters)) {
        change = FALSE
        for (i in seq_len(m)) {
            idx[i] <- which.min(rowSums(sweep(- centroids, 2,
                                              X[i, ], FUN = "+") ^ 2))
            if (idx[i] != old_idx[i] && (! change))
                change <- TRUE
        }
        for (i in seq_len(K)) {
            centroids[i, ] <- colMeans(X[idx == i, ])
        }

        if (! change) break

        old_idx <- idx
    }
    list(idx = idx, centroids = centroids)
}

dat <- read.table("../data/sp500_short_period.csv", sep = ",", header = TRUE)

movement <- matrix(as.integer(tail(dat, - 1L) - head(dat, - 1L) > 0),
                   nrow = ncol(dat), ncol = nrow(dat) - 1L, byrow = TRUE)
m <- nrow(movement)
n <- ncol(movement)

K <- 10                                 # 10 sectors
max_iters <- 1000

res <- km(movement, K, max_iters)
idx <- res$idx
centroids <- res$centroids

for (i in seq_len(K)) {
    message(sprintf("Stocks in group %d moving up together:", i))
    cat("\n", paste(colnames(dat)[idx == i], sep = ", "), "\n\n\n")
}


