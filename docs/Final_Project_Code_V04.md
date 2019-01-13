---
title: "CFRM 521 Final Project"
author: "Yohan Min & Peiyuan Song"
date: "June 4, 2018"
output:
  html_document:
    df_print: paged
    keep_md: true
  pdf_document: default
header-includes:
- \usepackage{float}
- \floatplacement{figure}{H}
- \usepackage[fontsize=12pt]{scrextend}
---





# Predicting Stock Price Movement Using Social Media Analysis

## Abstract
The purpose of this final project is to understand the research and replicate methods used in Derik Tsui's paper. We tried the 3 methods, Naive bayes, Support vector regression and K-nearest neighbors regression to compare with the original analysis. It turns out the results are slightly different due to the fact that the data for these analyses may be different we assume. 


## Background
Today's social media platforms is one of the most fast and efficient way that transport information among people as well as the financial market. This brings us an idea of study the relationship between people's comments on social media platforms and same period financial market performance. Some platforms like StockTwits provide a good and detailed resource of comments database, which we can build our model directly based on it.

Because of more and more financial institutions now start to adapt automated statistical techniques in their daily trading practices, the sample paper believes that further development of large-scale social media analysis will have the potential to introduce an additional source of investment alpha.

Same as our sample paper, our underlying assumption is that a correlation between aggregated sentiment indicator and the market price reaction. Thus, our StockTwits data which represent market sentiment can provide a robust and meaningful information of real financial market situation. 


## Method
### Data
We first download data from StockTwits, the data is only available in JSON format, and contains more than 566,000 comments data, covering 1592 stocks from the beginning of 2013 all the way through the end of 2016. Each data point is comprised of message body, timestamp, sentiment, and ticker symbols. 

We will first need to convert our raw data into txt or csv format for the ease of process with R. By doing so, we will use jsonlite package and convert raw data into matrix format. During this process, we will remove all message body, and only leave useful information in our processed sentiment dataset.

Price data for DJI Average can be retrieved using quantmod package, where we will get four years of pricing data from 2013 - 2016. Calculating forward 3-day return using exactly same method described by the sample paper. Reason of using 3-day return is to smooth out short-term volatility and market noise. 



```r
strt = read.table("../data/strt.txt",header = TRUE)
strt = strt[,-1:-2]
strt[,1] = as.factor(strt[,1])
#strt = ifelse(strt==0, "n", "y") 
dat_train = strt[-757:-1005,]
dat_test = strt[757:1005,]
```


Instead of using bag of words described in the sample paper, we will use number of bullish and bearish message in a single day. For example, if in a single day, bullish comments toward DJI's constituent stocks is more than that of bearish comments, we will identify that day as a day with bullish sentiment, and vice versa. That is, sentiment parameter = 1, when (# of bullish message) > (# of bearish message).


<table class="table table table" style="margin-left: auto; margin-right: auto; margin-left: auto; margin-right: auto; margin-left: auto; margin-right: auto;">
<caption>Cleaned data table (first 15 rows)</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> DJI.Close </th>
   <th style="text-align:right;"> MMM </th>
   <th style="text-align:right;"> AXP </th>
   <th style="text-align:right;"> AAPL </th>
   <th style="text-align:right;"> BA </th>
   <th style="text-align:right;"> CAT </th>
   <th style="text-align:right;"> CVX </th>
   <th style="text-align:right;"> CSCO </th>
   <th style="text-align:right;"> KO </th>
   <th style="text-align:right;"> DIS </th>
   <th style="text-align:right;"> XOM </th>
   <th style="text-align:right;"> GE </th>
   <th style="text-align:right;"> GS </th>
   <th style="text-align:right;"> HD </th>
   <th style="text-align:right;"> IBM </th>
   <th style="text-align:right;"> INTC </th>
   <th style="text-align:right;"> JNJ </th>
   <th style="text-align:right;"> JPM </th>
   <th style="text-align:right;"> MCD </th>
   <th style="text-align:right;"> MRK </th>
   <th style="text-align:right;"> MSFT </th>
   <th style="text-align:right;"> NKE </th>
   <th style="text-align:right;"> PFE </th>
   <th style="text-align:right;"> PG </th>
   <th style="text-align:right;"> TRV </th>
   <th style="text-align:right;"> UTX </th>
   <th style="text-align:right;"> UNH </th>
   <th style="text-align:right;"> VZ </th>
   <th style="text-align:right;"> V </th>
   <th style="text-align:right;"> WMT </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
</tbody>
</table>

### Training 
Next, we will try methods described in the sample paper and try to replicate similar results. Similar to the method as described in sample paper, we will avoid look ahead bias by set 1st 75% of historical data as training data, and the remaining 25% of data as the test set (data from Jan 2016 - Dec 2016). Trainings are all performed in dinfferent methods: NB, SVR and KNN. The parameters after each train are applied to test data to compare with the real value. 

\newpage

## Results
### Naive Bayes Analysis

```r
library(naivebayes)
# training
nb = naive_bayes(DJI.Close~., data=as.data.frame(dat_train))
#tables(nb)
#summary(nb)

# predicting
#dat_test
#predict(nb, dat_test[,-1], type = "class") 
#predict(nb, dat_test[,-1], type = "prob")
prd = predict(nb, dat_test[,-1], type = "class") 
#dat_test[,1]==prd
#sum(dat_test[,1]!=prd) # number of difference
nbv = sum(dat_test[,1]==prd)/length(dat_test[,1]) # % of correct
```

<table class="kable_wrapper table table table table" style="margin-left: auto; margin-right: auto; margin-left: auto; margin-right: auto; margin-left: auto; margin-right: auto; font-size: 10px; margin-left: auto; margin-right: auto;">
<caption style="font-size: initial !important;">NB train results in order of MMM,AXP,AAPL,BA,CAT,CVX,CSCO,KO,
DIS,XOM,GE,GS,HD,IBM,INTC,JNJ,JPM,MCD,MRK,MSFT,NKE,PFE,PG,TRV,UTX,UNH,VZ,V,
WMT</caption>
<tbody>
  <tr>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> 0 </th>
   <th style="text-align:right;"> 1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> mean </td>
   <td style="text-align:right;"> 0.1550633 </td>
   <td style="text-align:right;"> 0.1750000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sd </td>
   <td style="text-align:right;"> 0.3625391 </td>
   <td style="text-align:right;"> 0.3803996 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> 0 </th>
   <th style="text-align:right;"> 1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> mean </td>
   <td style="text-align:right;"> 0.4303797 </td>
   <td style="text-align:right;"> 0.4045455 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sd </td>
   <td style="text-align:right;"> 0.4959146 </td>
   <td style="text-align:right;"> 0.4913625 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> 0 </th>
   <th style="text-align:right;"> 1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> mean </td>
   <td style="text-align:right;"> 0.9588608 </td>
   <td style="text-align:right;"> 0.9386364 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sd </td>
   <td style="text-align:right;"> 0.1989272 </td>
   <td style="text-align:right;"> 0.2402693 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> 0 </th>
   <th style="text-align:right;"> 1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> mean </td>
   <td style="text-align:right;"> 0.6455696 </td>
   <td style="text-align:right;"> 0.6636364 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sd </td>
   <td style="text-align:right;"> 0.4790990 </td>
   <td style="text-align:right;"> 0.4730028 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> 0 </th>
   <th style="text-align:right;"> 1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> mean </td>
   <td style="text-align:right;"> 0.3291139 </td>
   <td style="text-align:right;"> 0.375000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sd </td>
   <td style="text-align:right;"> 0.4706367 </td>
   <td style="text-align:right;"> 0.484674 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> 0 </th>
   <th style="text-align:right;"> 1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> mean </td>
   <td style="text-align:right;"> 0.4430380 </td>
   <td style="text-align:right;"> 0.4454545 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sd </td>
   <td style="text-align:right;"> 0.4975326 </td>
   <td style="text-align:right;"> 0.4975816 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> 0 </th>
   <th style="text-align:right;"> 1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> mean </td>
   <td style="text-align:right;"> 0.6708861 </td>
   <td style="text-align:right;"> 0.6181818 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sd </td>
   <td style="text-align:right;"> 0.4706367 </td>
   <td style="text-align:right;"> 0.4863854 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> 0 </th>
   <th style="text-align:right;"> 1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> mean </td>
   <td style="text-align:right;"> 0.4620253 </td>
   <td style="text-align:right;"> 0.4863636 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sd </td>
   <td style="text-align:right;"> 0.4993466 </td>
   <td style="text-align:right;"> 0.5003830 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> 0 </th>
   <th style="text-align:right;"> 1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> mean </td>
   <td style="text-align:right;"> 0.7879747 </td>
   <td style="text-align:right;"> 0.7840909 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sd </td>
   <td style="text-align:right;"> 0.4093910 </td>
   <td style="text-align:right;"> 0.4119199 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> 0 </th>
   <th style="text-align:right;"> 1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> mean </td>
   <td style="text-align:right;"> 0.4810127 </td>
   <td style="text-align:right;"> 0.4340909 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sd </td>
   <td style="text-align:right;"> 0.5004318 </td>
   <td style="text-align:right;"> 0.4962011 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> 0 </th>
   <th style="text-align:right;"> 1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> mean </td>
   <td style="text-align:right;"> 0.6234177 </td>
   <td style="text-align:right;"> 0.5431818 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sd </td>
   <td style="text-align:right;"> 0.4852972 </td>
   <td style="text-align:right;"> 0.4986989 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> 0 </th>
   <th style="text-align:right;"> 1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> mean </td>
   <td style="text-align:right;"> 0.5696203 </td>
   <td style="text-align:right;"> 0.5818182 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sd </td>
   <td style="text-align:right;"> 0.4959146 </td>
   <td style="text-align:right;"> 0.4938218 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> 0 </th>
   <th style="text-align:right;"> 1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> mean </td>
   <td style="text-align:right;"> 0.4683544 </td>
   <td style="text-align:right;"> 0.4340909 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sd </td>
   <td style="text-align:right;"> 0.4997890 </td>
   <td style="text-align:right;"> 0.4962011 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> 0 </th>
   <th style="text-align:right;"> 1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> mean </td>
   <td style="text-align:right;"> 0.5063291 </td>
   <td style="text-align:right;"> 0.5545455 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sd </td>
   <td style="text-align:right;"> 0.5007529 </td>
   <td style="text-align:right;"> 0.4975816 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> 0 </th>
   <th style="text-align:right;"> 1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> mean </td>
   <td style="text-align:right;"> 0.6424051 </td>
   <td style="text-align:right;"> 0.6431818 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sd </td>
   <td style="text-align:right;"> 0.4800522 </td>
   <td style="text-align:right;"> 0.4796058 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> 0 </th>
   <th style="text-align:right;"> 1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> mean </td>
   <td style="text-align:right;"> 0.4462025 </td>
   <td style="text-align:right;"> 0.4022727 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sd </td>
   <td style="text-align:right;"> 0.4978858 </td>
   <td style="text-align:right;"> 0.4909146 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> 0 </th>
   <th style="text-align:right;"> 1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> mean </td>
   <td style="text-align:right;"> 0.4493671 </td>
   <td style="text-align:right;"> 0.375000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sd </td>
   <td style="text-align:right;"> 0.4982186 </td>
   <td style="text-align:right;"> 0.484674 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> 0 </th>
   <th style="text-align:right;"> 1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> mean </td>
   <td style="text-align:right;"> 0.3607595 </td>
   <td style="text-align:right;"> 0.2772727 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sd </td>
   <td style="text-align:right;"> 0.4809825 </td>
   <td style="text-align:right;"> 0.4481618 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> 0 </th>
   <th style="text-align:right;"> 1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> mean </td>
   <td style="text-align:right;"> 0.3449367 </td>
   <td style="text-align:right;"> 0.3045455 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sd </td>
   <td style="text-align:right;"> 0.4761016 </td>
   <td style="text-align:right;"> 0.4607385 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> 0 </th>
   <th style="text-align:right;"> 1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> mean </td>
   <td style="text-align:right;"> 0.8639241 </td>
   <td style="text-align:right;"> 0.8250000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sd </td>
   <td style="text-align:right;"> 0.3434130 </td>
   <td style="text-align:right;"> 0.3803996 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> 0 </th>
   <th style="text-align:right;"> 1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> mean </td>
   <td style="text-align:right;"> 0.6075949 </td>
   <td style="text-align:right;"> 0.5590909 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sd </td>
   <td style="text-align:right;"> 0.4890606 </td>
   <td style="text-align:right;"> 0.4970611 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> 0 </th>
   <th style="text-align:right;"> 1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> mean </td>
   <td style="text-align:right;"> 0.4778481 </td>
   <td style="text-align:right;"> 0.4840909 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sd </td>
   <td style="text-align:right;"> 0.5003013 </td>
   <td style="text-align:right;"> 0.5003157 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> 0 </th>
   <th style="text-align:right;"> 1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> mean </td>
   <td style="text-align:right;"> 0.2943038 </td>
   <td style="text-align:right;"> 0.2568182 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sd </td>
   <td style="text-align:right;"> 0.4564520 </td>
   <td style="text-align:right;"> 0.4373755 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> 0 </th>
   <th style="text-align:right;"> 1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> mean </td>
   <td style="text-align:right;"> 0.0949367 </td>
   <td style="text-align:right;"> 0.0727273 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sd </td>
   <td style="text-align:right;"> 0.2935924 </td>
   <td style="text-align:right;"> 0.2599839 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> 0 </th>
   <th style="text-align:right;"> 1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> mean </td>
   <td style="text-align:right;"> 0.1867089 </td>
   <td style="text-align:right;"> 0.2068182 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sd </td>
   <td style="text-align:right;"> 0.3902957 </td>
   <td style="text-align:right;"> 0.4054850 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> 0 </th>
   <th style="text-align:right;"> 1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> mean </td>
   <td style="text-align:right;"> 0.306962 </td>
   <td style="text-align:right;"> 0.2363636 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sd </td>
   <td style="text-align:right;"> 0.461965 </td>
   <td style="text-align:right;"> 0.4253317 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> 0 </th>
   <th style="text-align:right;"> 1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> mean </td>
   <td style="text-align:right;"> 0.4525316 </td>
   <td style="text-align:right;"> 0.4909091 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sd </td>
   <td style="text-align:right;"> 0.4985311 </td>
   <td style="text-align:right;"> 0.5004864 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> 0 </th>
   <th style="text-align:right;"> 1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> mean </td>
   <td style="text-align:right;"> 0.6740506 </td>
   <td style="text-align:right;"> 0.6636364 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sd </td>
   <td style="text-align:right;"> 0.4694719 </td>
   <td style="text-align:right;"> 0.4730028 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> 0 </th>
   <th style="text-align:right;"> 1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> mean </td>
   <td style="text-align:right;"> 0.4683544 </td>
   <td style="text-align:right;"> 0.4795455 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sd </td>
   <td style="text-align:right;"> 0.4997890 </td>
   <td style="text-align:right;"> 0.5001501 </td>
  </tr>
</tbody>
</table>

 </td>
  </tr>
</tbody>
</table>

\newpage
\pagebreak

### Support Vector Regression Analysis

```r
library(e1071)
modelsvm = svm(DJI.Close~., dat_train)
predYsvm = predict(modelsvm, dat_test[,-1])
svrv = sum(dat_test[,1] == predYsvm)/length(dat_test[,1])
summary(modelsvm)
```

```
## 
## Call:
## svm(formula = DJI.Close ~ ., data = dat_train)
## 
## 
## Parameters:
##    SVM-Type:  C-classification 
##  SVM-Kernel:  radial 
##        cost:  1 
##       gamma:  0.03448276 
## 
## Number of Support Vectors:  706
## 
##  ( 316 390 )
## 
## 
## Number of Classes:  2 
## 
## Levels: 
##  0 1
```


\pagebreak

### K-Nearest Neighbors Regression Analysis

```r
library(class)
knn.1 <-  knn(dat_train[,-1], dat_test[,-1], dat_train[,1], k=1)
knn.5 <-  knn(dat_train[,-1], dat_test[,-1], dat_train[,1], k=5)
knn.20 <- knn(dat_train[,-1], dat_test[,-1], dat_train[,1], k=20)

## Let's calculate the proportion of correct classification for k = 1, 5 & 20 
knnv1 = sum(dat_test[,1] == knn.1)/length(dat_test[,1]) # For knn = 1
knnv5 = sum(dat_test[,1] == knn.5)/length(dat_test[,1])
knnv20 = sum(dat_test[,1] == knn.20)/length(dat_test[,1])

# table(knn.1 ,dat_test[,1])
# table(knn.5 ,dat_test[,1])
# table(knn.20 ,dat_test[,1])
```

<table class="table table" style="margin-left: auto; margin-right: auto; margin-left: auto; margin-right: auto;">
<caption>Test accuracy, compared KNN with 
      1,5, and 20</caption>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> Test Accuracy </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> KNN1 </td>
   <td style="text-align:right;"> 0.5060 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> KNN5 </td>
   <td style="text-align:right;"> 0.4538 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> KNN20 </td>
   <td style="text-align:right;"> 0.5261 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Average </td>
   <td style="text-align:right;"> 0.4953 </td>
  </tr>
</tbody>
</table>

\newpage

## Summary & Discussion




Among the 3 methods, SVR and KNN perform better than NB with the test accuracy of 51.81% an 50.6% respectively. NB has the accuracy of 49.4%. These results are a bit different from the original anaysis that shows the results of accuracy for NB, SVR and KNN as 50.9%, 56.82% and 54.48%. 


<table class="table table" style="margin-left: auto; margin-right: auto; margin-left: auto; margin-right: auto;">
<caption>Test accuracy, compared</caption>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> Test Accuracy </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Naive.Bayes </td>
   <td style="text-align:right;"> 0.4940 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SVR </td>
   <td style="text-align:right;"> 0.5181 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> KNN </td>
   <td style="text-align:right;"> 0.5060 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Average </td>
   <td style="text-align:right;"> 0.5060 </td>
  </tr>
</tbody>
</table>


Also with respect to the individual stock predicting the market of stock price movement, our result shows that CAT has the highest test accuracy as 63.5% while AAPL has the lowest test accuracy of 30.5%. The overall discrepency between the original analysis and our results may be due to the difference of data used for analyzing the stock price movement. Since we can't figure out how the data is different and how the data the orginal analysis is based on was processed and cleaned, we are just guessing. But in general, we also found that NB performed less than the other two methods (i.e. SVR and KNN). 


```r
e = c()
for(i in 2:30) e[i] = sum(prd==dat_test[,i])/length(dat_test[,1])
e = e[-1]
names(e) = c("MMM","AXP","AAPL","BA","CAT","CVX","CSCO","KO","DIS","XOM",
             "GE","GS","HD","IBM","INTC","JNJ","JPM","MCD","MRK","MSFT",
             "NKE", "PFE","PG","TRV","UTX","UNH","VZ","V","WMT")
e = round(data.frame(e) *100,1)
colnames(e) = "Test accuracy(%)"

kable(e, caption = "Test accuracy, compared", booktabs = T) %>%
  kable_styling(latex_options = c("hold_position"))  %>%
  kable_styling(latex_options = "striped") %>%
  kable_styling(font_size = 9)
```

<table class="table table table" style="margin-left: auto; margin-right: auto; margin-left: auto; margin-right: auto; font-size: 9px; margin-left: auto; margin-right: auto;">
<caption style="font-size: initial !important;">Test accuracy, compared</caption>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> Test accuracy(%) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> MMM </td>
   <td style="text-align:right;"> 57.8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AXP </td>
   <td style="text-align:right;"> 52.6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AAPL </td>
   <td style="text-align:right;"> 30.5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BA </td>
   <td style="text-align:right;"> 47.4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CAT </td>
   <td style="text-align:right;"> 63.5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CVX </td>
   <td style="text-align:right;"> 47.8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CSCO </td>
   <td style="text-align:right;"> 37.3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> KO </td>
   <td style="text-align:right;"> 47.8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> DIS </td>
   <td style="text-align:right;"> 40.6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> XOM </td>
   <td style="text-align:right;"> 43.8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GE </td>
   <td style="text-align:right;"> 38.6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GS </td>
   <td style="text-align:right;"> 45.8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> HD </td>
   <td style="text-align:right;"> 46.2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> IBM </td>
   <td style="text-align:right;"> 56.6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> INTC </td>
   <td style="text-align:right;"> 39.8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> JNJ </td>
   <td style="text-align:right;"> 44.6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> JPM </td>
   <td style="text-align:right;"> 43.8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MCD </td>
   <td style="text-align:right;"> 33.3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MRK </td>
   <td style="text-align:right;"> 41.8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MSFT </td>
   <td style="text-align:right;"> 30.9 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NKE </td>
   <td style="text-align:right;"> 37.3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PFE </td>
   <td style="text-align:right;"> 44.2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PG </td>
   <td style="text-align:right;"> 43.4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> TRV </td>
   <td style="text-align:right;"> 54.2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> UTX </td>
   <td style="text-align:right;"> 58.2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> UNH </td>
   <td style="text-align:right;"> 41.4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VZ </td>
   <td style="text-align:right;"> 51.4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> V </td>
   <td style="text-align:right;"> 44.6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> WMT </td>
   <td style="text-align:right;"> 45.0 </td>
  </tr>
</tbody>
</table>

Sentiment in social media could be the good pedictor to forecast the market price movement. Due to the improvement of computational power and analysis techniques it is possible to estimate the uncertain market behavior better than before. On the other hand, there is still a limit as there are always uncertain phenomena that is hard to catch. Although Our result shows that the test accuracy is slightly betther than 50%, including other statistical methods to improve the processes that we used in this report, will enhance the test accuracy. 

Another limit from the database we are using is that messages are already identified as bullish and bearish by data provider. Some of messages are clear in their sentiment toward financial market while there are some of them can be considered as quite neutual. In that case, whether to catigorized them under bullish or bearish can be a very subjective decision and will produce bias. One way to improve is to consider add another category of neutral comments, so that we can collect all neutral and ambiguous comments under this category.


\newpage

## References
1.	Derek G. Tsui. Predicting Stock Price Movement Using Social Media Analysis, Stanford University, 2016
