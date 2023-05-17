#define _GNU_SOURCE
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <time.h>
#include <unistd.h>

#define LPN_SIZE 4096

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <filename> <qdepth1> [<qdepth2> ...]\n", argv[0]);
        return 1;
    }

    int fd = open(argv[1], O_RDONLY | O_DIRECT);
    if (fd == -1) {
        perror("open");
        return 1;
    }

    size_t qdepths[argc - 2];
    for (int i = 2; i < argc; i++) {
        qdepths[i - 2] = atoi(argv[i]);
    }
    size_t num_qdepths = argc - 2;

    // Allocate memory for read buffer
    void *buf = NULL;
    if (posix_memalign(&buf, LPN_SIZE, LPN_SIZE * qdepths[num_qdepths - 1])) {
        perror("posix_memalign");
        return 1;
    }

    // Initialize LPN offsets
    off_t lpn_offsets[qdepths[num_qdepths - 1]];
    for (int i = 0; i < qdepths[num_qdepths - 1]; i++) {
        lpn_offsets[i] = i * LPN_SIZE;
    }

    // Perform sequential reads with varying queue depths
    for (int i = 0; i < num_qdepths; i++) {
        size_t qdepth = qdepths[i];

        char output_filename[256];
        snprintf(output_filename, 256, "seq_read_latencies_qd%zu.txt", qdepth);
        FILE *output_file = fopen(output_filename, "w");
        if (!output_file) {
            perror("fopen");
            return 1;
        }

        struct timespec start, end;

        printf("Starting sequential read test with qdepth=%zu\n", qdepth);
        fflush(stdout);

        // Measure the time spent for each LPN
        double latencies[qdepth][qdepths[num_qdepths - 1]];
        memset(latencies, 0, sizeof(latencies));
        for (size_t lpn_idx = 0; lpn_idx < qdepths[num_qdepths - 1]; lpn_idx++) {
            /*char output_filename[256];
            snprintf(output_filename, 256, "seq_read_latencies_qd%zu_%zu.txt", qdepth, lpn_idx);
            FILE *output_file = fopen(output_filename, "w");
            if (!output_file) {
                perror("fopen");
                return 1;
            }
            */
            size_t num_ios = 10000;
            off_t offset = lpn_offsets[lpn_idx];

            clock_gettime(CLOCK_MONOTONIC, &start);
            for (size_t j = 0; j < num_ios; j++) {
                ssize_t ret = pread(fd, buf, LPN_SIZE, offset);
                if (ret == -1) {
                    perror("pread");
                    return 1;
                }
                clock_gettime(CLOCK_MONOTONIC, &end);
                double time_elapsed = (end.tv_sec - start.tv_sec) * 1e9 + (end.tv_nsec - start.tv_nsec);
                fprintf(output_file, "%f\n",time_elapsed);
                clock_gettime(CLOCK_MONOTONIC, &start);

            }
            //fclose(output_file);
            clock_gettime(CLOCK_MONOTONIC, &end);

            double time_elapsed = (end.tv_sec - start.tv_sec) * 1e9 + (end.tv_nsec - start.tv_nsec);
            double latency = time_elapsed / num_ios;
            latencies[qdepth - 1][lpn_idx] = latency;
        }
        fclose(output_file);
        // Output the latencies to a file
        /*
        char output_filename[256];
        snprintf(output_filename, 256, "seq_read_latencies_qd%zu.txt", qdepth);
        FILE *output_file = fopen(output_filename, "w");
        if (!output_file) {
            perror("fopen");
            return 1;
        }
        for (size_t lpn_idx = 0; lpn_idx < qdepths[num_qdepths - 1]; lpn_idx++) {
            fprintf(output_file, "%f\n",latencies[qdepth - 1][lpn_idx]);
        }
        fclose(output_file);
        */
    }

    return 0;
}
