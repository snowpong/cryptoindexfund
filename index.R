library(ggplot2)
library(dplyr)
library(httr)
library(jsonlite)

marketcap_response <- GET("https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc")
marketcap <- fromJSON(content(marketcap_response, as = "text"), flatten = TRUE)

stablecoins_response <- GET("https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&category=stablecoins&order=market_cap_desc")
stablecoins <- fromJSON(content(stablecoins_response, as = "text"), flatten = TRUE)

binance_response <- GET("https://api.coingecko.com/api/v3/exchanges/binance")
binance <- fromJSON(content(binance_response, as = "text"), flatten = TRUE)
binance_symbols <- tolower(unique(c(binance$tickers$base, binance$tickers$target)))

marketcap_excluding_stablecoins <- marketcap %>%
  filter(symbol %in% binance_symbols) %>% 
  filter(!symbol %in% stablecoins$symbol) %>%
  mutate(market_cap_squared = sqrt(market_cap)) %>%
  arrange(market_cap_rank) %>%
  slice_head(n = 10)

# Create Data
data <- data.frame(
  group = marketcap_excluding_stablecoins$symbol,
  value = marketcap_excluding_stablecoins$market_cap_squared,
  percentage = marketcap_excluding_stablecoins$market_cap_squared /
    sum(marketcap_excluding_stablecoins$market_cap_squared)
)

# Basic piechart
ggplot(data, aes(x="", y=value, fill=group)) + 
  geom_bar(stat="identity", width=1) +
  coord_polar("y", start=0)
