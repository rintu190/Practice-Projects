package src.patterns;

public class Patterns{
    public static void main(String[] args){
        int n = 5;
        print22(n);
    }
    // *
    // **
    // ***
    // ****
    // *****
    // ****
    // ***
    // **
    // *
    static void print10(int n) {
        for(int i  = 1; i <= 2*n - 1;i++){
            int stars = i > n ? 2*n - i : i;
            for(int j = 1; j <= stars; j++){
                System.out.print("*");
            }
            System.out.println();
        }
    }
    // 1
    // 01
    // 101
    // 0101
    // 10101
    static void print11(int n){
        int start = 1;
        for(int i = 0;i < n; i++){
            start = i % 2 == 0 ? 1 : 0;
            for(int j = 0; j <= i; j++){
                System.out.print(start);
                start = 1 - start;
            }
            System.out.println();
        }
    }
    // 1        1
    // 12      21
    // 123    321
    // 1234  4321
    // 1234554321
    static void print12(int n){
        int space = 2 * (n - 1);
        for(int i = 1;i <= n;i++){
            for(int j = 1;j <= i;j++){
                System.out.print(j);
            }
            for(int j = 1;j <= space;j++){
                System.out.print(" ");
            }
            for(int j = i;j >= 1;j--){
                System.out.print(j);
            }
            System.out.println();
            space -= 2;
        }

    }
    // 1 
    // 2 3 
    // 4 5 6 
    // 7 8 9 10 
    // 11 12 13 14 15 
    static void print13(int n){
        int number = 1;
        for(int i = 1;i <= n;i++){
            for(int j = 1;j <= i;j++){
                System.out.print(number + " ");
                number++;
            }
            System.out.println();
        }
    }
    // A 
    // A B 
    // A B C 
    // A B C D 
    // A B C D E 
    static void print14(int n){
        for(int i = 0;i < n;i++){
            for(char ch = 'A';ch <= 'A' + i;ch++){
                System.out.print(ch + " ");
            }
            System.out.println();
        }
    }
    // A B C D E 
    // A B C D 
    // A B C 
    // A B 
    // A     
    static void print15(int n){
        for(int i = n;i > 0;i--){
            for(char ch = 'A';ch < 'A' + i;ch++){
                System.out.print(ch + " ");
            }
            System.out.println();
        }
        //or below in inc order
        for(int i = 0;i < n;i++){
            for(char ch = 'A';ch <= 'A' + (n - i - 1);ch++){
                System.out.print(ch + " ");
            }
            System.out.println();
        }
    }
    // A 
    // B B 
    // C C C 
    // D D D D 
    // E E E E E     
    static void print16(int n){
        char ch ='A';
        for(int i = 0;i < n;i++){
            for(int j = 0;j <= i;j++){
                System.out.print(ch + " ");
            }
            ch++;
            System.out.println();
        }
    }
    //     A    
    //    ABA   
    //   ABCBA  
    //  ABCDCBA 
    // ABCDEDCBA
    static void print17(int n){
        for(int i = 0;i < n;i++){
            char ch ='A';
            int breakpoint = (2 * i + 1)/2;

            for(int j = 0;j < n -i -1;j++){
                System.out.print(" ");
            }

            for(int j = 0;j < 2 * i+1;j++){
                System.out.print(ch);
                if(j < breakpoint)
                    ch++;
                else
                    ch--;
            }

            for(int j = 0;j < n -i -1;j++){
                System.out.print(" ");
            }
            System.out.println();            
        }
    }
    // E 
    // D E 
    // C D E 
    // B C D E 
    // A B C D E 
    static void print18(int n){
        char last = (char) ('A' + n -1);
        for(int i = 0;i < n;i++){
            for(char ch = (char) (last - i); ch <= last;ch++){
                System.out.print(ch + " ");
            }
            System.out.println();
        }
    }
    // **********
    // ****  ****
    // ***    ***
    // **      **
    // *        *
    // *        *
    // **      **
    // ***    ***
    // ****  ****
    // **********
    static void print19(int n){
        for(int i = 0;i < n;i++){
            int space = 2 * i;
            int star = n - i;
            for(int j = 0;j < star;j++){
                System.out.print("*");
            }
            for(int j = 0; j < space;j++){
                System.out.print(" ");
            }
            for(int j = 0;j < star;j++){
                System.out.print("*");
            }
            System.out.println();
        }
        for(int i = 0;i < n;i++){
            int star = i + 1;
            int space = 2 * (n - i - 1);
            for(int j = 0;j < star;j++){
                System.out.print("*");
            }
            for(int j =0;j < space;j++){
                System.out.print(" ");
            }
            for(int j = 0;j < star;j++){
                System.out.print("*");
            }
            System.out.println();            

        }
    }
    // *        *
    // **      **
    // ***    ***
    // ****  ****
    // **********
    // ****  ****
    // ***    ***
    // **      **
    // *        *
     static void print20(int n){
        // int space = 2 * n - 2;                
        // for(int i = 1;i <= 2*n - 1;i++){            
        //     int stars = i;
        //     if(i > n)
        //         stars = 2 * n - i;

        //     for(int j = 1;j <= stars;j++){
        //         System.out.print("*");
        //     }
        //     for(int j = 1; j <= space;j++){
        //         System.out.print(" ");
        //     }

        //     for(int j = 1;j <= stars;j++){
        //         System.out.print("*");
        //     }
        //     if(i < n)
        //         space -= 2;
        //     else
        //         space += 2;  
        //     System.out.println();          

        // }
    for(int i = 1; i <= 2*n - 1; i++){
        int stars = (i <= n) ? i : 2*n - i;
        int space = 2 * (n - stars);

        for(int j = 1; j <= stars; j++)
            System.out.print("*");
        for(int j = 1; j <= space; j++)
            System.out.print(" ");
        for(int j = 1; j <= stars; j++)
            System.out.print("*");

        System.out.println();
        }        
     }
    // *****
    // *   *
    // *   *
    // *   *
    // *****
     static void print21(int n){
        for(int i = 0;i < n;i++){
            for(int j = 0;j < n;j++){
                if(i ==0 || j == 0 ||i == n - 1 || j == n - 1)
                    System.out.print("*");
                else 
                    System.out.print(" ");
            }
            System.out.println();
        }
     }
    // 5 5 5 5 5 5 5 5 5 
    // 5 4 4 4 4 4 4 4 5 
    // 5 4 3 3 3 3 3 4 5 
    // 5 4 3 2 2 2 3 4 5 
    // 5 4 3 2 1 2 3 4 5 
    // 5 4 3 2 2 2 3 4 5 
    // 5 4 3 3 3 3 3 4 5 
    // 5 4 4 4 4 4 4 4 5 
    // 5 5 5 5 5 5 5 5 5      
     static void print22(int n){
        for(int i = 0;i < 2 * n - 1;i++){
            for(int j = 0;j < 2 * n - 1;j++){
                int top = i;
                int left = j;
                int right = (2*n - 2) - j;
                int down = (2*n - 2) - i;
                System.out.print(n - Math.min(Math.min(top,down),Math.min(left,right)));
                System.out.print(" ");
            }
            System.out.println();
        }
     }
}