# pip install yfinance mplfinance pandas numpy scipy

import yfinance as yf
import pandas as pd
import numpy as np
import mplfinance as mpf
from scipy.signal import argrelextrema

# -----------------------------
# 1. Fetch historical NSE data
# -----------------------------
symbol = "RELIANCE.NS"
start_date = "2025-01-01"
end_date = "2025-10-25"

data = yf.download(symbol, start=start_date, end=end_date)
data = data.ffill()

# Flatten MultiIndex columns if yfinance returns multi-level
if isinstance(data.columns, pd.MultiIndex):
    data.columns = [col[1] if col[0]==symbol else col[0] for col in data.columns]

# Ensure all required columns exist
data = data[['Open','High','Low','Close','Volume']]

# -----------------------------
# 2. Candlestick Patterns
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

# -----------------------------
# 3. Marker function for mplfinance
# -----------------------------
apds = []

def add_marker(pattern, color, marker):
    # Ensure 1D Series
    if isinstance(pattern, pd.DataFrame):
        pattern = pattern.iloc[:,0]
    elif not isinstance(pattern, pd.Series):
        pattern = pd.Series(pattern, index=data.index)
    if pattern.any():
        apds.append(mpf.make_addplot(
            pattern.astype(float) * data['High'], 
            type='scatter', markersize=100, marker=marker, color=color
        ))

add_marker(doji, 'blue', 'o')
add_marker(hammer, 'green', '^')
add_marker(shooting_star, 'red', 'v')
add_marker(bull_engulf, 'green', '^')
add_marker(bear_engulf, 'red', 'v')

# -----------------------------
# 4. Support & Resistance
# -----------------------------
window = 5
local_min_idx = argrelextrema(data['Low'].values, np.less_equal, order=window)[0]
local_max_idx = argrelextrema(data['High'].values, np.greater_equal, order=window)[0]

local_min = data['Low'].iloc[local_min_idx]
local_max = data['High'].iloc[local_max_idx]

support_levels = local_min.values
resistance_levels = local_max.values

for lvl in support_levels:
    apds.append(mpf.make_addplot([lvl]*len(data), type='line', linestyle='--', color='green'))
for lvl in resistance_levels:
    apds.append(mpf.make_addplot([lvl]*len(data), type='line', linestyle='--', color='red'))

# -----------------------------
# 5. Trendlines
# -----------------------------
def draw_trendline(points, color):
    points = points.sort_index()
    for i in range(len(points)-1):
        x = [points.index[i], points.index[i+1]]
        y = [points.iloc[i], points.iloc[i+1]]
        trendline = pd.Series(index=data.index, dtype=float)
        trendline.loc[x[0]] = y[0]
        trendline.loc[x[1]] = y[1]
        trendline = trendline.interpolate(method='index')
        apds.append(mpf.make_addplot(trendline, type='line', linestyle='-', color=color))

draw_trendline(local_min, 'darkgreen')
draw_trendline(local_max, 'darkred')

# -----------------------------
# 6. High-Probability Buy/Sell Breakouts
# -----------------------------
volume_ma = data['Volume'].rolling(20).mean()
buy_signal = pd.Series(False, index=data.index)
sell_signal = pd.Series(False, index=data.index)

for lvl in resistance_levels:
    buy_signal |= (data['Close'] > lvl) & (data['Volume'] > volume_ma) & (bull_engulf | hammer)

for lvl in support_levels:
    sell_signal |= (data['Close'] < lvl) & (data['Volume'] > volume_ma) & (bear_engulf | shooting_star)

# -----------------------------
# 7. Risk/Reward Zones
# -----------------------------
risk_reward = 1.5
buy_sl = data['Low'] - (data['High'] - data['Low'])
buy_target = data['Close'] + (data['Close'] - buy_sl) * risk_reward
sell_sl = data['High'] + (data['High'] - data['Low'])
sell_target = data['Close'] - (sell_sl - data['Close']) * risk_reward

buy_target_zone = buy_signal * buy_target
buy_sl_zone = buy_signal * buy_sl
sell_target_zone = sell_signal * sell_target
sell_sl_zone = sell_signal * sell_sl

apds.append(mpf.make_addplot(buy_signal*data['Low'], type='scatter', markersize=150, marker='^', color='lime'))
apds.append(mpf.make_addplot(sell_signal*data['High'], type='scatter', markersize=150, marker='v', color='red'))
apds.append(mpf.make_addplot(buy_target_zone, type='line', linestyle='-.', color='green'))
apds.append(mpf.make_addplot(buy_sl_zone, type='line', linestyle='-.', color='darkgreen'))
apds.append(mpf.make_addplot(sell_target_zone, type='line', linestyle='-.', color='red'))
apds.append(mpf.make_addplot(sell_sl_zone, type='line', linestyle='-.', color='darkred'))

# -----------------------------
# 8. Plot Candlestick Chart
# -----------------------------
mpf.plot(data, type='candle', style='charles', volume=True,
         title=f'{symbol} Price Action with Signals & Risk/Reward Zones',
         addplot=apds, figsize=(14,7))
