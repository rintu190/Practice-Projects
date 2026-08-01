#include <stdio.h>
#include <unistd.h>
#include <sys/epoll.h>
#include <stdlib.h>

int main()
{
    int epfd;

    epfd = epoll_create1(0);

    if (epfd == -1)
    {
        perror("epoll_create1");
        exit(1);
    }

    printf("Linux epoll created successfully\n");
    printf("epoll fd: %d\n", epfd);

    close(epfd);

    return 0;
}