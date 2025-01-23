import pandas as pd
import matplotlib.pyplot as plt

# Load the CSV data
name="result_arm_m3_mqtt"
df = pd.read_csv(name+'.csv')

# First graph
ax1 = df.plot(
    kind='bar',
    x='Authentication',
    stacked=True,
    y=['Sign Time', 'Encrypt Time', 'Compression Time'],
	color=['#769359', '#A35966', '#4A90E2'],
	figsize=(20, 3.5),
	legend=False
    # title='Sign, Encrypt, Compression Time'
)
plt.xlabel('Delivery Configuration',  labelpad=15)
plt.ylabel('Time',  labelpad=15)
# plt.subplots_adjust(bottom=0.5)
plt.tick_params(axis='x', which='major', pad=30)

# Calculate Compression Ratio
df['Compression Ratio'] = df['Orig Size'] / df['Compresed Size']

ax3 = ax1.twinx()
ax3.plot(
    df['Authentication'],
    df['Compression Ratio'],
    color='blue',
    marker='o',
    label='Compression Ratio'
)
ax3.set_ylabel('Compression Ratio', labelpad=25)
ax3.tick_params(axis='y')

# Optionally, rotate the x-axis tick labels for better readability
# plt.xticks(rotation=45)
# plt.legend(title='Time Categories')
plt.tight_layout()
# Set SVG fonttype to use system fonts
plt.rcParams['svg.fonttype'] = 'none'

    # # Save the plot as an SVG file with the same name as the CSV file
    # svg_filename = csv_file.replace('.csv', '.svg')
    # plt.savefig(svg_filename, format='svg')
plt.savefig(name+'_packging.svg')
plt.close()

# Second graph
ax2 = df.plot(
    kind='bar',
    x='Authentication',
    stacked=True,
    y=['Verify Time', 'Decrypt Time', 'Decompression Time'],
	color=['#769359', '#A35966', '#4A90E2'],
    # title='Verify, Decrypt, Decompression Time'
	figsize=(20, 3.5),
	legend=False
)
plt.xlabel('Delivery Configuration', labelpad=15)
plt.ylabel('Time', labelpad=15)
# plt.subplots_adjust(bottom=0.5)
plt.tick_params(axis='x', which='major', pad=30)
# plt.xticks(rotation=90, ha='left')
# plt.legend(title='Time Categories')

# Create the secondary y-axis
ax3 = ax2.twinx()
ax3.plot(
    df['Authentication'],
    df['Security'],
    color='red',
    marker='o',
    label='Security Score'
)
ax3.set_ylabel('Security Score', labelpad=25)
ax3.tick_params(axis='y')


plt.tight_layout()
plt.savefig(name+ '_deploy.svg')
plt.close()

# Create separate legend
fig, ax = plt.subplots(figsize=(20, 0.5))
# handles, labels = ax1.get_legend_handles_labels()
handles1, labels1 = ax1.get_legend_handles_labels()
handles2, labels2 = ax3.get_legend_handles_labels()
handles = handles1 + handles2
labels = labels1 + labels2
legend = ax.legend(handles, labels, ncol=4, loc='center',  fontsize=20)
ax.axis('off')
fig.savefig('legend-pack.svg', bbox_inches='tight')
plt.close()