import os
import csv

kernels = [
    "qemu_cortex_a9",
]

applications = [
    "bloom_filter",
]

encryptions = [
    "aes_128",
    "aes_256",
]

compressions = [
    "lzw",
    "lzma2"
]

authentications = [
    "rsa_3k",
    "rsa_4k",
    "ecdsa_192",
    "ecdsa_384"
]

command = "bash ./run.sh b "

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
                                s, value = line.strip().split(",")
                                data_dict[s] = value

                        csvwriter.writerow([kern, app, auth, enc, cmp, data_dict["orig_size"], data_dict["comp_size"], \
                                            data_dict["sign_time"], data_dict["encrypt_time"], data_dict["comp_time"], \
                                                data_dict["verify_time"], data_dict["decrypt_time"], data_dict["decompress_time"]])
