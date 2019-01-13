# install.packages("jsonlite")
library(jsonlite)
library(xts)
library(tibble)
library(dplyr)
library(reshape2)
library(lubridate)
library(VGAM)
library(MASS)
library(spdep)

# Load data into R
out <- lapply(readLines("ST_data_for_DJIA.json"), fromJSON)

Out_Data <- data.frame()
Out_Date <- integer(0)
class(Out_Date) <- "Date"

# Need to update to run full data
for (i in c(1:1000)) {
  
  out_time <- as.Date(out[[i]]$timestamp)
  out_senti <- out[[i]]$sentiment
  out_symbol <- out[[i]]$symbols[1]
  item <- cbind(out_symbol, out_senti)
  Out_Data <- rbind(Out_Data,item)
  Out_Date <- c(Out_Date,out_time) ##?
}

Data_xts <- xts(Out_Data, Out_Date)
colnames(Data_xts) <- c("Ticker", "Sentiment")

write.zoo(Data_xts, file="test.csv")
write.zoo(Data_xts, file="test.txt")

### DIJA data cleaning for rtn
data = read.table("Data.txt")
head(data)
sort(table(data$V2), TRUE)

getSymbols("^DJI", from="2013-01-01", to="2016-12-31", src="yahoo")
class(DJI)
names(DJI)
dim(DJI)
head(DJI)
tail(DJI)
chartSeries(DJI, theme="white") # Plot closing price and trade volume
chartSeries(DJI, theme="white", subset="2015-12-01::2015-12-31")

D_close = DJI[,4]
chartSeries(D_close, theme="white") # Plot closing price and trade volume
head(D_close)
head(lag(D_close,-3))
rtn = (lag(D_close,-3) - D_close)/D_close
head(rtn)
class(rtn)
write.zoo(rtn, file="rtn.txt")

### stock data cleaning 
data = data.frame(data)
str(data)
head(data)
list = c("MMM","AXP","AAPL","BA","CAT","CVX","CSCO","KO","DIS","XOM","GE","GS","HD",
         "IBM","INTC","JNJ","JPM","MCD","MRK","MSFT","NKE","PFE","PG","TRV","UTX","UNH","VZ","V","WMT")


Q = data.frame(matrix(0,1462,1))
for(j in list){
  temp = data[data[,2] == j,]
  t = table(temp$V1, temp$V3)
  d = c()
  for(i in 1:length(t[,1])) d[i] = ifelse(t[i,1] < t[i,2],1,0)
  t = cbind(t,d)
  Q[,j] = as.data.frame(t[,4])[,1]
}

# head(data[data[,2] == "DWDP",],20)
# sum(data[,2] == "V")

head(Q)
frame = cbind(t,Q)
frame = frame[,-c(1:5)]
head(frame)
str(frame)
write.zoo(frame, file="frame.txt")

head(rtn)
length(rtn)
cl = ifelse(rtn >0, 1, 0)
str(cl)
head(cl)
write.zoo(cl, file="cl.txt")

## join rtn and stock
length(cl[,1])
length(frame[,1])

X = merge(data.frame(cl), data.frame(frame), by = 0, all = TRUE) ## DATA including NA
write.zoo(X, file="X.txt")
write.zoo(X, file="X.csv")
str(X)
xx = as.data.frame(X)
strt = xx[!is.na(xx[,2]),] ## DATA to start analysis 
write.zoo(strt, file="strt.txt")

## Analysis NB
strt = read.table("strt.txt",header = TRUE)
strt = strt[,-1:-2]
library(naivebayes)
str(strt)
strt[,1] = as.factor(strt[,1])
#strt = ifelse(strt==0, "n", "y") 
dat_train = strt[-757:-1005,]
dat_test = strt[757:1005,]

# training
nb = naive_bayes(DJI.Close~., data=as.data.frame(dat_train))
tables(nb)

# predicting
(dat_test)
predict(nb, dat_test[,-1], type = "class") 
predict(nb, dat_test[,-1], type = "prob")
prd = predict(nb, dat_test[,-1], type = "class") 
dat_test[,1]==prd
sum(dat_test[,1]!=prd) # number of difference
nbv = sum(dat_test[,1]==prd)/length(dat_test[,1]) # % of correct


e = c()
for(i in 2:30) e[i] = sum(prd==dat_test[,i])/length(dat_test[,1])
e = e[-1]
names(e) = c("MMM","AXP","AAPL","BA","CAT","CVX","CSCO","KO","DIS","XOM","GE","GS","HD",
"IBM","INTC","JNJ","JPM","MCD","MRK","MSFT","NKE","PFE","PG","TRV","UTX","UNH","VZ","V","WMT")
e = round(data.frame(e) *100,1)
colnames(e) = "Test accuracy"


## Analysis KNN
knn.1 <-  knn(dat_train[,-1], dat_test[,-1], dat_train[,1], k=1)
knn.5 <-  knn(dat_train[,-1], dat_test[,-1], dat_train[,1], k=5)
knn.20 <- knn(dat_train[,-1], dat_test[,-1], dat_train[,1], k=20)

## Let's calculate the proportion of correct classification for k = 1, 5 & 20 
knnv1 = sum(dat_test[,1] == knn.1)/length(dat_test[,1]) # For knn = 1
knnv5 = sum(dat_test[,1] == knn.5)/length(dat_test[,1])
knnv20 = sum(dat_test[,1] == knn.20)/length(dat_test[,1])

table(knn.1 ,dat_test[,1])
table(knn.5 ,dat_test[,1])
table(knn.20 ,dat_test[,1])

knn = t(data.frame("KNN1" = knnv1, "KNN5" = knnv5, "KNN20" = knnv20))
colnames(knn) = "Test Accuracy"
knn = round(rbind(knn,"Average" = mean(c(knnv1,knnv5,knnv20))),4)


## SVR analysis
library(e1071)
modelsvm = svm(DJI.Close~., dat_train)
predYsvm = predict(modelsvm, dat_test[,-1])
svrv = sum(dat_test[,1] == predYsvm)/length(dat_test[,1])
summary(modelsvm)

com = t(data.frame("Naive Bayes" = nbv, "SVR" = svrv, "KNN" = knnv))
colnames(com) = "Test Accuracy"
com = round(rbind(com,"Average" = mean(c(nbv,svrv,knnv))),4)

## KNN example
gc <- read.table("german.data.txt")
head (gc)
gc.bkup <- gc
str(gc)

## Convert the dependent var to factor. Normalize the numeric variables  
gc$V21 <- factor(gc$V21)

num.vars <- sapply(gc, is.numeric)
gc[num.vars] <- lapply(gc[num.vars], scale)

## Selecting only 3 numeric variables for this demostration, just to keep things simple
myvars <- c("V2", "V5", "V8")
gc.subset <- gc[myvars]
summary(gc.subset)

# Let's predict on a test set of 100 observations. Rest to be used as train set.
set.seed(123) 
test <- 1:100
train.gc <- gc.subset[-test,]
test.gc <- gc.subset[test,]

train.def <- gc$V21[-test]
test.def <- gc$V21[test]

## Let's use k values (no of NNs) as 1, 5 and 20 to see how they perform in terms of correct proportion of classification and success rate. The optimum k value can be chosen based on the outcomes as below...
library(class)
knn.1 <-  knn(train.gc, test.gc, train.def, k=1)
knn.5 <-  knn(train.gc, test.gc, train.def, k=5)
knn.20 <- knn(train.gc, test.gc, train.def, k=20)

## Let's calculate the proportion of correct classification for k = 1, 5 & 20 
sum(test.def == knn.1) # For knn = 1
sum(test.def == knn.5)
sum(test.def == knn.20)

table(knn.1 ,test.def)
table(knn.5 ,test.def)
table(knn.20 ,test.def)

##For K = 20, among 88 customers, 71 or 80%, is success rate.
## It seems increasing K increases the classification but reduces success rate. It is worse to class a customer as good when it is bad, than it is to class a customer as bad when it is good. 
## By looking at above success rates, K = 1 or K = 5 can be taken as optimum K.
## We can make a plot of the data with the training set in hollow shapes and the new ones filled in. 
## Plot for K = 1 can be created as follows - 

plot(train.gc[,c("V2","V5")],
     col=c(4,3,6,2)[gc.bkup[-test, "V8"]],
     pch=c(1,2)[as.numeric(train.def)],
     main="Predicted Default, by 1 Nearest Neighbors",cex.main=.95)

points(test.gc[,c("V2","V5")],
       bg=c(4,3,6,2)[gc.bkup[-test,"V8"]],
       pch=c(21,24)[as.numeric(knn.1)],cex=1.2,col=grey(.7))

legend("bottomright",pch=c(1,16,2,17),bg=c(1,1,1,1),
       legend=c("data 0","pred 0","data 1","pred 1"),
       title="default",bty="n",cex=.8)

legend("topleft",fill=c(4,3,6,2),legend=c(1,2,3,4),
       title="installment %", horiz=TRUE,bty="n",col=grey(.7),cex=.8)
