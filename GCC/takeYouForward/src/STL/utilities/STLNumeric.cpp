#include <iostream>
#include <complex>
#include <random>
#include <chrono>
#include <cmath>
#include <vector>
#include <algorithm>

using namespace std;

// ============== COMPLEX NUMBERS ==============

void demo_complex_creation() {
    cout << "\n=== COMPLEX - CREATION ===" << endl;
    
    complex<double> c1;                     // Default (0, 0)
    cout << "c1 (default): " << c1 << endl;
    
    complex<double> c2(3.0, 4.0);           // Real = 3, Imaginary = 4
    cout << "c2 (3, 4): " << c2 << endl;
    
    complex<double> c3(5.0);                // Real = 5, Imaginary = 0
    cout << "c3 (5): " << c3 << endl;
    
    complex<double> c4 = c2;                // Copy
    cout << "c4 (copy): " << c4 << endl;
}

void demo_complex_operations() {
    cout << "\n=== COMPLEX - OPERATIONS ===" << endl;
    
    complex<double> c1(3.0, 4.0);
    complex<double> c2(1.0, 2.0);
    
    // Arithmetic
    cout << "c1 + c2 = " << (c1 + c2) << endl;
    cout << "c1 - c2 = " << (c1 - c2) << endl;
    cout << "c1 * c2 = " << (c1 * c2) << endl;
    cout << "c1 / c2 = " << (c1 / c2) << endl;
}

void demo_complex_functions() {
    cout << "\n=== COMPLEX - FUNCTIONS ===" << endl;
    
    complex<double> c(3.0, 4.0);
    
    cout << "Real part: " << real(c) << endl;
    cout << "Imaginary part: " << imag(c) << endl;
    cout << "Magnitude: " << abs(c) << endl;
    cout << "Argument (angle): " << arg(c) << endl;
    cout << "Conjugate: " << conj(c) << endl;
    
    // Polar form
    complex<double> c_polar = polar(5.0, M_PI/4);
    cout << "Polar(5, π/4): " << c_polar << endl;
}

// ============== RANDOM NUMBERS ==============

void demo_random_device() {
    cout << "\n=== RANDOM - RANDOM_DEVICE ===" << endl;
    
    random_device rd;
    
    cout << "Random values from random_device:" << endl;
    for (int i = 0; i < 5; i++) {
        cout << "  " << rd() << endl;
    }
}

void demo_mt19937() {
    cout << "\n=== RANDOM - MT19937 ===" << endl;
    
    // Seed with random_device
    random_device rd;
    mt19937 gen(rd());
    
    cout << "5 random numbers (unseeded range):" << endl;
    for (int i = 0; i < 5; i++) {
        cout << "  " << gen() << endl;
    }
}

void demo_uniform_distribution() {
    cout << "\n=== RANDOM - UNIFORM DISTRIBUTION ===" << endl;
    
    random_device rd;
    mt19937 gen(rd());
    
    // Uniform distribution [0, 100]
    uniform_int_distribution<> dis(0, 100);
    
    cout << "10 random integers [0, 100]:" << endl;
    for (int i = 0; i < 10; i++) {
        cout << "  " << dis(gen);
        if ((i + 1) % 5 == 0) cout << endl;
        else cout << " ";
    }
}

void demo_uniform_real_distribution() {
    cout << "\n=== RANDOM - UNIFORM REAL DISTRIBUTION ===" << endl;
    
    random_device rd;
    mt19937 gen(rd());
    
    // Uniform real distribution [0.0, 1.0)
    uniform_real_distribution<> dis(0.0, 1.0);
    
    cout << "10 random doubles [0.0, 1.0):" << endl;
    for (int i = 0; i < 10; i++) {
        cout << "  " << dis(gen);
        if ((i + 1) % 5 == 0) cout << endl;
        else cout << " ";
    }
}

void demo_normal_distribution() {
    cout << "\n=== RANDOM - NORMAL DISTRIBUTION ===" << endl;
    
    random_device rd;
    mt19937 gen(rd());
    
    // Normal distribution (mean=0, stddev=1)
    normal_distribution<> dis(0.0, 1.0);
    
    cout << "10 random numbers (normal dist):" << endl;
    for (int i = 0; i < 10; i++) {
        cout << "  " << dis(gen);
        if ((i + 1) % 5 == 0) cout << endl;
        else cout << " ";
    }
}

void demo_bernoulli_distribution() {
    cout << "\n=== RANDOM - BERNOULLI DISTRIBUTION ===" << endl;
    
    random_device rd;
    mt19937 gen(rd());
    
    // Bernoulli distribution (50% chance)
    bernoulli_distribution dis(0.5);
    
    cout << "10 coin flips (true=heads, false=tails):" << endl;
    for (int i = 0; i < 10; i++) {
        cout << "  " << (dis(gen) ? "Heads" : "Tails");
        if ((i + 1) % 5 == 0) cout << endl;
        else cout << " ";
    }
}

void demo_random_shuffle() {
    cout << "\n=== RANDOM - SHUFFLE ===" << endl;
    
    vector<int> v = {1, 2, 3, 4, 5};
    
    cout << "Original: ";
    for (int x : v) cout << x << " ";
    cout << endl;
    
    random_device rd;
    mt19937 gen(rd());
    shuffle(v.begin(), v.end(), gen);
    
    cout << "Shuffled: ";
    for (int x : v) cout << x << " ";
    cout << endl;
}

// ============== CHRONO ==============

void demo_chrono_clock() {
    cout << "\n=== CHRONO - CLOCK ===" << endl;
    
    // Current time
    auto now = chrono::system_clock::now();
    time_t time = chrono::system_clock::to_time_t(now);
    cout << "Current time: " << ctime(&time) << endl;
    
    // High resolution clock
    auto start = chrono::high_resolution_clock::now();
    
    // Do something
    int sum = 0;
    for (int i = 0; i < 1000000; i++) {
        sum += i;
    }
    
    auto end = chrono::high_resolution_clock::now();
    
    // Calculate duration
    auto duration = chrono::duration_cast<chrono::microseconds>(end - start);
    cout << "Operation took: " << duration.count() << " microseconds" << endl;
}

void demo_chrono_duration() {
    cout << "\n=== CHRONO - DURATION ===" << endl;
    
    // Create durations
    chrono::seconds sec(5);
    chrono::milliseconds ms(5000);
    chrono::microseconds us(5000000);
    
    cout << "5 seconds = " << sec.count() << " seconds" << endl;
    cout << "5000 milliseconds = " << ms.count() << " ms" << endl;
    cout << "5000000 microseconds = " << us.count() << " us" << endl;
    
    // Conversion
    cout << "5 seconds in milliseconds: " 
         << chrono::duration_cast<chrono::milliseconds>(sec).count() << endl;
}

void demo_chrono_time_point() {
    cout << "\n=== CHRONO - TIME POINT ===" << endl;
    
    // Create time points
    auto now = chrono::system_clock::now();
    auto epoch = chrono::system_clock::time_point();
    
    // Duration since epoch
    auto duration = now - epoch;
    cout << "Seconds since epoch: " 
         << chrono::duration_cast<chrono::seconds>(duration).count() << endl;
}

void demo_chrono_performance_measurement() {
    cout << "\n=== CHRONO - PERFORMANCE MEASUREMENT ===" << endl;
    
    random_device rd;
    mt19937 gen(rd());
    uniform_int_distribution<> dis(1, 100);
    
    // Create vector
    vector<int> v;
    for (int i = 0; i < 100000; i++) {
        v.push_back(dis(gen));
    }
    
    // Measure sort time
    auto start = chrono::high_resolution_clock::now();
    sort(v.begin(), v.end());
    auto end = chrono::high_resolution_clock::now();
    
    auto duration = chrono::duration_cast<chrono::milliseconds>(end - start);
    cout << "Sorting 100000 random integers took: " 
         << duration.count() << " milliseconds" << endl;
}

void demo_chrono_timer() {
    cout << "\n=== CHRONO - CUSTOM TIMER ===" << endl;
    
    class Timer {
    private:
        chrono::high_resolution_clock::time_point start_;
        
    public:
        Timer() : start_(chrono::high_resolution_clock::now()) {}
        
        double elapsed() const {
            auto end = chrono::high_resolution_clock::now();
            auto duration = chrono::duration_cast<chrono::milliseconds>(end - start_);
            return duration.count();
        }
    };
    
    Timer timer;
    
    // Do some work
    int sum = 0;
    for (int i = 0; i < 10000000; i++) {
        sum += i * 2;
    }
    
    cout << "Task completed in: " << timer.elapsed() << " ms" << endl;
}

// ============== COMBINED EXAMPLE ==============

void demo_combined_numeric() {
    cout << "\n=== COMBINED EXAMPLE ===" << endl;
    
    // Complex arithmetic
    complex<double> z1(3, 4);
    complex<double> z2(1, 2);
    cout << "Complex: " << z1 << " * " << z2 << " = " << (z1 * z2) << endl;
    
    // Random numbers
    random_device rd;
    mt19937 gen(rd());
    uniform_real_distribution<> dis(0.0, 10.0);
    
    cout << "Random number [0, 10): " << dis(gen) << endl;
    
    // Timing
    auto start = chrono::high_resolution_clock::now();
    double result = sqrt(2.0);
    auto end = chrono::high_resolution_clock::now();
    
    auto duration = chrono::duration_cast<chrono::nanoseconds>(end - start);
    cout << "sqrt(2) = " << result << " (computed in " 
         << duration.count() << " ns)" << endl;
}

int main() {
    cout << "=== NUMERIC, RANDOM, TIME ===" << endl;
    
    // Complex numbers
    demo_complex_creation();
    demo_complex_operations();
    demo_complex_functions();
    
    // Random numbers
    demo_random_device();
    demo_mt19937();
    demo_uniform_distribution();
    demo_uniform_real_distribution();
    demo_normal_distribution();
    demo_bernoulli_distribution();
    demo_random_shuffle();
    
    // Chrono
    demo_chrono_clock();
    demo_chrono_duration();
    demo_chrono_time_point();
    demo_chrono_performance_measurement();
    demo_chrono_timer();
    
    // Combined
    demo_combined_numeric();
    
    return 0;
}
