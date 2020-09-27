library(tidymodels)
library(tidyverse)
library(quanteda)

postings = read_delim("data/stillinger_2019_tekst.csv",
                  delim=";")

postings = postings %>% 
        mutate(Stillingsbeskrivelse = gsub("<.*?>", "", `Stillingsbeskrivelse vasket`)) %>% 
        select(-`Stillingsbeskrivelse vasket`) %>% 
        rename(c('Stilling id'='Stilling Id'))

nav_overview = read_delim("data/ledige_stillinger_meldt_til_nav_2018.csv",
                          delim=";",
                          col_types  = cols(Yrke = col_factor(),
                                            Yrkesbetegnelse = col_factor()))

data = postings %>% 
        full_join(nav_overview, by = c("Stilling id")) %>% 
        drop_na(Stillingsbeskrivelse, Yrke) 


summary(data)

data %>% 
  group_by(Yrkesbetegnelse) %>% 
  summarise(count = n()) %>% 
  arrange(-count) %>% 
  top_n(10) 


data = data %>% 
        mutate("Lengde Stillingsbeskrivelse" = nchar(Stillingsbeskrivelse))

data %>% 
  group_by(Yrkesbetegnelse) %>% 
  summarise(avg = mean(`Lengde Stillingsbeskrivelse`)) %>% 
  arrange(-avg)



top_10 = data %>% 
  group_by(Yrkesbetegnelse) %>% 
  summarise(count = n()) %>% 
  arrange(-count) %>% 
  top_n(10) %>% 
  select(Yrkesbetegnelse)

smalldata = data %>% 
    filter(Yrkesbetegnelse %in% top_10$Yrkesbetegnelse) %>% 
    top_n(10000)

norwegian_stopwords = c(unlist(read.delim("data/stopwords-no.txt", 
                                 sep="\n", 
                                 encoding = "UTF-8",
                                 header = F,
                                 as.is = T)))

toks = tokens(smalldata$Stillingsbeskrivelse, 
                remove_punct = T,
                remove_symbols = T,
                remove_numbers = T,
                remove_url = T
                )

toks = tokens_remove(toks, norwegian_stopwords, valuetype="fixed")

dfm_mat = dfm(toks)

dfm_mat <- dfm_trim(dfm_mat, min_termfreq = 1000)

df = smalldata %>% 
      select(Yrkesbetegnelse) %>%  
      bind_cols(convert(dfm_mat, to="data.frame")) %>% 
      select(-doc_id) %>% 
      mutate(Yrkesbetegnelse = droplevels(Yrkesbetegnelse))

head(df)

data_split = initial_split(df, strata="Yrkesbetegnelse",p=0.8)

testing = testing(data_split)
training = training(data_split)


random_forest_fit = 
  rand_forest(mode="classification") %>% 
  set_engine("randomForest") %>% # use randomForest pkg 
  fit(Yrkesbetegnelse ~ ., data=training)



predictions =  random_forest_fit %>% 
  predict(testing, type="class") %>% 
  bind_cols(testing) %>% 
  arrange(Yrkesbetegnelse)

predictions %>% 
  metrics(truth = Yrkesbetegnelse, estimate=.pred_class)

eksempel_systemutvikler = "I utviklingsavdelingen vil du jobbe i et tverrfaglig Scrum-team, med både økonomer, testere og systemutviklere. Hos oss vil du få muligheten til å utfordre og utvikle deg selv på både front- og backend. Vi er ute etter deg som kan være med å finne gode og kreative løsninger og som tørr å vise deg fram. Du motiveres av utfordringer og har evne og vilje til å lære ny teknologi og å utforske nye problemstillinger."
input = tokens(eksempel_systemutvikler)
as_dfm = dfm(input)

as_dfm = dfm_match(as_dfm, features = featnames(dfm_mat))
as_df = convert(as_dfm, to = "data.frame")

predict(random_forest_fit, as_df, type="class")

eksempel_sykepleier = "Foruten å være sentral i det miljøterapeutiske arbeidet, vil samarbeid med pårørende og øvrige ledd i behandlingskjeden, slik som innsøkende instans, kommunehelsetjenesten og de tre SPH (Senter for psykisk helse) i vårt opptaksområde være viktige funksjoner for miljøpersonalet på Akuttpost Sør. Det utadretta arbeidet foregår både på telefon, ved bruk av elektronisk kommunikasjon (PLO-meldinger), og videokonferansemøter. Noe reisevirksomhet kan forekomme."
input = tokens(eksempel_sykepleier)
as_dfm = dfm(input)

as_dfm = dfm_match(as_dfm, features = featnames(dfm_mat))
as_df = convert(as_dfm, to = "data.frame")

predict(random_forest_fit, as_df, type="class")


saveRDS(random_forest_fit, "model.Rds")
saveRDS(dfm_mat, "dfm_mat.Rds")        
