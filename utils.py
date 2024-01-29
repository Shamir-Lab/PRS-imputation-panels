def fix_table(df):
    if 'threshold' in df:
        df.rename(columns={'threshold' : 'hyperparameter'}, inplace=True)
    if 'hyperparameter' in df:
        df['hyperparameter']=df['hyperparameter'].astype(str)
    return df