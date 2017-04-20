#The scrapper is built on Rvest package for data scrapping and RSelenium for browser automation.
library(rvest)
require(RSelenium)

#Initializing Selenium server
RSelenium::startServer()
##Selenium requires browser path or uses mozilla as default. PhantomJS is common selection for its headless browsing feature.
##Useragent settings has been mentioned to avoid bot detection.
eCap <- list(phantomjs.binary.path = "[path/to/browser]", phantomjs.page.settings.userAgent = "Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36")
remDr <- remoteDriver(browserName = "phantomjs", extraCapabilities = eCap)
remDr$open() #Start Server
remDr$setWindowSize(width = 800, height = 300) #Optional

#Figuring url and query
base_url <- "https://www.google.co.uk/search?hl=en&gl=uk&tbm=nws&authuser=0&q="
query <- "Trump+Loves+Putin"
url <- paste0(base_url,query)

remDr$navigate(url) #Navigating browser against url
remDr$screenshot(display=T) #Optional, to view current page

news <- NULL

#A loop to  navigate through result pages, first 15 has been selected for the purpose.
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
remDr$close() #Closing Selenium server
back <- news #Backing up dataframe
news <- news[!duplicated(news$links),] #Removing duplicates

write.csv(news, "google-news.csv", col.names = TRUE, quote = FALSE, row.names = FALSE,na="")
