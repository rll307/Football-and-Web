## -----------------------------------------------------------------------------------------
library(readtext)
library(dplyr)
library(tidytext)
library(ggplot2)
library(scales)
library(stringr)
library(tidyr)
library(GuardianR)
library(tm)
require(quanteda)


## -----------------------------------------------------------------------------------------
#The command bellow will interact with the Newspapers API and scrape the data from 2002 world cup.
#Try one for each Cup  you are interested in. Gardian makes possible to collect data back to 1999. 

cup2002 <- get_guardian("world+cup",
                        section="football",
                        from.date="2002-05-31",
                        to.date="2002-06-30",
                        api.key="my API key")


## -----------------------------------------------------------------------------------------
your.text.string <- paste(as.character(cup2002$body))


## ----clean_funtion_01---------------------------------------------------------------------
limpar_texto.html <- function(x) {
  return(gsub("<.*?>", "", x))
} #Cleans special HRML codes


## -----------------------------------------------------------------------------------------
limpar.pontuacao <- function(x){
  return(gsub(pattern = "\\W"," ",x))
} #Cleans unnecessary paragraphs 


## -----------------------------------------------------------------------------------------
limpar_texto.espacos <- function(x) {
  return(str_squish(x))
}#Cleans unnecessary spaces


## -----------------------------------------------------------------------------------------
limpar.letras.soltas <- function(x){
  return(gsub("\\b[A-z]\\b{1}", " ", x))
}


## -----------------------------------------------------------------------------------------
Clean_String <- function(string){
  # Lowercase
  temp <- tolower(string)
  # Remove everything that is not a number or letter (may want to keep more 
  # stuff in your actual analysis). 
  temp <- stringr::str_replace_all(temp,"[^a-zA-Z\\s]", " ")
  # Shrink down to just one white space
  temp <- stringr::str_replace_all(temp,"[\\s]+", " ")
  # Split it
  #temp <- stringr::str_split(temp, " ")[[1]]
  # Get rid of trailing "" if necessary
  indexes <- which(temp == "")
  if(length(indexes) > 0){
    temp <- temp[-indexes]
  } 
  return(temp)
}#


## -----------------------------------------------------------------------------------------
## In order to process the text-cleaning, just run it substituting "your.text"
your.text <- limpar_texto.html(your.text.string) #
your.text <- Clean_String(your.text)#
your.text <- limpar_texto.espacos(your.text)#
your.text <- limpar_texto.paragrafos(your.text)#
your.text <- limpar.pontuacao(your.text)#
your.text <- limpar.numeros(your.text)
your.text <- limpar.letras.soltas(your.text)
your.text <- gsub("getty images", " ", your.text)


## -----------------------------------------------------------------------------------------
#Make a dataframe out of your string
your.text.df <- data.frame(text = your.text, stringsAsFactors = F)

#Apply the stopwords
your.text.df  <- your.text.df  %>%
  unnest_tokens(word, text)%>%
  anti_join(stop_words)

#Repete one time for each World Cup


## -----------------------------------------------------------------------------------------
#This will produce a list of the words in each cup side by side with their proportion in a new column

frequency.cups <- bind_rows(mutate(cup2002.tidy, cup = "2002"),
                            mutate(cup2006.tidy, cup = "2006"),
                            mutate(cup2010.tidy, cup = "2010"),
                            mutate(cup2014.tidy, cup = "2014"),
                            mutate(cup2018.tidy, cup = "2018")) %>%
  mutate(word = str_extract(word, "[:alpha:]+")) %>%
  count(cup, word) %>%
  group_by(cup)%>%
  mutate(proportion = n / sum(n)) %>%
  select(-n) %>%
  spread(cup, proportion)


## -----------------------------------------------------------------------------------------
#This will add a total for each word cup
frequency.cups.total <- frequency.cups %>%
  group_by(cup) %>%
  summarize(total = sum(n))



## -----------------------------------------------------------------------------------------
#Now we join them together
frequency.cups.total <- left_join(frequency.cups,frequency.cups.total)


## --------------------------------------------------------------------------
library(knitr)
kable(frequency.cups.total[1:10,], caption = "Head of List")


## -----------------------------------------------------------------------------------------
#This commands will process this table in terms of ID/ITF numbers
freq_by_rank <- frequency.cups.total %>%
  group_by(cup) %>%
  mutate(rank = row_number(),
         `term frequency` = n/total)
freq_by_rank %>%
  ggplot(aes(rank, `term frequency`, color = cup)) +
  geom_line(size = 1, alpha = 0.8, show.legend = TRUE) +
  scale_x_log10() +
  scale_y_log10()

# Now we a producing a table for plotting
palavras.imp  <- freq_by_rank  %>%
  bind_tf_idf(word, cup, n)


## -----------------------------------------------------------------------------------------
library(knitr)
kable(palavras.imp [1:15,], caption = "Words and their importance")


## -----------------------------------------------------------------------------------------
palavras.imp  %>%
  arrange(desc(tf_idf)) %>%
  mutate(word = factor(word, levels = rev(unique(word)))) %>%
  group_by(cup) %>%
  top_n(10) %>%
  ungroup %>%
  ggplot(aes(word, tf_idf, fill = cup)) +
  geom_col(show.legend = FALSE) +
  labs(x = NULL, y = "tf-idf") +
  facet_wrap(~cup, ncol = 2, scales = "free") +
  coord_flip()


## -----------------------------------------------------------------------------------------
palavras.imp  %>%
  arrange(desc(tf_idf)) %>%
  mutate(word = factor(word, levels = rev(unique(word)))) %>%
  group_by(cup) %>%
  top_n(10) %>%
  ungroup %>%
  ggplot(aes(word, tf_idf, fill = cup)) +
  geom_col(show.legend = FALSE) +
  labs(x = NULL, y = "tf-idf") +
  facet_wrap(~cup, ncol = 2, scales = "free") +
  coord_flip()


## -----------------------------------------------------------------------------------------
# Creating a corpus out of a set of strings. Here processing 2008 
corpus.cluster.2018 <- Corpus(VectorSource(c.2018))


## -----------------------------------------------------------------------------------------
# The text is clean removing URL and other unwanted features. It is possible you have to get some words awaya by hand, as I did in the last line
corpus.cluster.2018 <- tm_map(corpus.cluster.2018, content_transformer(tolower))
removeURL <- function(x) gsub("http[[:alnum:][:punct:]]*", "", x) 
remove.users <-function(x) gsub("@[[:alnum:][:punct:]]*","",x)
corpus.cluster.2018 <- tm_map(corpus.cluster.2018, content_transformer(removeURL))
corpus.cluster.2018 <- tm_map(corpus.cluster.2018,content_transformer(remove.users))
corpus.cluster.2018 <- tm_map(corpus.cluster.2018, stripWhitespace)
corpus.cluster.2018 <- tm_map(corpus.cluster.2018, removePunctuation)
corpus.cluster.2018 <- tm_map(corpus.cluster.2018, 
                              function(x)removeWords(x,c(stopwords("en"),"bst","min","getty")))


## -----------------------------------------------------------------------------------------
#Now we are going to create a Document Matrix (see example above)
corpus.cluster.2018.tdm <- TermDocumentMatrix(corpus.cluster.2018)


## -----------------------------------------------------------------------------------------
#Deleting sparce words
corpus.cluster.2018.tdm <- removeSparseTerms(corpus.cluster.2018.tdm, sparse = 0.999)
cluster.2018.df <- as.data.frame(inspect(corpus.cluster.2018.tdm))


## -----------------------------------------------------------------------------------------
#Calculating distance amongst words
## Using Eucledean measurement
cluster.df.scale.2018 <- scale(cluster.2018.df)
cluster.d.2018 <- dist(cluster.2018.df, method = "euclidean")


## -----------------------------------------------------------------------------------------
#Ploting using the Ward Method
fit.ward2 <- hclust(cluster.d.2018, method = "ward.D2")
plot(fit.ward2)


## -----------------------------------------------------------------------------------------
#Creating a "Qunateda Corpus"
library(quanteda)
corpus.2018 <- corpus(clean.2018)


## -----------------------------------------------------------------------------------------
#Creating a data frame for processing the data. 
#Cleaning some custom words (those a more related to technical internet routine)
corpus.2018.df <- dfm(corpus.2018,
                      remove_numbers = TRUE, 
                      remove_punct = TRUE,
                      remove_symbols = TRUE,
                      verbose  = T) %>% 
  dfm_remove(c(stopwords("english"), "bst","min","getty","t", "s", "m","one", "re","ve","pm"))



## -----------------------------------------------------------------------------------------
#Deliting words which occur less than 20 times
corpus.2018.select.df <- dfm_trim(corpus.2018.df, min_termfreq = 20)


## -----------------------------------------------------------------------------------------
#Creating a Features frequence matrix
corpus.2018.select.fcm <- fcm(corpus.2018.select.df)


## -----------------------------------------------------------------------------------------
#Selecting the 50 more frequent words
corpus.2018.topfeats <-names(topfeatures(corpus.2018.df,50))
select.2018 <- fcm_select(corpus.2018.select.fcm, pattern = corpus.2018.topfeats)


## -----------------------------------------------------------------------------------------
#Calculating the size of the network
size <- log(colSums(dfm_select(corpus.2018.select.fcm, corpus.2018.topfeats)))


## -----------------------------------------------------------------------------------------
#Ploting the network in dark grey
set.seed(100)
textplot_network(fcm_select(corpus.2018.select.fcm, corpus.2018.topfeats),min_freq =0.8,
                 vertex_size = size/max(size)*3, edge_color="darkgray")

