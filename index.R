library(httr)
library(jsonlite)


response <- GET("https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc")

market_cap <- fromJSON(content(response, as = "text"), flatten = TRUE)
