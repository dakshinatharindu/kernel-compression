#include <wolfssl/wolfcrypt/chacha20_poly1305.h>
#include <wolfssl/wolfcrypt/random.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define AAD_SIZE 0  // Additional authenticated data size
#define KEY_SIZE 32
#define NONCE_SIZE 12
#define AUTH_TAG_SIZE 16
#define CHUNK_SIZE 1024

int encrypt_file(const char* input_file, const char* output_file, const byte* key) {
    FILE *in_fp, *out_fp;
    byte* buffer;
    byte* cipher;
    byte nonce[NONCE_SIZE];
    byte authTag[AUTH_TAG_SIZE];
    WC_RNG rng;
    long file_size;
    size_t bytes_read;
    int ret;

    // Initialize RNG
    ret = wc_InitRng(&rng);
    if (ret != 0) {
        printf("Failed to initialize RNG\n");
        return -1;
    }

    // Generate random nonce
    ret = wc_RNG_GenerateBlock(&rng, nonce, NONCE_SIZE);
    if (ret != 0) {
        printf("Failed to generate nonce\n");
        wc_FreeRng(&rng);
        return -1;
    }

    // Open input and output files
    in_fp = fopen(input_file, "rb");
    if (!in_fp) {
        printf("Failed to open input file\n");
        wc_FreeRng(&rng);
        return -1;
    }

    out_fp = fopen(output_file, "wb");
    if (!out_fp) {
        printf("Failed to open output file\n");
        fclose(in_fp);
        wc_FreeRng(&rng);
        return -1;
    }

    // Write nonce to output file
    fwrite(nonce, 1, NONCE_SIZE, out_fp);

    // Get file size
    fseek(in_fp, 0, SEEK_END);
    file_size = ftell(in_fp);
    fseek(in_fp, 0, SEEK_SET);

    // Allocate buffers
    buffer = (byte*)malloc(CHUNK_SIZE);
    cipher = (byte*)malloc(CHUNK_SIZE);
    if (!buffer || !cipher) {
        printf("Memory allocation failed\n");
        free(buffer);
        free(cipher);
        fclose(in_fp);
        fclose(out_fp);
        wc_FreeRng(&rng);
        return -1;
    }

    // Encrypt file in chunks
    while ((bytes_read = fread(buffer, 1, CHUNK_SIZE, in_fp)) > 0) {
        ret = wc_ChaCha20Poly1305_Encrypt(
            key,
            nonce,
            NULL, 0,  // AAD
            buffer, bytes_read,
            cipher,
            authTag
        );

        if (ret != 0) {
            printf("Encryption failed\n");
            free(buffer);
            free(cipher);
            fclose(in_fp);
            fclose(out_fp);
            wc_FreeRng(&rng);
            return -1;
        }

        // Write encrypted data
        fwrite(cipher, 1, bytes_read, out_fp);
    }

    // Write authentication tag
    fwrite(authTag, 1, AUTH_TAG_SIZE, out_fp);

    // Cleanup
    free(buffer);
    free(cipher);
    fclose(in_fp);
    fclose(out_fp);
    wc_FreeRng(&rng);

    return 0;
}

int main(int argc, char* argv[]) {
    if (argc != 3) {
        printf("Usage: %s <input_file> <output_file>\n", argv[0]);
        return 1;
    }

    // Generate or provide your own 32-byte key
    byte key[KEY_SIZE] = {
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
        0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10,
        0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18,
        0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f, 0x20
    };

    int result = encrypt_file(argv[1], argv[2], key);
    if (result == 0) {
        printf("File encrypted successfully\n");
    }

    return result;
}