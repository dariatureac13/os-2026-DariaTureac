/* fire.c - four threads sharing counter without synchronization.
 * Build: gcc -Wall -Wextra -pthread -o fire fire.c
 * Run: ./fire
 */
#include <stdio.h>
#include <pthread.h>

#define N 1000000
#define THREADS 4

long counter = 0;

void *work(void *arg) {
    long id = (long)arg;
    printf("thread %ld sees counter = %ld\n", id, counter);
    for (int i = 0; i < N; i++) {
        counter++; /* NOT atomic: read, add, write */
    }
    return NULL;
}

int main(void) {
    pthread_t threads[THREADS];
    for (long i = 0; i < THREADS; i++) {
        pthread_create(&threads[i], NULL, work, (void *)(i + 1));
    }
    for (int i = 0; i < THREADS; i++) {
        pthread_join(threads[i], NULL);
    }
    printf("expected: %d\n", THREADS * N);
    printf("counter: %ld (lost updates: the race)\n", counter);
    return 0;
}
