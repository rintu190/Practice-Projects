# pip install yfinance mplfinance pandas numpy

import yfinance as yf
import pandas as pd
import numpy as np
import mplfinance as mpf

# -----------------------------
# 1. Fetch historical NSE data
# -----------------------------
symbol = "RELIANCE.NS"
start_date = "2025-01-01"
end_date = "2025-10-25"

data = yf.download(symbol, start=start_date, end=end_date)
data = data[['Open','High','Low','Close','Volume']]

# -----------------------------
# 2. Ensure numeric 1D Series
# -----------------------------
for col in ['Open','High','Low','Close','Volume']:
    # Flatten if 2D
    if isinstance(data[col], pd.DataFrame):
        data[col] = data[col].iloc[:,0]
    data[col] = pd.to_numeric(data[col], errors='coerce')

# Fill missing values
data = data.ffill()

# -----------------------------
# 3. Candlestick Pattern Detection
# -----------------------------
doji = np.abs(data['Close'] - data['Open']) <= 0.1 * (data['High'] - data['Low'])
hammer = ((data['High'] - data['Low']) > 3*(data['Open'] - data['Close'])) & \
         (((data['Close'] - data['Low']) / (0.001 + data['High'] - data['Low'])) > 0.6)
shooting_star = ((data['High'] - data['Low']) > 3*(data['Open'] - data['Close'])) & \
                (((data['High'] - data['Close']) / (0.001 + data['High'] - data['Low'])) > 0.6)
bull_engulf = (data['Close'].shift(1) < data['Open'].shift(1)) & (data['Close'] > data['Open']) & \
              (data['Close'] > data['Open'].shift(1)) & (data['Open'] < data['Close'].shift(1))
bear_engulf = (data['Close'].shift(1) > data['Open'].shift(1)) & (data['Close'] < data['Open']) & \
              (data['Close'] < data['Open'].shift(1)) & (data['Open'] > data['Close'].shift(1))
tweezer_top = (data['High'] == data['High'].shift(1)) & (data['Close'] < data['Open'])
tweezer_bottom = (data['Low'] == data['Low'].shift(1)) & (data['Close'] > data['Open'])
morning_star = (data['Close'].shift(2) < data['Open'].shift(2)) & \
               (data['Close'].shift(1) < data['Open'].shift(1)) & \
               (data['Close'] > data['Open'].shift(2))
evening_star = (data['Close'].shift(2) > data['Open'].shift(2)) & \
               (data['Close'].shift(1) > data['Open'].shift(1)) & \
               (data['Close'] < data['Open'].shift(2))
piercing = (data['Close'].shift(1) < data['Open'].shift(1)) & \
           (data['Close'] > (data['Open'].shift(1)+data['Close'].shift(1))/2) & \
           (data['Open'] < data['Close'].shift(1))
dark_cloud = (data['Close'].shift(1) > data['Open'].shift(1)) & \
             (data['Close'] < (data['Open'].shift(1)+data['Close'].shift(1))/2) & \
             (data['Open'] > data['Close'].shift(1))
bull_harami = (data['Close'].shift(1) < data['Open'].shift(1)) & \
              (data['Close'] > data['Open']) & \
              (data['Close'] < data['Open'].shift(1)) & \
              (data['Open'] > data['Close'].shift(1))
bear_harami = (data['Close'].shift(1) > data['Open'].shift(1)) & \
              (data['Close'] < data['Open']) & \
              (data['Close'] > data['Open'].shift(1)) & (data['Open'] < data['Close'].shift(1))
inverted_hammer = ((data['High'] - data['Low']) > 3*(data['Close'] - data['Open'])) & \
                  (((data['High'] - data['Close']) / (0.001 + data['High'] - data['Low'])) > 0.6)
pin_bar_bull = (data['Close'] > data['Open']) & ((data['Low'] + data['Close'])/2 < data['Open'])
pin_bar_bear = (data['Close'] < data['Open']) & ((data['High'] + data['Close'])/2 > data['Open'])

# -----------------------------
# 4. Prepare Markers for Plot
# -----------------------------
apds = []

def add_marker(pattern, color, marker):
    # Convert boolean to numeric
    numeric_pattern = pattern.astype(int)
    if numeric_pattern.sum() > 0:
        apds.append(
            mpf.make_addplot(numeric_pattern * data['High'], 
                             type='scatter', markersize=100, marker=marker, color=color)
        )

# Add all patterns
patterns = [
    (doji,'blue','o'), (hammer,'green','^'), (shooting_star,'red','v'),
    (bull_engulf,'green','^'), (bear_engulf,'red','v'), (tweezer_top,'red','v'),
    (tweezer_bottom,'green','^'), (morning_star,'green','^'), (evening_star,'red','v'),
    (piercing,'green','^'), (dark_cloud,'red','v'), (bull_harami,'green','^'),
    (bear_harami,'red','v'), (inverted_hammer,'green','^'), (pin_bar_bull,'green','^'),
    (pin_bar_bear,'red','v')
]

for pat in patterns:
    add_marker(*pat)

# -----------------------------
# 5. Plot Candlestick Chart
# -----------------------------
mpf.plot(data, type='candle', style='charles', volume=True,
         title=f'{symbol} Price with Candlestick Patterns',
         addplot=apds, figsize=(14,7))
