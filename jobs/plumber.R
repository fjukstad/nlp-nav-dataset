library(plumber)
library(tidymodels)
library(quanteda)

model = readRDS("../model.Rds")
dfm_mat = readRDS("../dfm_mat.Rds")

#* @apiTitle Jobs

#* Predict what job 
#* @param job_description 
#* @get /predict
function(job_description = "") {
  
  input = tokens(job_description)
  as_dfm = dfm(input)
  
  as_dfm = dfm_match(as_dfm, features = featnames(dfm_mat))
  as_df = convert(as_dfm, to = "data.frame")
  
  prediction = predict(random_forest_fit, as_df, type="class")
return(prediction)
  
}

