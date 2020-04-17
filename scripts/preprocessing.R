#ładownie bibliotek

#zmiana katalogu roboczego
workDir <- "~/Studia/PJN"
setwd(workDir)

#lokalizacja katalogów funkcjonalnych
inputDir <- "./data"
outputDir <- "./results"
dir.create(outputDir, showWarnings = FALSE)

#utworzenie korpusu dokumentów
corpusDir <- paste(
  inputDir,
  "Literatura - streszczenia - orginał",
  sep = "/"
)
corpus <- VCorpus(
  DirSource(
    corpusDir,
    pattern = "*.txt",
    encoding = "UTF-8"
  ),
  readerControl = list(
    language = "pl_PL"
  )
)

#wstępne przetwarzanie
corpus <- tm_map(corpus,removeNumbers)
corpus <- tm_map(corpus,removePunctuation)
corpus <- tm_map(corpus,content_transformer(tolower))

stoplistFile <- paste(
  inputDir,
  "stopwords_pl.txt",
  sep = "/"
)

stoplist <- readLines(stoplistFile, encoding = "UTF-8")
corpus <- tm_map(corpus, removeWords, stoplist)
corpus <- tm_map(corpus, stripWhitespace)

#usunięcie z tekstów em dash i 3/4
removeChar <- content_transformer(function(text,pattern) gsub(pattern, "", text))
corpus <- tm_map(corpus, removeChar, intToUtf8(8722))
corpus <- tm_map(corpus, removeChar, intToUtf8(190))

#usunięcie rozszerzeń z nazw dokumentów
cutExtensions <- function(document, extension) {
  meta(document, "id") <- gsub(paste("\\.",extension,"$", sep=""),"", meta(document, "id"))
  return(document)
}
corpus <- tm_map(corpus, cutExtensions, "txt")

#usunięcie podziału na akapity z tekstu
pasteParagraph <- content_transformer(function(text, char) paste(text, collapse = char))
corpus <- tm_map(corpus, pasteParagraph, " ")
