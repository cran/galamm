# Generated by using Rcpp::compileAttributes() -> do not edit by hand
# Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

marginal_likelihood <- function(y, trials, X, Zt, Lambdat, beta, theta, theta_mapping, u_init, lambda, lambda_mapping_X, lambda_mapping_Zt, lambda_mapping_Zt_covs, weights, weights_mapping, family, family_mapping, k, maxit_conditional_modes, lossvalue_tol, gradient, hessian, reduced_hessian = FALSE) {
    .Call(`_galamm_marginal_likelihood`, y, trials, X, Zt, Lambdat, beta, theta, theta_mapping, u_init, lambda, lambda_mapping_X, lambda_mapping_Zt, lambda_mapping_Zt_covs, weights, weights_mapping, family, family_mapping, k, maxit_conditional_modes, lossvalue_tol, gradient, hessian, reduced_hessian)
}

