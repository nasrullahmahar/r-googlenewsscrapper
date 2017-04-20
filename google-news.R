library(rvest)
require(RSelenium)

RSelenium::startServer()
eCap <- list(phantomjs.binary.path = "C:/Users/Nouman R Khan/Downloads/zillow_script/zillow_script/phantomjs-2.1.1-windows/bin/phantomjs.exe", phantomjs.page.settings.userAgent = "Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36")
remDr <- remoteDriver(browserName = "phantomjs", extraCapabilities = eCap)
remDr$open()
remDr$setWindowSize(width = 800, height = 300)

base_url <- "https://www.google.co.uk/search?hl=en&gl=uk&tbm=nws&authuser=0&q="
query <- "Morley+Town+Leeds"
url <- paste0(base_url,query)

remDr$navigate(url)
remDr$screenshot(display=T)

news <- NULL
for(i in 1:15)
{
  page <- read_html(remDr$getPageSource()[[1]])
  links <- page %>% html_nodes(xpath="//*[@id=\'rso\']/div[1]/div/div/div/h3/a") %>% html_attr('href')
  title <- page %>% html_nodes(xpath="//*[@id=\'rso\']/div[1]/div/div/div/h3") %>% html_text()
  temp <- cbind.data.frame(title, links)
  news <- rbind(news, temp)
  webElem <- remDr$findElement('xpath','//*[@id="pnnext"]/span[2]')
  webElem$clickElement()
  Sys.sleep(5)
  print(i)
}
remDr$close()
back <- news

news <- news[!duplicated(news$links),]

news <- back[grepl("yorkshireevening",back$links),]
news$links <- as.character(news$links)

news$date <- NA
news$text <- NA

for(i in 1:nrow(news))
{
  url <- news$links[i]
  page <- read_html(url)
  text <- page %>% html_node("section.article-content.article__content") %>% html_text()
  text <- gsub("[\r\t\n]|Have your say", "", text)
  text <- gsub("  ", " ", text)
  news$text[i] <- text
  news$date[i] <- page %>% html_node("span.timestamp__date") %>% html_text()
  print(i)
}

write.table(news, "Morley-Town-articles.txt", sep="~", col.names = TRUE, quote = FALSE, row.names = FALSE,na="")
