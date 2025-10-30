#include <iostream>
#include <cstring>
#include <sys/ioctl.h>
#include <net/if.h>
#include <unistd.h>

int main() {
    const char *iface = "eth0";   // Change to your interface name (e.g., ens33, wlan0)

    int fd = socket(AF_INET, SOCK_DGRAM, 0);
    if (fd == -1) {
        perror("socket");
        return 1;
    }

    struct ifreq ifr;
    std::strncpy(ifr.ifr_name, iface, IFNAMSIZ);

    // 1. Get interface flags (UP/DOWN, etc.)
    if (ioctl(fd, SIOCGIFFLAGS, &ifr) == -1) {
        perror("ioctl");
        close(fd);
        return 1;
    }
    std::cout << iface << " flags: " << ifr.ifr_flags << std::endl;

    // 2. Get MTU
    if (ioctl(fd, SIOCGIFMTU, &ifr) == -1) {
        perror("ioctl");
        close(fd);
        return 1;
    }
    std::cout << iface << " MTU: " << ifr.ifr_mtu << std::endl;

    close(fd);
    return 0;
}
