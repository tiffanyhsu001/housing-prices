# imputing data filling in missing NA values

 training = read.csv("HTrainW19Final.csv", header=TRUE)
 imputedTraining = mice(training, nnet.MaxNWts = 4000)
 CompleteTraining = complete(imputedTraining)
 write.csv(CompleteTraining, "filledTrainData.csv", row.names=FALSE)

 testing = read.csv("HTestW19Final.csv", header=TRUE)
 imputedTesting = mice(testing, nnet.MaxNWts = 4000)
 CompleteTesting = complete(imputedTesting)
 write.csv(CompleteTesting, "completeTesting.csv", row.names=FALSE)

library(car)
filledTraining = read.csv("filledTrainData.csv", header = TRUE)
completetesting = read.csv("completeTesting.csv", header=TRUE)

trained1 = filledTraining[-c(1159,1308,2308),] #removing some bad lev pts
trained2 = trained1[trained1$Ob != 2438 & trained1$Ob != 529 & trained1$Ob != 2441,]


# making new predictors
Remodeled = rep(NA, nrow(trained2)) #whether the house has been remodeled
for(i in 1:nrow(trained2)){
  if(trained2$YearRemodAdd[i] > trained2$YearBuilt[i]){
    Remodeled[i] = "Yes"
  }else{
    Remodeled[i] = "No"
  }
}

trained2$Remodeled = as.factor(Remodeled)

Age = rep(NA, nrow(trained2)) #age of the house (present year - year built)
for(i in 1:nrow(trained2)){
  Age[i] = trained2$YrSold[i] - trained2$YearBuilt[i]
}
trained2$Age = Age


NumFloors = rep(NA, nrow(trained2)) #number of floors in house
for(i in 1:nrow(trained2)){
  if(trained2$X2ndFlrSF[i] == 0){
    NumFloors[i] = 1
  }else{
    NumFloors[i] = 2
  }
}
trained2$NumFloors = NumFloors 


YearsAgoRemod = rep(NA, nrow(trained2)) #years since remodeled
for(i in 1:nrow(trained2)){
  YearsAgoRemod[i] = trained2$YrSold[i] - trained2$YearRemodAdd[i]
}
trained2$YearsAgoRemod = YearsAgoRemod

GarageAge = rep(NA, nrow(trained2)) 
for(i in 1:nrow(trained2)){
  GarageAge[i] = trained2$GarageYrBlt[i] - trained2$YearBuilt[i]
}
trained2$GarageAge = GarageAge

Porch = rep(NA, nrow(trained2)) #PorchSF
for(i in 1:nrow(trained2)){
  Porch[i] = trained2$OpenPorchSF[i] + trained2$X3SsnPorch[i] + trained2$ScreenPorch[i] + trained2$EnclosedPorch[i]
}

trained2$Porch = Porch

BedrmBathRatio = rep(NA, nrow(trained2)) #PorchSF
for(i in 1:nrow(trained2)){
  if(trained2$BedroomAbvGr[i] != 0)
    BedrmBathRatio[i] = trained2$BedroomAbvGr[i]/(trained2$FullBath[i] + trained2$HalfBath[i])
  else if(trained2$BedroomAbvGr[i] == 0)
    BedrmBathRatio[i] = 0
}
trained2$BedrmBathRatio = BedrmBathRatio


#creating new pred in testing data
completetesting2 = completetesting
Age = rep(NA, nrow(completetesting2)) #age of the house (present year - year built)
for(i in 1:nrow(completetesting2)){
  if(completetesting2$YrSold[i] - completetesting2$YearBuilt[i] < 0){
    Age[i] = 0 
  }else{
    Age[i] = completetesting2$YrSold[i] - completetesting2$YearBuilt[i]
  }
}
completetesting2$Age = Age


YearsAgoRemod = rep(NA, nrow(completetesting2)) #years since remodeled
for(i in 1:nrow(completetesting2)){
  if(completetesting2$YrSold[i] - completetesting2$YearRemodAdd[i] < 0){
    YearsAgoRemod[i] = 0 
  }else{
    YearsAgoRemod[i] = completetesting2$YrSold[i] - completetesting2$YearRemodAdd[i]
  }
}
completetesting2$YearsAgoRemod = YearsAgoRemod

BedrmBathRatio = rep(NA, nrow(completetesting2)) 
for(i in 1:nrow(completetesting2)){
  if(completetesting2$BedroomAbvGr[i] != 0)
    BedrmBathRatio[i] = completetesting2$BedroomAbvGr[i]/(completetesting2$FullBath[i] + completetesting2$HalfBath[i])
  else if(completetesting2$BedroomAbvGr[i] == 0)
    BedrmBathRatio[i] = 0
}
completetesting2$BedrmBathRatio = BedrmBathRatio

NumFloors = rep(NA, nrow(completetesting2)) #number of floors in house
for(i in 1:nrow(completetesting2)){
  if(trained2$X2ndFlrSF[i] == 0){
    NumFloors[i] = 1
  }else{
    NumFloors[i] = 2
  }
}
completetesting2$NumFloors = NumFloors 


# Testing some models
m <- lm((SalePrice) ~ LotFrontage + OverallQual + OverallCond + YearsAgoRemod + MasVnrArea + Porch + BsmtFinSF1 + BsmtFinSF2  + X1stFlrSF + X2ndFlrSF + sqrt(NumFloors) + BsmtFullBath + (FullBath) + (HalfBath) + sqrt(BedroomAbvGr) + (KitchenAbvGr) + Fireplaces + GarageAge + GarageCars + MSZoning + Street + Alley + LandContour + LotConfig + LandSlope + Neighborhood + Condition1 + BldgType + HouseStyle + RoofStyle + RoofMatl + Exterior1st + Exterior2nd + MasVnrType + Foundation +  BsmtExposure + Heating + HeatingQC + CentralAir + Electrical + FireplaceQu + GarageType + GarageCond + PavedDrive + SaleType + SaleCondition + Remodeled + (Age), data = trained2)
inverseResponsePlot(m1) # transform y^0.75

#bad lev points
cook = cooks.distance(m)
cookN <- (rstudent(m)^2)/(8+1)*(hatvalues(m))/(1-hatvalues(m))

badlev = unique(which(cook> 4/(length(trained2$SalePrice)-(8+1))))

#removing bad lev pts
trained3 = trained2[ ! trained2$Ob %in% badlev, ]

#saving final training set

finalTrainingSet = write.csv(trained3, "finalTrainingSet.csv", row.names = F)

m1 <- lm((SalePrice)^0.75 ~ LotFrontage + OverallQual + OverallCond + YearsAgoRemod + MasVnrArea + Porch + BsmtFinSF1 + BsmtFinSF2  + X1stFlrSF + X2ndFlrSF + sqrt(NumFloors) + BsmtFullBath + (FullBath) + (HalfBath) + sqrt(BedroomAbvGr) + (KitchenAbvGr) + Fireplaces + GarageAge + GarageCars + MSZoning + Street + Alley + LandContour + LotConfig + LandSlope + Neighborhood + Condition1 + BldgType + HouseStyle + RoofStyle + RoofMatl + Exterior1st + Exterior2nd + MasVnrType + Foundation +  BsmtExposure + Heating + HeatingQC + CentralAir + Electrical + FireplaceQu + GarageType + GarageCond + PavedDrive + SaleType + SaleCondition + Remodeled + (Age), data = trained3)
summary(m1)
plot(m1)
vif(m1)

#too many predictors, run back AIC model
# 28 pred, also removed houseStyle, Porch, fireplaceQu, MSZoning
backAIC <- step(m1,direction="backward", data=trained3)
backAICm = lm((SalePrice)^0.75 ~ OverallQual + OverallCond + YearsAgoRemod + 
                MasVnrArea + BsmtFinSF1 + BsmtFinSF2 + X1stFlrSF + 
                X2ndFlrSF + sqrt(NumFloors) + BsmtFullBath + sqrt(BedroomAbvGr) + 
                KitchenAbvGr + Fireplaces + GarageCars + LotConfig + LandSlope + Neighborhood + Condition1 + 
                BldgType + Exterior1st + Exterior2nd + MasVnrType + Foundation + BsmtExposure + Heating + GarageType + SaleCondition + Age , data = trained3)
summary(backAICm) # R2 .9443 valid model vif .9454
plot(backAICm)
vif(backAICm)

# try some transformations
m2.1 = lm((SalePrice)^0.75 ~ I(OverallQual^2) + I(OverallCond^2) + YearsAgoRemod + 
            MasVnrArea + (BsmtFinSF1) + BsmtFinSF2 + X1stFlrSF + 
            I(X2ndFlrSF^2) + sqrt(NumFloors) + I(BsmtFullBath^2) + sqrt(BedroomAbvGr) + 
            I(KitchenAbvGr^2) + Fireplaces + I(GarageCars^2) + LotConfig + LandSlope + Neighborhood + Condition1 + 
            BldgType + Exterior1st + Exterior2nd + MasVnrType + Foundation + BsmtExposure + Heating + GarageType + SaleCondition + I(Age^.5) , data = trained3)
summary(m2.1) # .9529 valid model vif
plot(m2.1)
vif(m2.1)

predict2 = as.data.frame( (predict(m2.1, completetesting2))^(4/3) )
predict2$Ob = 1:1500
predict2 = predict2[,c(2,1)]
colnames(predict2) = c("Ob", "SalePrice")
write.csv(predict2,'newsub1.csv', row.names=FALSE)
summary(predict2$SalePrice)
# 0.90079 R2 with testing data
