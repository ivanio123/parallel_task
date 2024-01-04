package org.ppjava1;

import java.util.Arrays;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicLong;
import java.util.concurrent.atomic.AtomicLongArray;

public class parSum {
    long[] array;
    private AtomicLongArray values;
    private final ExecutorService executor;
    private AtomicInteger nextLength;
    private AtomicLongArray newValues;
    private AtomicInteger lastIndex = new AtomicInteger();
    private AtomicLong sum = new AtomicLong();
    private AtomicInteger nextLengthIteration = new AtomicInteger(0);
    private long[] secondValues;

    public parSum(int size) {
        this.array = getArray(size);
        this.values = new AtomicLongArray(array);
        this.secondValues = array;

        final int cores = Runtime.getRuntime().availableProcessors();
        executor = Executors.newFixedThreadPool(cores);

        nextLength = new AtomicInteger((values.length() + 1) / 2);
        newValues = new AtomicLongArray(nextLength.get());
    }

    private void applyRunnable(Runnable runnable) {
        executor.execute(runnable);
    }

    private long[] applyCallable(Callable<long[]> callable) {
        try {
            return executor.submit(callable).get();
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        } catch (ExecutionException e) {
            throw new RuntimeException(e);
        }
    }

    public void shutdown() {
        executor.shutdown();
    }

    public void sum() {
        applyRunnable(this::waveAlgorithm);
    }

    private synchronized void waveAlgorithm() {
        while (values.length() != 1) {
            nextLength.set((values.length() + 1) / 2);
            newValues = new AtomicLongArray(nextLength.get());
            while (nextLengthIteration.get() < nextLength.get()) {
                int haveNoPair = values.length() % 2;
                lastIndex.set(values.length() - 1 - nextLengthIteration.get());
                if (haveNoPair == 1 && nextLengthIteration.get() == lastIndex.get()) {
                    newValues.set(nextLengthIteration.get(), values.get(nextLengthIteration.get()));
                } else {
                    sum.set(values.get(nextLengthIteration.get()) + values.get(lastIndex.get()));
                    newValues.set(nextLengthIteration.get(), sum.get());
                }
                nextLengthIteration.getAndIncrement();
            }
            nextLengthIteration.set(0);
            values = newValues;

            if (values.length() == 1) {
                System.out.println(values);
            }
        }
    }


    private long[] getArray(int size) {
        long[] array = new long[size];

        for (int i = 0; i < size; i++) {
            array[i] = i + 1;
        }
        return array;
    }
}
