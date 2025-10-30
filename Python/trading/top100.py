# pip install yfinance pandas numpy scipy openpyxl

import yfinance as yf
import pandas as pd
import numpy as np
from scipy.signal import argrelextrema

# -----------------------------
# 1. Top 100 NSE stock symbols
# -----------------------------
top_100_symbols = [
    "RELIANCE.NS","TCS.NS","HDFCBANK.NS","INFY.NS","ICICIBANK.NS","HINDUNILVR.NS",
    "SBIN.NS","KOTAKBANK.NS","LT.NS","AXISBANK.NS","ITC.NS","BAJFINANCE.NS",
    "BHARTIARTL.NS","MARUTI.NS","HCLTECH.NS","NESTLEIND.NS","SUNPHARMA.NS","ULTRACEMCO.NS",
    "TECHM.NS","TITAN.NS","ONGC.NS","POWERGRID.NS","ADANIPORTS.NS","ASIANPAINT.NS",
    "DIVISLAB.NS","DRREDDY.NS","HDFCLIFE.NS","TATASTEEL.NS","JSWSTEEL.NS","COALINDIA.NS",
    "GRASIM.NS","BPCL.NS","EICHERMOT.NS","BRITANNIA.NS","SHREECEM.NS","HDFC.NS",
    "INDUSINDBK.NS","WIPRO.NS","M&M.NS","HINDALCO.NS","BAJAJFINSV.NS","TECHM.NS",
    "IOC.NS","HDFCAMC.NS","CIPLA.NS","UPL.NS","GAIL.NS","TATAMOTORS.NS","SBILIFE.NS",
    "VEDL.NS","LTTS.NS","HEROMOTOCO.NS","ICICIPRULI.NS","TATAPOWER.NS","LTI.NS",
    "MUTHOOTFIN.NS","HAVELLS.NS","PAGEIND.NS","PETRONET.NS","RECLTD.NS","TORNTPHARM.NS",
    "AJANTPHARM.NS","NMDC.NS","BOSCHLTD.NS","CONCOR.NS","SRF.NS","AUROPHARMA.NS",
    "BANKBARODA.NS","BEL.NS","ICICIGI.NS","NBCC.NS","MPHASIS.NS","INDIGO.NS","EXIDEIND.NS",
    "PEL.NS","CADILAHC.NS","ABB.NS","ALOKINDS.NS","ALKEM.NS","APOLLOHOSP.NS","BALKRISIND.NS",
    "BIOCON.NS","BERGEPAINT.NS","CHOLAFIN.NS","CROMPTON.NS","DLF.NS","FORTIS.NS","GLENMARK.NS",
    "HINDPETRO.NS","IBULHSGFIN.NS","JUBLFOOD.NS","KEI.NS","LICHSGFIN.NS","MRF.NS","NAUKRI.NS",
    "PEL.NS","PNB.NS","PIIND.NS","POWERINDIA.NS","RAMCOCEM.NS","RBLBANK.NS","SIEMENS.NS",
    "SRTRANSFIN.NS","TVSMOTOR.NS","UBL.NS","VOLTAS.NS","ZEEL.NS"
]

# -----------------------------
# 2. Function to detect high-probability trades
# -----------------------------
def detect_trade(stock_symbol):
    try:
        df = yf.download(stock_symbol, period="3mo", interval="1d")
        df = df[['Open','High','Low','Close','Volume']].ffill()
        
        if df.empty or len(df) < 20:
            return None

        # Candlestick patterns
        hammer = ((df['High'] - df['Low']) > 3*(df['Open'] - df['Close'])) & \
                 (((df['Close'] - df['Low']) / (0.001 + df['High'] - df['Low'])) > 0.6)
        shooting_star = ((df['High'] - df['Low']) > 3*(df['Open'] - df['Close'])) & \
                        (((df['High'] - df['Close']) / (0.001 + df['High'] - df['Low'])) > 0.6)
        bull_engulf = (df['Close'].shift(1) < df['Open'].shift(1)) & (df['Close'] > df['Open']) & \
                      (df['Close'] > df['Open'].shift(1)) & (df['Open'] < df['Close'].shift(1))
        bear_engulf = (df['Close'].shift(1) > df['Open'].shift(1)) & (df['Close'] < df['Open']) & \
                      (df['Close'] < df['Open'].shift(1)) & (df['Open'] > df['Close'].shift(1))
        
        # Support/Resistance
        local_min = df['Low'][argrelextrema(df['Low'].values, np.less_equal, order=5)[0]]
        local_max = df['High'][argrelextrema(df['High'].values, np.greater_equal, order=5)[0]]
        
        volume_ma = df['Volume'].rolling(20).mean()
        last_close = df['Close'].iloc[-1]
        last_volume = df['Volume'].iloc[-1]
        
        # High-probability buy
        buy = False
        buy_sl = np.nan
        buy_target = np.nan
        for lvl in local_max.values:
            if (last_close > lvl) and (last_volume > volume_ma.iloc[-1]) and (bull_engulf.iloc[-1] or hammer.iloc[-1]):
                buy = True
                buy_sl = df['Low'].iloc[-1] - (df['High'].iloc[-1]-df['Low'].iloc[-1])
                buy_target = last_close + (last_close - buy_sl)*1.5
                break
        
        # High-probability sell
        sell = False
        sell_sl = np.nan
        sell_target = np.nan
        for lvl in local_min.values:
            if (last_close < lvl) and (last_volume > volume_ma.iloc[-1]) and (bear_engulf.iloc[-1] or shooting_star.iloc[-1]):
                sell = True
                sell_sl = df['High'].iloc[-1] + (df['High'].iloc[-1]-df['Low'].iloc[-1])
                sell_target = last_close - (sell_sl - last_close)*1.5
                break
        
        if buy:
            return {"Symbol": stock_symbol, "Signal":"BUY", "Price":last_close, "SL":buy_sl, "Target":buy_target}
        elif sell:
            return {"Symbol": stock_symbol, "Signal":"SELL", "Price":last_close, "SL":sell_sl, "Target":sell_target}
        else:
            return None
    except Exception as e:
        print(f"Error with {stock_symbol}: {e}")
        return None

# -----------------------------
# 3. Scan all stocks
# -----------------------------
results = []
for sym in top_100_symbols:
    res = detect_trade(sym)
    if res:
        results.append(res)

# -----------------------------
# 4. Save daily report
# -----------------------------
if results:
    df_report = pd.DataFrame(results)
    df_report.to_excel("high_probability_trades.xlsx", index=False)
    print("Report saved: high_probability_trades.xlsx")
else:
    print("No high-probability trades found today.")
