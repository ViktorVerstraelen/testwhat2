context("check_function")

test_that("check_function - step by step", {
  lst <- list(DC_SOLUTION = "mean(1:3, na.rm = TRUE)",
              DC_SCT = "fun <- ex() %>% check_function('mean')
                        fun %>% check_arg('x') %>% check_equal()
                        fun %>% check_arg('na.rm') %>% check_equal()")

  lst$DC_CODE <- ""
  output <- test_it(lst)
  fails(output)
  fb_contains(output, "Have you called <code>mean()</code>")

  lst$DC_CODE <- "mean(1:3)"
  output <- test_it(lst)
  fails(output)
  fb_contains(output, "Check your call of <code>mean()</code>")
  fb_contains(output, "Did you specify the argument <code>na.rm</code>?")

  lst$DC_CODE <- "mean(1:3, na.rm = FALSE)"
  output <- test_it(lst)
  fails(output)
  fb_contains(output, "Check your call of <code>mean()</code>.")
  fb_contains(output, "Did you correctly specify the argument <code>na.rm</code>?")

  lst$DC_CODE <- "mean(1:3, na.rm = TRUE)"
  output <- test_it(lst)
  passes(output)
})

test_that("check_function - step by step - append", {
  lst <- list(DC_SOLUTION = "mean(1:3, na.rm = TRUE)",
              DC_SCT = "fun <- ex() %>% check_function('mean', append = FALSE)
                        fun %>% check_arg('x', append = FALSE) %>% check_equal(append = FALSE)
                        fun %>% check_arg('na.rm', append = FALSE) %>% check_equal(append = FALSE)")

  lst$DC_CODE <- ""
  output <- test_it(lst)
  fails(output)
  fb_contains(output, "Have you called <code>mean()</code>")

  lst$DC_CODE <- "mean(1:3)"
  output <- test_it(lst)
  fails(output)
  fb_excludes(output, "Check your call of <code>mean()</code>")
  fb_contains(output, "Did you specify the argument <code>na.rm</code>?")

  lst$DC_CODE <- "mean(1:3, na.rm = FALSE)"
  output <- test_it(lst)
  fails(output)
  fb_excludes(output, "Check your call of <code>mean()</code>.")
  fb_contains(output, "Did you correctly specify the argument <code>na.rm</code>?")

  lst$DC_CODE <- "mean(1:3, na.rm = TRUE)"
  output <- test_it(lst)
  passes(output)
})

test_that("check_function - custom eq_fun", {
  lst <- list()
  lst$DC_SOLUTION <- "mean(c(1, 2, 3))"
  lst$DC_SCT <- "ex() %>% check_function('mean') %>% check_arg('x') %>% check_equal(eq_fun = function(x, y) length(x) == length(y))"

  # correct
  exs <- list(
    list(code = "mean(c(1, 2, 3))", correct = TRUE),
    list(code = "mean(c(2, 3, 4))", correct = TRUE),
    list(code = "mean(1)", correct = FALSE)
  )

  for (ex in exs) {
    lst$DC_CODE <- ex$code
    output <- test_it(c(lst, DC_CODE = ex$code))
    if (ex$correct) passes(output) else fails(output)
  }
})

test_that("test_function step by step", {
  lst <- list(DC_SOLUTION = "mean(1:3, na.rm = TRUE)",
              DC_SCT = "test_function('mean', args = c('x', 'na.rm'))")

  lst$DC_CODE <- ""
  output <- test_it(lst)
  fails(output, mess_patt = "Have you called <code>mean\\(\\)</code>")

  lst$DC_CODE <- "mean(1:3)"
  output <- test_it(lst)
  fails(output, mess_patt = "Check your call of <code>mean\\(\\)</code>\\. Did you specify the argument <code>na.rm</code>?")

  lst$DC_CODE <- "mean(1:3, na.rm = FALSE)"
  output <- test_it(lst)
  fails(output, mess_patt = "Check your call of <code>mean\\(\\)</code>\\. Did you correctly specify the argument <code>na.rm</code>?")

  lst$DC_CODE <- "mean(1:3, na.rm = TRUE)"
  output <- test_it(lst)
  passes(output)
})

test_that("test_function step by step - custom", {
  lst <- list(DC_SOLUTION = "mean(1:3, na.rm = TRUE)",
              DC_SCT = "test_function('mean', args = c('x', 'na.rm'), not_called_msg = 'notcalled', args_not_specified_msg = 'notspecified', incorrect_msg = 'incorrect')")

  lst$DC_CODE <- ""
  output <- test_it(lst)
  fails(output, mess_patt = "Notcalled")

  lst$DC_CODE <- "mean(1:3)"
  output <- test_it(lst)
  fails(output)
  fb_contains(output, "Notspecified")
  fb_excludes(output, "Check your call of <code>mean()</code>")

  lst$DC_CODE <- "mean(1:3, na.rm = FALSE)"
  output <- test_it(lst)
  fails(output)
  fb_contains(output, "Incorrect")
  fb_excludes(output, "Check your call of <code>mean()</code>")

  lst$DC_CODE <- "mean(1:3, na.rm = TRUE)"
  output <- test_it(lst)
  passes(output)
})

test_that("test_function step by step - custom - 2", {
  lst <- list(DC_SOLUTION = "mean(1:3, na.rm = TRUE)",
              DC_SCT = "test_function('mean', args = c('x', 'na.rm'), not_called_msg = 'notcalled', args_not_specified_msg = c('notspecified', 'notspecified2'), incorrect_msg = c('incorrect1', 'incorrect2'))")

  lst$DC_CODE <- ""
  output <- test_it(lst)
  fails(output)
  fb_contains(output, "Notcalled")

  lst$DC_CODE <- "mean(1:3)"
  output <- test_it(lst)
  fails(output, "Notspecified2")

  lst$DC_CODE <- "mean(1:2, na.rm = FALSE)"
  output <- test_it(lst)
  fails(output, "Incorrect1")

  lst$DC_CODE <- "mean(1:3, na.rm = FALSE)"
  output <- test_it(lst)
  fails(output, mess_patt = "Incorrect2")

  lst$DC_CODE <- "mean(1:3, na.rm = TRUE)"
  output <- test_it(lst)
  passes(output)
})

test_that("test_function - index (1)", {
  lst <- list()
  lst$DC_SOLUTION <- "mean(1:10, na.rm = TRUE)"
  lst$DC_SCT <- "test_function('mean', args = c('x', 'na.rm'), index = 1)"

  lst$DC_CODE <- "mean(1:10, na.rm = TRUE)"
  output <- test_it(lst)
  passes(output)

  lst$DC_CODE <- "mean(1:10, na.rm = FALSE)"
  output <- test_it(lst)
  line_info(output, 1, 1, 20, 24)
  fails(output)

  lst$DC_CODE <- "mean(1:10, na.rm = FALSE)\nmean(1:10, na.rm = FALSE)"
  output <- test_it(lst)
  line_info(output, 1, 1, 20, 24)
  fails(output)

  # no more blacklisting, so fails
  lst$DC_CODE <- "mean(1:10, na.rm = FALSE)\nmean(1:10, na.rm = TRUE)"
  output <- test_it(lst)
  fails(output)
})

test_that("test_function - index (2)", {
  lst <- list()
  lst$DC_SOLUTION <- "mean(1:10, na.rm = TRUE)\nmean(1:10)"
  lst$DC_SCT <- "test_function('mean', args = 'x', index = 2)"

  lst$DC_CODE <- "mean(1:10, na.rm = TRUE)\nmean(1:10)"
  output <- test_it(lst)
  passes(output)

  lst$DC_CODE <- "mean(1:10)\nmean(1:10, na.rm = TRUE)"
  output <- test_it(lst)
  passes(output)

  lst$DC_CODE <- "mean(1:10, na.rm = TRUE)"
  output <- test_it(lst)
  fails(output)

  lst$DC_CODE <- "mean(1:10, na.rm = TRUE)\nmean(1:8)"
  output <- test_it(lst)
  fails(output)
  line_info(output, 2, 2, 6, 8)
})

test_that("test_function - index (3)", {
  lst <- list()
  lst$DC_PEC <- 'emails <- c("john.doe@ivyleague.edu", "education@world.gov", "dalai.lama@peace.org",
            "invalid.edu", "quant@bigdatacollege.edu", "cookie.monster@sesame.tv")'
  lst$DC_CODE <- 'sub("edu", "edu", emails)\nsub("edu", "edu", emails)'
  lst$DC_SOLUTION <- lst$DC_CODE

  lst$DC_SCT <- paste('test_function("sub", "pattern", index = 1)\n',
                      'test_function("sub", "replacement", index = 1)\n',
                      'test_function("sub", "x", index = 1)\n',
                      'test_function("sub", "pattern", index = 2)\n',
                      'test_function("sub", "replacement", index = 2)\n',
                      'test_function("sub", "x", index = 2)')
  output <- test_it(lst)
  passes(output)

  lst$DC_SCT <- paste('test_function("sub", "pattern", index = 1)\n',
                      'test_function("sub", "pattern", index = 2)\n',
                      'test_function("sub", "replacement", index = 1)\n',
                      'test_function("sub", "replacement", index = 2)\n',
                      'test_function("sub", "x", index = 1)\n',
                      'test_function("sub", "x", index = 2)')
  output <- test_it(lst)
  passes(output)
})

test_that("test_function - eq_condition", {
  lst <- list()
  lst$DC_CODE <- "df.equiv <- data.frame(a = c(1, 2, 3), b = c(4, 5, 6))\n  var(df.equiv)\n  df.not_equiv <- data.frame(a = c(1, 2, 3), b = c(4, 5, 6))\n  lm(df.not_equiv)"
  lst$DC_SOLUTION <- "df.equiv <- data.frame(c = c(1, 2, 3), d = c(4, 5, 6))\n  var(df.equiv)\n  df.not_equiv <- data.frame(c = c(7, 8, 9), d = c(4, 5, 6))\n  lm(df.not_equiv)"

  lst$DC_SCT <- "test_function('var', 'x')"
  output <- test_it(lst)
  passes(output)

  lst$DC_SCT <- "test_function('lm', 'formula')"
  output <- test_it(lst)
  fails(output)

  lst$DC_SCT <- "test_function('var', 'x', eq_condition = 'equal')"
  output <- test_it(lst)
  fails(output)

  lst$DC_SCT <- "test_function('lm', 'formula', eq_condition = 'equal')"
  output <- test_it(lst)
  fails(output)
})

test_that("test_function - eval", {
  lst <- list()
  lst$DC_SOLUTION <- "mean(1:3)"

  # eval = TRUE (the default)
  lst$DC_SCT <- "test_function('mean', args = 'x')"
  lst$DC_CODE <- "mean(1:2)"
  output <- test_it(lst)
  fails(output)
  lst$DC_CODE <- "mean(c(1, 2, 3))"
  output <- test_it(lst)
  passes(output)
  lst$DC_CODE <- "mean(1:3)"
  output <- test_it(lst)
  passes(output)

  # eval = FALSE
  lst$DC_SCT <- "test_function('mean', args = 'x', eval = FALSE)"
  lst$DC_CODE <- "mean(1:2)"
  output <- test_it(lst)
  fails(output)
  lst$DC_CODE <- "mean(c(1, 2, 3))"
  output <- test_it(lst)
  fails(output)
  lst$DC_CODE <- "mean(1 : 3)"
  output <- test_it(lst)
  passes(output)
  lst$DC_CODE <- "mean(1:3)"
  output <- test_it(lst)
  passes(output)

  # eval = NA
  lst$DC_SCT <- "test_function('mean', args = 'x', eval = NA)"
  lst$DC_CODE <- "mean(1:2)"
  output <- test_it(lst)
  passes(output)
  lst$DC_CODE <- "mean(c(1, 2, 3))"
  output <- test_it(lst)
  passes(output)
  lst$DC_CODE <- "mean(1:3)"
  output <- test_it(lst)
  passes(output)
})

# test_that("test_function errs correctly", {})

test_that("test_function - diff messages - 1", {
  lst <- list()
  lst$DC_SOLUTION <- "mean(1:20, trim = 0.1, na.rm = TRUE)"
  lst$DC_SCT <- "test_function('mean', args = c('x', 'trim', 'na.rm'))"

  mess_patt1 <- "Check your call of <code>mean\\(\\)</code>\\. Did you correctly specify the argument <code>x</code>?"
  mess_patt2 <- "It has length 10, while it should have length 20"

  # match by pos
  lst$DC_CODE <- "mean(1:10,\ntrim = 0.1,\nna.rm = TRUE)"
  output <- test_it(lst)
  fails(output, mess_patt = mess_patt1)
  fails(output, mess_patt = mess_patt2)
  line_info(output, 1, 1)

  # match by name
  lst$DC_CODE <- "mean(x = 1:10,\ntrim = 0.1,\nna.rm = TRUE)"
  output <- test_it(lst)
  fails(output, mess_patt = mess_patt1)
  fails(output, mess_patt = mess_patt2)
  line_info(output, 1, 1)

  # match by name
  lst$DC_CODE <- "mean(trim = 0.1,\nx = 1:10,\nna.rm = TRUE)"
  output <- test_it(lst)
  fails(output, mess_patt = mess_patt1)
  fails(output, mess_patt = mess_patt2)
  line_info(output, 2, 2)

  # match by name
  lst$DC_CODE <- "mean(trim = 0.1,\nna.rm = TRUE,\nx = 1:10)"
  output <- test_it(lst)
  fails(output, mess_patt = mess_patt1)
  fails(output, mess_patt = mess_patt2)
  line_info(output, 3, 3)

  # two args wrong -> only mention the first
  lst$DC_CODE <- "mean(1:10,\ntrim = 0.2,\nna.rm = TRUE)"
  output <- test_it(lst)
  fails(output, mess_patt = mess_patt1)
  fails(output, mess_patt = mess_patt2)
  line_info(output, 1, 1)

  lst$DC_CODE <- "mean(x = 1:10,\ntrim = 0.2,\nna.rm = TRUE)"
  output <- test_it(lst)
  fails(output, mess_patt = mess_patt1)
  fails(output, mess_patt = mess_patt2)
  line_info(output, 1, 1)

  lst$DC_CODE <- "mean(trim = 0.2,\nx = 1:10,\nna.rm = TRUE)"
  output <- test_it(lst)
  fails(output, mess_patt = mess_patt1)
  fails(output, mess_patt = mess_patt2)
  line_info(output, 2, 2)

  lst$DC_CODE <- "mean(trim = 0.2,\nna.rm = TRUE,\nx = 1:10)"
  output <- test_it(lst)
  fails(output, mess_patt = mess_patt1)
  fails(output, mess_patt = mess_patt2)
  line_info(output, 3, 3)
})

test_that("test_function - diff messages - 2", {
  lst <- list()
  lst$DC_SOLUTION <- "print('This is a serious thing!')"
  lst$DC_SCT <- "test_function('print', args = 'x', index = 1)"
  mess_patt1 <- "Check your call of <code>print\\(\\)</code>\\. Did you correctly specify the argument <code>x</code>?"

  lst$DC_CODE <- "print(123)"
  output <- test_it(lst)
  fails(output, mess_patt = mess_patt1)
  fails(output, "It is a number, while it should be a character string")

  lst$DC_CODE <- "print(c('this is', 'a serious thing'))"
  output <- test_it(lst)
  fails(output, mess_patt = mess_patt1)
  fails(output, "It has length 2, while it should have length 1")

  lst$DC_CODE <- "print('this is a serious thing!')"
  output <- test_it(lst)
  fails(output, mess_patt = mess_patt1)
  fails(output, "Note that R is case-sensitive")

  lst$DC_CODE <- "print('This is a serious thingyyy!')"
  output <- test_it(lst)
  fails(output, mess_patt = mess_patt1)
  fails(output, "There might be a typo in there")
})

test_that("test_function - diff messages - 3", {
  lst <- list()
  lst$DC_SOLUTION <- "print(123)"
  lst$DC_SCT <- "test_function('print', args = 'x', index = 1)"
  mess_patt1 <- "Check your call of <code>print\\(\\)</code>\\. Did you correctly specify the argument <code>x</code>?"

  lst$DC_CODE <- "print(c(T, F))"
  output <- test_it(lst)
  fails(output, mess_patt = mess_patt1)
  fails(output, "It is a logical vector, while it should be a number")

  lst$DC_CODE <- "print(c(123, 123))"
  output <- test_it(lst)
  fails(output, mess_patt = mess_patt1)
  fails(output, "It has length 2, while it should have length 1")

  lst$DC_CODE <- "print(c(a = 123))"
  output <- test_it(lst)
  passes(output)

  lst$DC_SCT <- "test_function('print', args = 'x', eq_condition = 'equal', index = 1)"
  lst$DC_CODE <- "print(c(a = 123))"
  output <- test_it(lst)
  fails(output, mess_patt = mess_patt1)
  fails(output, "Are you sure the attributes")
})

test_that("test_function - diff messages - try-errors", {
  lst <- list()
  lst$DC_SOLUTION <- "x <- 2; print(123 + x); x <- 'test'"
  lst$DC_SCT <- "test_function('print', args = 'x', index = 1)"
  lst$DC_CODE <- "print(123 + 'test')"
  expect_error(test_it(lst), regexp = "check_equal\\(\\) found an argument that causes an error when evaluated")

  lst <- list()
  lst$DC_SOLUTION <- "print(123)"
  lst$DC_SCT <- "test_function('print', args = 'x', index = 1)"
  lst$DC_CODE <- "print('test' + 123)"
  output <- test_it(lst)
  fails(output, mess_patt = "Check your call of <code>print\\(\\)</code>\\. Did you correctly specify the argument <code>x</code>?")
  fails(output, "Evaluating the expression you specified caused an error")
})

test_that("test_function - S3 functions", {
  lst <- list(
    DC_PEC = "set.seed(1)\nlibrary(rpart)\nfit <- rpart(Kyphosis ~ Age + Number + Start, method='class', data=kyphosis)",
    DC_CODE = "predict(object = fit, type = 'class', kyphosis)",
    DC_SOLUTION = "predict(object = fit, type = 'class', kyphosis)",
    DC_SCT = "test_function('predict', args = c('object', 'type'), index = 1)"
  )
  output <- test_it(lst)
  passes(output)

  lst <- list()
  lst$DC_SOLUTION <- "mean(c(1:10, NA), 0.1, TRUE)"
  lst$DC_CODE <- lst$DC_SOLUTION
  lst$DC_SCT <- "test_function('mean', args = c('x', 'trim', 'na.rm'))"
  output <- test_it(lst)
  passes(output)

  lst <- list()
  lst$DC_PEC <- "x <- seq(0, 2*pi, 0.01); y <- sin(x)"
  lst$DC_SOLUTION <- "plot(y ~ x, main = 'test', lwd = 4)"
  lst$DC_CODE <- lst$DC_SOLUTION
  lst$DC_SCT <- "test_function('plot', args = c('formula', 'main', 'lwd'))"
  output <- test_it(lst)
  passes(output)

  lst <- list()
  lst$DC_SOLUTION <- "plot(wt ~ mpg, data = mtcars)"
  lst$DC_CODE <- lst$DC_SOLUTION
  lst$DC_SCT <- "test_function('plot', args = c('formula', 'data'))"
  output <- test_it(lst)
  passes(output)
})

test_that("test_function - piped operators", {
  lst <- list()
  lst$DC_PEC <- "library(dplyr)"
  lst$DC_SOLUTION <- "mtcars %>% summarise(avg = mean(hp))"
  lst$DC_SCT <- "test_function('summarise', args = '.data')"

  lst$DC_CODE <- "mtcars %>% summarise(avg = mean(hp))"
  output <- test_it(lst)
  passes(output)

  lst$DC_CODE <- "mtcars %>% summarize(avg = mean(hp))"
  output <- test_it(lst)
  passes(output)

  lst$DC_CODE <- "cars %>% summarize(avg = mean(speed))"
  output <- test_it(lst)
  fails(output)
  line_info(output, 1, 1)

  lst$DC_CODE <- "mtcars %>% select(hp)"
  output <- test_it(lst)
  fails(output)
})

test_that("test_function - formulas", {
  lst <- list()
  lst$DC_SOLUTION <- "lm(mpg ~ wt + hp, data = mtcars)"
  lst$DC_SCT <- "test_function('lm', args = 'formula')"

  lst$DC_CODE <- "lm(mpg ~ wt + hp, data = mtcars)"
  output <- test_it(lst)
  passes(output)

  lst$DC_CODE <- "lm(mpg ~ hp + wt, data = mtcars)"
  output <- test_it(lst)
  passes(output)

  lst$DC_CODE <- "lm(mpg ~ wt + hp + drat, data = mtcars)"
  output <- test_it(lst)
  fails(output)

  lst <- list()
  lst$DC_SOLUTION <- "lm(mpg ~ ., data = mtcars)"
  lst$DC_CODE <- "lm(mpg ~ ., data = mtcars)"
  lst$DC_SCT <- "test_function('lm', args = 'formula')"
  output <- test_it(lst)
  passes(output)
})

test_that("test_function - plot calls", {
  lst <- list()
  lst$DC_PEC <- "df <- data.frame(time = seq(0, 2*pi, 0.01)); df$res <- sin(df$time)"
  lst$DC_SOLUTION <- "plot(df$time, df$res)"
  lst$DC_SCT <- "test_or({
    fun <- ex() %>% check_function('plot')
    fun %>% check_arg('x') %>% check_equal()
    fun %>% check_arg('y') %>% check_equal()
  }, {
    fun <- ex() %>% override_solution('plot(res ~ time, data = df)') %>% check_function('plot')
    fun %>% check_arg('formula') %>% check_equal()
    fun %>% check_arg('data') %>% check_equal()
  }, {
    ex() %>% override_solution('plot(df$res ~ df$time)') %>% check_function('plot') %>% check_arg('formula') %>% check_equal()
  })"

  lst$DC_CODE <- "plot(df$time, df$res)"
  output <- test_it(lst)
  passes(output)

  lst$DC_CODE <- "plot(df[['time']], df[['res']])"
  output <- test_it(lst)
  passes(output)

  lst$DC_CODE <- "plot(res ~ time, data = df)"
  output <- test_it(lst)
  passes(output)

  lst$DC_CODE <- "plot(df$res ~ df$time)"
  output <- test_it(lst)
  passes(output)

  lst$DC_CODE <- "plot(df$res, df$time)"
  output <- test_it(lst)
  fails(output)

  lst$DC_CODE <- "plot(df$time ~ df$res)"
  output <- test_it(lst)
  fails(output)

  lst$DC_CODE <- "plot(time ~ res, data = df)"
  output <- test_it(lst)
  fails(output)
})

test_that("test_function - ...", {
  lst <- list()
  lst$DC_SOLUTION <- "sum(1, 2, 3, 4, NA, na.rm = TRUE)"
  lst$DC_SCT <- "test_function('sum', args = c('...', 'na.rm'))"

  lst$DC_CODE <- "sum(1, 2, 3, 4, NA, na.rm = TRUE)"
  output <- test_it(lst)
  passes(output)

  lst$DC_CODE <- "sum(1, 1 + 1, 1 + 1 + 1, 4, NA, na.rm = TRUE)"
  output <- test_it(lst)
  passes(output)

  lst$DC_CODE <- "sum(na.rm = TRUE, 1, 1 + 1, 1 + 1 + 1, 4, NA)"
  output <- test_it(lst)
  passes(output)

  lst$DC_CODE <- "sum(1, 2, 3, 4, NA, na.rm = FALSE)"
  output <- test_it(lst)
  fails(output, mess_patt = "Check your call of <code>sum\\(\\)</code>\\. Did you correctly specify the argument <code>na\\.rm</code>")

  lst$DC_CODE <- "sum(1, 2, 3, NA, na.rm = TRUE)"
  output <- test_it(lst)
  fails(output, mess_patt = "Did you correctly specify the arguments that are matched to <code>...</code>")

  lst$DC_CODE <- "sum(1, 2, 4, 3, NA, na.rm = TRUE)"
  output <- test_it(lst)
  fails(output, mess_patt = "Did you correctly specify the arguments that are matched to <code>...</code>")

  lst <- list()
  lst$DC_SOLUTION <- "sum(1, 2, 3, 4, 5)"
  lst$DC_SCT <- "test_function('sum', args = '...')"

  lst$DC_CODE <- "sum(1, 2, 3, 4, 5)"
  output <- test_it(lst)
  passes(output)

  lst$DC_CODE <- "sum(1, 2, 3, 4)"
  output <- test_it(lst)
  fails(output, mess_patt = "Did you correctly specify the arguments that are matched to <code>...</code>")
})

test_that("test_function works appropriately inside test_corect", {
  lst <- list()
  lst$DC_SOLUTION <- "summary(mtcars)\nsummary(pressure)"
  lst$DC_CODE <- "summary(mtcars)\nsummary(cars)"
  lst$DC_SCT <- paste("test_correct(test_output_contains('summary(mtcars)'), test_function('summary', args = 'object', index = 1))",
                      "test_correct(test_output_contains('summary(pressure)'), test_function('summary', args = 'object', index = 2))", sep = "\n")

  output <- test_it(lst)
  fails(output)
  line_info(output, 2, 2)
})

test_that("check_arg allows for further zooming in", {
  code <- "ggplot(ChickWeight, aes(x = Time, y = weight)) + geom_line(aes(group = Chick))"
  lst <- list(
    DC_PEC = "library(ggplot2)",
    DC_SOLUTION = code,
    DC_CODE = code,
    DC_SCT = 'ex() %>% check_function("geom_line") %>% check_arg("mapping") %>% check_function("aes") %>% check_arg("group") %>% check_equal(eval = FALSE)'
  )
  output <- test_it(lst)
  passes(output)
})


# Nested function calls ---------------------------------------------------

test_that("check_function() works on nested function calls", {
  code <- "mean(rnorm(100, 10))"
  s <- setup_state(stu_code = code, sol_code = code) 
  passes2(
    s %>% 
      check_function("mean") %>% 
      check_arg("x") %>% 
      check_function("rnorm") %>% {
        check_arg(., "n") %>% check_equal()
        check_arg(., "mean") %>% check_equal()
      }
  )
})

test_that("check_function works with more deeply nested code", {
  code <- "cars %>% mutate(disty = factor(format(sqrt(dist + 1), digits = 5)))"
  s <- setup_state(stu_code = code, sol_code = code)
  passes2(
    s %>% 
      check_function("mutate") %>% 
      check_arg("disty") %>% 
      check_function("factor") %>%
      check_arg("x") %>% 
      check_function("format") %>% {
        check_arg(., "x") %>% 
          check_function("sqrt") %>%
          check_arg("x") %>% 
          check_equal(eval = FALSE)
        check_arg(., "digits") %>% 
          check_equal()
      }
  )
})

test_that("check_function works with more deeply nested code and qualifed function names", {
  code <- "cars %>% dplyr::mutate(disty = factor(format(sqrt(dist + 1), digits = 5)))"
  s <- setup_state(stu_code = code, sol_code = code) 
  passes2(
    s %>% 
      check_function("mutate") %>% 
      check_arg("disty") %>% 
      check_function("factor") %>%
      check_arg("x") %>% 
      check_function("format") %>% {
        check_arg(., "x") %>% 
          check_function("sqrt") %>%
          check_arg("x") %>% 
          check_equal(eval = FALSE)
        check_arg(., "digits") %>% 
          check_equal()
      }
  )
})

# Instructor errors -----------------------------------------------------------

test_that("check_function fails if called on the object state.", {
  code = "x = mean(1:3)"
  s <- setup_state(stu_code = code, sol_code = code)
  expect_error(s %>% check_object('x') %>% check_function('mean'),
               regexp = "`check_function()` should not be called on `check_object()`.",
               fixed = TRUE)
})

test_that("check_arg fails if not called on function state.", {
  code = "x = mean(1:3)"
  s <- setup_state(stu_code = code, sol_code = code)
  expect_error(s %>% check_object('x') %>% check_arg('x'),
               regexp = "`check_arg()` can only be called on `check_function()`.",
               fixed = TRUE)
})

test_that("check_function fails if not called on state.", {
  s <- setup_state("", "")
  expect_error(check_function('mean'),
               regexp = "The first argument to `check_function()` should be a state object. Maybe you forgot a dot?",
               fixed = TRUE)
})

test_that("check_arg works with positional arguments.", {
  code <- "cor(1:10, runif(10))"
  state <- setup_state(
    sol_code = code, stu_code = code
  )
  expect_error(
    state %>% 
      check_function("cor") %>% 
      check_arg(0)
  )
  passes2(
    state %>% 
      check_function("cor") %>% 
      check_arg(1)
  )
  passes2(
    state %>% 
      check_function("cor") %>% 
      check_arg(2)
  )
  expect_error(
    state %>% 
      check_function("cor") %>% 
      check_arg(3)
  )
})

test_that("check_arg works with positional arguments for dots.", {
  code <- "sum(1:5, 6:10)"
  state <- setup_state(
    sol_code = code, stu_code = code
  )
  expect_error(
    state %>% 
      check_function("sum") %>% 
      check_arg(0)
  )
  passes2(
    state %>% 
      check_function("sum") %>% 
      check_arg(1)
  )
  expect_error(
    state %>% 
      check_function("sum") %>% 
      check_arg(2)
  )
})
  
test_that("check_arg works with ... argument.", {
  code <- "sum(1:5, 6:10)"
  mistake <- "sum(1:5, 7:11)"
  state <- setup_state(
    sol_code = code, stu_code = mistake
  )
  expect_error(
    state %>% 
      check_function("sum") %>% 
      check_arg('...') %>% check_equal()
  )
  expect_error(
    state %>% 
      check_function("sum") %>% 
      check_arg(1) %>% check_equal()
  )
})

test_that("check_arg works with ..n arguments for dots.", {
  code <- "sum(1:5, 6:10)"
  state <- setup_state(
    sol_code = code, stu_code = code
  )
  passes2(
    state %>% 
      check_function("sum") %>% 
      check_arg("..1")
  )
  passes2(
    state %>% 
      check_function("sum") %>% 
      check_arg("..2")
  )
  expect_error(
    state %>% 
      check_function("sum") %>% 
      check_arg("..3")
  )
})
