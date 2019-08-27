# Predicting Housing Prices in Ames, Iowa

### Objective:
Building a linear regression model to predict housing prices in Ames, Iowa.

### Set up/ Initial Analysis:
Before beginning any analysis, I imputed my data’s missing NA values with the mice package.
Next, I investigated the categorical variables and their relationship with Sale Price. I did exploratory analysis using box plots for categorical variables. If there is high variation between the factors, this variable is considered a very influential (ideal) categorical variable. I recreated this plot with multiple other categorical variables and extracted the ones who displayed similarly ideal trends.

### Feature Engineering
In order to have higher R2, I did some research and looked up the popular factors that determine a house’s sale price. I created the resulting exra predictors: Remodeled (whether the house has ever been remodeled), NumFloors (the number of floors the house has), YearsAgoRemod (how many years it’s been since remodeled), GarageAge (age of the garage), and Porch (sum of all the assorted Porch variables together). After, I made sure to also recreate these variables in the testing data set.

### Linear Regression Modelling & Assumptions
I ran various multiple linear regression models, however diagnostic plots initially did not look ideal. After performing transformations, the diagnostic plots look much better, and there are no violations. I investigated the VIF scores as well, and they were all valid, under 5. However, I was still unhappy with the excessive number of predictors (40).

### Model Tweaking
To reduce my number of predictors, I conducted a backwards AIC test, using the step function. This, along with some further variable elimination, reduced my model down to 28 predictors. I reduced some of the categorical variables using the partial f test, using the anova(reduced, full) function. My model ended up having an R2 of .9454 with valid plots and valid VIF scores.

To further increase my R2, I performed a few transformations on variables that I inferred would be more influential on sale price with heavier weights. For example, I squared the # of cars that could fit in a garage because it’s very important in determining prices. These transformations increased my R2 to .9529 with valid plots and valid VIFs.

### Results
To finish off, I ran predictions on the testing data (after it was imputed) using the predict() function. My final R2 in Kaggle for the public leaderboard ended up being 0.90079.

### Conclusion
If I had more time for improvements, I would definitely work on reducing the number of predictors that I ended up having. Although I had 28 variables in my model, I had 111 Betas in my model because of the categorical variables with multiple factors. Specifically, I would figure out a way to reduce the Neighborhood variable to include fewer levels, as there are currently 24. The excessive number of predictors could be the cause of my model’s overfitting, and a simpler model is always better!

My final diagnostic plots ended up looking very good, however there was still a minor violation in the QQ plot, as the ends of my plot strayed off from the normal distribution. I would definitely spend more time improving this violation by performing powerTransform or boxCox. Similarly, there is a slight upwards trend at the end of my Scale-Location plot, which I would also spend more time fixing. Even with these slight mishaps, overall, my model is valid, including without the issue of multicollinearity.
