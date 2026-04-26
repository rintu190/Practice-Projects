#include <iostream>
#include <string>

using namespace std;

class BankAccount {
private:
    string owner;
    double balance;
public:
    BankAccount(string name,double initBalance){
        owner = name;
        balance = initBalance;
    }
    void deposit(double amount){
        if(amount > 0){
            balance += amount;
            cout << "deposited: $" << amount << endl;
        }
    }
    void displayStatus(){
        cout << "Account owner:" << owner << endl;
        cout << "Current Balance: $" << balance << endl;
        cout << "---------------------------" << endl;
    }
};

int main(){
    BankAccount account("Alice", 500);
    account.displayStatus();
    account.deposit(49);
    account.displayStatus();
}