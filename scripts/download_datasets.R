# Install packages if missing
pkgs <- c("quantmod", "gtrendsR", "readr")
to_install <- pkgs[!pkgs %in% installed.packages()[, "Package"]]
if(length(to_install)) install.packages(to_install)

library(quantmod)
library(gtrendsR)
library(readr)

dir.create("datasets", showWarnings = FALSE)

start_date <- as.Date("2020-01-01") # Before Covid to current date
end_date   <- Sys.Date()

# ---------------- S&P 500 ----------------
getSymbols("^GSPC", src="yahoo", from=start_date, to=end_date)

sp500 <- data.frame(
  date   = index(GSPC),
  open   = Op(GSPC),
  high   = Hi(GSPC),
  low    = Lo(GSPC),
  close  = Cl(GSPC),
  volume = Vo(GSPC)
)

write_csv(sp500, "datasets/sp500.csv")

# ---------------- VIX (Fear Index) ----------------
getSymbols("^VIX", src="yahoo", from=start_date, to=end_date)

vix <- data.frame(
  date = index(VIX),
  vix_close = Cl(VIX)
)

write_csv(vix, "datasets/vix.csv")

# ---------------- Google Trends ----------------
# Make sure dates are base R Dates (not zoo's)
start_date <- base::as.Date("2020-01-01")
end_date   <- base::as.Date("2021-01-01")

# Convert to the exact format Google Trends expects
time_str <- paste0(
  format(start_date, "%Y-%m-%d"),
  " ",
  format(end_date, "%Y-%m-%d")
)

print(time_str)  # sanity check: should look like "2020-01-01 2026-02-05"

terms <- c("recession", "stock market crash", "buy stocks now")

gt <- gtrendsR::gtrends(
  keyword = terms,
  geo     = "US",
  time    = time_str
)

gt_data <- gt$interest_over_time[, c("date","keyword","hits")]
readr::write_csv(gt_data, "datasets/google_trends.csv")

message("All datasets saved in /datasets folder ✅")