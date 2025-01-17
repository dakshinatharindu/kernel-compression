import os
import csv

kernels = [
    "qemu_cortex_a9",
    "qemu_cortex_r5"
]

applications = [
    "bloom_filter",
    "bubble_sort",
    "mini_nn"
]

encryptions = [
    "aes_128_cbc",
    "aes_256_cbc",
    "aes_128_ctr",
    "aes_256_ctr",
]

compressions = [
    "lzw",
    "lzma2"
]

authentications = [
    "rsa_3k",
    "rsa_4k",
    "ecdsa_192",
    "ecdsa_384",
    "dilithium",
    "falcon"
]

command = "bash run.sh b "

data_dict = {}

with open('results.csv', 'w', newline='') as csvfile:
    csvwriter = csv.writer(csvfile)
    # Write header
    csvwriter.writerow(['Kernel', 'Application', 'Authentication', 'Encryption', 'Compression', 'Orig Size', "Comp Size", \
                        "Sign Time", "Encrypt Time", "Comp Time", "Verify Time", "Decrypt Time", "Decomp Time"])

    for kern in kernels:
        for app in applications:
            for auth in authentications:
                for enc in encryptions:
                    for cmp in compressions:
                        print("Running: " + kern + " " + app + " " + enc + " " + cmp + " " + auth)

                        os.system(command + kern + " " + app + " " + enc + " " + cmp + " " + auth)

                        with open('run.log', 'r') as f:
                            for line in f:
                                parts = line.strip().split(",")
                                label = parts[0]

                                values = [float(x) for x in parts[1:]]

                                data_dict[label] = sum(values) / len(values)

                        csvwriter.writerow([kern, app, auth, enc, cmp, int(data_dict["orig_size"]), int(data_dict["comp_size"]), \
                                            round(1000*data_dict["sign_time"], 3), round(1000*data_dict["encrypt_time"], 3), round(1000*data_dict["comp_time"], 3), \
                                                round(1000*data_dict["verify_time"], 3), round(1000*data_dict["decrypt_time"], 3), round(1000*data_dict["decompress_time"], 3)])
