# Python script version of the Realtime R0 notebook
# Used for automated processing

# Originally by Kevin Systrom - April 17
# Adapted for South Africa - Vukosi Marivate & Schalk van Heerden 29 April

import pandas as pd
import numpy as np

from scipy import stats as sps
from scipy.interpolate import interp1d


remote_run = True


R_T_MAX = 12
r_t_range = np.linspace(0, R_T_MAX, R_T_MAX*100+1)

GAMMA = 1/7


def highest_density_interval(pmf, p=.9, debug=False):
    # If we pass a DataFrame, just call this recursively on the columns
    if(isinstance(pmf, pd.DataFrame)):
        return pd.DataFrame([highest_density_interval(pmf[col], p=p) for col in pmf],
                            index=pmf.columns)
    
    cumsum = np.cumsum(pmf.values)
    
    # N x N matrix of total probability mass for each low, high
    total_p = cumsum - cumsum[:, None]
    
    # Return all indices with total_p > p
    lows, highs = (total_p > p).nonzero()
    
    # Find the smallest range (highest density)
    best = (highs - lows).argmin()
    
    low = pmf.index[lows[best]]
    high = pmf.index[highs[best]]
    
    return pd.Series([low, high],
                     index=[f'Low_{p*100:.0f}',
                            f'High_{p*100:.0f}'])


if remote_run:
    # better results for remote branches when Action scripts are run
    base_url = "../"
else:
    # get data directly from source for easy local analysis
    base_url = "https://raw.githubusercontent.com/dsfsi/covid19za/master/"


url = base_url + 'data/covid19za_provincial_cumulative_timeline_confirmed.csv'
states_all = pd.read_csv(url,
                     parse_dates=['date'], dayfirst=True,
                     squeeze=True).sort_index()
states_all = states_all.rename(columns={'total':'Total RSA'})

# ZA: single plot
state_name = 'Total RSA'
cutoff = 25

# filter data if required
#state_filter = states_all[:-1];
states = states_all


def prepare_cases(cases, cutoff=25):
    new_cases = cases.diff()

    smoothed = new_cases.rolling(7,
        win_type='gaussian',
        min_periods=1,
        center=True).mean(std=2).round()
    
    idx_start = np.searchsorted(smoothed, cutoff)
    
    smoothed = smoothed.iloc[idx_start:]
    original = new_cases.loc[smoothed.index]
    
    return original, smoothed

cases = pd.Series(states[state_name].values,index=states['date'])

original, smoothed = prepare_cases(cases, cutoff)


def get_posteriors(sr, sigma=0.15):

    # (1) Calculate Lambda
    lam = sr[:-1].values * np.exp(GAMMA * (r_t_range[:, None] - 1))

    
    # (2) Calculate each day's likelihood
    likelihoods = pd.DataFrame(
        data = sps.poisson.pmf(sr[1:].values, lam),
        index = r_t_range,
        columns = sr.index[1:])
    
    # (3) Create the Gaussian Matrix
    process_matrix = sps.norm(loc=r_t_range,
                              scale=sigma
                             ).pdf(r_t_range[:, None]) 

    # (3a) Normalize all rows to sum to 1
    process_matrix /= process_matrix.sum(axis=0)
    
    # (4) Calculate the initial prior
    #prior0 = sps.gamma(a=4).pdf(r_t_range)
    prior0 = np.ones_like(r_t_range)/len(r_t_range)
    prior0 /= prior0.sum()

    # Create a DataFrame that will hold our posteriors for each day
    # Insert our prior as the first posterior.
    posteriors = pd.DataFrame(
        index=r_t_range,
        columns=sr.index,
        data={sr.index[0]: prior0}
    )
    
    # We said we'd keep track of the sum of the log of the probability
    # of the data for maximum likelihood calculation.
    log_likelihood = 0.0

    # (5) Iteratively apply Bayes' rule
    for previous_day, current_day in zip(sr.index[:-1], sr.index[1:]):

        #(5a) Calculate the new prior
        current_prior = process_matrix @ posteriors[previous_day]
        
        #(5b) Calculate the numerator of Bayes' Rule: P(k|R_t)P(R_t)
        numerator = likelihoods[current_day] * current_prior
        
        #(5c) Calcluate the denominator of Bayes' Rule P(k)
        denominator = np.sum(numerator)
        
        # Execute full Bayes' Rule
        posteriors[current_day] = numerator/denominator
        
        # Add to the running sum of log likelihoods
        log_likelihood += np.log(denominator)
    
    return posteriors, log_likelihood

# Note that we're fixing sigma to a value just for the example
posteriors, log_likelihood = get_posteriors(smoothed, sigma=.25)


# Note that this takes a while to execute - it's not the most efficient algorithm

## ERROR! Please review for South Africa country data range
## The rest of the data ranges does not crash
## But the statistical significance of any of the results are highly in doubt
## > At Box [8], Line 13 of highest_density_interval func
## > best = (highs - lows).argmin()
## > attempt to get argmin of an empty sequence
## Removing the confidence interval for now
#hdis = highest_density_interval(posteriors, p=.9)
most_likely = posteriors.idxmax().rename('ML')

# Look into why you shift -1
#result = pd.concat([most_likely, hdis], axis=1)
result = pd.concat([most_likely], axis=1)

# US: Since we now use a uniform prior, the first datapoint is pretty bogus, so just truncating it here
# ZA: rename to single_result to add to final province plots again
single_result = result.drop(result.index[0])

## add dumpy data for confidence columns
single_result['High_90'] = 0
single_result['Low_90'] = 0


sigmas = np.linspace(1/20, 1, 20)

# ZA: only consider the official 9 provinces
states_to_process = list(states.columns.values[2:11])
# ZA: do not think the total RSA sigma needs to be included to find max later
# states_to_process.append('Total RSA') 

results = {}

for state_name in states_to_process:
    
    print(state_name)
    
    # --> ZA prepare data
    # ZA: Rt is very small for some provinces
    cases = pd.Series(states[state_name].values,index=states['date'])
    cut = 10
    new, smoothed = prepare_cases(cases, cutoff=cut)
    
    # Rt for ZA is very small for some provinces
    # set threshold for smoothed data length at 3 to ensure posteriors can be calculated
    if len(smoothed) < 3:
        cut = 5
        new, smoothed = prepare_cases(cases, cutoff=cut)
        
        if len(smoothed) < 3:
            cut = 3
            new, smoothed = prepare_cases(cases, cutoff=cut)
            
            ## ignore Rt further for slow growth provinces
            if len(smoothed) < 3:
                print('BREAK')
                continue
            
    print(cut)
    ## <-- ZA prepare data
    
    result = {}
    
    # Holds all posteriors with every given value of sigma
    result['posteriors'] = []
    
    # Holds the log likelihood across all k for each value of sigma
    result['log_likelihoods'] = []
    
    for sigma in sigmas:
        posteriors, log_likelihood = get_posteriors(smoothed, sigma=sigma)
        result['posteriors'].append(posteriors)
        result['log_likelihoods'].append(log_likelihood)
    
    # Store all results keyed off of state name
    results[state_name] = result

print('Done.')


# Each index of this array holds the total of the log likelihoods for
# the corresponding index of the sigmas array.
total_log_likelihoods = np.zeros_like(sigmas)

# Loop through each state's results and add the log likelihoods to the running total.
for state_name, result in results.items():
    total_log_likelihoods += result['log_likelihoods']

# Select the index with the largest log likelihood total
max_likelihood_index = total_log_likelihoods.argmax()

# Select the value that has the highest log likelihood
sigma = sigmas[max_likelihood_index]
print(sigma)


final_results = None

for state_name, result in results.items():
    try:
        print(state_name)
        posteriors = result['posteriors'][max_likelihood_index]
        hdis_90 = highest_density_interval(posteriors, p=.9)
        hdis_50 = highest_density_interval(posteriors, p=.5)
        most_likely = posteriors.idxmax().rename('ML')
        result = pd.concat([most_likely, hdis_90, hdis_50], axis=1)

        # ZA: add province index
        result.index = pd.MultiIndex.from_product([[state_name], result.index], names=['state','date'])

        if final_results is None:
            final_results = result
        else:
            final_results = pd.concat([final_results, result])
        
    except:
        print('Fatal crash on final results routine: ' + state_name)
        continue
            
    if final_results is None:
        print('NO RESULTS')

print('Done.')


# US: This can be moved before the plots
# Since we now use a uniform prior, the first datapoint is pretty bogus, so just truncating it here
final_results = final_results.groupby('state').apply(lambda x: x.iloc[1:].droplevel(0))


# ZA: include Total RSA in export results
single_result.index = pd.MultiIndex.from_product([['Total RSA'], single_result.index], names=['state','date'])
final_results = pd.concat([final_results, single_result])


# Uncomment the following line if you'd like to export the data
export_results = final_results[['ML', 'High_90', 'Low_90']]

export_results.to_csv('../data/calc/calculated_rt_sa_provincial_cumulative.csv', float_format='%.2f')


url = base_url + 'data/district_data/combined_district_keys.csv'
district_keys = pd.read_csv(url, index_col=[0,1,3,8,7]).sort_index()
district_keys


def calculate_district_rt(state_title, data_file, export):
    
    if (export == False & remote_run == True):
        # Do not even calculate further
        return []
    
    # Download latest district data
    # Data file names are no longer following standards
    #data_file = 'provincial_' + state_title + '_cumulative.csv'
    url = base_url + 'data/district_data/' + data_file + '.csv'
    states = pd.read_csv(url,
                         parse_dates=['date'], dayfirst=True,
                         squeeze=True).sort_index()
    
    # TODO: "PerformanceWarning indexing past lexsort depth may impact performance"
    # warning with this type of filter. Possibly due to index that is not sorted.
    # Consider another filter or query method to solve this issue.
    district_records = district_keys.loc[(state_title.upper(),1,'Case',data_file)]
    district_titles = np.array(district_records[['Data_title','Friendly_title']])
    
    states_to_process = []
    for district in district_titles:
        key = district[0]
        title = district[1]
        if title.find('Unknown') >= 0:
            continue
        states = states.rename(columns={key:title})
        states_to_process.append(title)
    
    ## Get all sigmas

    sigmas = np.linspace(1/20, 1, 20)

    results = {}

    for state_name in states_to_process:
        
        try:

            print(state_name)

            cases = pd.Series(states[state_name].values,index=states['date'])
            cut = 10
            new, smoothed = prepare_cases(cases, cutoff=cut)

            # Rt for ZA is very small for some provinces
            # set threshold for smoothed data length at 3 to ensure posteriors can be calculated
            if len(smoothed) < 3:
                cut = 5
                new, smoothed = prepare_cases(cases, cutoff=cut)

                ## ignore Rt further for slow growth provinces
                if len(smoothed) < 3:
                    print('BREAK')
                    continue

            print(cut)

            result = {}

            # Holds all posteriors with every given value of sigma
            result['posteriors'] = []

            # Holds the log likelihood across all k for each value of sigma
            result['log_likelihoods'] = []

            for sigma in sigmas:
                posteriors, log_likelihood = get_posteriors(smoothed, sigma=sigma)
                result['posteriors'].append(posteriors)
                result['log_likelihoods'].append(log_likelihood)

            # Store all results keyed off of state name
            results[state_name] = result
            
        except:
            print('Fatal crash on sigmas routine: ' + state_name)
            continue

    print('Done')


    ## Get sigma for max likelihood

    # Each index of this array holds the total of the log likelihoods for
    # the corresponding index of the sigmas array.
    total_log_likelihoods = np.zeros_like(sigmas)

    # Loop through each state's results and add the log likelihoods to the running total.
    for state_name, result in results.items():
        total_log_likelihoods += result['log_likelihoods']

    # Select the index with the largest log likelihood total
    max_likelihood_index = total_log_likelihoods.argmax()

    # Select the value that has the highest log likelihood
    sigma = sigmas[max_likelihood_index]


    ## Compile final results

    final_results = None

    for state_name, result in results.items():
        
        try:
            print(state_name)
            posteriors = result['posteriors'][max_likelihood_index]
            hdis_90 = highest_density_interval(posteriors, p=.9)
            hdis_50 = highest_density_interval(posteriors, p=.5)
            most_likely = posteriors.idxmax().rename('ML')
            result = pd.concat([most_likely, hdis_90, hdis_50], axis=1)

            result.index = pd.MultiIndex.from_product([[state_name], result.index], names=['state','date'])

            if final_results is None:
                final_results = result
            else:
                final_results = pd.concat([final_results, result])
            
        except:
            print('Fatal crash on final results routine: ' + state_name)
            continue
            
    if final_results is None:
        print('NO RESULTS')
        return []

    final_results = final_results.groupby('state').apply(lambda x: x.iloc[1:].droplevel(0))


    ## Print max calculated Gaussian

    print('Max Sigma: ' + str(sigma))

    # Note: Not plotting anymore with this method! Focussing on results, not optomising matplotlib.
    # Create your own district plots in another notebook with the result data

    ## Plot all 

    #ncols = 2
    #nrows = int(np.ceil(len(results) / ncols))

    #fig, axes = plt.subplots(nrows=nrows, ncols=ncols, figsize=(15, nrows*3))

    #for i, (state_name, result) in enumerate(final_results.groupby('state')):
    #    plot_rt(result, axes.flat[i], state_name)

    #fig.tight_layout()

    #fig.suptitle('Real-time $R_t$ for ' + header, size=14)
    #fig.subplots_adjust(top=plotscale)


    ## Export results

    export_results = final_results[['ML', 'High_90', 'Low_90']]
    
    if export:
        filename = 'calculated_rt_' + state_title + '_district_cumulative.csv'
        export_results.to_csv('../data/calc/' + filename, float_format='%.2f')

    # Return latest rt results
    return export_results.groupby(level=0).last()


results_ec = calculate_district_rt('ec','provincial_ec_cumulative', export=False)


results_fs = calculate_district_rt('fs','provincial_fs_cumulative', export=False)


results_gp = calculate_district_rt('gp','provincial_gp_cumulative', export=True)


results_kzn = calculate_district_rt('kzn','provincial_kzn_cumulative', export=True)


results_lp = calculate_district_rt('lp','provincial_lp_cumulative', export=True)


results_mp = calculate_district_rt('mp','provincial_mp_cumulative', export=False)


results_nw = calculate_district_rt('nw','provincial_nw_cumulative', export=True)


results_wc = calculate_district_rt('wc','provincial_wc_cumulative', export=True)