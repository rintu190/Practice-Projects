# pip install yfinance pandas matplotlib scikit-learn

import yfinance as yf
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, classification_report

# -----------------------------
# 1. Fetch historical NSE data
# -----------------------------
symbol = "BAJFINANCE.NS"
start_date = "2025-01-01"
end_date = "2025-10-25"

data = yf.download(symbol, start=start_date, end=end_date)
data = data[['Open','High','Low','Close','Volume']]

# Ensure Series
close = data['Close'].iloc[:,0] if isinstance(data['Close'], pd.DataFrame) else data['Close']
high = data['High'].iloc[:,0] if isinstance(data['High'], pd.DataFrame) else data['High']
low = data['Low'].iloc[:,0] if isinstance(data['Low'], pd.DataFrame) else data['Low']
volume = data['Volume'].iloc[:,0] if isinstance(data['Volume'], pd.DataFrame) else data['Volume']

# -----------------------------
# 2. Technical Indicators
# -----------------------------
data['SMA_20'] = close.rolling(20).mean()
data['EMA_20'] = close.ewm(span=20, adjust=False).mean()

# RSI
delta = close.diff()
gain = delta.clip(lower=0)
loss = -delta.clip(upper=0)
avg_gain = gain.rolling(14).mean()
avg_loss = loss.rolling(14).mean()
rs = avg_gain / avg_loss
data['RSI'] = 100 - (100 / (1 + rs))

# MACD
ema_12 = close.ewm(span=12, adjust=False).mean()
ema_26 = close.ewm(span=26, adjust=False).mean()
data['MACD'] = ema_12 - ema_26
data['Signal'] = data['MACD'].ewm(span=9, adjust=False).mean()

# Bollinger Bands
data['BB_Mid'] = close.rolling(20).mean()
rolling_std = close.rolling(20).std()
data['BB_Upper'] = data['BB_Mid'] + 2*rolling_std
data['BB_Lower'] = data['BB_Mid'] - 2*rolling_std

# ATR
high_low = high - low
high_close = (high - close.shift()).abs()
low_close = (low - close.shift()).abs()
tr = pd.concat([high_low, high_close, low_close], axis=1).max(axis=1)
data['ATR_14'] = tr.rolling(14).mean()

# Stochastic Oscillator
low_14 = low.rolling(14).min()
high_14 = high.rolling(14).max()
data['%K'] = 100 * (close - low_14) / (high_14 - low_14)
data['%D'] = data['%K'].rolling(3).mean()

# OBV
obv = [0]
for i in range(1, len(data)):
    if close[i] > close[i-1]:
        obv.append(obv[-1] + volume[i])
    elif close[i] < close[i-1]:
        obv.append(obv[-1] - volume[i])
    else:
        obv.append(obv[-1])
data['OBV'] = obv

# CCI
tp = (high + low + close) / 3
sma_tp = tp.rolling(20).mean()
mad = tp.rolling(20).apply(lambda x: (x - x.mean()).abs().mean())
data['CCI'] = (tp - sma_tp) / (0.015 * mad)

# -----------------------------
# 3. Prepare Target for Prediction
# -----------------------------
# 1 = price up next day, 0 = price down next day
data['Target'] = (close.shift(-1) > close).astype(int)

# Drop last row with NaN target
data = data[:-1]

# Features for ML
features = ['SMA_20','EMA_20','RSI','MACD','Signal','BB_Upper','BB_Lower',
            'ATR_14','%K','%D','OBV','CCI']
X = data[features].fillna(0)  # fill NaNs
y = data['Target']

# -----------------------------
# 4. Train/Test Split
# -----------------------------
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, shuffle=False)

# -----------------------------
# 5. Random Forest Classifier
# -----------------------------
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train, y_train)
preds = model.predict(X_test)

# -----------------------------
# 6. Evaluate
# -----------------------------
print("Accuracy:", accuracy_score(y_test, preds))
print(classification_report(y_test, preds))

# -----------------------------
# 7. Predict next-day movement
# -----------------------------
latest_features = X.iloc[-1].values.reshape(1, -1)
next_day_pred = model.predict(latest_features)[0]
movement = "Up" if next_day_pred == 1 else "Down"
print(f"Predicted next-day price movement for {symbol}: {movement}")
