
## Text as Data: Kyle Davis (Assignment 4)
## Classification
# ALT+O to collapse


# 1: DGP and Synthetic Data, classification and error-testing -----------------------------------------------

set.seed(12345)
library(ggplot2)
library(MASS)
library(caret)
library(readtext) #for text data
library(quanteda) #^
library(Rlab)
library(boot)     #runs inv.logit
library(e1071)    #helps run Nbayes train()


N     <- 1000
P     <- 20
mu    <- runif(P, -1,1)
Sigma <- rWishart(n=1, df=P, Sigma=diag(P))[,,1]
Sigma <- ifelse(row(Sigma) != col(Sigma), 0, Sigma) # deletes the off diagonal
# values to ensure independence.
X     <- mvrnorm(N, mu=mu, Sigma = Sigma)
p     <- rbern(P, 0.37)
beta  <- p*rnorm(P,1,0.9) + (1-p)*rnorm(P,0,0.3)
eta   <- X%*%beta
pi    <- inv.logit(eta)
Y     <- rbern(N, pi)
sum(Y) #half success
Y     <- as.factor(Y)
data.lab4 <- data.frame(X, Y)


# naiveBayes Check:
model <- naiveBayes(Y ~ ., data = data.lab4)
class(model) #These can have tendency to over-state results.
#Model Characteristics
summary(model)
#Conditional Probabilities and a-priori probabilities:
print(model)

preds <- predict(model, newdata = data.lab4)
error <- as.numeric(Y) - as.numeric(preds)

# Mean Aboslute Error
mean(abs(error))

qplot(Y, preds, alpha=I(0.25))+
  geom_jitter()+
  xlab( expression(paste("Naive Bayes Predicted ", hat(y))))+
  ylab( expression(paste("Actual ", y)))+
  theme_bw()+
  theme(axis.text=element_text(size=12),
        axis.title=element_text(size=14))




mod_enet <- train(Y~., method="glmnet",
                 tuneGrid=expand.grid(alpha=seq(0,1,0.1),
                                      lambda=seq(0,200,1)),
                 data=data.lab4,
                 preProcess=c("center"),
                 trControl=trainControl(method="cv",number=2, search="grid"))


yhat = predict(mod_enet)
qplot(Y, yhat, alpha=I(0.25))+
  geom_jitter()+
  xlab( expression(paste("Training ", hat(y))))+
  ylab( expression(paste("Elastic Net ", y)))+
  theme_bw()+
  theme(axis.text=element_text(size=12),
        axis.title=element_text(size=14))

enet_beta = coef(mod_enet$finalModel, mod_enet$bestTune$lambda)
qplot(beta, enet_beta[-1])+
  xlab( expression(paste("True " , beta)))+
  ylab( expression(paste("Elastic Net " , hat(beta))))+
  theme_bw()+
  theme(axis.text=element_text(size=12),
        axis.title=element_text(size=14))




N      <- 1000
P      <- 20
mu2    <- runif(P, 0.5, 1.5)
Sigma2 <- rWishart(n=1, df=P, Sigma=diag(P))[,,1]
Sigma2 <- ifelse(row(Sigma2) != col(Sigma2), 0, Sigma2)
X2     <- mvrnorm(N, mu=mu2, Sigma = Sigma2)
p2     <- rbern(P, 1)
beta2  <- p2*rnorm(P,1,0.1) + (1-p2)*rnorm(P,0,1)
eta2   <- X2%*%beta2
pi2    <- inv.logit(eta2)
Y2     <- rbern(N, pi2)
Y2     <- as.factor(Y2)
data2.lab4 <- data.frame(X2, Y2)


model2 <- naiveBayes(Y2 ~ ., data = data2.lab4)
print(model2)
preds2 <- predict(model2, newdata = data2.lab4)
error2 <- as.numeric(Y2) - as.numeric(preds2)

# Root Mean Squred Error
sqrt(mean(error2^2))
# Mean Aboslute Error
mean(abs(error2))


mod_enet2 <- train(Y2~., method="glmnet",
                  tuneGrid=expand.grid(alpha=seq(0,1,0.1),
                                       lambda=seq(0,200,1)),
                  data=data2.lab4,
                  preProcess=c("center"),
                  trControl=trainControl(method="cv",number=2, search="grid"))


yhat2 = predict(mod_enet2)
qplot(Y2, yhat2, alpha=I(0.25))+
  geom_jitter()+
  xlab( expression(paste("Training ", hat(y))))+
  ylab( expression(paste("Elastic Net ", y)))+
  theme_bw()+
  theme(axis.text=element_text(size=12),
        axis.title=element_text(size=14))

enet_beta2 = coef(mod_enet2$finalModel, mod_enet2$bestTune$lambda)
qplot(beta2, enet_beta2[-1])+
  xlab( expression(paste("True " , beta)))+
  ylab( expression(paste("Elastic Net " , hat(beta))))+
  theme_bw()+
  theme(axis.text=element_text(size=12),
        axis.title=element_text(size=14))





# 2: Text as data ---------------------------------------------------------

# Load text data:
#load()
text.data

#Create Data Frame for use.
sparse <- as(review_mat, "sparseMatrix")
sparse <- as.data.frame(as.matrix(sparse))
text.data <- data.frame(review_sentiment, sparse)
names(text.data) #Always check


#Our data could be already in lowercase, but a few things may need cleaning:

library(stringr) #Helps clean text data
# Take out symbols and unwanted misc stuff:
text.data <- stringr::str_replace_all(names(text.data),"[^a-zA-Z\\s]", " ")

# Shrink down to just one remaining white space:
text.data <- stringr::str_replace_all(names(text.data),"[\\s]+", " ")

names(text.data) #check

# A way to delete X's?
not.want <- which(names(text.data) %in% c("Var_10", "Var_2", "Var_8"))
dat <- dat[, -not.want]
dat

text.model <- glm(review_sentiment ~ review_mat, family = gaussian, data=text.data)

lasso.q4 <- train(review_sentiment~., method="glmnet",
                  tuneGrid=expand.grid(alpha=0,
                                       lambda=seq(0,10,1)),
                  data=data.q4,
                  preProcess=c("center"),
                  trControl=trainControl(method="cv",number=2, search="grid"))

plot(lasso.q4)
lasso.q4$bestTune$lambda # best lambda value is 0


# These can work, other classification models can do really well such as SVMs, etc.
# Try using your data and penalized regression models to learn from data.

