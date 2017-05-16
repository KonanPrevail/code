## load the sample dataset
load_dataset <- function() {
    list(c(1, 3, 4), c(2, 3, 5), c(1, 2, 3, 5), c(2, 5))
}


## create a list of candidate item sets of size one
createC1 <- function(dataset) {
    c1 <- do.call("c", lapply(dataset, unique))
    ## no native dictionary data structure in R
    as.matrix(sort(unique(c1)))
}


## Returns all candidates that meets a minimum support level
scanD <- function(dataset, candidates, min_support) {
    sscnt <- apply(candidates, 1, function(can) {
        sum(sapply(dataset, function(tid) {
            all(can %in% tid)
        }))
    })

    num_items <- length(dataset)
    supportVec <- sscnt / num_items
    idx <- which(supportVec >= min_support)

    ## return
    ## retlist <- candidates[idx, ]        # we probably do not need it
    ## support_data
    cbind(support = supportVec, candidates)[idx, , drop = FALSE]
}


## Generate the joint transactions from candidate sets
aprioriGen <- function(freq_sets, k) {
    if (nrow(freq_sets) <= 1)
        return(NULL)
    freq_itemsets <- freq_sets[, - 1L, drop = FALSE]
    b1 <- unique(as.vector(freq_itemsets))
    res <- lapply(seq_len(nrow(freq_itemsets)), function(a) {
        b <- freq_itemsets[a, ]
        temp <- setdiff(b1, b)
        cbind(matrix(b, nrow = length(temp),
                     ncol = length(b), byrow = TRUE), temp)
    })
    out <- do.call("rbind", res)
    idx <- apply(out, 1, is.unsorted)
    out[! idx, , drop = FALSE]
}


## Generate a list of candidate item sets
apriori <- function(dataset, min_support = 0.5) {
    C1 <- createC1(dataset)
    kMax <- length(C1)
    L <- vector(mode = "list", length = kMax)
    L[[1L]] <- scanD(dataset, C1, min_support)
    if (! nrow(L[[1L]])) {
        message("\nNo any frequent itemset at all.\n")
        invisible(NULL)
    }
    for (k in seq(2, kMax)) {
        Ck <- aprioriGen(L[[k - 1L]], k)
        if (is.null(Ck))
            break
        L[[k]] <- scanD(dataset, Ck, min_support)
    }
    L[seq_len(k - 1L)]
}

## Create the association rules
## L: list of frequent item sets
## support_data: support data for those itemsets
## min_confidence: minimum confidence threshold
generateRules <- function(support_data, min_confidence = 0.7) {
    conf <- NULL
    for (i in seq_along(support_data)[- 1L]) {
        jMax <- nrow(support_data[[i]])
        for (j in seq_len(jMax)) {
            freqSet <- support_data[[i]][j, ]
            conf <- c(conf, calc_confidence(freqSet, support_data[[i - 1L]]))
        }
    }
    conf[conf >= min_confidence]
}


## Evaluate the rule generated
calc_confidence <- function(freqSet, supportSet) {
    suppSet <- supportSet[, - 1L, drop = FALSE]
    freqSet2 <- freqSet[- 1L]
    idx <- apply(suppSet, 1, function(a) {
        all(a %in% intersect(a, freqSet2))
    })
    ## output names
    nm <- apply(suppSet[idx, , drop = FALSE], 1, function(a) {
        c(as.character(setdiff(freqSet2, a)),
          paste0("(", paste(a, collapse = ", "), ")"))
    })
    nm <- apply(nm, 2, paste, collapse = " ---> ")
    setNames(freqSet[1L] / supportSet[idx, 1L], nm)
}

## sample usage
dataset <- load_dataset()
(support_data <- apriori(dataset, 0.3))
(generateRules(support_data, 0.5))

market <- read.table("market.csv", header = FALSE, sep = ",", nrows = 20L)
sampleDat <- apply(market, 1, function(a) {
    tmp <- na.omit(a)
    attr(tmp, "na.action") <- attr(tmp, "class") <- NULL
    tmp
})
support_market <- apriori(sampleDat, 0.05)
out <- generateRules(support_market, 0.9)
outDat <- data.frame(rules = names(out), confidence = out)
write.table(outDat, file = "out.csv", sep = ",", row.names = FALSE)
