writeLines(
  "**Portuguese**:
  Este script foi desenvolvido como forma de auxiliar colegas da área de LC.
  Se você quiser discutir outras aplicações, por favor, me escreva:
  Contato: Rodrigo Esteves de Lima-Lopes
  rll307@unicamp.br
  Outros scripts: http://www.iel.unicamp.br")

writeLines (
  "**English**:
  This script was developed as a way to assist colleagues in the LC area.
  If you need more information or would like to discuss further applications,
  please, drop me a line:
  Contact: Rodrigo Esteves de Lima-Lopes
  rll307@unicamp.br
  Other scripts: http://www.iel.unicamp.br ")


#' ---
#' title: 'Football and Web: Lexical Analysis of a Genre through Time'
#' author: "Rodrigo Esteves de Lima Lopes"
#' output: html_document
#' ---
#' 
# Lima-Lopes, Rodrigo Esteves de. 2020. ‘Football and Web: Lexical Analysis of a Genre through Time’. *Papéis: Revista do Programa de Pós-Graduação em Estudos de Linguagens* - UFMS 24 (47): 150–78. Available at [link](https://seer.ufms.br/index.php/papeis/article/view/9295)
# 
# I would it to be  a contribution to the replicability of studies in Applied Linguistics field. 
# 
# Please, if you have any comment, you can find me at: rll307@unicamp.br

#' 
#' ## Objectives
#'  - To study lexical choices in a group of sport news through a
#' diachronic corpus
#' 
#' ## Hypothesis:
#' - If the growth of importance in the internet news would change lexical choices within sports news. 
#' 
#' ## Motivation
#' * There has been a number of studies discussing the visual impact
#' of technology in layout and image/text relationship, but very few
#' comparing lexical changes
#' * Most of lexical and discussion is centred on platforms that were created for digital interaction
#' 
#' # Data collection and processing
#' The data for this study was a set of sports news from the Bristish newspaper The Guardian. The following createria was followed:
#' 
#' * Only sports articles published in the months of the World Cup were considered;
#' * Genres that did not fit the classification of *sports articles* were discarded;
#'    + Amongst the despised genres are: quizzes, letters from readers and chronicles;
#' * No photo or video galleries were considered;
#'    + The focus of this work was the written material.
#' 
#' articles in the given period for research, all articles referring to the World Cups studied were collected. 
#' 
#' Since Guardian's API allows the total scraping the total of the articles in the given period for research, all articles referring to the World Cups studied were collected.
#' 
#' 
#' Data was collected through data scraping using [R](https://www.r-project.org/):
#' 
#' - Package [GuardianR](https://cran.r-project.org/web/packages/GuardianR/index.html)
#'   - Data scraping using [Guardians’s API](https://open-platform.theguardian.com/documentation/)
#' 
#' 
#' - Data processing using the following packages
#'   1. [tm](https://cran.r-project.org/web/packages/tm/tm.pdf)
#'     * Used for cleaning the corpus and producing dendrogram hierarchical clustering
#'   2. [tidytext](https://cran.r-project.org/web/packages/tidytext/index.html)
#'     * Used for producing weighted wordlists
#'   3. [quanteda](https://quanteda.io/)
#'     * Used for producing network graphs
#' 
#' Lexical items were calculated using three measurements. Product of TF X IDF:
#' 
#' * Term Frequency(TF): measures the frequency of a term in a document
#' * Inverse document frequency(IDF): weights down the importance of more frequent words and scales up the rarer ones
#' 
#' Network Graph
#' * A matrix of words was calculated thought co-occurrence
#' 
#' |    |  I | like | traveling | to | Argentina |
#' |:--:|:--:|:----:|:---------:|:--:|:---------:|
#' | D1 | 10 | 20   | 11        | 22 | 0         |
#' | D2 | 1  | 2    | 33        | 3  | 1         |
#' Table 1: Example of Matrix
#' 
#' # The scripts
#' 
#' ## The packages
#' These are the necesssary packages for the commands to run:
#' 
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

#' 
#' ## Collecting the articles
#' 
#' 
#' 
## -----------------------------------------------------------------------------------------
#The command bellow will interact with the Newspapers API and scrape the data from 2002 world cup.
#Try one for each Cup  you are interested in. Gardian makes possible to collect data back to 1999. 

cup2002 <- get_guardian("world+cup",
                        section="football",
                        from.date="2002-05-31",
                        to.date="2002-06-30",
                        api.key="my API key")

#' 
#' Just repeat this same command for the World Cups from 2006 to 2018. **My API Key** stands for an unique code that the Guardian's API makes available for each researcher. 
#' 
#' ## Save as a character
#' 
#' The command bellow takes only the text of the result database and saves it as an string for later use. 
#' 
## -----------------------------------------------------------------------------------------
your.text.string <- paste(as.character(cup2002$body))

#' 
#' ## Cleaning the texts and making dendrograms
#' These are a set of functions one might use for cleaning the texts before making the dendrograms. 
#' 
## ----clean_funtion_01---------------------------------------------------------------------
limpar_texto.html <- function(x) {
  return(gsub("<.*?>", "", x))
} #Cleans special HRML codes

#' 
## -----------------------------------------------------------------------------------------
limpar.pontuacao <- function(x){
  return(gsub(pattern = "\\W"," ",x))
} #Cleans unnecessary paragraphs 

#' 
## -----------------------------------------------------------------------------------------
limpar_texto.espacos <- function(x) {
  return(str_squish(x))
}#Cleans unnecessary spaces

#' 
## -----------------------------------------------------------------------------------------
limpar.letras.soltas <- function(x){
  return(gsub("\\b[A-z]\\b{1}", " ", x))
}

#' 
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

#' 
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

#' 
#' Now lets apply a stoplists to the data. I used an ordinary stoplists of English, so grammatical words would be ingored in the word lists
#' 
## -----------------------------------------------------------------------------------------
#Make a dataframe out of your string
your.text.df <- data.frame(text = your.text, stringsAsFactors = F)

#Apply the stopwords
your.text.df  <- your.text.df  %>%
  unnest_tokens(word, text)%>%
  anti_join(stop_words)

#Repete one time for each World Cup

#' 
#' Now let us compare some frequence. I will guide you step by step.
#' 
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

#' 
## -----------------------------------------------------------------------------------------
#This will add a total for each word cup
frequency.cups.total <- frequency.cups %>%
  group_by(cup) %>%
  summarize(total = sum(n))


#' 
## -----------------------------------------------------------------------------------------
#Now we join them together
frequency.cups.total <- left_join(frequency.cups,frequency.cups.total)

#' 
#' The result might look like this:
#' 
## ---- results="asis"----------------------------------------------------------------------
library(knitr)
kable(frequency.cups.total[1:10,], caption = "Head of List")

#' 
#' 
#' This table does not tell us much. THis is beacuse words are not organised bby their frequency or their importance. 
#' 
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

#' 
#' This table should look like something like this:
#' 
## -----------------------------------------------------------------------------------------
library(knitr)
kable(palavras.imp [1:15,], caption = "Words and their importance")

#' 
#' This is a command to plot the list as we saw at the original paper. Printing the top ten
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

#' 
#' 
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

#' 
#' ## Dendrogram hierarchical clustering
#' 
#' In order to to the clustering, we will reprocess the corpus. Much of what we will be doing now is related to the TM package. This data processes each year individually. 
#' 
## -----------------------------------------------------------------------------------------
# Creating a corpus out of a set of strings. Here processing 2008 
corpus.cluster.2018 <- Corpus(VectorSource(c.2018))

#' 
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

#' 
## -----------------------------------------------------------------------------------------
#Now we are going to create a Document Matrix (see example above)
corpus.cluster.2018.tdm <- TermDocumentMatrix(corpus.cluster.2018)

#' 
## -----------------------------------------------------------------------------------------
#Deleting sparce words
corpus.cluster.2018.tdm <- removeSparseTerms(corpus.cluster.2018.tdm, sparse = 0.999)
cluster.2018.df <- as.data.frame(inspect(corpus.cluster.2018.tdm))

#' 
## -----------------------------------------------------------------------------------------
#Calculating distance amongst words
## Using Eucledean measurement
cluster.df.scale.2018 <- scale(cluster.2018.df)
cluster.d.2018 <- dist(cluster.2018.df, method = "euclidean")

#' 
## -----------------------------------------------------------------------------------------
#Ploting using the Ward Method
fit.ward2 <- hclust(cluster.d.2018, method = "ward.D2")
plot(fit.ward2)

#' 
#' # Network of words
#' 
#' The idead behind this network is making a clearer view of the main collocates whithin a text. Its calculation relies in thq [Quanteda package](https://quanteda.io/). The example here also relies on 2018 world cup, but you can apply it to all data. 
#' 
## -----------------------------------------------------------------------------------------
#Creating a "Qunateda Corpus"
library(quanteda)
corpus.2018 <- corpus(clean.2018)

#' 
## -----------------------------------------------------------------------------------------
#Creating a data frame for processing the data. 
#Cleaning some custom words (those a more related to technical internet routine)
corpus.2018.df <- dfm(corpus.2018,
                      remove_numbers = TRUE, 
                      remove_punct = TRUE,
                      remove_symbols = TRUE,
                      verbose  = T) %>% 
  dfm_remove(c(stopwords("english"), "bst","min","getty","t", "s", "m","one", "re","ve","pm"))


#' 
## -----------------------------------------------------------------------------------------
#Deliting words which occur less than 20 times
corpus.2018.select.df <- dfm_trim(corpus.2018.df, min_termfreq = 20)

#' 
## -----------------------------------------------------------------------------------------
#Creating a Features frequence matrix
corpus.2018.select.fcm <- fcm(corpus.2018.select.df)

#' 
## -----------------------------------------------------------------------------------------
#Selecting the 50 more frequent words
corpus.2018.topfeats <-names(topfeatures(corpus.2018.df,50))
select.2018 <- fcm_select(corpus.2018.select.fcm, pattern = corpus.2018.topfeats)

#' 
## -----------------------------------------------------------------------------------------
#Calculating the size of the network
size <- log(colSums(dfm_select(corpus.2018.select.fcm, corpus.2018.topfeats)))

#' 
## -----------------------------------------------------------------------------------------
#Ploting the network in dark grey
set.seed(100)
textplot_network(fcm_select(corpus.2018.select.fcm, corpus.2018.topfeats),min_freq =0.8,
                 vertex_size = size/max(size)*3, edge_color="darkgray")
