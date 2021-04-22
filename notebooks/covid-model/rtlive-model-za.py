from pip._internal import main
try:
    import pymc3 as pm
except:
    from pip._internal import main
    main(['install', 'pymc3'])
    import pymc3 as pm
        
import pandas as pd
from covid.models.generative import GenerativeModel

from covid.data import summarize_inference_data

url = '../../data/covid19za_provincial_cumulative_timeline_confirmed.csv'
states_cases = pd.read_csv(url, parse_dates=['date'], dayfirst=True, index_col=0)
states_cases.tail()

url = '../../data/covid19za_timeline_testing.csv'
states_tests = pd.read_csv(url, parse_dates=['date'], dayfirst=True, index_col=0)
states_tests.tail()

cases = pd.Series(states_cases['total'], index=states_cases.index, name='cases')

casezero = states_cases.index[0]
caselast = states_cases.index[-1]

idx = pd.date_range(casezero, caselast)

tests_all = pd.Series(states_tests['cumulative_tests'], index=states_tests.index, name='tests')

tests = tests_all.loc[casezero:caselast]

combined_model = pd.concat([cases, tests], axis=1)

combined_model.loc[casezero, 'tests'] = 163

filled_model = combined_model.reindex(idx, method='ffill')

final_filled_model = filled_model.ffill(axis=0)

final_filled_model['positive'] = final_filled_model['cases'].diff()
final_filled_model['total'] = final_filled_model['tests'].diff()

df_model = final_filled_model.iloc[1:]

region = 'Total RSA'

gm = GenerativeModel(region, df_model)
gm.sample()

result = summarize_inference_data(gm.inference_data)

export_results = result[['median', 'upper_80', 'lower_80', 'infections', 'test_adjusted_positive']]
export_results = export_results.rename(columns={'median': 'Median', 'upper_80': 'High_80', 'lower_80': ' Low_80', 'infections': 'Infections', 'test_adjusted_positive': 'Adjusted_Postive'})

export_path = '../../data/calc/calculated_rt_sa_mcmc.csv'
export_results.to_csv(export_path, float_format='%.3f')
