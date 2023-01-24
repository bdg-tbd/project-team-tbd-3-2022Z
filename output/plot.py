import matplotlib.pyplot as plt
import pandas as pd


def get_cluster_and_group(df, cluster):
    return df.loc[df['cluster'] == cluster].drop(columns=['cluster']).groupby(['modlib', 'spark-executors']).mean()


def plot(df, name):
    df.unstack(1).plot.bar()
    plt.title(f'Czasy trenowania modeli dla zbioru danych 1e6 dla {name}')
    plt.xlabel('Biblioteka')
    plt.ylabel('Czas trenowania modelu [s]')
    plt.legend(['1 egzekutor', '2 egzekutory', '6 egzekutorów', '8 egzekutorów'])
    plt.subplots_adjust(bottom=0.33)
    plt.ylim(top=320)
    plt.savefig(f'./output/plots/{name}_times.png')


def main():
    modlib_cols = ['library', 'model']

    df = pd.read_csv('./output/times.csv').drop(columns=['group'])
    df['modlib'] = df[modlib_cols].apply(lambda x: f'{x[0]} ({x[1]})', axis=1)
    df = df.drop(columns=modlib_cols)

    dp_df = get_cluster_and_group(df, 'dataproc')
    ks_df = get_cluster_and_group(df, 'k8s')

    plot(dp_df, 'Dataproc')
    plot(ks_df, 'k8s')


if __name__ == '__main__':
    main()
