#' Fit a generalized additive latent and mixed model
#'
#' This function fits a generalized additive latent and mixed model (GALAMMs),
#' as described in
#' \insertCite{sorensenLongitudinalModelingAgeDependent2023;textual}{galamm}.
#' The building blocks of these models are generalized additive mixed models
#' (GAMMs) \insertCite{woodGeneralizedAdditiveModels2017a}{galamm}, of which
#' generalized linear mixed models
#' \insertCite{breslowApproximateInferenceGeneralized1993,harvilleMaximumLikelihoodApproaches1977,hendersonBestLinearUnbiased1975,lairdRandomEffectsModelsLongitudinal1982}{galamm}
#' are special cases. GALAMMs extend upon GAMMs by allowing factor structures,
#' as commonly used to model hypothesized latent traits underlying observed
#' measurements. In this sense, GALAMMs are an extension of generalized linear
#' latent and mixed models (GLLAMMs)
#' \insertCite{skrondalGeneralizedLatentVariable2004,rabe-heskethGeneralizedMultilevelStructural2004}{galamm}
#' which allows semiparametric estimation. The implemented algorithm used to
#' compute model estimates is described in
#' \insertCite{sorensenLongitudinalModelingAgeDependent2023;textual}{galamm},
#' and is an extension of the algorithm used for fitting generalized linear
#' mixed models by the \code{lme4} package
#' \insertCite{batesFittingLinearMixedEffects2015}{galamm}. The syntax used to
#' define factor structures is based on that used by the \code{PLmixed} package,
#' which is detailed in
#' \insertCite{rockwoodEstimatingComplexMeasurement2019;textual}{galamm}.
#'
#' @param formula A formula specifying the model. Smooth terms are defined in
#'   the style of the \code{mgcv} and \code{gamm4} packages, see
#'   \insertCite{woodGeneralizedAdditiveModels2017a}{galamm} for an
#'   introduction. Random effects are specified using \code{lme4} syntax, which
#'   is described in detail in
#'   \insertCite{batesFittingLinearMixedEffects2015}{galamm}. Factor loadings
#'   will also be part of the model formula, and is based on the syntax of the
#'   \code{PLmixed} package
#'   \insertCite{rockwoodEstimatingComplexMeasurement2019}{galamm}.
#'
#' @param weights An optional formula object specifying an expression for the
#'   residual variance. Defaults to \code{NULL}, corresponding to homoscedastic
#'   errors. The formula is defined in \code{lme4} style; see vignettes and
#'   examples for details.
#'
#' @param data A data.frame containing all the variables specified by the model
#'   formula, with the exception of factor loadings.
#'
#' @param family A vector containing one or more model families. For each
#'   element in \code{family} there should be a corresponding element in
#'   \code{family_mapping} specifying which elements of the response are
#'   conditionally distributed according to the given family. Currently family
#'   can be one of \code{gaussian}, \code{binomial}, and \code{poisson}, and
#'   only canonical link functions are supported.
#'
#' @param family_mapping Optional integer vector mapping from the elements of
#'   \code{family} to rows of \code{data}. Defaults to \code{rep(1L,
#'   nrow(data))}, which means that all observations are distributed according
#'   to the first element of \code{family}.
#'
#' @param load.var Optional character specifying the name of the variable in
#'   \code{data} identifying what the factors load onto. That is, each unique
#'   value of \code{load.var} corresponds to a unique factor loading. Currently
#'   only a single loading is supported, so \code{load.var} must have length
#'   one. Default to \code{NULL}, which means that there are no loading
#'   variables.
#'
#' @param lambda Optional list of factor loading matrices. Numerical values
#'   indicate that the given value is fixed, while \code{NA} means that the
#'   entry is a parameter to be estimated. Defaults to \code{NULL}, which means
#'   that there are no factor loading matrices.
#'
#' @param factor Optional list of character vectors identical to the factor
#'   loadings specified in \code{formula}. For each list element, the \eqn{j}th
#'   entry in the character vector corresponds to the \eqn{j}th column of the
#'   corresponding matrix in \code{lambda}. Defaults to \code{NULL}, which means
#'   that there are no factor loadings.
#'
#' @param factor_interactions Optional list of length equal to the list provided
#'   in the \code{factor} argument. If provided, each element of the lists
#'   should itself be a list of length equal to the number of columns in the
#'   corresponding matrix provided to the \code{lambda} argument. Each list
#'   element should be a \code{formula} object containing the write-hand side of
#'   a regression model, of the form \code{~ x + z}. Defaults to \code{NULL},
#'   which means that no factor interactions are used.
#'
#' @param start Optional named list of starting values for parameters. Possible
#'   names of list elements are \code{"theta"}, \code{"beta"}, \code{"lambda"},
#'   and \code{"weights"}, all of should be numerical vectors with starting
#'   values. Default to \code{NULL}, which means that some relatively sensible
#'   defaults are used.
#'
#' @param control Optional control object for the optimization procedure of
#'   class \code{galamm_control} resulting from calling
#'   \code{\link{galamm_control}}. Defaults to \code{NULL}, which means that the
#'   defaults of \code{\link{galamm_control}} are used.
#'
#' @return A model object of class \code{galamm}, containing the following
#'   elements:
#' * \code{call} the matched call used when fitting the model.
#' * \code{random_effects} a list containing the following two elements:
#'   * \code{b} random effects in original parametrization.
#'   * \code{u} random effects standardized to have identity covariance matrix.
#' * \code{model} a list with various elements related to the model setup and
#'   fit:
#'   * \code{deviance} deviance of final model.
#'   * \code{deviance_residuals} deviance residuals of the final model.
#'   * \code{df} degrees of freedom of model.
#'   * \code{family} a list of one or more family objects, as specified in the
#'   \code{family} arguments to \code{galamm}.
#'   * \code{factor_interactions} List of formulas specifying interactions
#'   between latent and observed variables, as provided to the argument
#'   \code{factor_interactions} to \code{galamm}. If not provided, it is
#'   \code{NULL}.
#'   * \code{fit} a numeric vector with fitted values.
#'   * \code{fit_population} a numeric vector with fitted values excluding
#'   random effects.
#'   * \code{hessian} Hessian matrix of final model, i.e., the second
#'   derivative of the log-likelihood with respect to all model parameters.
#'   * \code{lmod} Linear model object returned by \code{lme4::lFormula}, which
#'   is used internally for setting up the models.
#'   * \code{loglik} Log-likelihood of final model.
#'   * \code{n} Number of observations.
#'   * \code{pearson_residual} Pearson residuals of final model.
#'   * \code{reduced_hessian} Logical specifying whether the full Hessian
#'   matrix was computed, or a Hessian matrix with derivatives only with respect
#'   to beta and lambda.
#'   * \code{response} A numeric vector containing the response values used when
#'   fitting the model.
#'   * \code{weights_object} Object with weights used in model fitting. Is
#'   \code{NULL} when no weights were used.
#' * \code{parameters} A list object with model parameters and related
#'   information:
#'   * \code{beta_inds} Integer vector specifying the indices of fixed
#'   regression coefficients among the estimated model parameters.
#'   * \code{dispersion_parameter} One or more dispersion parameters of the
#'   final model.
#'   * \code{lambda_dummy} Dummy matrix of factor loadings, which shows the
#'   structure of the loading matrix that was supplied in the \code{lambda}
#'   arguments.
#'   * \code{lambda_inds} Integer vector specifying the indices of factor
#'   loadings among the estimated model parameters.
#'   * \code{lambda_interaction_inds} Integer vector specifying the indices
#'   of regression coefficients for interactions between latent and observed
#'   variables.
#'   * \code{parameter_estimates} Numeric vector of final parameter estimates.
#'   * \code{parameter_names} Names of all parameters estimates.
#'   * \code{theta_inds} Integer vector specifying the indices of variance
#'   components among the estimated model parameters. Technically these are the
#'   entries of the Cholesky decomposition of the covariance matrix.
#'   * \code{weights_inds} Integer vector specifying the indices of estimated
#'   weights (used in heteroscedastic Gaussian models) among the estimated model
#'   parameters.
#'  * \code{gam} List containing information about smooth terms in the model.
#'   If no smooth terms are contained in the model, then it is a list of length
#'   zero.
#'
#' @export
#'
#' @references \insertAllCited{}
#'
#' @examples
#' # Mixed response model ------------------------------------------------------
#'
#' # The mresp dataset contains a mix of binomial and Gaussian responses.
#'
#' # We need to estimate a factor loading which scales the two response types.
#' loading_matrix <- matrix(c(1, NA), ncol = 1)
#'
#' # Define mapping to families.
#' families <- c(gaussian, binomial)
#' family_mapping <- ifelse(mresp$itemgroup == "a", 1, 2)
#'
#'
#' # Fit the model
#' mod <- galamm(
#'   formula = y ~ x + (0 + level | id),
#'   data = mresp,
#'   family = families,
#'   family_mapping = family_mapping,
#'   factor = list("level"),
#'   load.var = "itemgroup",
#'   lambda = list(loading_matrix)
#' )
#'
#' # Summary information
#' summary(mod)
#'
#'
#' # Heteroscedastic model -----------------------------------------------------
#' # Residuals allowed to differ according to the item variable
#' # We also set the initial value of the random intercept standard deviation
#' # to 1
#' mod <- galamm(
#'   formula = y ~ x + (1 | id), weights = ~ (1 | item),
#'   data = hsced, start = list(theta = 1)
#' )
#' summary(mod)
#'
#' # Generalized additive mixed model with factor structures -------------------
#'
#' # The cognition dataset contains simulated measurements of three latent
#' # time-dependent processes, corresponding to individuals' abilities in
#' # cognitive domains. We focus here on the first domain, and take a single
#' # random timepoint per person:
#' dat <- subset(cognition, domain == 1)
#' dat <- split(dat, f = dat$id)
#' dat <- lapply(dat, function(x) x[x$timepoint %in% sample(x$timepoint, 1), ])
#' dat <- do.call(rbind, dat)
#' dat$item <- factor(dat$item)
#'
#' # At each timepoint there are three items measuring ability in the cognitive
#' # domain. We fix the factor loading for the first measurement to one, and
#' # estimate the remaining two. This is specified in the loading matrix.
#' loading_matrix <- matrix(c(1, NA, NA), ncol = 1)
#'
#' # We can now estimate the model.
#' mod <- galamm(
#'   formula = y ~ 0 + item + sl(x, factor = "loading") +
#'     (0 + loading | id),
#'   data = dat,
#'   load.var = "item",
#'   lambda = list(loading_matrix),
#'   factor = list("loading")
#' )
#'
#' # We can plot the estimated smooth term
#' plot_smooth(mod, shade = TRUE)
#'
#'
#' # Interaction between observed and latent covariates ------------------------
#' # Define the loading matrix
#' lambda <- list(matrix(c(1, NA, NA), ncol = 1))
#'
#' # Define the regression functions, one for each row in the loading matrix
#' factor_interactions <- list(list(~1, ~1, ~x))
#'
#' # Fit the model
#' mod <- galamm(
#'   formula = y ~ type + x:response + (0 + loading | id),
#'   data = latent_covariates,
#'   load.var = "type",
#'   lambda = lambda,
#'   factor = list("loading"),
#'   factor_interactions = factor_interactions
#' )
#'
#' # The summary output now include an interaction between the latent variable
#' # and x, for predicting the third element in "type"
#' summary(mod)
#'
#' @family modeling functions
#'
#' @md
galamm <- function(formula, weights = NULL, data, family = gaussian,
                   family_mapping = rep(1L, nrow(data)),
                   load.var = NULL, lambda = NULL, factor = NULL,
                   factor_interactions = NULL,
                   start = NULL, control = galamm_control()) {
  data <- stats::na.omit(data)
  if (nrow(data) == 0) stop("No data, nothing to do.")
  data <- as.data.frame(data)
  mc <- match.call()

  family_list <- setup_family(family)
  if (!is.vector(family_mapping)) {
    stop("family_mapping must be a vector.")
  }
  if (is.numeric(family_mapping)) {
    family_mapping <- as.integer(family_mapping)
  }

  stopifnot(length(family_list) == length(unique(family_mapping)))

  tmp <- setup_factor(load.var, lambda, factor, data)
  data <- tmp$data
  lambda_orig <- tmp$lambda
  rm(tmp)

  rf <- lme4::findbars(formula)
  rf <- if (!is.null(rf)) {
    stats::as.formula(paste("~", paste("(", rf, ")", collapse = "+")))
  }
  gobj <- gamm4(fixed = lme4::nobars(formula), random = rf, data = data)
  colnames(gobj$lmod$X) <- gsub("^X", "", colnames(gobj$lmod$X))

  response_obj <-
    setup_response_object(family_list, family_mapping, data, gobj)
  lambda_mappings <- define_factor_mappings(
    gobj, load.var, lambda_orig, factor, factor_interactions, data
  )

  lambda <- lambda_mappings$lambda

  theta_mapping <- gobj$lmod$reTrms$Lind - 1L
  theta_inds <- seq_along(gobj$lmod$reTrms$theta)
  beta_inds <- max(theta_inds) + seq_along(colnames(gobj$lmod$X))
  lambda_inds <- max(beta_inds) + seq_along(lambda[[1]][lambda[[1]] >= 2])

  if (!is.null(weights)) {
    weights_obj <- lme4::mkReTrms(lme4::findbars(weights), fr = data)
    if (length(weights_obj$flist) > 1) {
      stop("Multiple grouping terms in weights not yet implemented.")
    }
    delta <- diff(weights_obj$Zt@p)
    weights_mapping <- as.integer(weights_obj$flist[[1]]) - 2L
    weights_mapping[delta == 0] <- -1L
    weights_inds <- length(unique(weights_mapping)) +
      max(c(theta_inds, beta_inds, lambda_inds)) - 1L
  } else {
    weights_obj <- NULL
    weights_mapping <- integer()
    weights_inds <- integer()
  }

  bounds <- c(
    gobj$lmod$reTrms$lower,
    rep(-Inf, length(beta_inds) + length(lambda_inds)),
    rep(0, length(weights_inds))
  )

  y <- response_obj[, 1]
  trials <- response_obj[, 2]
  u_init <- rep(0, nrow(gobj$lmod$reTrms$Zt))
  family_txt <- vapply(family_list, function(f) f$family, "a")
  k <- find_k(family_txt, family_mapping, y, trials)

  maxit_conditional_modes <- ifelse(
    length(family_list) == 1 & family_list[[1]]$family == "gaussian",
    1, control$maxit_conditional_modes
  )

  mlwrapper <- function(par, gradient = FALSE, hessian = FALSE) {
    marginal_likelihood(
      y = y,
      trials = trials,
      X = gobj$lmod$X,
      Zt = gobj$lmod$reTrms$Zt,
      Lambdat = gobj$lmod$reTrms$Lambdat,
      beta = par[beta_inds],
      theta = par[theta_inds],
      theta_mapping = theta_mapping,
      u_init = u_init,
      lambda = par[lambda_inds],
      lambda_mapping_X = lambda_mappings$lambda_mapping_X,
      lambda_mapping_Zt = lambda_mappings$lambda_mapping_Zt,
      lambda_mapping_Zt_covs = lambda_mappings$lambda_mapping_Zt_covs,
      weights = par[weights_inds],
      weights_mapping = weights_mapping,
      family = family_txt,
      family_mapping = family_mapping - 1L,
      k = k,
      maxit_conditional_modes = maxit_conditional_modes,
      lossvalue_tol = control$pwirls_tol_abs,
      gradient = gradient,
      hessian = hessian,
      reduced_hessian = control$reduced_hessian
    )
  }

  mlmem <- memoise::memoise(mlwrapper)
  fn <- function(par, gradient, hessian = FALSE) {
    mlmem(par, gradient, hessian)$logLik
  }
  gr <- function(par, gradient, hessian = FALSE) {
    mlmem(par, gradient, hessian)$gradient
  }

  par_init <-
    set_initial_values(gobj, start, beta_inds, lambda_inds, weights_inds)

  if (control$method == "L-BFGS-B") {
    opt <- stats::optim(par_init,
      fn = fn, gr = gr, gradient = TRUE,
      method = "L-BFGS-B", lower = bounds,
      control = control$optim_control
    )
  } else {
    opt <- lme4::Nelder_Mead(
      fn = function(x) -fn(x, gradient = FALSE), par = par_init,
      lower = bounds, control = control$optim_control
    )
    opt$value <- -opt$fval
  }

  final_model <- mlwrapper(opt$par, gradient = TRUE, hessian = TRUE)

  # Update Cholesky factor of covariance matrix
  gobj$lmod$reTrms$Lambdat@x <- opt$par[theta_inds][gobj$lmod$reTrms$Lind]
  # Update Zt to include factor loadings (if there are factor loadings)
  if (length(lambda_inds) > 1) {
    pars <- c(1, opt$par[lambda_inds])

    if (is.null(factor_interactions)) {
      # Must take into account the possible existence of zero
      inds <- lambda_mappings$lambda_mapping_Zt + 2L
      gobj$lmod$reTrms$Zt@x[inds == 0] <- 0
      gobj$lmod$reTrms$Zt@x[inds != 0] <- pars[inds]
    } else {
      gobj$lmod$reTrms$Zt@x <-
        as.numeric(Map(function(l, x) sum(pars[l + 2L] * x),
          l = lambda_mappings$lambda_mapping_Zt,
          x = lambda_mappings$lambda_mapping_Zt_covs
        ))
    }
  }

  # Random effects in original parametrization
  b <- Matrix::t(gobj$lmod$reTrms$Lambdat) %*% final_model$u

  # Compute prediction including random effects
  linear_predictor_fixed <- as.numeric(gobj$lmod$X %*% opt$par[beta_inds])
  linear_predictor_random <- as.numeric(Matrix::t(gobj$lmod$reTrms$Zt) %*% b)

  extractor <- function(i, inc_random = TRUE) {
    family_list[[family_mapping[[i]]]]$linkinv(
      linear_predictor_fixed[[i]] +
        ifelse(inc_random, linear_predictor_random[[i]], 0)
    )
  }

  fit <- vapply(seq_along(family_mapping), extractor, numeric(1))
  fit_population <- vapply(seq_along(family_mapping), extractor,
    numeric(1),
    inc_random = FALSE
  )

  pearson_residuals <- (response_obj[, 1] - fit) /
    unlist(Map(function(x, y) sqrt(family_list[[x]]$variance(y)),
      x = family_mapping, y = fit
    ))

  if (length(family_list) == 1 && family_list[[1]]$family == "gaussian") {
    deviance_residuals <- response_obj[, 1] - fit
    deviance <- -2 * opt$value
  } else {
    # McCullagh and Nelder (1989), page 39
    tmp <- lapply(
      family_list,
      function(x) {
        x$dev.resids(
          response_obj[, 1] / response_obj[, 2],
          fit, response_obj[, 2]
        )
      }
    )
    dev_res <- sqrt(vapply(
      seq_along(family_mapping),
      function(i) tmp[[family_mapping[[i]]]][[i]], 1
    ))

    deviance_residuals <- sign(response_obj[, 1] - fit) * dev_res
    deviance <- sum((dev_res)^2)
  }

  ret <- list()

  ret$call <- mc
  ret$random_effects <- list(
    b = as.numeric(b),
    u = as.numeric(final_model$u)
  )
  ret$model <- list(
    deviance = deviance,
    deviance_residuals = deviance_residuals,
    df = length(opt$par) +
      sum(vapply(
        family_list,
        function(x) !x$family %in% c("binomial", "poisson"),
        logical(1)
      )),
    family = family_list,
    factor_interactions = factor_interactions,
    fit = fit,
    fit_population = fit_population,
    hessian = final_model$hessian,
    lmod = gobj$lmod,
    loglik = opt$value,
    n = nrow(gobj$lmod$X),
    pearson_residuals = pearson_residuals,
    reduced_hessian = control$reduced_hessian,
    response = response_obj[, 1],
    weights_obj = weights_obj
  )

  # Distinguish lambda indicies from regression coefficients in interactions
  # between observed and latent covariates
  if (length(lambda_inds) > 0) {
    lambda_standard_inds <- intersect(lambda[[1]], lambda_orig[[1]]) - 1L
    lambda_standard_inds <- lambda_standard_inds[lambda_standard_inds > 0] +
      min(lambda_inds) - 1

    lambda_interaction_inds <- setdiff(lambda[[1]], lambda_orig[[1]]) - 1L
    lambda_interaction_inds <-
      lambda_interaction_inds[lambda_interaction_inds > 0] +
      min(lambda_inds) - 1
  } else {
    lambda_interaction_inds <- lambda_standard_inds <- lambda_inds
  }

  ret$parameters <- list(
    beta_inds = beta_inds,
    dispersion_parameter = final_model$phi,
    lambda_dummy = lambda_orig,
    lambda_inds = lambda_standard_inds,
    lambda_interaction_inds = lambda_interaction_inds,
    parameter_estimates = opt$par,
    parameter_names = c(
      paste0("theta", seq_along(theta_inds), recycle0 = TRUE),
      colnames(gobj$lmod$X),
      paste0("lambda", seq_along(lambda_standard_inds), recycle0 = TRUE),
      paste0("lambda_interaction",
        seq_along(lambda_interaction_inds),
        recycle0 = TRUE
      ),
      paste0("weights", seq_along(weights_inds), recycle0 = TRUE)
    ),
    theta_inds = theta_inds,
    weights_inds = weights_inds
  )

  class(ret) <- "galamm"

  ret$gam <- gamm4.wrapup(gobj, ret, final_model)

  ret
}
