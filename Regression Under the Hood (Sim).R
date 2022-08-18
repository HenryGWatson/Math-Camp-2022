# R Workshop Week 7: Regression under the Hood

# Simulate Data

  data <- data.frame(x = rep(NA,100), y = rep(NA, 100), e = rep(NA, 100))
  data$x <- rnorm(100, mean = 0, sd = 5)
  
  b0 <- 0
  b1 <- 1
  data$e = rnorm(100, mean = 0, sd = 5)
  
  data$y <- b0 + b1*data$x + data$e
  
  lm <- lm(y ~ x, data = data)
  summary(lm)
  plot(data$x, data$y)

# What is the formula for a beta coefficient?

    #Summation of "demeaned" X times "demeaned" Y
    #divided by Summation of "demeaned" X squared
  
  #Take the mean of the independent variable and subtract from the actual values
  x_mean <- mean(data$x)
  data$x_demean <- data$x - x_mean
  
  #Take the mean of the dependent variable and subtract from the actual values
  y_mean <- mean(data$y)
  data$y_demean <- data$y - y_mean
  
  #Multiply the demeaned X and Y
  data$xtimesy <- data$x_demean * data$y_demean
  
  #Take the sum across all observations
  numerator <- sum(data$xtimesy)
  
  #Square the demeaned X and sum across all observations
  data$x_demeansq <- data$x_demean^2
  denominator <- sum(data$x_demeansq)
  
  #Divide Summation of "demeaned" X times "demeaned" Y by 
    #Summation of "demeaned" X squared
  beta <- numerator / denominator
  beta
  lm
  
  abline(lm, col = "red")
  
  #Numerator is very similar to covariance of X and Y
  numerator / (nrow(data) - 1)
  cov(data$x,data$y)
  
  #Denominator is very similar to variance (standard deviation squared) of X
  denominator / (nrow(data) - 1)
  var(data$x)

#You can also calculate the intercept
  #Intercept = mean of Y minus beta coefficient times mean of X
  alpha <- mean(data$y) - beta*mean(data$x)
  alpha
  lm
  
#Calculating our errors manually
  #Calculate predicted values of Y using Y = alpha + beta*X
  data$y_pred <- alpha + (data$x * beta)
  #Error is the difference between the predicted and actual Y values
  data$error <- data$y - data$y_pred 
  
  plot(error ~ y_pred, data = data) 
  abline(h = 0)
  
  plot(fitted(lm), resid(lm))
  abline(h = 0)
    
  #When do we have larger values of beta?
    #When the numerator is large (positive or negative) and the denominator is small
  
  #When is the numerator large?
    #When X and Y are both signed the same, X times Y is positive
    #When X and Y are signed differently, X times Y is negative
    #If X and Y have no relationship, you will have a lot of positive *and* negative values, 
      # so the sum will be close to 0
    hist(data$xtimesy)
  
  #When is the denominator small?
    #When there is less variance in X
    hist(data$x)
  
#Calculating R-squared manually
    #The Residual Sum of Squares (RSS) is the sum of squared errors
    #Want this to be as small as possible
    plot(y ~ x, data = data,
         ylim = c(-25,20))
    abline(lm, col = "red")
    abline(h = mean(data$y), col = "blue")
    segments(data$x, data$y,
             data$x, data$y_pred,
             col = "green")
    
    #The Total Sum of Squares (TSS) is the sum of squared differences between
      #actual Y values and the mean of Y
    plot(y ~ x, data = data,
         ylim = c(-25,20))
    abline(lm, col = "red")
    abline(h = mean(data$y), col = "blue")
    segments(data$x, data$y,
             data$x, y_mean,
             col = "gold")
    
    #Recall that the difference between observed and modeled is the error
      #Square as a way of taking absolute values
      rss <- sum(data$error^2)
    #Recall that the difference between observed and mean is de-meaned
      #Square as a way of taking absolute values
      tss <- sum(data$y_demean^2)
    rsquared <- 1 - (rss / tss)
    rsquared
    summary(lm)
 
#Calculating Standard Errors manually
    #First we take the variance of the error term
    #We'll compute this manually (rather than using the var command) because we need to adjust for degrees of freedom
    
    var_error <- rss / (nobs(lm) - 2)
    
    #We divide by the number of observations (-1) times the variance of our X variable
    
    n <- nobs(lm) - 1
    var_x <- var(data$x)
    
        #Note: this is equivalent to the sum of squared differences between X and X-bar which we calculated earlier
        sum(data$x_demeansq)
        n * var_x
    
    #Then simply divide, and take the square root to get the standard error
    
    var_beta <- var_error / (n * var_x)
    se_beta <- sqrt(var_beta)
    se_beta
    
    #Compare to the model output
    
    summary(lm)
    
        #Note: The formula includes a term for 1 minus the correlation with other independent variables
        #This only applies when doing multivariate regression

    #Let's plot to see what this standard error means (for bivariate regression at least)
        
        #ggplot is the easiest way to visualize this, but requires installing a package
          install.packages("ggplot2")
          library(ggplot2)
          
          ggplot(data = data, aes(x = x, y = y)) + 
            geom_point() + 
            geom_smooth(method = "lm", se = TRUE)
        
        #We can also *sort of* do this by hand
        #We draw new lines, adjusting alpha and beta
          out <- summary(lm)
          
          plot(y ~ x, data = data,
               ylim = c(-25,20))
          abline(lm, col = "blue")
          abline(a = alpha + (1.96 * out$coefficients[1,2]),
                 b = beta - (1.96 * se_beta),
                 col = "black")
          abline(a = alpha - (1.96 * out$coefficients[1,2]),
                 b = beta + (1.96 * se_beta),
                 col = "black")
        #This is oversimplified, but hopefully it gives some idea of how the interval is constructed
    
    #From here, we can get the t-value and p-value also
    
    tvalue <- beta / se_beta
    tvalue
    
    #For the p-value, we use number of observations - 2.
    #Minus 2 because we have two variables: an intercept and the one independent variable
    #We see what the probability of observing a more extreme value than that t-value would be using pt()
    #The value is multiplied by 2 because we are doing a two-sided test
    pvalue <- 2 * pt(tvalue, nobs(lm) - 2, lower.tail = FALSE)
    pvalue
    