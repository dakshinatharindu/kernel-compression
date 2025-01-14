import os
import csv

kernels = [
    "qemu_cortex_a9",
]

applications = [
    "bloom_filter",

]

encryptions = [
    "-aes-128-cbc",
]

compressions = [
    "lzw"
]

authentications = [
    "rsa_3k"
]

command = "bash ./run.sh b "

with open('results.csv', 'w', newline='') as csvfile:
    csvwriter = csv.writer(csvfile)
    # Write header
    csvwriter.writerow(['Kernel', 'Application', 'Authentication', 'Encryption', 'Compression', 'Orig Size', "Comp Size", "Time"])

    for kern in kernels:
        for app in applications:
            for auth in authentications:
                for enc in encryptions:
                    for cmp in compressions:
                        os.system(command + kern + " " + app + " " + enc + " " + cmp + " " + auth)
                        # print(command + kern + " " + app + " " + enc + " " + cmp + " " + auth)
                        # with open('run.log', 'r') as f:
                        #     num1 = int(f.readline())
                        #     num2 = int(f.readline())
                        #     time = float(f.readline())

                        # csvwriter.writerow([kern, app, auth, enc, cmp, num1, num2, time])
