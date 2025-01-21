import os
import csv

kernels = [
    "qemu_cortex_a9",
    # "qemu_cortex_r5",
    # "mps2/an521/cpu0/ns"
]

applications = [
    "../applications/bloom_filter",
    # "../applications/mini_nn",
    # "../applications/vector_3d",
    # "zephyr/samples/tfm_integration/tfm_ipc",
    # "zephyr/samples/tfm_integration/psa_crypto",
    # "zephyr/samples/tfm_integration/psa_secure_partition",
    # "zephyr/samples/net/telnet",
    # "zephyr/samples/net/mqtt_publisher",
    # "zephyr/samples/net/wifi",
]

encryptions = [
    "aes_128_cbc",
    "aes_256_cbc",
    "aes_128_ctr",
    "aes_256_ctr",
    # "chacha20"
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

auth_map = {
    "rsa_3k": "r3",
    "rsa_4k": "r4",
    "ecdsa_192": "e1",
    "ecdsa_384": "e3",
    "dilithium": "d",
    "falcon": "f"
}

enc_map = {
    "aes_128_cbc": {
        "lzw": "c1",
        "lzma2": "c2"
    },
    "aes_256_cbc": {
        "lzw": "c3",
        "lzma2": "c4"
    },
    "aes_128_ctr": {
        "lzw": "c5",
        "lzma2": "c6"
    },
    "aes_256_ctr": {
        "lzw": "c7",
        "lzma2": "c8"
    },
}

def sec_strength(auth, enc, cmp):
    return auth_map[auth] + "-" + enc_map[enc][cmp]

def app_name(app):
    return app.split("/")[-1]

def sec_score(ss):
    if ss == "r3-c1":
        return 7
    else:
        return 8

with open('results.csv', 'w', newline='') as csvfile:
    csvwriter = csv.writer(csvfile)
    # Write header
    csvwriter.writerow(['Kernel', 'Benchmark', 'Authentication', 'Orig Size', "Compresed Size", \
                        "Sign Time", "Encrypt Time", "Compression Time", "Verify Time", "Decrypt Time", "Decompression Time", "Security"])

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
                                try:
                                    values = [float(x) for x in parts[1:]]
                                except:
                                    data_dict[label] = 0
                                    continue

                                data_dict[label] = sum(values) / len(values)

                        ss = sec_strength(auth, enc, cmp)

                        csvwriter.writerow([kern, app_name(app), ss, int(data_dict["orig_size"]), int(data_dict["comp_size"]), \
                                            round(1000*data_dict["sign_time"], 3), round(1000*data_dict["encrypt_time"], 3), round(1000*data_dict["comp_time"], 3), \
                                                round(1000*data_dict["verify_time"], 3), round(1000*data_dict["decrypt_time"], 3), round(1000*data_dict["decompress_time"], 3), sec_score(ss)])
