# Text analysis on job posting data from NAV 
This was a small experiment to get familiar with basic natural language
processing (NLP) techniques. Nothing fancy to see here. It simply
creates a random forest model for predicting the profession based on a job
description from a job posting. The analysis uses the open 
[NAV stillingsannonser](https://data.nav.no/datapakke/2f6ce2a2c65dd50709d389486da3947a)
dataset, so shout-out to [NAV](https://github.com/navikt) for sharing their
data! Also a big shout-out to the
[stopwords-no](https://github.com/stopwords-iso/stopwords-no) repository for
sharing Norwegian stopwords which I could easily remove with their list. 

Note that I've reduced the number of professions to predict, as well as the
number of words that go into the model, just to make things run faster. There
are a total of 2348 different professions in the dataset, so I've reduced it to
the top 10 professions. The goal was to try to make something that sort of
worked, not a perfect model in any sense. 

# Run the analysis yourself? 
Since the datasets are kind of big, you have to `cd` into the `data/` folder and
run [data/get-data.sh](data/get-data.sh) to download the data.  To run the
analysis, simply run everything in the `analysis.R` file.

