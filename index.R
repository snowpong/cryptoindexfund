library(dplyr)
library(httr)
library(jsonlite)

marketcap_response <- GET("https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc")
marketcap <- fromJSON(content(marketcap_response, as = "text"), flatten = TRUE)

stablecoins_response <- GET("https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&category=stablecoins&order=market_cap_desc")
stablecoins <- fromJSON(content(stablecoins_response, as = "text"), flatten = TRUE)

marketcap_excluding_stablecoins <- marketcap %>%
  filter(!symbol %in% stablecoins$symbol) %>%
  arrange(market_cap_rank)
