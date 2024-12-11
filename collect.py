import os
import csv

kernels = [
    "qemu_cortex_r5",
    "qemu_cortex_a9",
]

applications = [
    "bloom_filter",
    "bubble_sort",
    "mppt",
    "mini_nn"
]

encryptions = [
    "-aes-128-cbc",
    "-aes-256-cbc"
]

command = "./run.sh b "

with open('results.csv', 'w', newline='') as csvfile:
    csvwriter = csv.writer(csvfile)
    # Write header
    csvwriter.writerow(['Kernel', 'Application', 'Encryption', 'Compression Ratio', 'Time'])

    for kern in kernels:
        for app in applications:
            for enc in encryptions:
                os.system(command + kern + " " + app + " " + enc)

                with open('run.log', 'r') as f:
                    num1 = int(f.readline())
                    num2 = int(f.readline())
                    time = float(f.readline())

                cr = num1 / num2

                csvwriter.writerow([kern, app, enc, cr, time])
