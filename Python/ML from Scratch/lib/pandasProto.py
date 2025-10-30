import pandas as pd
data = {
    'Country':['Brazil','Russia','India','None'],
    'Population' : [200.4,143.5,None,52.98]
}
df = pd.DataFrame(data)
df['Population'].fillna(df['Population'].mean(),inplace =True)
print(df)