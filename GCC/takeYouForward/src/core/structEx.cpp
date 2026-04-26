#include <iostream>
#include <cstring>

using namespace std;
void printBook(struct Books book);
void printBookPointer( struct Books *book); 

struct Books {
    char title[50];
    char author[50];
    char subject[100];
    int book_id;
};

int main(){
    struct Books book1;
    struct Books book2;

    strcpy(book1.title, "Learn c++");
    strcpy(book1.author, "chand miyan");
    strcpy(book1.subject, "c++ programming");
    book1.book_id = 64123;

    strcpy(book2.title, "design apttern");
    strcpy(book2.author, "rintu");
    strcpy(book2.subject, "dsa and design patterhns");
    book2.book_id = 63223;

    printBook(book1);
    printBook(book2);
    
    printBookPointer(&book1);

    return 0;
}

void printBook(struct Books book){
    cout << "Book title: " << book.title << endl;
    cout << "Book author: " << book.author << endl;
    cout << "book subject: " << book.subject << endl;
    cout << "Book id: " << book.book_id << endl;
    cout << endl;
}

void printBookPointer( struct Books *book ) {
   cout << "Book title : " << book->title <<endl;
   cout << "Book author : " << book->author <<endl;
   cout << "Book subject : " << book->subject <<endl;
   cout << "Book id : " << book->book_id <<endl;
}
