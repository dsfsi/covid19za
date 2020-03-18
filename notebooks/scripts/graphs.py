import os
import seaborn as sns
import matplotlib.pyplot as plt
from datetime import datetime
from textwrap import wrap
### NOTE: `conda install basemap`
import conda
conda_file_dir = conda.__file__
conda_dir = conda_file_dir.split('lib')[0]
proj_lib = os.path.join(os.path.join(conda_dir, 'share'), 'proj')
os.environ["PROJ_LIB"] = proj_lib
from mpl_toolkits.basemap import Basemap

def vertical_bar_chart(df, x, y, label, sort, figsize=(13, 9), ascending=True):
    """
    This customize vertical bar chart from seaborn(sns as aliased above) 
    Args:
        df: dataframe 
        x: x-axis column 
        y: y-axis column
        label: string to label the graph
        figsize: figure size to make chart small or big
        ascending: ascending order from smallest to biggest
        sort: which column to sort by 
        
    Returns:
        None
    """
    sns.set(style="whitegrid")
    fig, ax = plt.subplots(figsize=figsize)
    #sns.set_color_codes(sns.color_palette(["#0088c0"]))
    # Text on the top of each barplot
    ax = sns.barplot(x=x, y=y, data=df.sort_values(sort, ascending=ascending),
            label=label, color="b", palette=["#0088c0"])
    
    total = df[y].sum()
    for p in ax.patches:
        ax.annotate(str(format(p.get_height()/total * 100, '.2f')) + '%' + ' (' + str(int(p.get_height())) + ')', 
                    (p.get_x() + p.get_width() / 2., p.get_height()), 
                    ha = 'center', va = 'center', 
                    xytext = (0, 10), textcoords = 'offset points')
    
    y_value=['{:,.0f}'.format(x/total * 100) + '%' for x in ax.get_yticks()]
    plt.yticks(list(plt.yticks()[0]) + [10])
    ax.set_yticklabels(y_value)
    plt.xlabel('')
    plt.ylabel('')
    sns.despine(left=True, bottom=True)
    
def horizontal_bar_chart(df, x, y, label, figsize=(16, 16)):
    """
    This customize horizontal bar chart from seaborn(sns as aliased above) 
    Args:
        df: dataframe 
        x: x-axis column 
        y: y-axis column
        label: string to label the graph
        figsize: figure size to make chart small or big
        
    Returns:
        None
    """
    sns.set(style="whitegrid")
    fig, ax = plt.subplots(figsize=figsize)
    ax = sns.barplot(x=x, y=y, data=df,
            label=label, color="b", palette=["#0088c0"])
    total = df.values[:, 1].sum()
    for i, v in enumerate(df.values[:, 1]):
        ax.text(v + 0.1, i + .25, str(format(v / total * 100, '.2f')) + '% (' + str(v) + ')')
        
    labels = [ '\n'.join(wrap(l, 20)) for l in df.values[:, 0]]
    ax.set_yticklabels(labels)
    x_value=['{:,.0f}'.format(x/total * 100) + '%' for x in ax.get_xticks()]
    plt.xticks(list(plt.xticks()[0]) + [10])
    ax.set_xticklabels(x_value)
    plt.ylabel('')
    plt.xlabel('')
    sns.despine(left=True, bottom=True)
    
def line_graph(df, column, figsize=(12, 8)):
    """
    This customize line chart from matplotlib(plt as aliased above) 
    Args:
        df: dataframe 
        column: x-axis column
        label: string to label the graph
        figsize: figure size to make chart small or big
        
    Returns:
        None
    """
    fig, ax = plt.subplots(figsize=figsize)
    line_data = df[column].value_counts().reset_index().sort_values(by='index')
    line_data['Cumulative Frequency'] = line_data[column].cumsum()
    line_data.plot(x='index', y=column, style='o-', ax=ax, label='Daily Infection')
    line_data.plot(x='index', y='Cumulative Frequency', style='ro-', ax=ax)
    plt.xticks(rotation=90)
    plt.xlabel('')
    
def general_line_graph(df, x, y, figsize=(12, 8)):
    """
    This customize line chart from matplotlib(plt as aliased above) 
    Args:
        df: dataframe 
        column: x-axis column
        label: string to label the graph
        figsize: figure size to make chart small or big
        
    Returns:
        None
    """
    fig, ax = plt.subplots(figsize=figsize)
    df.plot(x=x, y=y, style='o-', ax=ax, label='Daily Tests')
    plt.xticks(rotation=90)
    plt.xlabel('')
    

def pie_chart(df, column):
    """
    This customize pie chart from matplotlib(plt as aliased above) 
    Args:
        df: dataframe 
        column: x-axis column
        label: string to label the graph
        figsize: figure size to make chart small or big
        
    Returns:
        None
    """
    X = df[column].value_counts()
    colors = ['#0088C0', '#82DAFF']
    plt.pie(X.values, labels=X.index, colors=colors,
            startangle=90,
            explode = (0, 0),
            textprops={'fontsize': 14},
            autopct = '%1.2f%%')
    plt.axis('equal')
    plt.show()

def flat_globe(travel, colors):
    """
    This customize map chart from Basemap(plt as aliased above) 
    Args:
        df: dataframe 
        column: x-axis column
        label: string to label the graph
        figsize: figure size to make chart small or big
        
    Returns:
        None
    """
    plt.figure(figsize = (30,30))
    m = Basemap(projection='gall')
    m.fillcontinents(color="#61993b",lake_color="#008ECC")
    m.drawmapboundary(fill_color="#5D9BFF")
    m.drawcountries(color='#585858',linewidth = 1)
    m.drawstates(linewidth = 0.2)
    m.drawcoastlines(linewidth=1)
    countries = list(travel.Source.unique())
    for item in countries:
        for index, row in travel[travel.Source == item].drop_duplicates().iterrows():
            x2, y2 = m.gcpoints( row["Source_Lat"], row["Source_Lon"], row["Dest_Lat"], row["Dest_Lon"], 20)
            plt.plot(x2,y2,color=colors[countries.index(item)],linewidth=0.8)
    plt.show()

def globe(travel, colors):
    """
    This customize map chart from Basemap(plt as aliased above) 
    Args:
        df: dataframe 
        column: x-axis column
        label: string to label the graph
        figsize: figure size to make chart small or big
        
    Returns:
        None
    """
    plt.figure(figsize=(16,16))
    m = Basemap(projection='ortho', lat_0=0, lon_0=0)
    m.drawmapboundary(fill_color='#5D9BFF')
    m.fillcontinents(color='#0D9C29',lake_color='#008ECC')
    m.drawcountries(color='#585858',linewidth=1)
    m.drawcoastlines()
    countries = list(travel.Source.unique())
    for item in countries:
        for index, row in travel[travel.Source == item].drop_duplicates().iterrows():
            x2, y2 = m.gcpoints( row["Source_Lat"], row["Source_Lon"], row["Dest_Lat"], row["Dest_Lon"], 20)
            plt.plot(x2,y2,color=colors[countries.index(item)],linewidth=0.8)
    plt.show()
