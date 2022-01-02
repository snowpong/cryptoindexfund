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
  filter(!symbol %in% stablecoins$symbol)

index_fund <- marketcap_excluding_stablecoins %>%
  mutate(market_cap_squared = sqrt(market_cap)) %>%
  arrange(market_cap_rank) %>%
  slice_head(n = 10) %>%
  mutate(percentage = market_cap_squared / sum(market_cap_squared)) %>%
  mutate(label = sprintf("%s %.0f%%", symbol, percentage * 100))

ggplot(index_fund, aes(x = "", y = percentage, fill = reorder(label, -percentage))) +
  geom_col() +
  geom_text(aes(label = symbol), position = position_stack(vjust = 0.5)) +
  coord_polar(theta = "y", start = 0) +
  theme_void()
