## Football and Web: Lexical Analysis of a Genre through Time


The aim of this document is to discuss the methodological procedures followed in my article Football and Web: Lexical Analysis of a Genre through Time. The article is available at:

Lima-Lopes, Rodrigo Esteves de. 2020. ‘Football and Web: Lexical Analysis of a Genre through Time’. *Papéis: Revista do Programa de Pós-Graduação em Estudos de Linguagens* - UFMS 24 (47): 150–78. Available at [link](https://seer.ufms.br/index.php/papeis/article/view/9295)

I would it to be  a contribution to the replicability of studies in Applied Linguistics field. 

Please, if you have any comment, you can find me at: [rll307@unicamp.br](<mailto:rll307@unicamp.com?subject="Football and web">)

## Objective
- To study lexical choices in a group of sport news through a diachronic corpus

## Hypothesis
- If the growth of importance in the internet news would change lexical choices within sports news.

## Motivation
- There has been a number of studies discussing the visual impact of technology in layout and image/text relationship, but very few comparing lexical changes
- Most of lexical and discussion is centred on platforms that were created for digital interaction

## Guardian API
For this study we will need a API development code from the Guardian. It is a simple processes, the The Open Platform is available [here]https://open-platform.theguardian.com/)

## Data collection and processing
The data for this study was a set of sports news from the Bristish newspaper The Guardian. The following createria was followed:

- Only sports articles published in the months of the World Cup were considered;
- Genres that did not fit the classification of sports articles were discarded;
    - Amongst the despised genres are: quizzes, letters from readers and chronicles;
- No photo or video galleries were considered;
    - The focus of this work was the written material.
- All articles referring to the World Cups studied were collected.

Since Guardian’s API allows the total scraping the total of the articles in the given period for research, all articles referring to the World Cups studied were collected.

### Data was collected through data scraping using R:

- [Package GuardianR](https://cran.r-project.org/web/packages/GuardianR/index.html)
    - Data scraping using Guardians’s API
- Data processing using the following packages
    1. [tm](https://cran.r-project.org/web/packages/tm/tm.pdf)
        - Used for cleaning the corpus and producing dendrogram hierarchical clustering
    2. [Tidytext](https://cran.r-project.org/web/packages/tidytext/index.html)
        - Used for producing weighted wordlists
    3. [Quanteda](https://quanteda.io/)
        - Used for producing network graphs

### Lexical items were calculated using three measurements. Product of TF X IDF:

- Term Frequency(TF): measures the frequency of a term in a document
- Inverse document frequency(IDF): weights down the importance of more frequent words and scales up the rarer ones
- A Network Graph was calculated thought co-occurrence matrix
