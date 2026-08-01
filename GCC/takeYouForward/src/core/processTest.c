#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

int main()
{
    printf("Parent process started\n");

    pid_t pid = fork();

    if (pid < 0)
    {
        perror("fork failed");
        exit(1);
    }

    if (pid == 0)
    {
        // Child process
        printf("Child process running\n");
        printf("Child PID: %d\n", getpid());

        execl("/bin/ls", "ls", "-l", NULL);

        perror("execl failed");
        exit(1);
    }
    else
    {
        // Parent process
        printf("Parent PID: %d\n", getpid());

        wait(NULL);

        printf("Child finished\n");
    }

    return 0;
}